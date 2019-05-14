//
//  ShopVM.h
//  MVVM_NORAC
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShopModel;
NS_ASSUME_NONNULL_BEGIN

typedef void(^ShopResServiceCallSucBlock)(NSArray<ShopModel*>*);
typedef void(^ShopResServiceCallFaiBlock)(NSError*);


typedef ShopResServiceCallSucBlock ShopReloadData;

/** 这里是针对table(plain类型)的哪个cell, 如果是别的view更新的时候 第二个参数必须能确定要更新的是哪个V(view和VC) */
typedef void(^ShopUpdateData)(ShopModel*, NSInteger);

/** 同样是外界拿到block将idx传进来更新model的, 这里的参数也是和上面更新视图一样 针对的是table(plain类型)的哪个cell发生了交互 */
typedef void(^ShopUpdateModel)(NSInteger, bool);

@interface ShopVM : NSObject
+ (instancetype)shopWithResServiceCallSuc:(ShopResServiceCallSucBlock)suc
                                     fail:(ShopResServiceCallFaiBlock)fail;

/** model变化后, 由这个block去回调更新view */
@property (nonatomic,copy) ShopUpdateData updateBlock;

/** 外界交互有这个block更新model */
@property (nonatomic,copy,readonly) ShopUpdateModel updateModelBlock;


- (void)request;

/** vc要更新cell的时候 从这里拿数据 自己去找,这里没有模拟多组的时候, 如果是多组自己实现,原理一样*/
- (NSArray<ShopModel*>*)models;
@end

NS_ASSUME_NONNULL_END
