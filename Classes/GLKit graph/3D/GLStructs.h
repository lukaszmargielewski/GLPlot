//
//  GLStructs.h
//  Accel
//
//  Created by Lukasz Margielewski on 28/08/2014.
//
//


#ifndef Accel_GLStructs_h
#define Accel_GLStructs_h

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_EMBEDDED
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#else
#import <OpenGL/OpenGL.h>
#endif
#import "ConstantsAndMacros.h"

#pragma mark - 2D:

typedef struct GLVector2D{
    
    GLfloat x,y;
    
}GLVector2D;

static inline GLVector2D GLVector2DMake(GLfloat x, GLfloat y){
    
    GLVector2D vector;
    
    vector.x = x;
    vector.y = y;
    
    return vector;
}
typedef struct GLVector2DTextured{
    
    GLVector2D position;
    GLVector2D uv;
    
}GLVector2DTextured;

#pragma mark - 3D:

typedef struct GLVector3D{
    
    GLfloat x,y,z;
    
}GLVector3D;

static inline GLVector3D GLVector3DMake(GLfloat x, GLfloat y, GLfloat z){
    
    GLVector3D vector;
    
    vector.x = x;
    vector.y = y;
    vector.z = z;
    
    return vector;
}

#pragma mark - 4D:


typedef struct GLVector4D{
    
    GLfloat x,y,z,w;
    
}GLVector4D;

static inline GLVector4D GLVector4DMake(GLfloat x, GLfloat y, GLfloat z, GLfloat w){
    
    GLVector4D vector;
    
    vector.x = x;
    vector.y = y;
    vector.z = z;
    vector.w = w;
    
    return vector;
}

#endif
