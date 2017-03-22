//
//  TransCell.h
//  Mumble
//
//  Created by HanChien Chun on 2016/8/15.
//
//

#import <UIKit/UIKit.h>

@interface TransCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *labelUserName;
@property (retain, nonatomic) IBOutlet UIImageView *imageUser;
@property (retain, nonatomic) IBOutlet UILabel *price;

@end
