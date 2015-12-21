//
//  GLScene.h
//  FF
//
//  Created by Lukasz Margielewski on 08/04/14.
//
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


#import "GLPlot.h"
#import "GLProgram.h"

typedef enum GLGraphAxis{

    GLGraphAxisX = 0,
    GLGraphAxisY
    
}GLGraphAxis;

@class GLGraph;

@protocol GLGraphDataSource <NSObject>

-(NSString *)GLGraph:(GLGraph *)glGraph labelForAxis:(GLGraphAxis)axis forValue:(double)value;

@end

@interface GLGraph : NSObject

@property GLVector4D clearColor;
@property (nonatomic) CGRect visibleRegion;
@property (nonatomic) CGRect bounds2D;

@property (nonatomic, assign) GLKView *hostingView;

@property (nonatomic, assign)id<GLGraphDataSource>dataSource;

@property (nonatomic, readonly) GLProgram *shader;

@property (nonatomic, readonly) GLKMatrix4 mvp;
@property (nonatomic, readonly) GLKMatrix4 mvpBounds2D;

@property (nonatomic, readonly) NSMutableArray *nodes;

-(NSArray *)allPlots;
-(NSArray *)allPlotNames;
-(void)update;
-(void)render;

-(void)addNode:(GLNode *)overlay;
-(void)removeNode:(GLNode *)overlay;

-(void)addPlot:(GLPlot *)plot;
-(void)removePlot:(GLPlot *)plot;
-(void)removePlotWithName:(NSString *)name;

-(GLPlot *)plotWithName:(NSString *)name;

-(void)clear;
-(void)clearAxisLabelsCacheForAxis:(GLGraphAxis)axis;


-(CGPoint)glPointFromUIKitPoint:(CGPoint)point;
@end
