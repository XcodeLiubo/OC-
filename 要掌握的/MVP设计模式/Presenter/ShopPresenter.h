//
//  ShopPresenter.h
//  MVP设计模式
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import <Foundation/Foundation.h>



@class ShopModel;
@protocol ShopPresenter <NSObject>

@optional
- (void)reloadViewWith:(NSArray<ShopModel*>* const)dataArray;

@end


NS_ASSUME_NONNULL_BEGIN

@interface ShopPresenter : NSObject


+ (instancetype)shopPWith:(id<ShopPresenter>)obj;


/** 请求数据 */
- (void)requestData;

/** vc要更新cell的时候 从这里拿数据 自己去找,这里没有模拟多组的时候, 如果是多组自己实现,原理一样*/
- (NSArray<ShopModel*>*)models;


/** view交互后VC通过调用P的这个方法,去更新对应的model*/
- (void)updateShopModelWithIdx:(NSInteger)idx userSel:(bool)select;

@end

NS_ASSUME_NONNULL_END
