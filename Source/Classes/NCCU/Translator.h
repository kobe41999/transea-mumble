//
//  Translator.h
//  Mumble
//
//  Created by HanChien Chun on 2016/8/15.
//
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

@interface Translator : NSObject

@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) NSNumber *rating;
@property (retain, nonatomic) NSString *userIcon;
@property (retain, nonatomic) NSNumber *price;

@end
