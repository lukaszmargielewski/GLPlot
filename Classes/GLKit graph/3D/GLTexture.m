//
//  OpenGLTexture3D.m
//  NeHe Lesson 06
//
//  Created by Jeff LaMarche on 12/24/08.
//  Copyright 2008 Jeff LaMarche Consulting. All rights reserved.
//

#import "GLTexture.h"

@implementation GLTexture
@synthesize filename;
@synthesize texture = _texture;
@synthesize size = _size;

+(CGContextRef)createBitmapContextForSize:(CGSize)size colorSpace:(CGColorSpaceRef)colorSpace textureData:(GLubyte **)textureData{

    *textureData = (GLubyte *)malloc(size.width * size.height * 4);

    BOOL cccr = NO;
    if (colorSpace == NULL) {
        cccr = YES;
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }

    CGContextRef textureContext = CGBitmapContextCreate(*textureData, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedLast);

    CGContextClearRect(textureContext, CGRectMake(0, 0, size.width, size.height));
    
    if (cccr) {
        CGColorSpaceRelease(colorSpace);
    }
    return textureContext;
}
-(id)initWithCGImageRef:(CGImageRef)imageRef{

    if (self = [super init]) {
        
        _size = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
        
        GLubyte *textureData;
        
        CGContextRef textureContext = [GLTexture createBitmapContextForSize:_size colorSpace:CGImageGetColorSpace(imageRef) textureData:&textureData];
    
        CGContextSetBlendMode(textureContext, kCGBlendModeCopy);
        CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)_size.width, (float)_size.height), imageRef);
        CGContextRelease(textureContext);
        
        [self initGLTextureWithData:textureData];
        
        
        free(textureData);
        free(imageRef);
    }
    
    return self;
}
-(void)initGLTextureWithData:(GLubyte *)textureData{

    glGenTextures(1, &_texture);GL_ERROR_CHECK_DEBUG();
    glBindTexture(GL_TEXTURE_2D, _texture);GL_ERROR_CHECK_DEBUG();
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);GL_ERROR_CHECK_DEBUG();
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);GL_ERROR_CHECK_DEBUG();
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);GL_ERROR_CHECK_DEBUG();
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);GL_ERROR_CHECK_DEBUG();
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _size.width, _size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);GL_ERROR_CHECK_DEBUG();
    
    glEnable(GL_BLEND);GL_ERROR_CHECK_DEBUG();
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);GL_ERROR_CHECK_DEBUG();
}
- (GLTexture *)textureWithFilename:(NSString *)inFilename
{
		self.filename = inFilename;
        
        NSString *extension = [filename pathExtension];
		NSString *baseFilenameWithExtension = [filename lastPathComponent];
		NSString *baseFilename = [baseFilenameWithExtension substringToIndex:[baseFilenameWithExtension length] - [extension length] - 1];
        
		NSString *path = [[NSBundle mainBundle] pathForResource:baseFilename ofType:extension];
		NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
		
        
        UIImage *image = [[UIImage alloc] initWithData:texData];
        if (image == nil)
            return nil;

    
	return [[GLTexture alloc] initWithCGImageRef:image.CGImage];
}
+(GLTexture *)textureWithString:(NSString *)string font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment availableWidth:(CGFloat)width relativePadding:(UIEdgeInsets)relativePadding{

    return [[GLTexture alloc] initWithString:string font:font textColor:textColor backgroundColor:backgroundColor lineBreakMode:lineBreakMode textAlignment:textAlignment availableWidth:width relativePadding:relativePadding];
}
-(id)initWithString:(NSString *)string font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment availableWidth:(CGFloat)width relativePadding:(UIEdgeInsets)relativePadding{

    if (self = [super init]) {
        
        if (width <= 0) {
            width = MAXFLOAT;
        }
        
        CGSize availableSize = CGSizeMake(width, MAXFLOAT);
        
        CGSize s = [string sizeWithFont:font constrainedToSize:availableSize lineBreakMode:lineBreakMode];
        _size.width = s.width * (1 + relativePadding.left + relativePadding.right);
        _size.height = s.height * (1 + relativePadding.top + relativePadding.bottom);
        
        _size.width = ceilf(_size.width);
        _size.height = ceilf(_size.height);
        
        CGFloat x = relativePadding.left * _size.width;
        CGFloat y = relativePadding.top * _size.height;
        
        CGRect rect = CGRectMake(0, 0, _size.width, _size.height);
        CGRect rectText = CGRectMake(x, y, s.width, s.height);
        GLubyte *textureData;
        
        CGContextRef textureContext = [GLTexture createBitmapContextForSize:_size colorSpace:NULL textureData:&textureData];
        
        CGContextTranslateCTM(textureContext, 0, _size.height);
        CGContextScaleCTM(textureContext, 1.0, -1.0);
        
        UIGraphicsPushContext(textureContext);
        CGContextSetFillColorWithColor(textureContext, backgroundColor.CGColor);
        CGContextFillRect(textureContext, rect);
        CGContextSetFillColorWithColor(textureContext, textColor.CGColor);
        [string drawInRect:rectText withFont:font lineBreakMode:lineBreakMode alignment:textAlignment];
        UIGraphicsPopContext();
        //CGContextShowTextAtPoint (textureContext, 0, 0, [string cStringUsingEncoding:NSUTF8StringEncoding], string.length);
        CGContextRelease(textureContext);
        
        [self initGLTextureWithData:textureData];
        free(textureData);
        
    }
    
    return self;
    
}
- (void)dealloc
{
	glDeleteTextures(1, &_texture);

}
@end
