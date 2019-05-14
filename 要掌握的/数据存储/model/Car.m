//
//  Car.m
//  数据存储
//
//  Created by 刘泊 on 2019/5/8.
//  Copyright © 2019 LB. All rights reserved.
//

#import "Car.h"
static inline bool _pathAvaiable(NSString*path){
    NSFileManager* mgr = [NSFileManager defaultManager];

    ////如果路径存在
    if([mgr fileExistsAtPath:path]){
        bool result = NO;

        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&result];

        return result;
    }


    return [mgr createDirectoryAtPath:path withIntermediateDirectories:1 attributes:nil error:nil];

}

@implementation Car
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _money = [aDecoder decodeFloatForKey:@"money"];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeFloat:_money forKey:@"money"];
    [aCoder encodeObject:_name forKey:@"name"];
}


+ (BOOL)supportsSecureCoding{
    return true;
}




#pragma mark - 从文件路径读取内容构建Car(解档)
+ (instancetype)carWithPath:(NSString* _Nonnull)path{
    NSParameterAssert(path.length != 0);



    ////调用解档类 他内部会调用 Car的initWithCoder协议
    if (@available(iOS 11,*)){
        NSData* data = [NSData dataWithContentsOfFile:path];
        return (Car*)[NSKeyedUnarchiver unarchivedObjectOfClass:self fromData:data error:nil];
    }

    return(Car*)[NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

#pragma mark - 将car对象存储到本地(归档)
- (BOOL)carSave:(NSString* _Nonnull)path{
    NSParameterAssert(path.length != 0);
    if (@available(iOS 11,*))
        return [[NSKeyedArchiver archivedDataWithRootObject:self
                                      requiringSecureCoding:1
                                                      error:nil] writeToFile:path atomically:1];



    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}



#pragma mark - 从carsPath读取多个car
+ (NSArray<__kindof Car*>*)carsWithCarkey:(NSArray<NSString*>*)keys
                                     path:(NSString* _Nonnull)carsPath{
    NSParameterAssert(carsPath.length != 0);
    if (!keys.count)return nil;

    if (!_pathAvaiable(carsPath))return nil;
    

    NSMutableArray<Car*>* result = [NSMutableArray arrayWithCapacity:keys.count];
    for (NSString* key in keys) {
        NSString* newPath = [carsPath stringByAppendingPathComponent:key];
        [result addObject:[self carWithPath:newPath]];
    }

    if (result.count)return [NSArray arrayWithArray:result];

    return nil;
}


#pragma mark - 多个car归档
+ (BOOL)carsSaveWithCars:(NSDictionary<NSString*,__kindof Car*>*_Nonnull)cars
                   path:(NSString* _Nonnull)carsPath{
    NSParameterAssert(carsPath.length != 0);
    if (cars.allValues.count == 0)return false;

    if (@available(iOS 11.0, *)) {
        /**
            ..../carsPath/key1
            ..../carsPath/key2
            ..../carsPath/key3
            ...
            ..../carsPath/keyn

            一个一个的car被归档
         */


        ///如果已经是一个文件了 直接返回
        if (!_pathAvaiable(carsPath))return false;

        

        ////不是文件就创建目录
        if(![[NSFileManager defaultManager]createDirectoryAtPath:carsPath withIntermediateDirectories:1 attributes:nil error:nil])
            return false;

        __block bool com = false;
        __block NSInteger idx = 0;
        __block NSMutableArray<NSString*>* recordKey = [NSMutableArray arrayWithCapacity:cars.allKeys.count];
        [cars enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key,
                                                  __kindof Car * _Nonnull obj,
                                                  BOOL * _Nonnull stop) {
            NSString* newPath = [carsPath stringByAppendingPathComponent:key];
            com = [obj carSave:newPath];
            if(com == false){
                *stop = 1;
                [recordKey addObject:key];
            }else{
                idx++;
                if (idx != cars.allKeys.count)
                    com = false;
            }
        }];

        ////如果上述只要一个归档失败, 全部都要删除
        if (recordKey.count) {
            for (NSString* key in recordKey) {
                NSString* newPath = [carsPath stringByAppendingPathComponent:key];
                [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
            }
        }

        return com;
    }




    NSMutableData* data = [NSMutableData data];

    ////将NSKeyedArchiver对象和data关联起来
    NSKeyedArchiver* arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];

    [cars enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, __kindof Car * _Nonnull obj, BOOL * _Nonnull stop) {
        [arch encodeObject:obj forKey:key];
    }];

    [arch finishEncoding];

    return [data writeToFile:carsPath atomically:1];

}
@end
