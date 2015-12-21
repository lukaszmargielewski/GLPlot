//
//  GLScene.m
//  FF
//
//  Created by Lukasz Margielewski on 08/04/14.
//
//

#import "GLGraph.h"
#import "GLTexture.h"
#import "GLSprite.h"

#include <vector>
using namespace std;


typedef struct GLVector2DColor{

    GLVector2D position;
    GLVector4D color;
    
}GLVector2DColor;

@interface GLGraph()

@end


@implementation GLGraph{

    NSMutableArray *_plots;
    NSMutableDictionary *_plotsDict;
    NSMutableArray *_overlays;
    
    NSMutableDictionary *_ymarkSprites;
    NSMutableDictionary *_xmarkSprites;
    // Dictionary With Non Retained Keys and Object Values
    CFMutableDictionaryRef _intObjDictX;
    CFMutableDictionaryRef _intObjDictY;
    vector<GLVector2DColor> yMarksVertices;
    vector<GLVector2DColor> xMarksVertices;
    
    GLuint _yMarksBuffer;
    GLuint _xMarksBuffer;
    
    UIColor *labelColor;
    UIColor *labelBackgroundColor;
    
    // Grid shader:
    GLProgram *_shaderGrid;
    
}
@synthesize shader  = _shader;
@synthesize mvp     = _mvp;
@synthesize mvpBounds2D = _mvpBounds2D;
@synthesize nodes  = _overlays;


-(void)dealloc{
    
    glDeleteBuffers(1, &_xMarksBuffer);
    glDeleteBuffers(1, &_yMarksBuffer);
    
    if (_hostingView) {
        [_hostingView removeObserver:self forKeyPath:@"frame"];
    }
    
    CFRelease(_intObjDictX);
    CFRelease(_intObjDictY);

}


-(id)init{


    self = [super init];
    
    if (self) {

        _plots          = [[NSMutableArray alloc] initWithCapacity:10];
        _plotsDict          = [[NSMutableDictionary alloc] initWithCapacity:10];
        _overlays       = [[NSMutableArray alloc] initWithCapacity:10];
        
        _ymarkSprites   = [[NSMutableDictionary alloc] initWithCapacity:20];
        _xmarkSprites   = [[NSMutableDictionary alloc] initWithCapacity:20];
        
        // Dictionary With Non Retained Keys and Object Values
        _intObjDictX = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        _intObjDictY = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        
        glGenBuffers(1, &_xMarksBuffer);
        glGenBuffers(1, &_yMarksBuffer);

        labelColor = [UIColor whiteColor];
        labelBackgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.4];
        
        [self configureDefaultGL];
        
    }
    
    return self;
}
-(void)configureDefaultGL{

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    // Default shader (simple color unifrom), attributes and uniforms:
    _shader = [GLProgram cachedProgram:@"ShaderUniformColor"];
    
    // Grid shader:
    _shaderGrid = [GLProgram cachedProgram:@"ShaderColor"];
}
-(void)setHostingView:(GLKView *)hostingView{

    if (_hostingView) {
        [_hostingView removeObserver:self forKeyPath:@"frame"];
    }
    if (_hostingView != hostingView){
    
        _hostingView = hostingView;
        [_hostingView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    self.bounds2D = self.visibleRegion = _hostingView.bounds;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    if (object == _hostingView && [keyPath isEqualToString:@"frame"]) {
        
        self.bounds2D = _hostingView.bounds;
    }
}
-(void)setBounds2D:(CGRect)bounds2D{

    _bounds2D = bounds2D;
    
    float left      = CGRectGetMinX(_bounds2D);
    float right     = CGRectGetMaxX(_bounds2D);
    float bottom    = CGRectGetMinY(_bounds2D);
    float top       = CGRectGetMaxY(_bounds2D);
    
    _mvpBounds2D = GLKMatrix4MakeOrtho(left, right,bottom, top, 1, -1);
    
}
-(void)recalculateYaxis{


    //NSLog(@"visibleRegion: %@", NSStringFromCGRect(visibleRegion));
    GLfloat left      = CGRectGetMinX(_visibleRegion);
    GLfloat right     = CGRectGetMaxX(_visibleRegion);
    GLfloat bot       = CGRectGetMinY(_visibleRegion);
    GLfloat top       = CGRectGetMaxY(_visibleRegion);
    
    GLfloat height    = CGRectGetHeight(_visibleRegion);
    
    int     digits      = 1;
    float   range       = 1;
    
    while (height >= range * 10) {
        digits++;
        range *= 10;
    }
    
    
    GLfloat markDistance = 0.1 * range;
    
    GLfloat top_ = ceilf(top / markDistance) * markDistance;
    GLfloat bot_ = floorf(bot / markDistance) * markDistance;
    
    
    //NSLog(@"height: %.2f, range: %.2f digits: %i, mark distance: %.2f", height, range, digits, markDistance);
    
    
    
    int yMarksVerticesEstimated = ceilf((top_ - bot_) / markDistance) * 2;
    yMarksVertices.reserve(yMarksVerticesEstimated);
    yMarksVertices.clear();
    
    NSMutableArray *existingSpritesToRemove = [[_ymarkSprites allKeys] mutableCopy];
    
    GLfloat axisx = MAX(left,0);
    GLfloat axismarkx = axisx;
    GLfloat axismarkw = _visibleRegion.size.width / 30;
    GLfloat axismarkh = markDistance * 0.9;
    GLfloat axismarkh2 = axismarkh * 0.5;
    
    GLfloat y = top_;
    
    BOOL dataSourceDriven = (_dataSource && [_dataSource respondsToSelector:@selector(GLGraph:labelForAxis:forValue:)]);
    
    while (y >= bot_) {
        
        GLVector4D color = (y == 0) ? GLVector4DMake(0, 0, 1, 1) : GLVector4DMake(0, 0, 0, 1);
        GLVector2DColor vc;
        
        vc.position = GLVector2DMake(axisx, y);
        vc.color = color;
        yMarksVertices.push_back(vc);
        
        vc.position = GLVector2DMake(right, y);
        vc.color = color;
        yMarksVertices.push_back(vc);
        
        // Marks textures and sprites:
        int yint = (int)round(y * 100);
        NSString *yMarkAsString = (NSString *)CFDictionaryGetValue(_intObjDictY, (void *)yint);
        if (!yMarkAsString) {
            
            if (dataSourceDriven)
                yMarkAsString = [_dataSource GLGraph:self labelForAxis:GLGraphAxisY forValue:y];
            
            if (!yMarkAsString)
                yMarkAsString = [NSString stringWithFormat:@"%.1f", y];
            
            CFDictionarySetValue(_intObjDictY, (void *)yint, (__bridge const void *)(yMarkAsString));
        }
        
        
        GLSprite *sprite = [_ymarkSprites valueForKey:yMarkAsString];
        [existingSpritesToRemove removeObject:yMarkAsString];
        
        
        if (!sprite) {
            
            GLTexture *texture = [GLTexture textureWithString:yMarkAsString font:[UIFont systemFontOfSize:30] textColor:labelColor backgroundColor:labelBackgroundColor lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentRight availableWidth:0 relativePadding:UIEdgeInsetsMake(0,0.2, 0, 0.2)];
            
            sprite = [GLSprite spriteWithTexture:texture];
            sprite.borderColor = GLVector4DMake(0, 1, 0, 1);
            [_ymarkSprites setValue:sprite forKey:yMarkAsString];
            
            
            
        }
        
        [self addNode:sprite];
       
        CGRect f = sprite.frame;
        
        
        f.size.height       = axismarkh;
        f.origin.y          = y - axismarkh2;
        f.size.width        = axismarkw;
        f.origin.x          = (axismarkx == 0) ? axismarkx - axismarkw : axismarkx;
        
        sprite.frame        = f;
        sprite.borderColor  = GLVector4DMake(1, 0, 0, 1);
        
        y -= markDistance;
        
    }//
    
    
    // Remove marks, which are not in visible area anymore:
    for (NSString *key in existingSpritesToRemove) {
        GLSprite *sprite = [_ymarkSprites valueForKey:key];
        [self removeNode:sprite];
        [_ymarkSprites removeObjectForKey:key];
    }
    
    //}
    //NSLog(@"Nodes count: %i, yMarks prites count: %i", _overlays.count, _ymarkSprites.count);
    GLsizei ymvsib = sizeof(GLVector2DColor) * yMarksVertices.size(); // Y marks vertices size in bytes
    glBindBuffer(GL_ARRAY_BUFFER, _yMarksBuffer);
    
    GLVector2DColor *vc =  yMarksVertices.data();
    //NSLog(@"allocating %i bytes for y marks buffer (%lu items)", ymvsib, yMarksVertices.size());
    glBufferData(GL_ARRAY_BUFFER, ymvsib, vc, GL_STATIC_DRAW);GL_ERROR_CHECK_DEBUG();
    
}
-(void)recalculateXaxis{
    
    // FIXME: Something fishy is going on with x axis labels (cthey change, dissappear and scroll strangely)
    //NSLog(@"visibleRegion: %@", NSStringFromCGRect(visibleRegion));
    GLfloat _left      = CGRectGetMinX(_visibleRegion);
    GLfloat _right     = CGRectGetMaxX(_visibleRegion);
    GLfloat _bot       = CGRectGetMinY(_visibleRegion);
    GLfloat _top       = CGRectGetMaxY(_visibleRegion);
    
    GLfloat width    = CGRectGetWidth(_visibleRegion);
    
    float   range       = 0.1;
    while (width > range && range <= 1000)range *= 10;
    
    GLfloat markDistance = MIN(MAX(0.01, (0.01 * range)), 1000);
    
    GLfloat right_ = floorf(_right / markDistance) * markDistance;
    GLfloat left_ = ceilf(_left / markDistance) * markDistance;
    
    //NSLog(@"width: %.2f, range: %.2f, mark distance: %.2f | l: %.3f, %.3f | r: %.3f, %.3f", width, range, markDistance, _left, left_, _right, right_);
    
    int xMarksVerticesEstimated = ceilf((right_ - left_) / markDistance) * 2;
    xMarksVertices.reserve(xMarksVerticesEstimated);
    xMarksVertices.clear();
    
    NSMutableArray *existingSpritesToRemove = [[_xmarkSprites allKeys] mutableCopy];
    
    GLfloat axisy = MIN(_bot,0);
    GLfloat axismarky = axisy;
    
    GLfloat x = MAX(left_, 0);
    
    BOOL dataSourceDriven = (_dataSource && [_dataSource respondsToSelector:@selector(GLGraph:labelForAxis:forValue:)]);
    
    
    
    while (x <= _right) {
        
        GLVector4D color = (x == 0) ? GLVector4DMake(0, 0, 1, 1) : GLVector4DMake(0, 0, 0, 1);
        GLVector2DColor vc;
        
        vc.position = GLVector2DMake(x, axisy);
        vc.color = color;
        xMarksVertices.push_back(vc);
        
        vc.position = GLVector2DMake(x, _top);
        vc.color = color;
        xMarksVertices.push_back(vc);
        
        // Marks textures and sprites:
        int xint = (int)round(x * 100);
        NSString *xMarkAsString = (NSString *)CFDictionaryGetValue(_intObjDictX, (void *)xint);

        if (!xMarkAsString) {
            
            if (dataSourceDriven)
                xMarkAsString = [_dataSource GLGraph:self labelForAxis:GLGraphAxisX forValue:x];
            
            if (!xMarkAsString)
                xMarkAsString = [NSString stringWithFormat:@"%.1f", x];
            
            CFDictionarySetValue(_intObjDictX, (void *)xint, (__bridge const void *)(xMarkAsString));
        }
        
        
        GLSprite *sprite = [_xmarkSprites valueForKey:xMarkAsString];
        [existingSpritesToRemove removeObject:xMarkAsString];
        
        
        if (!sprite) {
            
            GLTexture *texture = [GLTexture textureWithString:xMarkAsString font:[UIFont systemFontOfSize:30] textColor:labelColor backgroundColor:labelBackgroundColor lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft availableWidth:0 relativePadding:UIEdgeInsetsMake(0,0.2, 00, 0.2)];
            
            sprite = [GLSprite spriteWithTexture:texture];
            
            // sprite.borderColor = GLVector4DMake(0, 1, 0, 1);
            // NSLog(@"Creating %@ from number: %f | xint: %i", xMarkAsString, x, xint);
            
            [_xmarkSprites setValue:sprite forKey:xMarkAsString];
        
        }
        
        [self addNode:sprite];
        
        CGRect f = sprite.frame;
        
        GLfloat axismarkh = _visibleRegion.size.height / 30;
        GLfloat axismarkw = markDistance * 0.9;
        GLfloat axismarkw2 = axismarkw * 0.5;

        f.size.width        = axismarkw;
        f.origin.x          = x - axismarkw2;
        
        f.size.height       = axismarkh;
        f.origin.y          = axismarky;
        
        sprite.frame        = f;
        
        x += markDistance;
        
    }//
    
    
    // Remove marks, which are not in visible area anymore:
    for (NSString *key in existingSpritesToRemove) {
        GLSprite *sprite = [_xmarkSprites valueForKey:key];
        [self removeNode:sprite];
        [_xmarkSprites removeObjectForKey:key];
    }
    
    //}
    //NSLog(@"Nodes count: %i, yMarks prites count: %i", _overlays.count, _ymarkSprites.count);
    GLsizei xmvsib = sizeof(GLVector2DColor) * xMarksVertices.size(); // X marks vertices size in bytes
    glBindBuffer(GL_ARRAY_BUFFER, _xMarksBuffer);
    
    GLVector2DColor *vc =  xMarksVertices.data();
    //NSLog(@"allocating %i bytes for y marks buffer (%lu items)", ymvsib, yMarksVertices.size());
    glBufferData(GL_ARRAY_BUFFER, xmvsib, vc, GL_STATIC_DRAW);GL_ERROR_CHECK_DEBUG();
    
}
-(void)clearAxisLabelsCacheForAxis:(GLGraphAxis)axis{
    
    switch (axis) {
        case GLGraphAxisX:
        {
            
            for(NSString *key in _xmarkSprites)
                [self removeNode:_xmarkSprites[key]];
            [_xmarkSprites removeAllObjects];
            
            CFRelease(_intObjDictX);
            _intObjDictX = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        }
            break;
        case GLGraphAxisY:
        {
            for(NSString *key in _ymarkSprites)
                [self removeNode:_ymarkSprites[key]];
            [_ymarkSprites removeAllObjects];
            
            CFRelease(_intObjDictY);
            _intObjDictY = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        }
            break;
        default:
            break;
    }

}

-(void)setVisibleRegion:(CGRect)visibleRegion{

    if (!CGRectEqualToRect(visibleRegion, _visibleRegion)) {

        _visibleRegion = visibleRegion;
        
        GLfloat left      = CGRectGetMinX(_visibleRegion);
        GLfloat right     = CGRectGetMaxX(_visibleRegion);
        GLfloat bot       = CGRectGetMinY(_visibleRegion);
        GLfloat top       = CGRectGetMaxY(_visibleRegion);
        
        [self recalculateYaxis];
        [self recalculateXaxis];
        // 1. Projection matrix:
        _mvp = GLKMatrix4MakeOrtho(left, right,bot, top, 1, -1);
        
        for (GLNode *node in _overlays) {
            [node setNeedsCulling];
        }
        // 3. Mark plots for culling:
        for (GLPlot *plot in _plots) {

            [plot setNeedsCulling];
        }
        

    }
}
-(void)clear{

    [_plots removeAllObjects];
    [_plotsDict removeAllObjects];
    [_overlays removeAllObjects];
    
    // Add marks back:
    for (NSString *key in [_xmarkSprites allKeys]) {
        GLSprite *markSprite = [_xmarkSprites valueForKey:key];
        [self addNode:markSprite];
    }
    for (NSString *key in [_ymarkSprites allKeys]) {
        GLSprite *markSprite = [_ymarkSprites valueForKey:key];
        [self addNode:markSprite];
    }
}

-(void)addNode:(GLNode *)overlay{
    
    if (![_overlays containsObject:overlay]) {
        [_overlays addObject:overlay];
        
    }
    
}
-(void)removeNode:(GLNode *)overlay{
    
    if ([_overlays containsObject:overlay]) {
        [_overlays removeObject:overlay];
        
    }
    
}

-(void)addPlot:(GLPlot *)plot{

    NSString *name = plot.name;
    
    if (![_plots containsObject:plot]) {
       [_plots addObject:plot];
        [_plotsDict setValue:plot forKey:name];
        
    }
    
}
-(void)removePlot:(GLPlot *)plot{

    [self removePlotWithName:plot.name];
}
-(void)removeAllPlots{

}
-(void)removePlotWithName:(NSString *)name{
    

    GLPlot *plot = [_plotsDict valueForKey:name];
    
    if (plot) {
        [_plots removeObject:plot];
        [_plotsDict removeObjectForKey:name];
        
    }
    
}
-(GLPlot *)plotWithName:(NSString *)name{

    return [_plotsDict valueForKey:name];
}

-(NSArray *)allPlots{return  _plots;}
-(NSArray *)allPlotNames{return [_plotsDict allKeys];}

-(void)update{

    for (GLPlot *plot in _plots) {
        [plot updateInGraph:self];
        
    }
    
    for (GLNode *overlay in _overlays) {
        [overlay updateInGraph:self];
        
    }
   
}
-(void)render {
    
    //  NSLog(@"in EEScene's render");
    glClearColor(_clearColor.x, _clearColor.y, _clearColor.z, _clearColor.z);
    glClear(GL_COLOR_BUFFER_BIT);

    [_shader use];
    
    glUniformMatrix4fv([_shader uniformIndex:kModelViewProjectionMatrixUniformName], 1, NO, _mvp.m);
    glEnableVertexAttribArray([_shader attributeIndex:kPositionAttributeName]);

    
    for (GLPlot *plot in _plots) {
        [plot renderInGraph:self];
        
    }

    //glDisableVertexAttribArray(_positionAttribute);
    
    [self renderAxis];

    [_shader use];
    
    for (GLNode *overlay in _overlays) {
        [overlay renderInGraph:self];
        
    }
}
-(void)renderAxis{

    // Render Y axis:
    GLsizei ymvc = yMarksVertices.size();
    if (ymvc > 0) {
        
        GLsizei stride = sizeof(GLVector2DColor);
        [_shaderGrid use];
        
        glLineWidth(1);
        glBindBuffer(GL_ARRAY_BUFFER, _yMarksBuffer);
        
        
        GLint api           = [_shaderGrid attributeIndex:kPositionAttributeName];
        GLint aci           = [_shaderGrid attributeIndex:kColorAttributeName];
        GLint umvpi         = [_shaderGrid uniformIndex:kModelViewProjectionMatrixUniformName];
        const void *p_off   = (void *)offsetof(GLVector2DColor, position);
        const void *c_off   = (void *)offsetof(GLVector2DColor, color);
        
        glEnableVertexAttribArray(api);
        glEnableVertexAttribArray(aci);
        
        glUniformMatrix4fv(umvpi, 1, NO, _mvp.m);
        GL_ERROR_CHECK_DEBUG();
        
        glVertexAttribPointer(api, 2, GL_FLOAT, GL_FALSE, stride, p_off);
        GL_ERROR_CHECK_DEBUG();
        
        glVertexAttribPointer(aci, 4, GL_FLOAT, GL_FALSE, stride, c_off);
        GL_ERROR_CHECK_DEBUG();
        
        //NSLog(@"rendering %i bytes for y marks buffer (%i items)", ymvc * stride, ymvc);
        glDrawArrays(GL_LINES, 0, ymvc);
        GL_ERROR_CHECK_DEBUG();
    }
    
    // Render X axis:
    GLsizei xmvc = xMarksVertices.size();
    if (xmvc > 0) {
        
        GLsizei stride = sizeof(GLVector2DColor);
        [_shaderGrid use];
        
        glLineWidth(1);
        glBindBuffer(GL_ARRAY_BUFFER, _xMarksBuffer);
        
        
        GLint api           = [_shaderGrid attributeIndex:kPositionAttributeName];
        GLint aci           = [_shaderGrid attributeIndex:kColorAttributeName];
        GLint umvpi         = [_shaderGrid uniformIndex:kModelViewProjectionMatrixUniformName];
        
        const void *p_off   = (void *)offsetof(GLVector2DColor, position);
        const void *c_off   = (void *)offsetof(GLVector2DColor, color);
        
        glEnableVertexAttribArray(api);
        glEnableVertexAttribArray(aci);
        
        glUniformMatrix4fv(umvpi, 1, NO, _mvp.m);
        GL_ERROR_CHECK_DEBUG();
        
        glVertexAttribPointer(api, 2, GL_FLOAT, GL_FALSE, stride, p_off);
        GL_ERROR_CHECK_DEBUG();
        
        glVertexAttribPointer(aci, 4, GL_FLOAT, GL_FALSE, stride, c_off);
        GL_ERROR_CHECK_DEBUG();
        
        //NSLog(@"rendering %i bytes for y marks buffer (%i items)", ymvc * stride, ymvc);
        glDrawArrays(GL_LINES, 0, xmvc);
        GL_ERROR_CHECK_DEBUG();
    }
}

#pragma mark - Calculations:

-(CGPoint)glPointFromUIKitPoint:(CGPoint)point{
    
    CGFloat W = CGRectGetWidth(self.hostingView.bounds);
    CGFloat H = CGRectGetHeight(self.hostingView.bounds);

    CGFloat w = CGRectGetWidth(_visibleRegion);
    CGFloat h = CGRectGetHeight(_visibleRegion);
    
    CGFloat war = w / W;
    CGFloat har = h / H;
    
    CGPoint glPoint = _visibleRegion.origin;
    glPoint.y = CGRectGetMaxY(_visibleRegion);
    
    glPoint.x += (war * point.x);
    glPoint.y -= (har * point.y);
    
    return glPoint;
    
}

@end
