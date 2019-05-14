//
//  PlistVC.m
//  数据存储
//
//  Created by 刘泊 on 2019/5/8.
//  Copyright © 2019 LB. All rights reserved.
//

#import "PlistVC.h"

@interface PlistVC ()

@end

@implementation PlistVC

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
        plist的存放几乎和 NSUserDefaults 一样
        但是plist是由字典构成, 字典里只能存放 NSObject类型, 没有基本的数据类型
     */

    NSString* document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, 1) firstObject];
    NSString* path = [document stringByAppendingPathComponent:@"dic.plist"];

    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:20];

    [dic setObject:@3 forKey:@"number"];
    [dic setObject:@[@1,@2] forKey:@"array"];

    [dic writeToFile:path atomically:1];


    ///自己动在取的时候 转换成可变的
    NSMutableDictionary* getDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSLog(@"%@ %@",getDic, getDic.class);

    ///取出的数组是可变的 不论`当时存的时候 数组是可变的还是不可变的
    NSMutableArray* array = getDic[@"array"];
    [array addObject:@999];
    NSLog(@"%@ %@",[getDic[@"array"] class], array.class);
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
