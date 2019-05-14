//
//  ViewController2.m
//  MVP设计模式
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ViewController2.h"

#import "ShopPresenter.h"

#import "ShopCell.h"

#import "ShopModel.h"


@interface ViewController2 ()<UITableViewDataSource,UITableViewDelegate,ShopPresenter>
@property (nonatomic,weak) UITableView* table;

@property (nonatomic,strong) ShopPresenter* shopPresenter;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUPUI];

    ////getter里将self绑定到了P中 并请求数据
    [self.shopPresenter requestData];
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
    return [self.shopPresenter models].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;

    return [ShopCell cellWithTable:tableView
                               idx:indexPath
                       assignBlock:^void(UILabel * _Nonnull __weak nameLab, UIButton * _Nonnull __weak btn){
                           nameLab.text = [[weakSelf.shopPresenter models] objectAtIndex:indexPath.row].shopName;
                           btn.selected = [[weakSelf.shopPresenter models] objectAtIndex:indexPath.row].shopUseSelect;
                       }userSelBlock:^void(bool userSelState,NSIndexPath* indexP) {
                           [weakSelf.shopPresenter updateShopModelWithIdx:indexPath.row userSel:userSelState];
                       }];


}



- (void)reloadViewWith:(NSArray<ShopModel *> *const)dataArray{
    [_table reloadData];
}



- (ShopPresenter *)shopPresenter{
    if (!_shopPresenter) {
        _shopPresenter = [ShopPresenter shopPWith:self];
    }
    return _shopPresenter;
}

@end
