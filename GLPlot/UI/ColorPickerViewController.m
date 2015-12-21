//
//  ColorPickerViewController.m
//  Accel
//
//  Created by Lukasz Margielewski on 22/08/14.
//
//

#import "ColorPickerViewController.h"
#import "HRColorPickerView.h"

@interface ColorPickerViewController ()

@end

@implementation ColorPickerViewController{

    HRColorPickerView *_colorPickerView;
    
}

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _colorPickerView = [[HRColorPickerView alloc] init];
    _colorPickerView.color = _color;

    [self.view addSubview:_colorPickerView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _colorPickerView.frame = (CGRect) {.origin = CGPointZero, .size = self.view.frame.size};
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        CGRect frame = _colorPickerView.frame;
        frame.origin.y = self.topLayoutGuide.length;
        frame.size.height -= self.topLayoutGuide.length;
        _colorPickerView.frame = frame;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *bbiSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    
    self.navigationItem.rightBarButtonItem = bbiSave;
    
    if (_needsCancelButton) {

        UIBarButtonItem *bbiCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = bbiCancel;

    }
    
    self.title = @"Choose color:";
    
}
-(IBAction)save:(id)sender{

    [_delegate ColorPickerViewController:self didFinishWithColor:_colorPickerView.color];
}
-(IBAction)cancel:(id)sender{

    [_delegate ColorPickerViewControllerDidCancel:self];
}
-(void)colorChanged:(HRColorPickerView *)pickerView{

    self.color = pickerView.color;
    
}

@end
