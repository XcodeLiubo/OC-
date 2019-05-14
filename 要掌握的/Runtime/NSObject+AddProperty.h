//
//  NSObject+AddProperty.h
//  Runtime
//
//  Created by 刘泊 on 2019/5/14.
//  Copyright © 2019 LB. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (AddProperty)
/** 分类里扩展一个添加属性的方法 取值赋值就根据kvc就行了*/
+ (bool)addPropertyWithPName:(NSString*)name;

/** 移除 不存在也是true, 本质是删除不了的*/
+ (bool)rmvPropertyWithPName:(NSString*)name;
@end

NS_ASSUME_NONNULL_END
