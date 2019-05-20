//
//  ACTUISafeNavigationController.m
//  iPadControls
//
//  Created by Ryan Manalo on 4/25/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import "ACTUISafeNavigationController.h"

@interface ACTUISafeNavigationController ()

@end

@implementation ACTUISafeNavigationController

-(UIViewController *)popViewControllerAnimatedSUPER:(BOOL)animated{
    
    return [super popViewControllerAnimated:animated];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated{
    
    if (self.safeDelegate && ![self.safeDelegate navigationController:self
                                             shouldPopViewController:[self.viewControllers lastObject]
                                                                 pop:^{ [super popViewControllerAnimated:animated]; } ]){
        return nil;
    }
    
    return [super popViewControllerAnimated:animated];
}
-(NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
    
    if (self.safeDelegate && ![self.safeDelegate navigationController:self
                                             shouldPopViewController:[self.viewControllers lastObject]
                                                                 pop:^{ [super popToRootViewControllerAnimated:animated]; }]){
        return nil;
    }
    
    return [super popToRootViewControllerAnimated:animated];
}

-(NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (self.safeDelegate && ![self.safeDelegate navigationController:self
                                             shouldPopViewController:[self.viewControllers lastObject]
                                                                 pop:^{ [super popToViewController:viewController animated:animated]; }])
    {
        return nil;
    }
    
    return [super popToViewController:viewController animated:animated];
}

-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    
    if (item == [[self.viewControllers lastObject] navigationItem]){
        
        [self popViewControllerAnimated:YES];
        return NO;
        
    }
    
    return YES;
}


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
    
    }
    return self;
}


-(void)viewDidLoad{
    
    [super viewDidLoad];
}


-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];

}


@end
