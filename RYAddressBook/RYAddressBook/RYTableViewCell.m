//
//  RYTableViewCell.m
//  RYAddressBook
//
//  Created by Robert on 15/4/21.
//  Copyright (c) 2015年 NationSky. All rights reserved.
//

#import "RYTableViewCell.h"

@implementation RYTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)configureForInfo:(RYAddressBookModel *)info {
    self.textLabel.text = info.username;
    self.detailTextLabel.text = info.photoNumber;
}
@end
