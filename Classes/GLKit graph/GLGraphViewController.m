//
//  GLGraphViewController.m
//  FF
//
//  Created by Lukasz Margielewski on 08/04/14.
//
//

#import "GLGraphViewController.h"


@implementation GLGraphViewController{

    
    CGPoint lastTranslationPoint;
    CGRect graphRectAtPinchingStart;

    CGPoint lastTouchPosition;
    CGPoint firstTouchPosition;
    
    BOOL scaleDirectionDecided;
    BOOL scaleHorizontally;
    
    UIBarButtonItem *selectBbi;
    UIBarButtonItem *selectionTypeBbi;
    UIBarButtonItem *selectionClear;
    UIBarButtonItem *toggleLgend;
    
    GLGraphViewControllerMode _prevMode;

    NSNumberFormatter *_nf;

    UINavigationController *gLegendNavCOntroller;
    
    UIPopoverController *popoverSelection;
    
    GLNode *_currentNode;
}


-(void)loadView{

    
    self.delegate = self;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    CGRect b = [[UIScreen mainScreen] bounds];
    
    UIView *v                       = [[UIView alloc] initWithFrame:b];
    v.backgroundColor               = [UIColor whiteColor];
    
    _glkView                        = [[GLKView alloc] initWithFrame:b context:context];
    _glkView.autoresizingMask       = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _glkView.drawableColorFormat    = GLKViewDrawableColorFormatRGB565;
    _glkView.drawableDepthFormat    = GLKViewDrawableDepthFormat16;
    _glkView.drawableMultisample    = GLKViewDrawableMultisampleNone;
    _glkView.opaque                 = YES;
    _glkView.delegate = self;
    
    //[v addSubview:_glkView];
    self.view = _glkView;
    self.navigationController.navigationBar.translucent = self.navigationController.toolbar.translucent = NO;
}

-(void)viewDidLoad{
    
    
    _nf = [[NSNumberFormatter alloc] init];
    [_nf setMaximumFractionDigits:1];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    panGesture.delegate = self;
    [self.glkView addGestureRecognizer:panGesture];
 
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    pinchGesture.delegate = self;
    [self.glkView addGestureRecognizer:pinchGesture];
    
    
    UIBarButtonItem *flex               = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    selectBbi          = [[UIBarButtonItem alloc] initWithTitle:@"Start selection:" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleSelectionMode:)];
    
    selectionClear     = [[UIBarButtonItem alloc] initWithTitle:@"Clear selection(s)" style:UIBarButtonItemStyleBordered target:self action:@selector(clearSelections:)];
 
    selectionTypeBbi = [[UIBarButtonItem alloc] initWithTitle:self.selection.name style:UIBarButtonItemStyleBordered target:self action:@selector(selectionSettings:)];
    selectionTypeBbi.tintColor = self.selection.color;
    
    UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:@"Clear plots" style:UIBarButtonItemStylePlain target:self action:@selector(clearPlots:)];
    
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self setToolbarItems:@[flex, selectBbi,selectionTypeBbi,flex, selectionClear, flex, flex, clear]];
    
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{return YES;}
-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
-(void)viewWillDisappear:(BOOL)animated{

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

}

-(void)initGraph{

    _mode = GLGraphViewControllerModeDefault;
    graph = [GLGraph new];
    graph.clearColor = GLVector4DMake(1.0, 1.0, 1.0, 1.0);
    graph.dataSource = self;
    graph.hostingView = self.glkView;
    
    CGRect gvr = graph.visibleRegion;
    
    gvr.size.height = 2.6;
    gvr.origin.y = -1.3;
    gvr.size.width = 2;
    graph.visibleRegion = gvr;
    
    [self configurePlots];

    
    
}
-(void)configurePlots{}


- (void)glkViewControllerUpdate:(GLKViewController *)controller {
    
    // NSLog(@"in glkViewControllerUpdate");
    if (!graph) {
        [self initGraph];
    }
    
    [graph update];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

    
    // NSLog(@"in EEScene's render");
    [graph render];
    
}

#pragma mark - Zooming and panning:

-(void)translateFromPanGesture:(UIPanGestureRecognizer *)panGesture{

    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        lastTranslationPoint = [panGesture translationInView:self.glkView];
        
    }
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint currentTranslationPoint = [panGesture translationInView:self.glkView];
        
        CGFloat dx = lastTranslationPoint.x - currentTranslationPoint.x;
        CGFloat dy = lastTranslationPoint.y - currentTranslationPoint.y;
        
        CGFloat W = CGRectGetWidth(self.glkView.bounds);
        CGFloat H = CGRectGetHeight(self.glkView.bounds);
        
        CGRect graphRect = graph.visibleRegion;
        
        CGFloat w = CGRectGetWidth(graphRect);
        CGFloat h = CGRectGetHeight(graphRect);
        
        CGFloat war = w / W;
        CGFloat har = h / H;
        
        graphRect.origin.x += war * dx;
        graphRect.origin.y -= har * dy;
        
        graph.visibleRegion = graphRect;
        
        lastTranslationPoint = currentTranslationPoint;
    }
    
}


-(void)panned:(UIPanGestureRecognizer *)panGesture{

    CGPoint point = [panGesture locationInView:_glkView];
    
    for (UIView *subview in _glkView.subviews) {
        
        if (CGRectContainsPoint(subview.frame, point)) {
            return;
        }
    }

    if (_mode == GLGraphViewControllerModeDefault) {
        [self translateFromPanGesture:panGesture];
        
    }else if (_mode == GLGraphViewControllerModeSelection) {
        
        [self selectionFromPanGesture:panGesture];
        
    }
}

static inline CGPoint CGPointDistance(CGPoint point1, CGPoint point2){
    return CGPointMake(point2.x - point1.x, point2.y - point1.y);
}

-(void)pinched:(UIPinchGestureRecognizer *)pinchGesture{

    
    if (pinchGesture.numberOfTouches < 2) {
        return;
    }
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
    
        firstTouchPosition = lastTouchPosition = [pinchGesture locationInView:self.glkView];
        
        graphRectAtPinchingStart = graph.visibleRegion;

        scaleDirectionDecided = NO;
        
        
    }else if (pinchGesture.state == UIGestureRecognizerStateChanged) {

        CGPoint touch1Location = [pinchGesture locationOfTouch:0 inView:self.glkView];
        CGPoint touch2Location = [pinchGesture locationOfTouch:1 inView:self.glkView];
        
        CGPoint deltaMove = CGPointDistance(touch1Location, touch2Location);
        
        if (!scaleDirectionDecided) {
         
            
            //if(ABS(deltaMove.x) > 5 || ABS(deltaMove.y) > 5){
            
                scaleHorizontally = ABS(deltaMove.x) > ABS(deltaMove.y);
                scaleDirectionDecided = YES;
                pinchGesture.scale = 1.0;
            //}
            
        
        }else{
        
            CGRect graphRect = graphRectAtPinchingStart;
            CGFloat scale = pinchGesture.scale;
            
            if(scaleHorizontally){
                
                graphRect.size.width /= scale;
                //NSLog(@"%f x scale: %f -> %f", graphRectAtPinchingStart.size.width, scale, graphRect.size.width);
                graph.visibleRegion = graphRect;
                
            }else{
                
                graphRect.size.height /= scale;
                //NSLog(@"%f y scale: %f -> %f", graphRectAtPinchingStart.size.height, scale, graphRect.size.height);
                graph.visibleRegion = graphRect;
            }
            
            
            //NSLog(@"gprah rect: %@", NSStringFromCGRect(graph.visibleRegion));
        }
        
       
        
    }else if (pinchGesture.state == UIGestureRecognizerStateEnded || pinchGesture.state == UIGestureRecognizerStateChanged){
    
        scaleDirectionDecided = NO;
    }
    
}


#pragma mark - Development:
#define kALertViewTagClearPlotsConfirm 222
#define kALertViewTagClearSelectionsConfirm 333

-(void)clearPlots:(UIBarButtonItem *)sender{

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure" message:@"Your data will be lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, delete", nil];
    alertView.tag = kALertViewTagClearPlotsConfirm;
    [alertView show];
    
}
-(void)clearPlotsConfirmed{
    
    [graph clear];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{

    switch (alertView.tag) {
        case kALertViewTagClearPlotsConfirm:
        {
        
            switch (buttonIndex) {
                case 1:
                    [self clearPlotsConfirmed];
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case kALertViewTagClearSelectionsConfirm:
        {
            
            switch (buttonIndex) {
                case 1:
                    [self clearSelectionsConfirmed];
                    break;
                    
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Selection:

-(IBAction)toggleSelectionMode:(id)sender{
    
    if (_mode != GLGraphViewControllerModeSelection) {
        
        _prevMode = _mode;
        
        _mode = GLGraphViewControllerModeSelection;
        
        [selectBbi setTitle:@"Stop selecting"];
        
    }else{
        
        _mode = _prevMode;
        [selectBbi setTitle:@"Start selection:"];
        
    }
}
-(IBAction)clearSelections:(id)sender{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure" message:@"Your data will be lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, delete", nil];
    alertView.tag = kALertViewTagClearSelectionsConfirm;
    [alertView show];
    
}
-(void)clearSelectionsConfirmed{

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name != %@", @"selection"];
    [graph.nodes filterUsingPredicate:pred];

}
-(IBAction)selectionSettings:(UIBarButtonItem *)button{
    
    
    if(!popoverSelection){
        
        GLGraphViewSelectionSettingsViewController *svc = [[GLGraphViewSelectionSettingsViewController alloc] init];
        svc.delegate = self;
        svc.selection = self.selection;
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:svc];
        
        popoverSelection = [[UIPopoverController alloc] initWithContentViewController:nc];
        popoverSelection.delegate = self;
        [popoverSelection presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
    
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    if (popoverController == popoverSelection) {
        popoverSelection = nil;
    }
}

-(void)selectionFromPanGesture:(UIPanGestureRecognizer *)panGesture{
    
    
    CGPoint currentTouchLocation    = [panGesture locationInView:self.glkView];
    CGPoint gl_point_current        = [graph glPointFromUIKitPoint:currentTouchLocation];
    
    CGFloat x, y, w, h;
    
    x = gl_point_current.x;
    
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        firstTouchPosition = lastTouchPosition = [panGesture locationInView:self.glkView];
        lastTranslationPoint = [panGesture translationInView:self.glkView];
        
        if (_selection.type == GLGraphViewSelectionTypeWidthOnly) {
        
            

            y = graph.visibleRegion.origin.y;
            w = _selection.size.width;
            h = CGRectGetHeight(graph.visibleRegion);
            
        }else if(_selection.type == GLGraphViewSelectionTypeStandard){
        
            y = gl_point_current.y;
            w = 0;
            h = 0;
        }
        
        // Create selection GLNode:
        _currentNode = [GLNode new];
        _currentNode.lineWidth = 2;
        _currentNode.name = @"selection";
        _currentNode.identityNumber = _selection.selectionId;
        _currentNode.identityString = _selection.machine_name;
        _currentNode.identityObject = _selection;
        _currentNode.active = YES;
        
       // int cc = CGColorGetNumberOfComponents(_selection.color.CGColor);
        const CGFloat *comps = CGColorGetComponents(_selection.color.CGColor);
        _currentNode.color = GLVector4DMake(comps[0], comps[1], comps[2], comps[3]);
        [graph addNode:_currentNode];
        
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {

        if (_selection.type == GLGraphViewSelectionTypeWidthOnly) {
            
            x = gl_point_current.x;
            y = graph.visibleRegion.origin.y;
            w = _selection.size.width;
            h = CGRectGetHeight(graph.visibleRegion);
        
            
        }else if(_selection.type == GLGraphViewSelectionTypeStandard){
        
            
            CGPoint glp_start = [graph glPointFromUIKitPoint:firstTouchPosition];
            
            
            x = MIN(gl_point_current.x, glp_start.x);
            y = MIN(gl_point_current.y, glp_start.y);
            
            w = ABS(gl_point_current.x - glp_start.x);
            h = ABS(gl_point_current.y - glp_start.y);
            
        }
        
        
        CGRect f = CGRectMake(x,y,w,h);
        [_currentNode setVerticesFromCGRect:f];
        
        lastTranslationPoint = currentTouchLocation;
        
    }
    else if(panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled){
    
        _currentNode.active = NO;
    }
    
}

#pragma mark - GLGraphViewSelectionSettingsViewControllerDelegate:

-(GLGraphViewSelection *)selection{

    if (!_selection) {
        _selection = [GLGraphViewSelectionSettingsViewController defaultSelection];
    }
    
    return _selection;
}

-(void)GLGraphViewSelectionSettingsViewControllerViewControllerDiDCancel:(GLGraphViewSelectionSettingsViewController *)controller{

    if (popoverSelection) {
        [popoverSelection dismissPopoverAnimated:YES];
        popoverSelection = nil;
    }
}
-(void)GLGraphViewSelectionSettingsViewControllerViewController:(GLGraphViewSelectionSettingsViewController *)controller didFinishWithSelection:(GLGraphViewSelection *)selection{

    if (popoverSelection) {
        [popoverSelection dismissPopoverAnimated:YES];
        popoverSelection = nil;
    }
    
    self.selection = selection;
    selectionTypeBbi.title = _selection.name;
    selectionTypeBbi.tintColor = _selection.color;
    
    if (_mode != GLGraphViewControllerModeSelection) [self toggleSelectionMode:nil];
}

#pragma mark - GLGraphDataSource:

-(NSString *)GLGraph:(GLGraph *)glGraph labelForAxis:(GLGraphAxis)axis forValue:(double)value{

    NSString *label = [_nf stringFromNumber:@(value)];// [NSString stringWithFormat:@"%.1f", value];
    //DLog(@"axis: %i value: %.3f, label: %@", axis, value, label);
    return label;
}




@end
