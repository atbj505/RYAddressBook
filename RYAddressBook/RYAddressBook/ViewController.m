//
//  ViewController.m
//  RYAddressBook
//
//  Created by Robert on 15/4/21.
//  Copyright (c) 2015年 NationSky. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "THContactView.h"
#import "RYAddressBook.h"
#import "RYAddressBookModel.h"
#import "TableViewDataSource.h"
#import "RYTableViewCell.h"

static NSString * const CellIdentifier = @"identifier";

@interface ViewController ()<UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TableViewDataSource *dataSource;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
    [self refreshPersonInfoTableView];
}
- (void)initial {
    self.dataArray = [NSMutableArray array];
    self.tableView = [[UITableView alloc] init];
    [self.tableView registerClass:[RYTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.tableView];
    
    WEAK_SELF(weakSelf);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.view);
    }];
}
- (void)refreshPersonInfoTableView {
    TableViewCellConfigureBlock configBlock = ^(RYTableViewCell *cell, RYAddressBookModel *model) {
        [cell configureForInfo:model];
    };
    [RYAddressBook getPersonInfo:^(NSArray *personInfos) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 对获取数据进行排序
            NSArray *result = [RYAddressBook sortPersonInfos:personInfos];
            for (NSArray *subArr in result) {
                
                NSArray *arr = [self transitionFromPersonInfos:subArr];
                
                [_dataArray addObject:arr];
            }
            NSLog(@"%@",_dataArray);
            self.dataSource = [[TableViewDataSource alloc] initWithItems:_dataArray cellIdentifier:CellIdentifier configureCellBlock:configBlock];
            self.tableView.dataSource = self.dataSource;
            [self.tableView reloadData];
        });
    }];
}
- (NSArray *)transitionFromPersonInfos:(NSArray *)personInfos
{
    NSMutableArray *arr = [NSMutableArray array];
    
    for (RYPersonInfo *info in personInfos) {
        
        for (NSDictionary *dict in info.phone) {
            
            for (NSString *number in dict.allValues) {
                RYAddressBookModel *model = [[RYAddressBookModel alloc] init];
                model.username = info.fullName;
                model.photoNumber = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
                [arr addObject:model];
            }
        }
    }
    
    return arr;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
@end
