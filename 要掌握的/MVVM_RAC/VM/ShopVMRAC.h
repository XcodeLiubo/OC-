//
//  ShopVM.h
//  MVVM_NORAC
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShopModel, RACSubject;

NS_ASSUME_NONNULL_BEGIN

@interface ShopVM : NSObject
- (void)request;

/** vc要更新cell的时候 从这里拿数据 自己去找,这里没有模拟多组的时候, 如果是多组自己实现,原理一样*/
- (NSArray<ShopModel*>*)models;


+ (instancetype)shopWithV:(id)v
         requestSucSignal:(RACSubject*)suc
                  failure:(RACSubject*)failure;
@end

NS_ASSUME_NONNULL_END
