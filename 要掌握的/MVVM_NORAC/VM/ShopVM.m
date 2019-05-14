//
//  ShopVM.m
//  MVVM_NORAC
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ShopVM.h"

#import "ShopModel.h"

@interface ShopVM (){
    ShopUpdateModel _updateModelBlock;
}
@property (nonatomic,copy) ShopResServiceCallSucBlock resSucBlock;
@property (nonatomic,copy) ShopResServiceCallFaiBlock resFaiBlock;


@end


@implementation ShopVM
+ (instancetype)shopWithResServiceCallSuc:(ShopResServiceCallSucBlock)suc
                                     fail:(ShopResServiceCallFaiBlock)fail{
    NSParameterAssert(suc != nil);
    return [[ShopVM alloc] initWithResSuc:suc fail:fail];
}

- (instancetype)initWithResSuc:(ShopResServiceCallSucBlock)suc fail:(ShopResServiceCallFaiBlock)fail{
    if (self = [super init]) {
        _resSucBlock = suc;
        _resFaiBlock = fail;
    }
    return self;
}


- (ShopUpdateModel)updateModelBlock{
    __weak typeof(self) weakSelf = self;
    if (!_updateModelBlock) {
        _updateModelBlock = ^void(NSInteger idx, bool select){
            ShopModel* model = [[weakSelf models] objectAtIndex:idx];
            model.shopUseSelect = select;
        };
    }
    return _updateModelBlock;
}



#pragma mark - 请求数据
- (void)request{
    __weak typeof(self) weakSelf = self;
    [ShopModel requestWithShopServiceSuc:^(NSArray<ShopModel *> * _Nonnull models) {
        weakSelf.resSucBlock(models);
    } failure:^(NSError * _Nonnull error) {
        if (weakSelf.resFaiBlock) weakSelf.resFaiBlock(error);
    } url:NULL args:NULL];
}


- (NSArray<ShopModel*>*)models{
    return [ShopModel allModels];
}
@end
