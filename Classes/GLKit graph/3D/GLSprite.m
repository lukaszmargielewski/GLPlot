//
//  GLSprite.m
//  Accel
//
//  Created by Lukasz Margielewski on 14/04/14.
//
//

#import "GLSprite.h"
#import "GLProgram.h"
#import "GLGraph.h"



@implementation GLSprite{

    
}
@synthesize texture = _texture;

+(GLProgram *)program{

    static GLProgram *program = nil;
    
    if (!program) {
        program = [GLProgram cachedProgram:@"ShaderTexture"];
        
    }
    
    return program;
    
}

-(void)renderInGraph:(GLGraph *)graph{
    
    //return;
    if (!_verticesCount || !_visible)return;

    GLProgram *shader = [GLSprite program];
    [shader use];
    
    
    GLint api = [shader attributeIndex:kPositionAttributeName];
    GLint ati = [shader attributeIndex:kTextureCoordinateAttributeName];
    
    glEnableVertexAttribArray(api);
    glEnableVertexAttribArray(ati);
    
    
    GLint umvpi = [shader uniformIndex:kModelViewProjectionMatrixUniformName];
    GLint uti = [shader uniformIndex:kTextureUniformName];
    GLint uci = [shader uniformIndex:kColorUniformName];
    
    GLKMatrix4 mvpMatrix = graph.mvp;
    
    glUniformMatrix4fv(umvpi, 1, NO, mvpMatrix.m);GL_ERROR_CHECK_DEBUG();
    
    // Texture sampler2D:
    glActiveTexture(GL_TEXTURE0);GL_ERROR_CHECK_DEBUG();
    glBindTexture(GL_TEXTURE_2D, _texture.texture);GL_ERROR_CHECK_DEBUG();
    glUniform1i(uti, 0);GL_ERROR_CHECK_DEBUG();
    
    GLsizei stride = sizeof(GLVector2DTextured);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);GL_ERROR_CHECK_DEBUG();
    // Setting position:
    glVertexAttribPointer(api, 2, GL_FLOAT, GL_FALSE, stride, offsetof(GLVector2DTextured, position));GL_ERROR_CHECK_DEBUG();
    // Setting uv:
    glVertexAttribPointer(ati, 2, GL_FLOAT, GL_FALSE, stride, offsetof(GLVector2DTextured, uv));GL_ERROR_CHECK_DEBUG();

    glDrawArrays(GL_TRIANGLES, 0, _verticesCount);GL_ERROR_CHECK_DEBUG();
    
    if (_borderWidth > 0) {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        GLfloat left    = CGRectGetMinX(_frame);
        GLfloat right   = CGRectGetMaxX(_frame);
        GLfloat top     = CGRectGetMinY(_frame);
        GLfloat bot     = CGRectGetMaxY(_frame);
        
        GLProgram *borderShader = [GLProgram cachedProgram:@"ShaderUniformColor"];
        [borderShader use];
        
        uci =   [borderShader uniformIndex:kColorUniformName];
        api =   [borderShader attributeIndex:kPositionAttributeName];
        umvpi = [borderShader uniformIndex:kModelViewProjectionMatrixUniformName];
        
        glEnableVertexAttribArray(api);

        GLVector2D f[4] = {
            
            GLVector2DMake(left, bot),
            GLVector2DMake(left, top),
            GLVector2DMake(right, top),
            GLVector2DMake(right, bot)
        };
        
        
        
        glLineWidth(_borderWidth);
        glUniformMatrix4fv(umvpi, 1, NO, mvpMatrix.m);GL_ERROR_CHECK_DEBUG();
        glVertexAttribPointer(api, 2, GL_FLOAT, GL_FALSE, 0, f);GL_ERROR_CHECK_DEBUG();
        glUniform4fv(uci, 1, (GLfloat *)&_borderColor);GL_ERROR_CHECK_DEBUG();
        glDrawArrays(GL_LINE_LOOP, 0, 4);GL_ERROR_CHECK_DEBUG();
    }
    
    glDisableVertexAttribArray(api);
    glDisableVertexAttribArray(ati);
    
}


+(GLSprite *)spriteWithImageRef:(CGImageRef)imageRef{

    return [[GLSprite alloc] initWithImageRef:imageRef];
    
}
-(id)initWithImageRef:(CGImageRef)imageRef{

    self = [super init];
    
    
    if (self) {
        
        _texture = [[GLTexture alloc] initWithCGImageRef:imageRef];
        [self commonInit];
        self.frame = CGRectMake(0, 0, _texture.size.width, _texture.size.height);
        GL_ERROR_CHECK_DEBUG();
        
    }
    
    return self;
    
}

-(id)initWithTexture:(GLTexture *)texture{

    self = [super init];
    
    if (self) {
        
        _texture = texture;
        GL_ERROR_CHECK_DEBUG();
        [self commonInit];
        self.frame = CGRectMake(0, 0, _texture.size.width, _texture.size.height);
        
    }
    
    return self;

}

+(GLSprite *)spriteWithTexture:(GLTexture *)texture{

    return [[GLSprite alloc] initWithTexture:texture];
}

-(void)commonInit{
    
    _borderWidth = 0;
    _borderColor = GLVector4DMake(0, 0, 0, 1);
    _verticesCount = 6;
    
    GLsizei bufferSizeInBytes = sizeof(GLVector2DTextured) * _verticesCount;
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);GL_ERROR_CHECK_DEBUG();
    glBufferData(GL_ARRAY_BUFFER, bufferSizeInBytes, NULL, GL_DYNAMIC_DRAW);GL_ERROR_CHECK_DEBUG();
    
    
}


-(void)setFrame:(CGRect)frame{

    _frame = frame;
    
    GLfloat left    = CGRectGetMinX(_frame);
    GLfloat right   = CGRectGetMaxX(_frame);
    GLfloat top     = CGRectGetMinY(_frame);
    GLfloat bot     = CGRectGetMaxY(_frame);
    
    GLint           size    = sizeof(GLVector2DTextured) *_verticesCount;
    unsigned long   offset  = 0;
    GLVector2DTextured *selRect  = malloc(size);
    
    GLVector2DTextured vvv;
    vvv.position = GLVector2DMake(left, bot);
    vvv.position = GLVector2DMake(left, bot);
    
    GLfloat uv_top = 1, uv_bot = 0, uv_left = 0, uv_right = 1;
    
    //GLfloat arh = _texture.size.height / _frame.size.height;
    //GLfloat arw = _texture.size.width / _frame.size.width;
    
    switch (_contentMode) {
        case GLContentModeTopLeft:
        {
        
            //uv_right    = _texture.size.width / _frame.size.width;
            //uv_bot      = _texture.size.height / _frame.size.height;
        }
            break;
            
        default:
            break;
    }
    
    selRect[0].position = GLVector2DMake(left, bot);
    selRect[0].uv       = GLVector2DMake(uv_left, uv_bot);
    
    selRect[1].position = GLVector2DMake(left, top);
    selRect[1].uv       = GLVector2DMake(uv_left, uv_top);
    
    selRect[2].position = GLVector2DMake(right, top);
    selRect[2].uv       = GLVector2DMake(uv_right, uv_top);
    
    selRect[3].position = GLVector2DMake(left, bot);
    selRect[3].uv       = GLVector2DMake(uv_left, uv_bot);
    
    selRect[4].position = GLVector2DMake(right, bot);
    selRect[4].uv       = GLVector2DMake(uv_right, uv_bot);
    
    selRect[5].position = GLVector2DMake(right, top);
    selRect[5].uv       = GLVector2DMake(uv_right, uv_top);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferSubData(GL_ARRAY_BUFFER, offset, size, selRect);GL_ERROR_CHECK_DEBUG();
    
    free(selRect);
}
@end
