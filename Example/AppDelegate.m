//
//  iGutAppDelegate.m
//  iGut
//
//  Created by Lukasz Margielewski on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "GLPlotExampleViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    
    // Override point for customization after application launch.
    //1. Main  window:
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIWindow *w = [[UIWindow alloc] initWithFrame:bounds];
    self.window = w;
    
    UIViewController *rootViewController = [[GLPlotExampleViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    navigationController.wantsFullScreenLayout = NO;
    navigationController.navigationBar.opaque = YES;
    
    self.window.rootViewController  = navigationController;
    [self.window makeKeyAndVisible];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {
    

}


@end
