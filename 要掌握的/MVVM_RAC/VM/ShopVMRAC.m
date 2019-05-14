//
//  ShopVM.m
//  MVVM_NORAC
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ShopVMRAC.h"

#import "ShopModelRAC.h"

#import <ReactiveObjC/ReactiveObjC.h>

@interface ShopVM ()

@property (nonatomic,strong) RACSubject* sucSubSignal;
@property (nonatomic,strong) RACSubject* failSubSignal;
@end


@implementation ShopVM
- (NSArray<ShopModel*>*)models{
    return [ShopModel allModels];
}

#pragma mark - rac的方式
+ (instancetype)shopWithV:(id)v
         requestSucSignal:(RACSubject*)suc
                  failure:(RACSubject*)failure{

    NSParameterAssert(suc != nil);
    return [[self alloc] initWithSucSignal:suc failure:failure];
}

- (instancetype)initWithSucSignal:(RACSubject*)suc failure:(RACSubject*)failure{
    if (self = [super init]) {
        _sucSubSignal = suc;
        _failSubSignal = failure;
    }
    return  self;
}

#pragma mark - 请求数据
- (void)request{
    __weak typeof(self) weakSelf = self;
    [ShopModel requestWithShopServiceSuc:^(NSArray<ShopModel *> * _Nonnull models) {
        [weakSelf.sucSubSignal sendNext:models];
    } failure:^(NSError * _Nonnull error) {
        if (weakSelf.failSubSignal) [weakSelf.failSubSignal sendNext:(error)];
    } url:NULL args:NULL];
}
@end
