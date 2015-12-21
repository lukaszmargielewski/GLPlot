//
//  GLGraphSelectionEditViewController.h
//  Accel
//
//  Created by Lukasz Margielewski on 19/08/14.
//
//

#import <UIKit/UIKit.h>
#import "ColorPickerViewController.h"

@class GLGraphSelectionEditViewController;
@class GLGraphViewSelection;

@protocol GLGraphSelectionEditViewControllerDelegate <NSObject>

-(void)GLGraphSelectionEditViewController:(GLGraphSelectionEditViewController *)controller didSaveSelection:(GLGraphViewSelection *)selection;
-(void)GLGraphSelectionEditViewControllerDidCancel:(GLGraphSelectionEditViewController *)controller;

@end

@interface GLGraphSelectionEditViewController : UITableViewController<UITextFieldDelegate, ColorPickerViewControllerDelegate>

@property (nonatomic, assign) id<GLGraphSelectionEditViewControllerDelegate>delegate;
@property (nonatomic, copy) GLGraphViewSelection *selection;

@end
