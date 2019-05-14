//
//  ViewController.m
//  要掌握的
//
//  Created by 刘泊 on 2019/4/27.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSOperationQueue* qu = [[NSOperationQueue alloc] init];
    qu.maxConcurrentOperationCount = 1;

    [qu addOperationWithBlock:^{
        NSLog(@"__5 %@",NSThread.currentThread);
    }];

    [qu addOperationWithBlock:^{
        NSLog(@"__1 %@",NSThread.currentThread);
    }];


    [qu addOperationWithBlock:^{
        NSLog(@"__4 %@",NSThread.currentThread);
    }];

    [qu addOperationWithBlock:^{
        NSLog(@"__3 %@",NSThread.currentThread);
    }];

    [qu addOperationWithBlock:^{
        NSLog(@"__2 %@",NSThread.currentThread);
    }];

    [qu addOperationWithBlock:^{
        NSLog(@"__6 %@",NSThread.currentThread);
    }];

    NSLog(@(__func__));
}


@end
