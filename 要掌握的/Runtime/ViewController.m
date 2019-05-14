//
//  ViewController.m
//  Runtime
//
//  Created by 刘泊 on 2019/5/12.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ViewController.h"

#import "LBLog.h"

#import <objc/runtime.h>
#import "NSObject+AddProperty.h"
#import "NSObject+LBKVO.h"
#import "Person.h"

@interface Son : Person
@property (nonatomic,strong) NSString* age;
@end

@implementation Son



@end


@interface ViewController ()
@property (nonatomic) NSInteger age;
@property (nonatomic,strong) Person* p;
@end



@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    Person* p = [Person new];
    p.name = @"zl";
    _p = p;

    [p kvoRegiesterName:@"name"
               observer:self
               callback:^(id  _Nonnull old, id  _Nonnull modified, NSString * _Nonnull keyName) {
                   NSLog(@"%@ %@ %@",old, modified,keyName);
    }];



    Class newC = objc_allocateClassPair(self.class, "VC2", 0);
    objc_registerClassPair(newC);
    objc_disposeClassPair(newC);


}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%@",_p.name);
    _p.name = @"lisi";
    NSLog(@"%@",_p.name);
    [self kvoRemoveWith:_p name:@"name"];
}


@end






