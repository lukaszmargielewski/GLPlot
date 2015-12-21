//
//  GLGraphNode.h
//  FF
//
//  Created by Lukasz Margielewski on 09/04/14.
//
//

#import <Foundation/Foundation.h>
#import "GLStructs.h"

@class GLGraph;

@interface GLNode : NSObject{
 
    CGRect          _boundingBox;
    CGRect          _visibleRect;
    
    short          _bytesPerVertice;
    
    GLuint          _vbo;
    //GLsizei         _vboOffset; // Stores offset of vertices, with which _vdo buffer was created (created ater culling)
    //GLsizei         _vboCount;  // vbo vertices count (culled)
    
    GLsizei         _verticesCount; // Total vertices count.
                                    // !!! Subclasses must make sure this fields is alwasy properly updated
    BOOL            _needsCulling;
    BOOL            _visible;
    
}

@property (nonatomic, readonly)     CGRect boundingBox;
@property (nonatomic, readonly)     GLsizei verticesCount;

@property (nonatomic, assign)       BOOL visible;
@property (nonatomic, assign)       BOOL selected;
@property (nonatomic, assign)       BOOL active;

@property (nonatomic) GLVector4D color;
@property (nonatomic) GLVector4D colorActive;
@property (nonatomic) GLVector4D colorSelected;

@property (nonatomic) GLfloat     lineWidth;

// Fields helping to identify node:
@property (nonatomic)          int tag;
@property (nonatomic, strong)  NSString *name;
@property (nonatomic, strong)  NSString *identityString;
@property (nonatomic, strong)  NSNumber *identityNumber;
@property (nonatomic, strong)  id identityObject;

-(void)setVerticesFromCGRect:(CGRect)rect;

-(void)setNeedsCulling;

-(void)renderInGraph:(GLGraph *)graph;
-(void)updateInGraph:(GLGraph *)graph;

/**
 Override this method in subclasses to adjust _vboOffset & _vboCount
 Basic implementation simply assigns: _vboOffset = 0 and _vboCount to total amount of vertices.
 */

-(void)cull;

@end
