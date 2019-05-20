//
//  ACTUISafeNavigationController.h
//  iPadControls
//
//  Created by Ryan Manalo on 4/25/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ACTUISafeNavigationDelegate <NSObject>
@required
- (BOOL)navigationController:(UINavigationController *)navigationController
     shouldPopViewController:(UIViewController *)controller pop:(void(^)())pop;
@end


@interface ACTUISafeNavigationController : UINavigationController <UINavigationBarDelegate>
@property (weak, nonatomic) id<ACTUISafeNavigationDelegate> safeDelegate;

- (BOOL)navigationBar:(UINavigationBar *)navigationBar
        shouldPopItem:(UINavigationItem *)item;


@end
