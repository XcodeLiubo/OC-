//
//  ArchiveVC.m
//  数据存储
//
//  Created by 刘泊 on 2019/5/8.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ArchiveVC.h"

#import "Car.h"

@interface ArchiveVC ()

@end

@implementation ArchiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
        主要是用来存储自定义的数据结构
     */


    ////单个对象的归档
    [self archiveSignalObjc];


    [self archiveOjbcs];

}

#pragma mark - 单一对象的归档
- (void)archiveSignalObjc{

    Car* car1 = [Car new];
    car1.name = @"柯尼塞";
    car1.money = 1.0e8;

    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, 1).firstObject stringByAppendingPathComponent:@"car1"];

    ////将car1存储到path下面
    if ([car1 carSave:path]) {
        NSLog(@"归档成功");
    }else NSLog(@"归档失败");

    Car* car2 = [Car carWithPath:path];
    NSLog(@"%@ %f",car2.name, car2.money);
}


#pragma mark - 多个对象一起归档
- (void)archiveOjbcs{
    NSMutableDictionary<NSString*, Car*>* dic = [NSMutableDictionary dictionaryWithCapacity:3];
    for (NSInteger i = 0; i < 3; ++i) {
        Car* car = [Car new];
        car.name = @(arc4random_uniform(100)).stringValue;
        car.money = arc4random_uniform(1e9);

        [dic setObject:car forKey:@(i).stringValue];
        NSLog(@"%@ %f",car.name,car.money);
    }

    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, 1).firstObject stringByAppendingPathComponent:@"cars"];

    if ([Car carsSaveWithCars:dic path:path]) {
        NSLog(@"归档成功");
    }else{
        NSLog(@"归档失败");
    }


    NSArray<Car*>* getCars = [Car carsWithCarkey:@[@"0",@"1",@"2"] path:path];
    for (Car* car in getCars) {
        NSLog(@"%@ %f",car.name,car.money);
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
