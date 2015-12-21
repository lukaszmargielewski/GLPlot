//
//  GLGraphViewController.h
//  FF
//
//  Created by Lukasz Margielewski on 08/04/14.
//
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import "GLGraphViewSelectionSettingsViewController.h"
#import "GLGraph.h"



typedef enum GLGraphViewControllerMode{

    GLGraphViewControllerModeDefault = 0,
    GLGraphViewControllerModeSelection
    
}GLGraphViewControllerMode;

@class GLGraphViewController;

@protocol GLGraphViewControllerDelegate <NSObject>

-(void)GLGraphViewControllerWantsToClose:(GLGraphViewController *)controller;

@end

@interface GLGraphViewController : GLKViewController<GLKViewControllerDelegate, GLGraphDataSource, UIPopoverControllerDelegate, GLGraphViewSelectionSettingsViewControllerDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>{

    GLGraph *graph;
}


@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic) GLGraphViewControllerMode mode;

@property (nonatomic, assign) id<GLGraphViewControllerDelegate>navigationDelegate;
@property (nonatomic, strong) GLGraphViewSelection *selection;

// Override this in subclasses:
-(void)configurePlots;
-(void)clearPlotsConfirmed;

@end
