//
//  AppDelegate.h
//  Mumble
//
//  Created by HanChien Chun on 2016/7/26.
//
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property BOOL connectionActive;

@property NSString *currentRequestUser;
@property NSString *currentExpert;
@property double currentCallDuration;

@end
