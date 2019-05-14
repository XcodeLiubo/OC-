//
//  NSObject+LBKVO.m
//  Runtime
//
//  Created by 刘泊 on 2019/5/14.
//  Copyright © 2019 LB. All rights reserved.
//

#import "NSObject+LBKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define _ClassPrefix @"_LBKVO_"



@implementation NSObject (LBKVO)
+ (NSMutableDictionary*)allRegisterClass{
    static NSMutableDictionary* _dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dic = [NSMutableDictionary dictionaryWithCapacity:20];
    });
    return _dic;
}


#pragma mark - 注册KVO
- (void)kvoRegiesterName:(NSString* _Nonnull)pName
                observer:(id _Nonnull)obj
                callback:(LBKVO_Callback _Nullable)callback{
    NSParameterAssert(pName.length != 0);
    NSParameterAssert(obj != nil);


    @synchronized(@"create"){
        ///0 检查当前的pName有没有在属性里 没有不能监听
        if(![self checkPropertyAvaiable:pName])return;

        ///1 检查当前类 如果之前动态创建了, 就不再创建
        if([self needCreateClass])
            [self createClassWith:pName observer:obj callback:callback];
    }
}


#pragma mark - 检查有没有这个属性
- (bool)checkPropertyAvaiable:(NSString*)pName{
    ///返回的可能是父类的某个属性
    return class_getProperty(self.class, pName.UTF8String);
}

#pragma mark - 是否需要创建类
- (bool)needCreateClass{
    /**
     这里要获取真正的class 因为如果self用过系统的kvo, isa指针发生了变化, 调用self.class返回的还是kvo之前的class,
     这里考虑的情况是 self用系统的kvo监听了某个属性eg:name, 现在又跑来这里监听name
     */
    Class reallyClass = object_getClass(self);

    NSString* rcStr = NSStringFromClass(reallyClass);
    if ([rcStr hasPrefix:@"NSKVONotifying_"])   return false;

    if ([rcStr hasPrefix:_ClassPrefix])         return false;

    return true;
}

#pragma mark - 创建class
- (void)createClassWith:(NSString*)pName
               observer:(id)observer
               callback:(LBKVO_Callback)callback{

    Class reallyClass = object_getClass(self);

    NSString* tmpClassName = [_ClassPrefix stringByAppendingString:NSStringFromClass(reallyClass)];

    ///创建新的class
    Class newClass = objc_allocateClassPair(reallyClass, tmpClassName.UTF8String, 0);

    ///将被监听者的isa指向新建的类
    object_setClass(self, newClass);

    NSString* _setMethodName = [NSString stringWithFormat:@"set%@:",pName.capitalizedString];

    ///如果之前添加过
    class_addMethod(newClass, NSSelectorFromString(_setMethodName), imp_implementationWithBlock(^void(__weak id obj, id value){
        if (callback) {
            id old = [obj valueForKey:pName];
            ///通知外界
            callback(old,value,pName);
            NSString* varName = [@"_" stringByAppendingString:pName];
            Ivar var = class_getInstanceVariable([obj class], varName.UTF8String);
            if (var) {
                object_setIvar(obj, var, value);
            }
        }

    }), "v@:@");
    ///注册
    objc_registerClassPair(newClass);

    ///key: 监听的名字  value
    [[self.class allRegisterClass] setObject:@{@"class":newClass,
                                               @"observer":observer}
                                      forKey:pName];
}
#pragma mark - 观察者来移除
- (void)kvoRemoveWith:(id)ob
                 name:(NSString*)name{
    NSMutableDictionary* info = [NSObject allRegisterClass];
    NSDictionary* subInfo = info[name];

    /**
        这里要注意的问题

        这里一定要保证,在objc_disposeClassPair后, 没有指针再指向那块内存了, 因为这里定义了一个局部变量subInfo, 崩溃之前是因为subInfo的销毁是在函数之后会release一次他引用的对象(里面是有指针指向那块内存的), 这个时候objc_disposeClassPair已经释放掉了那一块内存, 所以直接崩溃,后来是在objc_disposeClassPair, 把subInfo置空,就ok了

     */

    ///麻痹的这里大坑, 必须先把class取出来, 然后释放掉字典里的东西, 不然后面objc_disposeClassPair的时候直接崩溃
    id recordOb = subInfo[@"observer"];
    Class tmpC = subInfo[@"class"];

    [info removeAllObjects];
    subInfo = nil;


    if (subInfo && recordOb == self) {
        ///重置之前被监听者的isa
        object_setClass(ob, [tmpC superclass]);

        ///这里会释放掉类对象, 所以在释放类对象之前, 应该保证没有指针指向已经释放的类对象
        objc_disposeClassPair(tmpC);

        [info removeObjectForKey:name];
    }
}

@end
