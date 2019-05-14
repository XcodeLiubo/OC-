//
//  RACTModel.h
//  RACTest
//
//  Created by 刘泊 on 2019/5/6.
//  Copyright © 2019 LB. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RACSubject;

@interface RACTModel : NSObject
@property (nonatomic,strong) NSString* text;

@property (nonatomic,strong) NSString* card;

@property (nonatomic) bool userSel;

/** 文本信号 由model自己创建*/
@property (nonatomic,strong,readonly) RACSubject* textSignal;


@end

NS_ASSUME_NONNULL_END
