//
//  ViewController.m
//  RYAddressBook
//
//  Created by Robert on 15/4/21.
//  Copyright (c) 2015年 NationSky. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"

#import "THContactPickerView.h"
#import "RYAddressBook.h"
#import "RYAddressBookModel.h"
#import "RYTableViewCell.h"

static NSString * const CellIdentifier = @"identifier";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, THContactPickerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NSArray *currentArray;
@property (nonatomic, strong) NSMutableArray *selectArray;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) THContactPickerView *contactPickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)initial {
    //通讯录数据
    self.dataArray = [NSMutableArray array];
    //检索结果数据
    self.searchArray = [NSMutableArray array];
    //选择数据
    self.selectArray = [NSMutableArray array];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    
    [self addTableView];
    [self createContactPickerView];
    [self refreshPersonInfoTableView];
}

/**
 *  添加tableView
 */
- (void)addTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _contactPickerView.frame.size.height+_contactPickerView.frame.origin.y, ScreenWidth, ScreenHeight - (_contactPickerView.frame.size.height+_contactPickerView.frame.origin.y)) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    [_tableView registerClass:[RYTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:_tableView];
}

/**
 *  添加searchBar（被THContactPickerView取代）
 */
- (void)addsearchBar {
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    _searchBar.delegate = self;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    [_searchBar setBarTintColor:[UIColor clearColor]];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [v addSubview:_searchBar];
    _tableView.tableHeaderView = v;
    
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
}

/**
 *  添加THContactPickerView
 */
- (void)createContactPickerView
{
    _contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 25)];
    _contactPickerView.delegate = self;
    [_contactPickerView setPlaceholderString:@"点击搜索联系人"];
    [self.view addSubview:_contactPickerView];
}

/**
 *  获取通讯录数据
 */
- (void)refreshPersonInfoTableView {
    [RYAddressBook getPersonInfo:^(NSArray *personInfos) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 对获取数据进行排序
            NSArray *result = [RYAddressBook sortPersonInfos:personInfos];
            for (NSArray *subArr in result) {
                //数据转化为model对象
                NSArray *arr = [self transitionFromPersonInfos:subArr];
                
                [_dataArray addObject:arr];
                _currentArray = _dataArray;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }];
}

/**
 *  获取搜索结果数据
 */
- (void)refreshSearchTableView:(NSString *)searchText {
    [_searchArray removeAllObjects];
    
    NSMutableString *searchKey = [[NSMutableString alloc] initWithString:searchText];
    CFStringTransform((__bridge CFMutableStringRef)searchKey, 0, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)searchKey, 0, kCFStringTransformStripDiacritics, NO);
    
    int index = Index(searchKey);
    
    NSArray *subArr = [_dataArray objectAtIndex:index];
    
    for (RYAddressBookModel *model in subArr) {
        
        NSMutableString *username = [[NSMutableString alloc] initWithString:model.username];
        CFStringTransform((__bridge CFMutableStringRef)username, 0, kCFStringTransformMandarinLatin, NO);
        CFStringTransform((__bridge CFMutableStringRef)username, 0, kCFStringTransformStripDiacritics, NO);
        
        NSString *regex = [NSString stringWithFormat:@"^%@.*$", searchKey];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        if ([predicate evaluateWithObject:username]) {
            
            [_searchArray addObject:model];
        }
    }
    
    [self loadSearchData];
}

- (void)adjustTableViewFrame:(BOOL)animated {
    CGRect frame = _tableView.frame;
    
    frame.origin.y = _contactPickerView.frame.size.height + _contactPickerView.frame.origin.y;
    
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    
    if(animated) {
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _tableView.frame = frame;
        } completion:nil];
    }
    else{
        _tableView.frame = frame;
    }
}

- (NSArray *)transitionFromPersonInfos:(NSArray *)personInfos {
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

#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* myView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width, 22)];
    myView.backgroundColor = [UIColor blackColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 90, 22)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = SpellFromIndex(section);
    [myView addSubview:titleLabel];
    return myView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_currentArray == _searchArray) {
        return 0;
    }
    if (((NSArray *)[_dataArray objectAtIndex:section]).count==0) {
        return 0;
    }
    return 30;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (_currentArray == _searchArray) {
        return @[];
    }
    tableView.sectionIndexColor = [UIColor blackColor];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < 27; i++) {
        [arr addObject:SpellFromIndex(i)];
    }
    return arr;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_currentArray == _searchArray) {
        return 1;
    }
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_currentArray == _searchArray) {
        return _searchArray.count;
    }
    return ((NSArray *)[_dataArray objectAtIndex:section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RYTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[RYTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    RYAddressBookModel *item = nil;
    if (_currentArray == _searchArray) {
        item = _searchArray[indexPath.row];
    }else if(_currentArray == _dataArray) {
        item = _dataArray[indexPath.section][indexPath.row];
    }
    
    [cell configureForInfo:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_contactPickerView resignKeyboard];
    
    RYAddressBookModel *addressModel;
    
    if (_currentArray == _dataArray) {
        addressModel = [[_currentArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }else {
        addressModel = [_currentArray objectAtIndex:indexPath.row];
    }
    
    if ([_selectArray containsObject:addressModel]) {
        
        [_selectArray removeObject:addressModel];
        
        [_contactPickerView removeContact:addressModel.photoNumber];
        
    }else {
        
        [_selectArray addObject:addressModel];
        
        [_contactPickerView addContact:addressModel.photoNumber
                              withName:addressModel.username];
    }
    [self loadAllContactData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_contactPickerView resignKeyboard];
}

#pragma mark -
#pragma mark THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        
        [self loadAllContactData];
        
    } else {
        
        [self refreshSearchTableView:textViewText];
        
    }
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    [self adjustTableViewFrame:YES];
}

- (void)contactPickerDidRemoveContact:(id)contact {
    RYAddressBookModel *removeModel = nil;
    
    for (RYAddressBookModel *model in _selectArray) {
        if (model) {
            if (model.photoNumber == contact) {
                removeModel = model;
            };
        }
    }

    [_selectArray removeObject:removeModel];
    
    [self loadAllContactData];
    
}
- (void)loadSearchData {
    _currentArray = _searchArray;
    [_tableView reloadData];
    [self adjustTableViewFrame:YES];
}

- (void)loadAllContactData {
    _currentArray = _dataArray;
    [_tableView reloadData];
    [self adjustTableViewFrame:YES];
}

@end
