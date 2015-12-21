//
//  GLGraphViewSelection.h
//  Accel
//
//  Created by Lukasz Margielewski on 17/08/14.
//
//

#import <Foundation/Foundation.h>

typedef enum GLGraphViewSelectionType{

    GLGraphViewSelectionTypeStandard = 0,
    GLGraphViewSelectionTypeWidthOnly,
    GLGraphViewSelectionTypesCount
    
}GLGraphViewSelectionType;

static NSString *NSStringFromGLGraphViewSelectionType(GLGraphViewSelectionType type){

    NSString *string = @"Unknown";
    
    switch (type) {
        case GLGraphViewSelectionTypeStandard:
            string = @"Standard";
            break;
        case GLGraphViewSelectionTypeWidthOnly:
            string = @"Width Only";
            break;
        default:
            break;
    }
    return string;
}

@interface GLGraphViewSelection : NSObject<NSCoding, NSCopying>

@property (nonatomic)           NSNumber *selectionId;
@property (nonatomic, strong)   NSString *name;
@property (nonatomic, strong)   NSString *machine_name;
@property (nonatomic)           GLGraphViewSelectionType type;
@property (nonatomic, strong)   UIColor *color;
@property (nonatomic)           CGSize size;

@end
