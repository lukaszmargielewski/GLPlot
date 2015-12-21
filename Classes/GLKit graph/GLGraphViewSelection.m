//
//  GLGraphViewSelection.m
//  Accel
//
//  Created by Lukasz Margielewski on 17/08/14.
//
//

#import "GLGraphViewSelection.h"

@implementation GLGraphViewSelection


#pragma mark - NSCoding:


/*
 
 @property (nonatomic)           unsigned long selectionId;
 @property (nonatomic, strong)   NSString *name;
 @property (nonatomic)           GLGraphViewSelectionType type;
 
 @property (nonatomic)           CGSize size;
 */


#define kNameKey        @"name"
#define kMachineNameKey @"machine_name"
#define kTypeKey        @"type"

#define kIdKey         @"selectionId"
#define kSizeKey       @"size"
#define kColorKey      @"color"

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:_name forKey:kNameKey];
    [encoder encodeObject:_machine_name forKey:kMachineNameKey];
    [encoder encodeObject:_color forKey:kColorKey];
    [encoder encodeObject:_selectionId forKey:kIdKey];
    
    [encoder encodeInt:_type forKey:kTypeKey];
    [encoder encodeCGSize:_size forKey:kSizeKey];
    
    
}
-(id)init{

    self = [super init];
    
    if (self) {
        _color = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    
    
    self =  [super init];
    
    if (self) {
    
        self.name           = [decoder decodeObjectForKey:kNameKey];
        self.machine_name   = [decoder decodeObjectForKey:kMachineNameKey];
        self.type           = [decoder decodeIntForKey:kTypeKey];
        self.selectionId    = [decoder decodeObjectForKey:kIdKey];
        self.size           = [decoder decodeCGSizeForKey:kSizeKey];
        self.color          = [decoder decodeObjectForKey:kColorKey];

        if (!_color) {
            _color = [UIColor blackColor];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    GLGraphViewSelection * copy = [[GLGraphViewSelection alloc] init];
    
    if (copy) {
        
        // Copy NSObject subclasses
        copy.name           = [self.name copy];
        
        copy.machine_name   = [self.machine_name copy];
        copy.selectionId    = [self.selectionId copy];
        copy.color          = [self.color copy];
        
        // Copy ivars (simple):
        copy.size = self.size;
        copy.type = self.type;
        
    }
    
    return copy;
}
@end
