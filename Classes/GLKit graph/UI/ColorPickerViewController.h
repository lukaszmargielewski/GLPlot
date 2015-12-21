//
//  ColorPickerViewController.h
//  Accel
//
//  Created by Lukasz Margielewski on 22/08/14.
//
//

#import <UIKit/UIKit.h>

@class ColorPickerViewController;

@protocol ColorPickerViewControllerDelegate <NSObject>

-(void)ColorPickerViewController:(ColorPickerViewController *)controller didFinishWithColor:(UIColor *)color;
-(void)ColorPickerViewControllerDidCancel:(ColorPickerViewController *)controller;

@end

@interface ColorPickerViewController : UIViewController

@property (nonatomic, assign) id<ColorPickerViewControllerDelegate>delegate;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic) BOOL needsCancelButton;

@end
