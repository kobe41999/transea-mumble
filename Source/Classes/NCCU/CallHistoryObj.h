//
//  CallHistoryObj.h
//  Mumble
//
//  Created by HanChien Chun on 2016/8/24.
//
//

#import <Realm/Realm.h>

@interface CallHistoryObj : NSObject

@property (retain, nonatomic) NSString *expert;
@property (retain, nonatomic) NSDate *date;
@property (retain, nonatomic) NSNumber *rating;
@property (retain, nonatomic) NSNumber *duration;

@end
