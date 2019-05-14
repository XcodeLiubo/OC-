//
//  RACTModel.m
//  RACTest
//
//  Created by 刘泊 on 2019/5/6.
//  Copyright © 2019 LB. All rights reserved.
//

#import "RACTModel.h"
#import <ReactiveObjC.h>
#import <NSObject+RACKVOWrapper.h>

@interface RACTModel(){
    __strong RACSubject* _textSignal;
}
@property (nonatomic,strong) RACDisposable* kvoDis;
@end


@implementation RACTModel
- (instancetype)init{
    if (self = [super init]) {

        @weakify(self);
        _kvoDis = [RACObserve(self, text) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.textSignal sendNext:x];
        }];
    }
    return self;
}


- (RACSubject *)textSignal{
    if (!_textSignal) {
        _textSignal = [RACSubject subject];
    }

    return  _textSignal;
}

- (void)dealloc{
    [_kvoDis dispose];

}
@end
