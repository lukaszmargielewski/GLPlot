#import "GLProgram.h"

#pragma mark -
#pragma mark Private Extension Method Declaration
@interface GLProgram()
{

    GLuint          program, vertShader, fragShader;
    NSMutableDictionary *_attribLocations, *_uniformLocations;
    
}

#pragma mark -

@end

@implementation GLProgram
@synthesize name = _name;
@synthesize program = program;

+(NSMutableDictionary *)cache{

        
        static dispatch_once_t pred;
        static NSMutableDictionary *shared = nil;
        
        dispatch_once(&pred, ^{
            
            shared = [[NSMutableDictionary alloc] init];
            
            //[shared printEntityList];
        });
        return shared;

}

+(NSString *)nameforVS:(NSString *)vs fs:(NSString *)fs{

    NSString *name = [NSString stringWithFormat:@"%@_%@", [vs lastPathComponent], [fs lastPathComponent]];
    return name;
}
+(GLProgram *)cachedProgram:(NSString *)vfShaderName{

    return [GLProgram cachedProgramWithVertexShaderFilename:vfShaderName fragmentShaderFilename:vfShaderName];
}
+(GLProgram *)cachedProgramWithVertexShaderFilename:(NSString *)vShaderFilename
                             fragmentShaderFilename:(NSString *)fShaderFilename{


    NSString *name = [GLProgram nameforVS:vShaderFilename fs:fShaderFilename];
    GLProgram *program = [[GLProgram cache] valueForKey:name];
    
    if (!program) {
        program = [[GLProgram alloc] initWithVertexShaderFilename:vShaderFilename fragmentShaderFilename:fShaderFilename];
        [[GLProgram cache] setValue:program forKey:name];
    }
    
    return program;
}

-(id)init{
    
    NSAssert(NO, @"GLProgram default initialier not allowed - must use nitWithVertexShaderFilename:(NSString *)vShaderFilename \
             fragmentShaderFilename:(NSString *)fShaderFilename");
    
    return nil;
}


- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename 
            fragmentShaderFilename:(NSString *)fShaderFilename{
    
    if (self = [super init])
    {
        _attribLocations = [[NSMutableDictionary alloc] initWithCapacity:10];
        _uniformLocations = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        NSString *vertShaderPathname, *fragShaderPathname;
        program = glCreateProgram();
        
        vertShaderPathname = [[NSBundle mainBundle] 
                              pathForResource:vShaderFilename 
                              ofType:@"vsh"];
        
        fragShaderPathname = [[NSBundle mainBundle]
                              pathForResource:fShaderFilename
                              ofType:@"fsh"];
        
        _name = [GLProgram nameforVS:vShaderFilename fs:fShaderFilename];
        
        GLint status;
        const GLchar *source;
        
        
        // 1. Vertex shader:
        source = (GLchar *)[[NSString stringWithContentsOfFile:vertShaderPathname
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil] UTF8String];
        if (!source)
        {
            NSLog(@"Failed to load vertex shader");
            return NO;
        }
        //NSLog(@"Compiling source:\n%s", source);
        
        vertShader = glCreateShader(GL_VERTEX_SHADER);GL_ERROR_CHECK_DEBUG();
        glShaderSource(vertShader, 1, &source, NULL);
        glCompileShader(vertShader);
        
        glGetShaderiv(vertShader, GL_COMPILE_STATUS, &status);
        if (!status) {
            GLint infoLen = 0;
            glGetShaderiv(vertShader, GL_INFO_LOG_LENGTH, &infoLen);
            if (infoLen > 1) {
                char *infoLog = malloc(sizeof(char) * infoLen);
                glGetShaderInfoLog(vertShader, infoLen, NULL, infoLog);
                NSLog(@"Error compiling vertex shader: %s", infoLog);
                free(infoLog);
            }
        }
        
        
        // 2. Fragment shader:
        
        
        
        source = (GLchar *)[[NSString stringWithContentsOfFile:fragShaderPathname
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil] UTF8String];
        

        if (!source)
        {
            NSLog(@"Failed to load fragment shader");
            return NO;
        }
        //NSLog(@"Compiling source:\n%s", source);
        
        fragShader = glCreateShader(GL_FRAGMENT_SHADER);GL_ERROR_CHECK_DEBUG();
        glShaderSource(fragShader, 1, &source, NULL);
        glCompileShader(fragShader);
        
        glGetShaderiv(fragShader, GL_COMPILE_STATUS, &status);
        if (!status) {
            GLint infoLen = 0;
            glGetShaderiv(fragShader, GL_INFO_LOG_LENGTH, &infoLen);
            if (infoLen > 1) {
                char *infoLog = malloc(sizeof(char) * infoLen);
                glGetShaderInfoLog(fragShader, infoLen, NULL, infoLog);
                NSLog(@"Error compiling fragment shader: %s", infoLog);
                free(infoLog);
            }
        }
        
        
        // 3. Linking if compilation succeded:
        if (status == GL_TRUE) {
          
            
            glAttachShader(program, vertShader);
            glAttachShader(program, fragShader);
            
            // Link:
            
            glLinkProgram(program);
            glValidateProgram(program);
            
            glGetProgramiv(program, GL_LINK_STATUS, &status);
            if (status == GL_FALSE)
                return nil;
            
            if (vertShader)
                glDeleteShader(vertShader);
            if (fragShader)
                glDeleteShader(fragShader);
        }
    }
    
    return self;
}


#pragma mark -

- (GLint)attributeIndex:(NSString *)attributeName{
    
    NSNumber *iii = [_attribLocations valueForKey:attributeName];
    
    if (iii) {
        return [iii intValue];
    }
    
    GLint i = glGetAttribLocation(program, [attributeName UTF8String]);GL_ERROR_CHECK_DEBUG();

    [_attribLocations setValue:@(i) forKey:attributeName];
    return i;
    
}
- (GLint)uniformIndex:(NSString *)uniformName{
    
    NSNumber *iii = [_uniformLocations valueForKey:uniformName];
    
    if (iii) {
        return [iii intValue];
    }
    
    GLint i = glGetUniformLocation(program, [uniformName UTF8String]);GL_ERROR_CHECK_DEBUG();
    [_uniformLocations setValue:@(i) forKey:uniformName];
    return i;
    
}

#pragma mark -

- (void)use{
    glUseProgram(program);
}
- (void)link{

    glLinkProgram(program);
    
    [_attribLocations removeAllObjects];
    [_uniformLocations removeAllObjects];
}

#pragma mark -

- (void)dealloc{
   
    
    if (vertShader)
        glDeleteShader(vertShader);
    
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (program)
        glDeleteProgram(program);

}
@end
