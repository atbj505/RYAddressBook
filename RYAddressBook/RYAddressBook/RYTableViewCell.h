//
//  RYTableViewCell.h
//  RYAddressBook
//
//  Created by Robert on 15/4/21.
//  Copyright (c) 2015年 NationSky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYAddressBookModel.h"

@interface RYTableViewCell : UITableViewCell

- (void)configureForInfo:(RYAddressBookModel *)info;
@end
