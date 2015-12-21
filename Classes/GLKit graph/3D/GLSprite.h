//
//  GLSprite.h
//  Accel
//
//  Created by Lukasz Margielewski on 14/04/14.
//
//

#import "GLNode.h"
#import "GLTexture.h"

typedef enum GLContentMode{

    GLContentModeTopLeft    = 0,
    GLContentModeTop,
    GLContentModeTopRight,

    GLContentModeCenterLeft,
    GLContentModeCenter,
    GLContentModeCenterRight,
    
    GLContentModeBottomLeft,
    GLContentModeBottom,
    GLContentModeBottomRight,
    
    GLContentModeScaleAspectFit,
    GLContentModeScaleAspectFill,
    GLContentModeScaleToFill,
    

}GLContentMode;

@interface GLSprite : GLNode

@property (nonatomic) CGRect frame;
@property (nonatomic) GLfloat borderWidth;
@property (nonatomic) GLVector4D borderColor;

@property (nonatomic) GLContentMode contentMode;
@property (nonatomic, readonly) GLTexture *texture;

-(id)initWithImageRef:(CGImageRef)imageRef;
+(GLSprite *)spriteWithImageRef:(CGImageRef)imageRef;

-(id)initWithTexture:(GLTexture *)texture;
+(GLSprite *)spriteWithTexture:(GLTexture *)texture;


@end
