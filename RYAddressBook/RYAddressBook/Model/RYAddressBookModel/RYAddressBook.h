//
//  RYAddressBook.h
//  RYAddressBook
//
//  Created by Robert on 15/4/21.
//  Copyright (c) 2015年 NationSky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RYPersonInfo.h"

typedef void (^AddressBookBlock) (NSArray *personInfos);

@interface RYAddressBook : NSObject

/**
 *  将数字转化为字母 0~26 1~25=a~z 26=#
 */
NSString* SpellFromIndex(int index);

/**
 *  获取索引
 */
int Index(NSString *firstSpell);
/**
 *  获取用户所有通讯录信息
 *
 *  @return 所有通讯录数据信息数组
 */
+ (void)getPersonInfo:(AddressBookBlock)addressBookBlock;

/**
 *  根据关键字匹配所有用户信息
 *
 *  @param keyWord 匹配关键字
 *
 *  @return 匹配到的通讯录数据信息数组
 */
+ (void)searchPersonInfo:(NSString *)keyWord addressBookBlock:(AddressBookBlock)addressBookBlock;

/**
 *  根据姓名进行数组的重排序
 *
 *  @param personInfos 获取的通讯录数据信息数组
 */
+ (NSArray *)sortPersonInfos:(NSArray *)personInfos;

@end
