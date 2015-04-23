//
//  RYTableViewCell.m
//  RYAddressBook
//
//  Created by Robert on 15/4/21.
//  Copyright (c) 2015年 NationSky. All rights reserved.
//

#import "RYTableViewCell.h"

@interface RYTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *phoneNumber;

@end

static const int GAP = 10;

@implementation RYTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialUI];
    }
    return self;
}

- (void)initialUI {
    self.nameLabel = [[UILabel alloc] init];
    [self addSubview:self.nameLabel];
    self.phoneNumber = [[UILabel alloc] init];
    [self addSubview:self.phoneNumber];
    [self addConstraint];
}

- (void)addConstraint {
    WEAK_SELF(weakSelf);
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.mas_left).offset(2*GAP);
        make.right.mas_equalTo(weakSelf.phoneNumber.mas_left).offset(-3*GAP);
        make.height.mas_equalTo(@(self.frame.size.height/2));
        make.centerY.mas_equalTo(weakSelf.mas_centerY);
    }];
    
    [self.phoneNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.nameLabel.mas_right).offset(3*GAP);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-2*GAP);
        make.height.mas_equalTo(weakSelf.nameLabel.mas_height);
        make.centerY.mas_equalTo(weakSelf.nameLabel.mas_centerY);
    }];
}

- (void)configureForInfo:(RYAddressBookModel *)info {
    self.nameLabel.text = info.username;
    self.phoneNumber.text = info.photoNumber;
}

@end
