//
//  UITextFieldCell.m
//  Accel
//
//  Created by Lukasz Margielewski on 19/08/14.
//
//

#import "UITextViewCell.h"

@implementation UITextViewCell

@synthesize textView = _textView;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _textView = [[UITextView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_textView];
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
    _textView.frame = f;
}
@end
