//
//  GLGraphNode.m
//  FF
//
//  Created by Lukasz Margielewski on 09/04/14.
//
//

#import "GLNode.h"
#import "GLGraph.h"



@implementation GLNode{
    
}
@synthesize verticesCount = _verticesCount;

-(void)dealloc{
    
    glDeleteBuffers(1, &_vbo);
}
-(id)init{
    
    self = [super init];
    
    if (self) {
        
        glGenBuffers(1, &_vbo);
        
        _bytesPerVertice    = sizeof(GLVector2D);
        _verticesCount      = 0;
        
        _visible            = YES;
        _boundingBox        = CGRectZero;
        _visibleRect        = CGRectZero;
        
        _color              = GLVector4DMake(0, 0, 0, 1);
        _colorActive        = GLVector4DMake(0, 1, 0, 0.5);
        _colorSelected      = GLVector4DMake(0, 0, 1, 0.5);
        
        _lineWidth          = 1.0;
    }
    return self;
}

-(void)renderInGraph:(GLGraph *)graph{
    
    if (!_verticesCount || !_visible)return;

    GLProgram *shader = graph.shader;
    [graph.shader use];
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    
    // Setting color:
    GLint cui = [shader uniformIndex:kColorUniformName];
    GLint ati = [shader attributeIndex:kPositionAttributeName];

    glEnableVertexAttribArray(ati);
    glVertexAttribPointer(ati, 2, GL_FLOAT, GL_FALSE, 0, 0);GL_ERROR_CHECK_DEBUG();

    //NSLog(@"verts to draw: %i, _verticesCount: %lu, _vboOffset: %i, _vboCount: %i", _verticesToDrawCount, _verticesCount, _vboOffset, _vboCount);
    
    if (_active || _selected) {
        
        if (_active) {
            
            glLineWidth(_lineWidth * 2.0);
            glUniform4fv(cui, 1, (GLfloat *)&_colorActive);GL_ERROR_CHECK_DEBUG();
            glDrawArrays(GL_LINE_STRIP, 0, _verticesCount);GL_ERROR_CHECK_DEBUG();
            
        }
        
        if (_selected) {
            glLineWidth(_lineWidth * 3.0);
            glUniform4fv(cui, 1, (GLfloat *)&_colorSelected);GL_ERROR_CHECK_DEBUG();
            glDrawArrays(GL_LINE_STRIP, 0, _verticesCount);GL_ERROR_CHECK_DEBUG();
        }
    }
    
    glLineWidth(_lineWidth);
    glUniform4fv(cui, 1, (GLfloat *)&_color);GL_ERROR_CHECK_DEBUG();
    glDrawArrays(GL_LINE_STRIP, 0, _verticesCount);GL_ERROR_CHECK_DEBUG();
    
    

}
-(void)updateInGraph:(GLGraph *)graph{

    _visibleRect = graph.visibleRegion;
    
    if (_needsCulling) {
        [self cull];
    }
  
}
-(void)setNeedsCulling{

    _needsCulling = YES;
}
-(void)cull{

    // Culing updates VBO:
    // Default mplmentation does nothing:
    _needsCulling = NO;
}


#pragma mark - Vertices editing:
-(void)setVerticesFromCGRect:(CGRect)rect{

    GLVector2D selRect [] = {
        
        CGRectGetMinX(rect), CGRectGetMinY(rect),
        CGRectGetMaxX(rect), CGRectGetMinY(rect),
        CGRectGetMaxX(rect), CGRectGetMaxY(rect),
        CGRectGetMinX(rect), CGRectGetMaxY(rect),
        CGRectGetMinX(rect), CGRectGetMinY(rect),
    };
    
    _boundingBox = rect;
    _verticesCount = 5;
    
    unsigned long long sizeInBytes     = _bytesPerVertice * _verticesCount;
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeInBytes, selRect, GL_STATIC_DRAW);

}


@end
