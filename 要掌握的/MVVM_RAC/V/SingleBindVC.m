//
//  SingleBindVC.m
//  MVVM_RAC
//
//  Created by 刘泊 on 2019/5/6.
//  Copyright © 2019 LB. All rights reserved.
//

#import "SingleBindVC.h"

#import "ShopCell.h"


#import "ShopVMRAC.h"

#import <ReactiveObjC.h>

@interface SingleBindVC ()<UITableViewDelegate,UITableViewDataSource>
/** table */
@property (nonatomic,weak) IBOutlet UITableView* table;

@property (nonatomic,strong) ShopVM* vm;
@end

@implementation SingleBindVC

- (void)viewDidLoad {
    [super viewDidLoad];

    _table.rowHeight = 160;

    [self.vm request];
}



#pragma mark - table datasource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [ShopCell cellWithTable:tableView idx:indexPath vm:self.vm];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.vm models].count;
}


- (ShopVM *)vm{
    if (!_vm) {
        RACSubject* suc = [RACSubject subject];

        ////订阅
        @weakify(self);
        [suc subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.table reloadData];
        }];

        
        RACSubject* fail = [RACSubject subject];
        [fail subscribeNext:^(id  _Nullable x) {
            NSLog(@"%@",x);
        }];
        _vm = [ShopVM shopWithV:self requestSucSignal:suc failure:fail];
    }
    return _vm;
}

@end
