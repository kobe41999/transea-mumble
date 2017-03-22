//
//  MainVC.h
//  Mumble
//
//  Created by HanChien Chun on 2016/7/26.
//
//

#import <UIKit/UIKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "DebugKit.h"
#import "PFQuery.h"

@interface MainVC : UIViewController

@property BOOL started;

// Tab with container
@property (strong,nonatomic) UIViewController *destinationViewController;
@property (strong, nonatomic) UIViewController *oldViewController;


@end
