//
//  GLPlotSegment.m
//  Accel
//
//  Created by Lukasz Margielewski on 25/08/2014.
//
//

#import "GLSegment.h"

#include <vector>
using namespace std;


@implementation GLSegment{
    
    vector<GLVector2D>_vertices;
}

@synthesize firstVector = _firstVector;
@synthesize lastVector = _lastVector;
@synthesize vbo = _vbo;
@synthesize  vertsCount = _vertsCount;
@synthesize size = _size;

-(void)dealloc{
    
    glDeleteBuffers(1, &_vbo);
    _vertices.clear();
}

-(id)init{
    
    NSAssert(NO, @"GLSegment init not allowed. Use initWithIndex:size: instead");
    return nil;
}
-(id)initWithSize:(GLsizei) size index:(GLuint)index{
    
    self = [super init];
    
    if (self) {
        
        _size = size;
        _index = index;
        _vertsCount = 0;
        _firstVector = _lastVector = GLVector2DMake(0, 0);
        
        _vertices.reserve(size);
        GLsizei bytes =  sizeof(GLVector2D) * _size;
        glGenBuffers(1, &_vbo);
        glBindBuffer(GL_ARRAY_BUFFER, _vbo);GL_ERROR_CHECK_DEBUG();
        glBufferData(GL_ARRAY_BUFFER,bytes, NULL, GL_DYNAMIC_DRAW);GL_ERROR_CHECK_DEBUG();
    }
    
    return self;
    
}


-(BOOL)addGLVector2D:(GLVector2D)vector{
    
    if (_vertsCount >= _size){
        //NSLog(@"++++++++ %i segment is full", _index);
        return NO;
    }
    
    if (_vertsCount == 0)_firstVector = vector;
    _lastVector = vector;
    
    _vertices.push_back(vector);
    
    GLsizei  bytesForVector = sizeof(GLVector2D);
    GLuint    offset = _vertsCount * bytesForVector;
    
    _vertsCount++;
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);GL_ERROR_CHECK_DEBUG();
    glBufferSubData(GL_ARRAY_BUFFER, offset, bytesForVector, &vector);GL_ERROR_CHECK_DEBUG();
    
    //NSLog(@"Added %lu/%lu vert to %i seg | vert size: %i, ofset: %i", _vertsCount, _size, _index, bytesForVector, offset);
    return YES;
    
}
@end
