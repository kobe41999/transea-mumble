//
//  TransCell.m
//  Mumble
//
//  Created by HanChien Chun on 2016/8/15.
//
//

#import "TransCell.h"

@implementation TransCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_labelUserName release];
    [_imageUser release];
    [_price release];
    [super dealloc];
}
@end
