//
//  GLGraphPlotEditViewController.h
//  Accel
//
//  Created by Lukasz Margielewski on 19/08/14.
//
//

#import <UIKit/UIKit.h>
#import "ColorPickerViewController.h"
#import "GLPlot.h"

typedef enum GLPlotEditingSection{

    GLPlotEditingSectionMain = 0,
    GLPlotEditingSectionReadOnly,
    GLPlotEditingSectionText,
    GLPlotEditingSectionExtraOptionalInfo,
    
    GLPlotEditingSectionsCount      // make sure this entry is always last

}GLPlotEditingSection;

typedef enum GLPlotEditingSectionMainItems{
    
    GLPlotEditingSectionMainItemName = 0,
    GLPlotEditingSectionMainItemTitle,
    GLPlotEditingSectionMainItemTag,
    GLPlotEditingSectionMainItemColor,
    
    GLPlotEditingSectionMainItemsCount  // make sure this entry is always last
    
}GLPlotEditingSectionMainItems;

typedef enum GLPlotEditingSectionReadOnlyItems{
    
    GLPlotEditingSectionReadOnlyItemIdentifier = 0,
    GLPlotEditingSectionReadOnlyItemVerticesCount,
    
    GLPlotEditingSectionReadOnlyItemsCount  // make sure this entry is always last
    
}GLPlotEditingSectionReadOnlyItems;


@class GLGraphPlotEditViewController;

@protocol GLGraphPlotEditViewControllerDelegate <NSObject>

-(void)GLGraphPlotEditViewController:(GLGraphPlotEditViewController *)controller didSavePlot:(GLPlot *)plot;
-(void)GLGraphPlotEditViewController:(GLGraphPlotEditViewController *)controller didCreateNewPlot:(GLPlot *)plot;
-(void)GLGraphPlotEditViewController:(GLGraphPlotEditViewController *)controller willDeletePlot:(GLPlot *)plot;
-(void)GLGraphPlotEditViewController:(GLGraphPlotEditViewController *)controller didDeletePlot:(GLPlot *)plot;

-(void)GLGraphPlotEditViewControllerDidCancel:(GLGraphPlotEditViewController *)controller;

@end

@interface GLGraphPlotEditViewController : UITableViewController<UITextFieldDelegate, UITextViewDelegate, ColorPickerViewControllerDelegate>

@property (nonatomic, assign) id<GLGraphPlotEditViewControllerDelegate>delegate;
@property (nonatomic, strong) GLPlot *plot;

@end
