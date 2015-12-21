//
//  AccelGraphsViewController.m
//  Accel
//
//  Created by Lukasz Margielewski on 24/08/2014.
//
//

#import "GLPlotExampleViewController.h"


#define kPlotName_dummy @"dummy"


@interface GLPlotExampleViewController ()

@end

@implementation GLPlotExampleViewController{

    NSTimeInterval _start_time;
    NSTimeInterval _dt;
    
    NSTimer *_dummyTimer;
    BOOL _dummy;
    
}

-(void)viewDidLoad{


    [super viewDidLoad];
    UIBarButtonItem *dummyPlots = [[UIBarButtonItem alloc] initWithTitle:@"Dummy" style:UIBarButtonItemStyleBordered target:self action:@selector(dummy:)];
    self.navigationItem.rightBarButtonItems = @[dummyPlots];
 
    [self dummy:nil];
}


#pragma mark - Method Candidates for subclass & instances used here:

-(void)configurePlots{
    
    _start_time = 0;
    
    [graph clear];
    
    GLPlot *plotMag     = [[GLPlot alloc] initWithName:kPlotName_dummy];
    plotMag.color = GLVector4DMake(1, 0, 0, 0.6);
    
    [graph addPlot:plotMag];
    
}
-(void)clearPlotsConfirmed{
    
    [super clearPlotsConfirmed];
    
    _start_time = 0;
    
    
}
-(void)updateDTValues{
    
    CGRect f = graph.visibleRegion;
    NSTimeInterval tNow = [NSDate date].timeIntervalSince1970;
    
    
    if (_start_time == 0){
        f.origin.x = tNow;
        _start_time = tNow;
        
    }
    
    _dt = tNow - _start_time;
    
    if (_dt > CGRectGetMaxX(f)) {
        
        f.origin.x += (_dt - CGRectGetMaxX(f));
        graph.visibleRegion = f;
    }
}

#pragma mark - Dev / Dummy & Test:

-(void)dummy:(UIBarButtonItem *)sender{
    
    _dummy = !_dummy;
    //return;
    
    if (_dummyTimer) {
        [_dummyTimer invalidate];
        _dummyTimer = nil;
        
    }else{
        
        _start_time = [[NSDate date] timeIntervalSince1970];
        _dummyTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(generateDummyEntry:) userInfo:nil repeats:YES];
    }
    
}
- (void)glkViewControllerUpdate:(GLKViewController *)controller {
    
    if (_dummy) {
        [self generateDummyEntry:nil];
    }
    [super glkViewControllerUpdate:controller];
    
}
-(void)generateDummyEntry:(NSTimer *)timer{

  
    double y = sin(_dt);//(double)(arc4random() % 255) / 255.0;
    GLVector2D vmagnitude  = GLVector2DMake(_dt, y);
    
    [[graph plotWithName:kPlotName_dummy] addVector2D:vmagnitude];
    _dt += 0.05;
    [self updateDTValues];
    
}
@end
