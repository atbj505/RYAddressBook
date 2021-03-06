//
//  RYAddressBook.m
//  RYAddressBook
//
//  Created by Robert on 15/4/21.
//  Copyright (c) 2015年 NationSky. All rights reserved.
//

#import "RYAddressBook.h"


@interface RYAddressBook ()

@property (nonatomic, copy) AddressBookBlock addressBookBlock;

@end

@implementation RYAddressBook

NSString* SpellFromIndex(int index)
{
    if (index == 26)
        return @"#";
    else
        return [NSString stringWithFormat:@"%c", [@"A" characterAtIndex:0]+index];
}

int Index(NSString *firstSpell)
{
    int i = [firstSpell characterAtIndex:0] - [@"a" characterAtIndex:0];
    
    if ([firstSpell isEqualToString:@"#"] || i < 0 || i > 26) {
        return 26;
    }
    
    return [firstSpell characterAtIndex:0] - [@"a" characterAtIndex:0];
}

/**
 *  获取用户所有通讯录信息
 */
+ (void)getPersonInfo:(AddressBookBlock)addressBookBlock
{
    [[self alloc] getPersonInfo:addressBookBlock];
}

/**
 *  根据关键字匹配所有用户信息
 */
+ (void)searchPersonInfo:(NSString *)keyWord addressBookBlock:(AddressBookBlock)addressBookBlock
{
    [[self alloc] searchPersonInfo:keyWord addressBookBlock:addressBookBlock];
}

/**
 *  根据姓名进行数组的重排序
 */
+ (NSArray *)sortPersonInfos:(NSArray *)personInfos
{
    return [[self alloc] sortPersonInfos:personInfos];
}

- (void)getPersonInfo:(AddressBookBlock)addressBookBlock
{
    self.addressBookBlock = addressBookBlock;
    [self searchPersonInfo:@""];
}

- (void)searchPersonInfo:(NSString *)keyWord addressBookBlock:(AddressBookBlock)addressBookBlock
{
    self.addressBookBlock = addressBookBlock;
    [self searchPersonInfo:keyWord];
}

- (NSArray *)sortPersonInfos:(NSArray *)personInfos
{
    if (![personInfos isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (int i = 0; i < 27; i++) {
        [arr addObject:[NSMutableArray array]];
    }
    
    for (NSObject *obj in personInfos) {
        
        if (![obj isKindOfClass:[RYPersonInfo class]]) {
            continue;
        }
        
        RYPersonInfo *personInfo = (RYPersonInfo *)obj;
        
        NSMutableArray *subArr = [arr objectAtIndex:Index(personInfo.firstSpell)];
        [subArr addObject:personInfo];
    }
    
    return arr;
}

/**
 *  根据关键字查询通讯录信息
 */
- (void)searchPersonInfo:(NSString *)keyWord
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    // 开始查询通讯录
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
        if (granted) {
            [self filterContentForSearchText:keyWord];
        }
    });
}

/**
 *  开始匹配通讯录信息
 */
- (void)filterContentForSearchText:(NSString*)searchText
{
    //如果没有授权则退出
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
        return;
    }
    
    NSArray *blockArray = [NSArray array];
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if([searchText length]==0)
    {
        //查询所有
        blockArray = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
    } else {
        
        //条件查询
        CFStringRef cfSearchText = (CFStringRef)CFBridgingRetain(searchText);
        blockArray = CFBridgingRelease(ABAddressBookCopyPeopleWithName(addressBook, cfSearchText));
        
        CFRelease(cfSearchText);
    }
    
    // 类型转换
    blockArray = transformElements(blockArray);
    
    // 返回BlockArray
    self.addressBookBlock(blockArray);
}

/**
 *  将所有元素转化为JXPersonInfo类型数组
 */
NSArray* transformElements(NSArray* arr)
{
    NSMutableArray *rtnArray = [NSMutableArray array];
    for (int i = 0; i < arr.count; i++) {
        ABRecordRef recordRef = CFBridgingRetain([arr objectAtIndex:i]);
        RYPersonInfo *personInfo = [RYPersonInfo personInfoWithABRecordRef:recordRef];
        
        [rtnArray addObject:personInfo];
    }
    return rtnArray;
}
@end
