//
//  ViewController.m
//  MVVM_NORAC
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ViewController.h"
#import "ShopCell.h"
#import "ShopVM.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,weak) UITableView* table;
@property (nonatomic,strong) ShopVM* shopVM;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUPUI];

    [self.shopVM request];
}


#pragma mark - UI布局的代码
- (void)setUPUI{
    UITableView* table = [UITableView new];
    table.delegate = self;
    table.dataSource = self;
    table.rowHeight = 150;
    [self.view addSubview:table];
    _table = table;
    table.translatesAutoresizingMaskIntoConstraints = false;
    [table.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = 1;
    [table.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = 1;
    [table.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = 1;
    [table.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = 1;
}


#pragma mark - table datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.shopVM models].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ShopCell cellWithTable:tableView
                               idx:indexPath
                                vm:self.shopVM];
}



- (ShopVM *)shopVM{
    if (!_shopVM) {
        __weak typeof(self) weakSelf = self;
        _shopVM = [ShopVM shopWithResServiceCallSuc:^(NSArray<ShopModel *> * _Nonnull models) {
            [weakSelf.table reloadData];
        } fail:^(NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];

        _shopVM.updateBlock = ^(ShopModel * _Nonnull model, NSInteger idx) {
            NSIndexPath* indexP = [NSIndexPath indexPathForRow:idx inSection:0];
            [weakSelf.table reloadRowsAtIndexPaths:@[indexP] withRowAnimation:(UITableViewRowAnimationFade)];
        };
    }

    return _shopVM;
}
@end
