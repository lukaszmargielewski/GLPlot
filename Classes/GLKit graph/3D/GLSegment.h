//
//  GLPlotSegment.h
//  Accel
//
//  Created by Lukasz Margielewski on 25/08/2014.
//
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>
#import "GLStructs.h"


@interface GLSegment : NSObject

@property (nonatomic, readonly) GLuint vbo;

@property (nonatomic, readonly) unsigned long vertsCount;
@property (nonatomic, readonly) unsigned long size;

@property (nonatomic, readonly) GLVector2D firstVector, lastVector;
@property (nonatomic) GLuint index;

-(id)initWithSize:(GLsizei) size index:(GLuint)index;
-(BOOL)addGLVector2D:(GLVector2D)vector;
@end
