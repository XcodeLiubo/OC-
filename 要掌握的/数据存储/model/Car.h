//
//  Car.h
//  数据存储
//
//  Created by 刘泊 on 2019/5/8.
//  Copyright © 2019 LB. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Car : NSObject<NSCoding,NSSecureCoding>
/** 车名 */
@property (nonatomic,strong) NSString* name;

/** 价格 */
@property (nonatomic) float money;

/** 品牌 */
@property (nonatomic,strong) NSString* brand;

/** 时间 */
@property (nonatomic,strong) NSString* time;

/** 从文件路径读取内容构建Car(解档)*/
+ (instancetype)carWithPath:(NSString* _Nonnull)path;

/** 将car对象存储到本地(归档) */
- (BOOL)carSave:(NSString* _Nonnull)path;

/** 从carsPath读取多个car */
+ (NSArray<__kindof Car*>*)carsWithCarkey:(NSArray<NSString*>*)keys
                                     path:(NSString* _Nonnull)carsPath;

/** 多个car归档 */
+ (BOOL)carsSaveWithCars:(NSDictionary<NSString*,__kindof Car*>*_Nonnull)cars
                   path:(NSString* _Nonnull)carsPath;


@end

NS_ASSUME_NONNULL_END
