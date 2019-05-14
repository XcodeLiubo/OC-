//
//  ViewController.m
//  MVP设计模式
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ViewController.h"

#import "ShopPresenter.h"

#import "ShopCell.h"


#warning 整个VC里没有包含 model, 只包含view(table和cell)
#warning ShopPresenter里没有包含任何UIKit的内容, 只是业务逻辑的处理


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,ShopPresenter>
@property (nonatomic,weak) UITableView* table;

@property (nonatomic,strong) ShopPresenter* shopPresenter;
@end

@implementation ViewController

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

#warning 2 参数source是由P提供,VC的.m里并没有引入model, model全有P掌管,需要的时候向P拿
#warning 3 block表示按钮点击传给了VC, 再由VC向P申请修改model(实际上view和VC在mvp里是同一等级的,这里还是view依赖vc去向P通信,无伤大雅)
    return [ShopCell cellWithTable:tableView
                               idx:indexPath
                            source:[[self.shopPresenter models] objectAtIndex:indexPath.row]
                      userSelBlock:^void(bool userSelState,NSIndexPath* indexP) {
                          [weakSelf.shopPresenter updateShopModelWithIdx:indexPath.row userSel:userSelState];
                      }];
}




#pragma mark - P的代理(由P内部请求数据后, 通知代理更新table)
- (void)reloadViewWith:(NSArray<ShopModel *> *const)dataArray{
#warning 2 VC遵循了P的代理, 当P的数据发生变化的时候(eg:请求到数据), 通过代理通知VC,VC再刷新视图
    [_table reloadData];
}



- (ShopPresenter *)shopPresenter{
    if (!_shopPresenter) {

#warning 1. VC被P直接引用
        _shopPresenter = [ShopPresenter shopPWith:self];
    }
    return _shopPresenter;
}
@end
