//
//  GLPlotDynamic.h
//  Accel
//
//  Created by Lukasz Margielewski on 11/04/14.
//
//

#import "GLNode.h"
#import "GLSegment.h"

#define kGLPlotFileExtension @"glplot"
#define kGLPlotMaximumNameLenght                30
#define kGLPlotMaximumIdentifierStringLenght    50
#define kGLPlotMaximumTitleLenght               100
#define kGLPlotMaximumTextLenght                300
#define kGLPlotMaximumExtraInfoLenght           300
/**
 *  Plot class
 */
@interface GLPlot : GLNode

@property (nonatomic, readonly) NSString *filePath;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *identifier_string;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *extra_info;
@property (nonatomic) int lineMode;
@property (nonatomic) int tag;

/**
 *  Custom initializer which takes persistence file path as argument
 *
 *  @param filePath path to the location when data will be saved
 *
 *  @return initialized plot instance
 */
-(id)initWithFilePath:(NSString *)filePath;
-(id)initWithName:(NSString *)name;

-(void)clear;


/**
Adds new point to the end of he buffer (head)
Retunrs YES if added, no if buffer is full
*/
-(BOOL)addVector2D:(GLVector2D)vector2;

#pragma mark - Persistence:
/**
 *  Functions returns path to the defualt location where plots are stored
 *
 *  @return absolute path to the save / read directory. It is ready to save
 */
+(NSString *)defaultStorageDirectory;

-(void)save;
-(unsigned long long)unsavedBytes;

@end
