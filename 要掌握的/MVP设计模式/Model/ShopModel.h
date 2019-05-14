//
//  ShopModel.h
//  MVP设计模式
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface ShopModel : NSObject
/** 商品名称 */
@property (nonatomic,strong) NSString* shopName;


////////////////////////附加////////////////////
/** 用户是否选中 */
@property (nonatomic,getter=isSelect) bool shopUseSelect;


/** 购买的个数 demo里先不考虑库存 */
@property (nonatomic) NSInteger shopNum;




/** 这个模型负责请求自己的数据 */
+ (void)requestWithShopServiceSuc:(void(^)(NSArray<ShopModel*>* models))suc
                          failure:(void(^)(NSError* error))error
                              url:(NSString*)url
                             args:(NSDictionary*)dic;

/** 这个结果只有在调用完 request后才可能有值 */
@property (nonatomic,class,readonly) NSMutableArray<ShopModel*>* allModels;


@end


