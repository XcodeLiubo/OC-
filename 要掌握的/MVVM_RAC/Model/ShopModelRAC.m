//
//  ShopModel.m
//  MVP设计模式
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ShopModelRAC.h"


static NSMutableArray<ShopModel*>* allModels_;

@implementation ShopModel

- (instancetype)init{
    if (self = [super init]) {
        self.shopNum = 0;
        self.shopUseSelect = false;
    }
    return self;
}


+ (instancetype)modelWithDic:(NSDictionary*)dic{
    if (!dic) return self.new;
    ShopModel* model = [self new];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}







/** 这个模型负责请求自己的数据 */
+ (void)requestWithShopServiceSuc:(void(^)(NSArray<ShopModel*>* models))suc
                          failure:(void(^)(NSError* error))error
                              url:(NSString*)url
                             args:(NSDictionary*)dic{
#ifndef DEBUG
    /** 各种判断(url是否空等等) */
    if (!url.length)return;

    if (!suc) return;

    if (!error)return;
#endif
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* tmpShops = @[
                              @{@"shopName":@"商品1"},
                              @{@"shopName":@"商品2"},
                              @{@"shopName":@"商品3"},
                              @{@"shopName":@"商品4"},
                              @{@"shopName":@"商品5"},
                              @{@"shopName":@"商品6"},
                              @{@"shopName":@"商品7"},
                              ];

        for (NSInteger i = 0; i < tmpShops.count; ++i) {
            ShopModel* model = [ShopModel modelWithDic:tmpShops[i]];
            [self.allModels addObject:model];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            ///这里没有模拟error的情况
            suc(self.allModels);

        });
    });
}


+ (NSMutableArray<ShopModel *> *)allModels{
    /** 默认开20个空间 */
    if (!allModels_) allModels_ = [NSMutableArray arrayWithCapacity:20];
    return allModels_;
}
@end
