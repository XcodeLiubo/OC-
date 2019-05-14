//
//  UserDefaultsVC.m
//  数据存储
//
//  Created by 刘泊 on 2019/5/8.
//  Copyright © 2019 LB. All rights reserved.
//

#import "UserDefaultsVC.h"

@interface UserDefaultsVC ()

@end

@implementation UserDefaultsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    ////路径介绍
    [self pathInfoFun];

    [self userDefault];

}

#pragma mark - 路径介绍
- (void)pathInfoFun{

    /**
     获取应用程序创建的沙盒根目录

     模拟器上看 改目录下有4个文件夹和一个plist
     > SystemData 表示系统存放的一些数据 不要管

     > tmp 临时的文件夹 里面存放的系统会随时删除 不要存放持久化的数据, iTunes不会同步

     > Library
     1. Library/Caches: 适合文件大, 不需要备份的不很重要的数据, iTunes也不会同步
     2. Library/Preferences 保存应用的设置信息, 这里iTunes会同步(NSUserDefault 存储的数据是创建了plist存储在这里)

     > Document 专门用来供用户存储数据的地方 iTunes会同步


     */
    NSString* progressRootPath = NSHomeDirectory();
    NSLog(@"progressRootPath: %@",progressRootPath);

    /**
     当前用户的登录名
     如果是模拟器, 这个返回的值是 @""
     如果是真机 我自己的 返回的是 @"mobile"
     */
    NSString* userName = NSUserName();
    NSLog(@"userName: %@",userName);


    /**
     当前用户全名的字符串
     如果是模拟器, 这个值返回的是 @""
     如果是真机 返回的是@"Mobile User"
     */
    NSString* fullUserName = NSFullUserName();
    NSLog(@"fullUserName: %@",fullUserName);


    /**
     当前用户的主目录路径
     其实返回的结果就是progressRootPath
     */
    NSString* userPath = NSHomeDirectoryForUser(userName);
    NSLog(@"userPath: %@",userPath);


    /**
     这个返回的是沙盒下的 临时路径
     在模拟器上 = progressRootPath/tmp/
     在真机山  就不一样了, 完全被封锁了
     */
    NSString* tmpPath = NSTemporaryDirectory();
    NSLog(@"tmpPath: %@",tmpPath);


    /**
     返回用户系统的根目录
     真机和模拟器返回的都是 @"/"
     */
    NSString* sysPath = NSOpenStepRootDirectory();
    NSLog(@"%@",sysPath);



    /**
     获取Document目录
     */
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, 1);
    NSLog(@"%@",paths);
}


#pragma mark - NSUserDefult
- (void)userDefault{

    /**
        NSUserDefaults 是创建了plist 存储在了Library/Preference 中,

     所以它支持的只有 Foundation里的数据结构
        > 基本数据类型  float double NSInteger bool

        > NSNumber

        > NSArray

        > NSDictionary

        > NSString

        > NSData

        > NSDate

        > NSURL


        优点
            不需要关系文件名
            快速键值对存储
            能够存储基本数据类型, 其实是内部转换成了NSNumber(NSInter float double)
            由系统的类在底层读写, 有线程安全(注意存的时候调用同步)


        缺点
            不能存储自定义数据类型
            取出的数据是不可变的
     */


    NSUserDefaults* sys = [NSUserDefaults standardUserDefaults];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{


        ////存储bool
        [sys setBool:true forKey:@"bool"];

        ////存储float
        [sys setFloat:134.5f forKey:@"float"];

        ////存储int
        [sys setInteger:123132 forKey:@"NSInteger"];

        ///存储 double
        [sys setDouble:123.12313121 forKey:@"double"];

        ////存储url
        [sys setURL:[NSURL URLWithString:@"https://www.baidu.com"] forKey:@"url"];

        ///存储数组(存储的时候是可变的)
        [sys setObject:@[@"value1",@2,@"value3"].mutableCopy forKey:@"array"];


        ///存储字典
        [sys setObject:@{@"key1":@123,@"key2":@345}.mutableCopy forKey:@"dic"];


        ////存储NSNumber
        [sys setObject:@100 forKey:@"number"];

        ///存储date
        [sys setObject:[NSDate date] forKey:@"date"];


        ////存储data
        NSMutableData* dataStr = [@"NSData" dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
        [sys setObject:dataStr forKey:@"data"];


        ///存储date
        [sys setObject:NSDate.date forKey:@"date"];


        [sys synchronize];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"bool value: %d",[sys boolForKey:@"bool"]);
            NSLog(@"\n");

            NSLog(@"float value: %f",[sys floatForKey:@"float"]);
            NSLog(@"\n");

            NSLog(@"NSInteger value: %zd",[sys integerForKey:@"NSInteger"]);
            NSLog(@"\n");

            NSLog(@"double value: %lf",[sys doubleForKey:@"double"]);
            NSLog(@"\n");

            NSLog(@"url value: %@",[sys URLForKey:@"url"]);
            NSLog(@"url value: %@",[sys objectForKey:@"url"]); ///返回的是二级制的data
            NSLog(@"\n");

            ///返回的是不可变的数组, 当初存的是可变的
            NSLog(@"array value: %@ %@",[sys arrayForKey:@"array"],[sys arrayForKey:@"array"].class);
            NSLog(@"array value: %@ %@",[sys objectForKey:@"array"],[[sys objectForKey:@"array"] class]);
            NSLog(@"\n");

            ///返回的是不可变的字典, 当初存放的是可变的
            NSLog(@"dic value: %@ %@",[sys objectForKey:@"dic"],[[sys objectForKey:@"dic"] class]);
            NSLog(@"\n");

            ///返回的是不可变的data, 当初存放的是可变的
            NSLog(@"data value: %@ %@",[sys dataForKey:@"data"],[sys dataForKey:@"data"].class);
            NSLog(@"data value: %@ %@",[sys objectForKey:@"data"],[[sys objectForKey:@"data"]class]);
            NSLog(@"\n");


            NSLog(@"date value: %@ %@",[sys objectForKey:@"date"],[[sys objectForKey:@"date"]class]);
            NSLog(@"\n");


        });
    });

}



@end
