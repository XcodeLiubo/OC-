//
//  NSObject+AddProperty.m
//  Runtime
//
//  Created by 刘泊 on 2019/5/14.
//  Copyright © 2019 LB. All rights reserved.
//

#import "NSObject+AddProperty.h"
#import <objc/runtime.h>
@implementation NSObject (AddProperty)
+ (NSMutableDictionary*)newPropertys{
    static NSMutableDictionary* _newPropetys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _newPropetys = [NSMutableDictionary dictionaryWithCapacity:20];
    });
    return _newPropetys;
}
+ (bool)addPropertyWithPName:(NSString *)name{
    if (name.length == 0)return false;

    if([self checkProperty:name])return false;

    @synchronized (@"__add") {
        return [self _addPropertyWith:name];
    }


}

+ (bool)checkProperty:(NSString*)name{
    ////先检查成员列表里有没有
    if(class_getInstanceVariable(self, [@"_" stringByAppendingString:name].UTF8String)) return true;

    return false;
}

+ (bool)_addPropertyWith:(NSString*)name{
    ///动态添加属性 @property(nonatomic,strong) id obj;
    NSString* attStr = [@"T@,&,N,V_{name}}" stringByReplacingOccurrencesOfString:@"{name}" withString:name];
    objc_property_attribute_t att[] = {
        "",attStr.UTF8String
    };
    const char* cStr = name.UTF8String;
    bool result = class_addProperty(self.class, cStr, att, 1);

    if (!result) {
        class_replaceProperty(self.class, cStr, att, 1);
    }


    NSString* getName = name;
    class_addMethod(self, NSSelectorFromString(getName), imp_implementationWithBlock(^NSString*(NSObject* obj){
        return [[NSObject newPropertys] valueForKey:name];
    }), "@@:");

    NSString* setStr = [NSString stringWithFormat:@"set%@:",name.capitalizedString];
    class_addMethod(self, NSSelectorFromString(setStr), imp_implementationWithBlock(^void(NSObject* obj,NSString* value){
        [[NSObject newPropertys] setObject:value forKey:name];
    }), "v@:@");

    return true;
}

+ (bool)rmvPropertyWithPName:(NSString*)name{
    if (name.length == 0)return false;

    if (![self checkProperty:name]) return true;

    if(!class_getProperty(self, name.UTF8String))return true;

    @synchronized (@"__rmv") {
        return [self _rmvPropertyWithPName:name];
    }
}


+ (bool)_rmvPropertyWithPName:(NSString*)name{
    [[self newPropertys] removeObjectForKey:name];
    return true;
}
@end
