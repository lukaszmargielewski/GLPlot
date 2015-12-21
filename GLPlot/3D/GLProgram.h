#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


#define kColorUniformName @"color"
#define kColorAttributeName @"color"
#define kModelViewProjectionMatrixUniformName @"mvp"
#define kPositionAttributeName @"position"
#define kTextureCoordinateAttributeName @"a_texture"
#define kTextureUniformName @"s_texture"

#define GL_ERROR_CHECK_DEBUG() ({ GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s\n", __error, __FUNCTION__); (__error ? NO : YES); })

@interface GLProgram : NSObject 
{
}
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) GLuint program;

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename;

+(GLProgram *)cachedProgram:(NSString *)vfShaderName;
+(GLProgram *)cachedProgramWithVertexShaderFilename:(NSString *)vShaderFilename
                             fragmentShaderFilename:(NSString *)fShaderFilename;



- (GLint)attributeIndex:(NSString *)attributeName;
- (GLint)uniformIndex:(NSString *)uniformName;

- (void)use;
- (void)link;

@end
