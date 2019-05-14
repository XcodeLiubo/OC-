//
//  LBLog.h
//  Runtime
//
//  Created by 刘泊 on 2019/5/14.
//  Copyright © 2019 LB. All rights reserved.
//

#ifndef _LBLOG_H
#define _LBLOG_H

#if __OBJC__

#define getTypeStr(_V) {\
NSString* str = @(@encode(__typeof(_V)));\
if([str hasSuffix:@"c]"]){\
str = @"s";\
}else if([str isEqualToString:@"i"]){\
str = @"C";\
}\
NSLog([@"%" stringByAppendingString:str],_V);\
}
#define LogMaxArg 10
#define LogArgList0 10,9,8,7,6,5,4,3,2,1

#define Log(...) Log_args(LogMaxArg,__VA_ARGS__,LogArgList0)(__VA_ARGS__)
#define Log_args(N,...) Log_Find_index(__VA_ARGS__,LogArgList0)
#define Log_Find_index(_0,_1,_2,_3,_4,_5,_6,_7,_8,_9,...) LogFun(Log_,__VA_ARGS__)
#define LogFun(Fun,F,...) Fun##F

#define Log_1(_V)                   getTypeStr(_V);

#define Log_2(_V,...)               getTypeStr(_V);Log_1(__VA_ARGS__)

#define Log_3(_V,...)               getTypeStr(_V);Log_2(__VA_ARGS__)

#define Log_4(_V,...)               getTypeStr(_V);Log_3(__VA_ARGS__)

#define Log_5(_V,...)               getTypeStr(_V);Log_4(__VA_ARGS__)

#define Log_6(_V,...)               getTypeStr(_V);Log_5(__VA_ARGS__)

#define Log_7(_V,...)               getTypeStr(_V);Log_6(__VA_ARGS__)

#define Log_8(_V,...)               getTypeStr(_V);Log_7(__VA_ARGS__)

#define Log_9(_V,...)               getTypeStr(_V);Log_8(__VA_ARGS__)

#define Log_10(_V,...)              getTypeStr(_V);Log_9(__VA_ARGS__)
#endif

#endif
