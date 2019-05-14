//
//  BinaryStremVC.m
//  数据存储
//
//  Created by 刘泊 on 2019/5/8.
//  Copyright © 2019 LB. All rights reserved.
//

#import "BinaryStremVC.h"

@interface BinaryStremVC ()

@end

@implementation BinaryStremVC

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString* document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, 1) firstObject];
    NSString* path = [document stringByAppendingPathComponent:@"data"];

    NSData* data= [@"123".mutableCopy dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:path atomically:1];

    NSData* getData = [NSData dataWithContentsOfFile:path options:(NSDataReadingMappedIfSafe) error:nil];
    NSString* getStr = [[NSString alloc] initWithData:getData encoding:NSUTF8StringEncoding];

    ///取出来是不可变的
    NSLog(@"%@ %@ %@",getData.class, getStr,getStr.class);

    
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
