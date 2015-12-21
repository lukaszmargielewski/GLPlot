//
//  UITextFieldCell.m
//  Accel
//
//  Created by Lukasz Margielewski on 19/08/14.
//
//

#import "UITextFieldCell.h"

@implementation UITextFieldCell
@synthesize textField = _textField;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _textField = [[UITextField alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_textField];
    }
    return self;
}

-(void)layoutSubviews{

    [super layoutSubviews];
    [self.textLabel sizeToFit];
    
    //CGRect tf = self.textLabel.frame;
    
    CGRect f = self.contentView.bounds;
    f.origin.x = 5;//CGRectGetMaxX(tf) + 5;
    f.size.width -= 10;//CGRectGetWidth(f) - CGRectGetMinX(f) - 10;
    self.textField.frame = f;
}
@end
