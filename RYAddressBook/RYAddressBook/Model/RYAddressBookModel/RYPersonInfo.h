//
//  RYPersonInfo.h
//  RYAddressBook
//
//  Created by Robert on 15/4/21.
//  Copyright (c) 2015年 NationSky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface RYPersonInfo : NSObject

/**
 *  单值信息
 */
#define PROPERTY_STR_READONLY(name) @property (nonatomic, copy) NSString *name;
// 姓
PROPERTY_STR_READONLY(firstName)
// 名
PROPERTY_STR_READONLY(lastName)
// 中间名
PROPERTY_STR_READONLY(middlename)
// 全名
PROPERTY_STR_READONLY(fullName)
// 搜索索引
PROPERTY_STR_READONLY(firstSpell)
// 前缀
PROPERTY_STR_READONLY(prefix)
// 后缀
PROPERTY_STR_READONLY(suffix)
// 昵称
PROPERTY_STR_READONLY(nickname)
// 姓_音标
PROPERTY_STR_READONLY(firstnamePhonetic)
// 名_音标
PROPERTY_STR_READONLY(lastnamePhonetic)
// 中间名_音标
PROPERTY_STR_READONLY(middlenamePhonetic)
// 公司
PROPERTY_STR_READONLY(organization)
// 工作
PROPERTY_STR_READONLY(jobtitle)
// 部门
PROPERTY_STR_READONLY(department)
// 生日
PROPERTY_STR_READONLY(birthday)
// 备忘录
PROPERTY_STR_READONLY(note)
// 第一次创建用户信息的时间
PROPERTY_STR_READONLY(firstknow)
// 最后一次更改用户信息的时间
PROPERTY_STR_READONLY(lastknow)
// 名片类型(company/person)
PROPERTY_STR_READONLY(kind)

// 多值信息
#define PROPERTY_ARR_READONLY(name) @property (nonatomic, strong) NSArray *name;
// 邮箱
PROPERTY_ARR_READONLY(email)
// 地址
PROPERTY_ARR_READONLY(address)
// 日期
PROPERTY_ARR_READONLY(dates)
// iMessage
PROPERTY_ARR_READONLY(iMessage)
// 电话号码
PROPERTY_ARR_READONLY(phone)
// URL链接
PROPERTY_ARR_READONLY(url)

#define PROPERTY_IMG_READONLY(name) @property (nonatomic, strong) UIImage *name;
// 图片
PROPERTY_IMG_READONLY(image)


/**
 *  初始化方法
 *
 *  @param ref 联系人属性
 *
 *  @return 实例对象
 */
- (id)initWithABRecordRef:(ABRecordRef)ref;

/**
 *  初始化类方法
 *
 *  @param ref 联系人属性
 *
 *  @return 实例对象
 */
+ (id)personInfoWithABRecordRef:(ABRecordRef)ref;

@end
