//
//  ShopPresenter.m
//  MVP设计模式
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ShopPresenter.h"

#import "ShopModel.h"

struct struct_ShopPresenterDelegate {
    __weak id<ShopPresenter> delegate;
    bool res_reloadViewWith;
};

typedef struct struct_ShopPresenterDelegate struct_ShopPresenterDelegate;

@interface ShopPresenter (){
    struct_ShopPresenterDelegate _delegate;
}
@end


@implementation ShopPresenter

+ (instancetype)shopPWith:(id<ShopPresenter>)obj{
    return [[self alloc] initWithDelegate:obj];
}

- (instancetype)initWithDelegate:(id<ShopPresenter>)obj{
    if (self = [super init]) {
        if (obj) {
            self->_delegate.delegate = obj;
            if ([obj respondsToSelector:@selector(reloadViewWith:)]) {
                self->_delegate.res_reloadViewWith = true;
            }else self->_delegate.res_reloadViewWith = false;
        }
    }
    return self;
}


/** 请求数据 */
- (void)requestData{
    [ShopModel requestWithShopServiceSuc:^(NSArray<ShopModel *> * _Nonnull models) {
        if (self->_delegate.res_reloadViewWith) {
            [self->_delegate.delegate reloadViewWith:models];
        }
    } failure:^(NSError * _Nonnull error) {
        
    } url:NULL args:NULL];
}

/** vc要更新cell的时候 从这里拿数据 自己去找 */
- (NSArray<ShopModel*>*)models{
    return [ShopModel allModels];
}

- (void)updateShopModelWithIdx:(NSInteger)idx userSel:(bool)select{
    ShopModel* model = [[self models] objectAtIndex:idx];
    model.shopUseSelect = select;
}

@end
