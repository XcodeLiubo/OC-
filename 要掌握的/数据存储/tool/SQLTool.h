//
//  SQLTool.h
//  数据存储
//
//  Created by 刘泊 on 2019/5/8.
//  Copyright © 2019 LB. All rights reserved.
//

#import <Foundation/Foundation.h>




typedef void(^ToolSelectSucBlock)(NSArray<NSArray*>*_Nullable);

typedef void(^ToolSelectFaiBlock)(NSError*_Nonnull);

typedef void(^ToolSqlCallback)(bool result);

typedef ToolSqlCallback ToolSqlCallInsert;

typedef ToolSqlCallback ToolSqlCallUpdate;

typedef ToolSqlCallback ToolSqlCallDelete;

typedef ToolSqlCallback ToolSqlCallDropT;

typedef ToolSqlCallback ToolSqlCallClose;

#define _Method_Callback(_des_) callback:(ToolSqlCall##_des_ _Nonnull)callback


#define FUN_ASYN()


typedef enum:NSInteger {
    TableColumnType_int = 0,
    TableColumnType_char,
    TableColumnType_long,
    
    TableColumnType_text,

    TableColumnType_double,
    TableColumnType_float
}TableColumnType;



@interface SQLTool<__covariant _type_> : NSObject

/** 当前对象是否可用, 意思是如果打开表失败, 所有的操作都没有意义 */
@property (nonatomic,readonly) bool avaiable;

/** sqlite的路径 如果打开表失败 是nil */
@property (nonatomic,strong,readonly) NSString* _Null_unspecified sqlPath;

/** 表名 如果打开表失败 是nil */
@property (nonatomic,strong,readonly) NSString* _Null_unspecified tName;

/** 表里的列的类型 具体看 TableColumnType*/
@property (nonatomic,strong) NSArray<NSNumber*>*_Null_unspecified types;

/** 是否连接状态 如果打开表则true, 关闭则false*/
@property (nonatomic,getter=isConnect,readonly) bool connect;

/** 打开表 数据库*/
+ (instancetype _Nonnull)openSqliteWithPath:(NSString*_Nullable)path
                                   openCall:(ToolSqlCallback _Nullable)callback;

/** 打开表
    如果没有表会创建一个新的
    tName必须传 查询的时候要用到
    types表示列的类型 查询的时候要用到 必须传 具体看TableColumnType*/
- (void)openTableWith:(NSString*_Nonnull)sql
      optionTableName:(NSString*_Nonnull)tName
           columnType:(NSArray<NSNumber*>*_Nonnull)types
             callback:(ToolSqlCallback _Nullable)callback FUN_ASYN();

/** 断开后可以再尝试连接 */
- (void)againConnectWith:(ToolSqlCallback _Nullable)callback FUN_ASYN();

/** 断开连接 */
- (void)closeCallback:(ToolSqlCallClose _Nonnull)callback FUN_ASYN();

/** 删除表 */
- (void)dropTableCallback:(ToolSqlCallDropT _Nonnull)callback FUN_ASYN();

/** 搜索
    sql可以nil, 这个时候搜索的全部表的数据
    typesArray 每一列的数据类型 具体看 TableColumnType
 */
- (void)selectWithSql:(NSString*_Nullable)sql
                  suc:(ToolSelectSucBlock _Nullable )sucCallback
                 fail:(ToolSelectFaiBlock _Nullable )FaiCallback FUN_ASYN();


/** 获取列的名字 */
- (void)fetchTableColumnName:(void(^_Nullable)(NSArray<NSString*>*_Null_unspecified))namesCallback;

/** 获取多少记录 */
- (void)fetchTableRecords:(void(^_Nullable)(int))countCallback;


/** 插入 */
- (void)insertWithSql:(NSString*_Nonnull)sql _Method_Callback(Insert) FUN_ASYN();


/** 删除记录 */
- (void)deleteWithSql:(NSString*_Nonnull)sql _Method_Callback(Delete) FUN_ASYN();


/** 更新记录 */
- (void)updateWithSql:(NSString*_Nonnull)sql _Method_Callback(Update) FUN_ASYN();

@end
#undef FUN_ASYN
