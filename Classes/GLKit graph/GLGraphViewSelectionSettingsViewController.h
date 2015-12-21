//
//  GLGraphViewSelectionSettingsViewControllerViewController.h
//  Accel
//
//  Created by Lukasz Margielewski on 17/08/14.
//
//

#import <UIKit/UIKit.h>
#import "GLGraphViewSelection.h"
#import "GLGraphSelectionEditViewController.h"

@class GLGraphViewSelectionSettingsViewController;

@protocol GLGraphViewSelectionSettingsViewControllerDelegate <NSObject>

-(void)GLGraphViewSelectionSettingsViewControllerViewControllerDiDCancel:(GLGraphViewSelectionSettingsViewController *)controller;
-(void)GLGraphViewSelectionSettingsViewControllerViewController:(GLGraphViewSelectionSettingsViewController *)controller didFinishWithSelection:(GLGraphViewSelection *)selection;

@end
@interface GLGraphViewSelectionSettingsViewController : UITableViewController<GLGraphSelectionEditViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) GLGraphViewSelection *selection;
@property (nonatomic, assign) id<GLGraphViewSelectionSettingsViewControllerDelegate>delegate;

@property (nonatomic, readonly, strong) NSString *selectionsPath;

+(GLGraphViewSelection *)defaultSelection;
@end
