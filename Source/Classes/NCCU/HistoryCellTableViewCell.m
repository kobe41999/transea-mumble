//
//  HistoryCellTableViewCell.m
//  Mumble
//
//  Created by HanChien Chun on 2016/8/24.
//
//

#import "HistoryCellTableViewCell.h"

@implementation HistoryCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_rating release];
    [_labelDuration release];
    [_labelExpert release];
    [_labelDate release];
    [super dealloc];
}
@end
