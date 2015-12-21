//
//  OpenGLTexture3D.h
//  NeHe Lesson 06
//
//  Created by Jeff LaMarche on 12/24/08.
//  Copyright 2008 Jeff LaMarche Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLStructs.h"


@interface GLTexture : NSObject {
    
	  
	NSString	*filename;
}
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, retain) NSString *filename;

@property (nonatomic, readonly) GLuint texture;

- (GLTexture *)textureWithFilename:(NSString *)inFilename;
- (id)initWithCGImageRef:(CGImageRef)imageRef;

+(GLTexture *)textureWithString:(NSString *)string font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment availableWidth:(CGFloat)width relativePadding:(UIEdgeInsets)relativePadding;

-(id)initWithString:(NSString *)string font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment availableWidth:(CGFloat)width relativePadding:(UIEdgeInsets)relativePadding;


@end
