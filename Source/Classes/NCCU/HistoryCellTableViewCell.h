//
//  HistoryCellTableViewCell.h
//  Mumble
//
//  Created by HanChien Chun on 2016/8/24.
//
//

#import "HCSStarRatingView.h"
#import <UIKit/UIKit.h>

@interface HistoryCellTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet HCSStarRatingView *rating;
@property (retain, nonatomic) IBOutlet UILabel *labelDuration;
@property (retain, nonatomic) IBOutlet UILabel *labelExpert;
@property (retain, nonatomic) IBOutlet UILabel *labelDate;


@end
