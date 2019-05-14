//
//  SQLTool.m
//  数据存储
//
//  Created by 刘泊 on 2019/5/8.
//  Copyright © 2019 LB. All rights reserved.
//

#import "SQLTool.h"

#import <sqlite3.h>

#define weakself() __weak typeof(self) weakSelf = self;

@interface SQLTool()
@property (nonatomic) sqlite3** sql_db;

/** 操作线程 */
@property (nonatomic,strong)  NSBlockOperation* taskOp;

/** 自定义串行队列 */
@property (nonatomic,strong) NSOperationQueue* taskQ;

/** 除开closeTask外所有的任务 */
@property (nonatomic,strong) NSMutableArray<NSBlockOperation*>* tasks;

/** 主要负责关闭数据库的任务 */
@property (nonatomic,strong) NSBlockOperation* closeTask;

/** 数据关闭后的回调 */
@property (nonatomic,copy) ToolSqlCallClose closeCallback;

/** 记录当前正在执行的任务 因为队列肯定在引用它 他的值就是taks的lastObject */
@property (nonatomic,weak) NSBlockOperation* taskingOp;

@property (nonatomic,copy) ToolSqlCallback connectSqlCallback;

@end


@implementation SQLTool
+ (instancetype _Nonnull)openSqliteWithPath:(NSString*)path
                                  openCall:(ToolSqlCallback)callback{
    if (path.length == 0)return nil;
    if (callback == nil) return nil;

    return [[self alloc] initWithPath:path openCallback:callback];
}

- (instancetype)initWithPath:(NSString*)path
            openCallback:(ToolSqlCallback)callback{
    if (self = [super init]) {
        _sqlPath = path.copy;
        self.connectSqlCallback = callback;
        [self initializeData];
        [self OpenSqlWith:callback];
    }
    return self;
}

#pragma mark - 打开数据库
- (void)OpenSqlWith:(ToolSqlCallback)callback{
    if (self.connect)return callback(false);
    NSParameterAssert(callback != nil);

    self.connectSqlCallback = callback;


    weakself();
    NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^{
        int result = sqlite3_open(weakSelf.sqlPath.UTF8String,weakSelf.sql_db);
        if (result == SQLITE_OK) {
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [weakSelf assignAvaiable:true];
                callback(true);
            }];
        }else{
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [weakSelf assignAvaiable:false];
                [weakSelf clearAllSate];
                callback(false);
            }];
        }
    }];
    [self.tasks addObject:op];
    [self.taskQ addOperation:op];
}


#pragma mark - 打开表
- (void)openTableWith:(NSString*_Nonnull)sql
      optionTableName:(NSString*_Nonnull)tName
           columnType:(NSArray<NSNumber*>*_Nonnull)types
             callback:(ToolSqlCallback _Nullable)callback{
    [self checkSqlCallback:callback];
    NSParameterAssert(sql.length!=0);
    NSParameterAssert(tName.length!=0);
    NSParameterAssert(types.count!=0);

    _tName = tName.copy;
    _types = types.copy;


    weakself();
    NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^{
        if (sqlite3_exec(*(weakSelf.sql_db), sql.UTF8String, NULL, NULL, NULL) == SQLITE_OK) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                callback(true);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                callback(false);
            }];
        }
    }];
    [self.tasks addObject:op];
    [self.taskQ addOperation:op];
}


#pragma mark - 重连数据库
- (void)againConnectWith:(ToolSqlCallback)callback{
    if (callback) {
        self.connectSqlCallback = callback;
    }
    [self OpenSqlWith:callback];
}

#pragma mark - 断开连接
- (void)closeCallback:(ToolSqlCallback _Nonnull)callback{
    [self checkSqlCallback:callback];


    ////如果当前有 记录的 关闭数据库的任务正在执行 直接返回关闭失败
    if (self.closeTask.executing)return;


    self.closeCallback = callback;



    /////查看当前有没有任务 没有任务就创建关闭的task 并直接添加到队列里去
    if (!self.tasks.count) {
        [self.taskQ addOperation:self.closeTask];
        return;
    }



    ////如果有任务 先停掉所有的任务 这里的任务里是没有 closetask的
    [_taskQ cancelAllOperations];


    ////从任务数组里取出 最开始添加的任务, 这个任务可能正在执行
    self.taskingOp = self.tasks.firstObject;

    ///移除掉所有的任务
    [self.tasks removeAllObjects];


    /**
    在队列里停掉所有的任务, 但是当前正在执行的也就是数组里的第一条, 查看他的状态


     如果 taskingOp 正在执行,
        > 那么逻辑上的步骤应该是
            1. 这个任务执行完成后 将任务删除, 所以表面上要有个引用,等到后面任务完成的时候释放掉
                1.1 实际上在没有从数组里删除所有任务前 强引用这个tasking 有taskQ和tasks
                1.2 所以直接从数组里将任务删掉, 剩下就只有taskQ强引用它
                1.3 用一个弱指针引用它, 为了方便
                1.4 任务执行完毕后, taskQ会在内部删除掉这个任务, 就没有强引用了

        > 实际做法
            1. 不查看状态 直接清空数组

     如果 taskingOp没有执行
        > 直接删掉所有的任务


     所以不管taskingOp的状态怎么样, 都直接清空数组
     */

    [self.taskQ addOperation:self.closeTask];
}

#pragma mark - 删除表
- (void)dropTableCallback:(ToolSqlCallback _Nonnull)callback{

    [self sqlCommonCallback:callback sql:[NSString stringWithFormat:@"drop table if exists %@",self.tName]];
}


#pragma mark - 插入
- (void)insertWithSql:(NSString*_Nonnull)sql _Method_Callback(Insert){
    [self sqlCommonCallback:callback sql:sql];
}


#pragma mark - 删除记录
- (void)deleteWithSql:(NSString*_Nonnull)sql _Method_Callback(Delete){
    [self sqlCommonCallback:callback sql:sql];
}


#pragma mark - 更新记录
- (void)updateWithSql:(NSString*_Nonnull)sql _Method_Callback(Update){
    [self sqlCommonCallback:callback sql:sql];
}


#pragma mark - 搜索 sql可以nil, 这个时候搜索的全部表的数据
- (void)selectWithSql:(NSString*_Nullable)sql
                  suc:(ToolSelectSucBlock _Nullable )sucCallback
                 fail:(ToolSelectFaiBlock _Nullable )faiCallback{

    NSParameterAssert(sucCallback!=nil);

    if (self.connect) {
        if (sql.length == 0)
            sql = [@"select * from {_table_};" stringByReplacingOccurrencesOfString:@"{_table_}" withString:self.tName];

        weakself();
        NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^{
            sqlite3_stmt* sqlSt = NULL;
            if (sqlite3_prepare_v2(*(weakSelf.sql_db), sql.UTF8String, -1, &sqlSt, NULL) == SQLITE_OK) {
                NSMutableArray* recordsArray = @[].mutableCopy;

                while (sqlite3_step(sqlSt) == SQLITE_ROW) {

                    NSMutableArray* column = [NSMutableArray arrayWithCapacity:weakSelf.types.count];
                    for(int i = 0; i < weakSelf.types.count; ++i){
                        TableColumnType type = [weakSelf.types[i] integerValue];

                        switch(type){

                            case TableColumnType_int:
                            case TableColumnType_char:
                            case TableColumnType_long:{
                                int ID = sqlite3_column_int(sqlSt, (int)i);
                                [column addObject:@(ID)];
                            }break;

                            case TableColumnType_text:{
                                const uint8_t* name = sqlite3_column_text(sqlSt, i);
                                if(strlen((const char*)name))
                                    [column addObject:[NSString stringWithFormat:@"%s",name]];
                                else [column addObject:@""];
                            }break;

                            case TableColumnType_double:
                            case TableColumnType_float:{
                                float money = sqlite3_column_double(sqlSt, 2);
                                [column addObject:@(money)];
                            }break;
                        }

                    }
                    [recordsArray addObject:column];
                }


                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    sucCallback(recordsArray);
                }];

                sqlite3_finalize(sqlSt);
            }else{
                if(faiCallback)faiCallback([NSError errorWithDomain:@"查询失败" code:NSNotFound userInfo:nil]);
            }
        }];

        [self.tasks addObject:op];
        [self.taskQ addOperation:op];

    }else{
        if(faiCallback)faiCallback([NSError errorWithDomain:@"查询失败" code:NSNotFound userInfo:nil]);
    }

}


#pragma mark - 获取列的名字 */
- (void)fetchTableColumnName:(void(^)(NSArray<NSString*>*))namesCallback{
    weakself();
    NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^{
        /////获取表里的列的名字 sql: PRAGMA table_info(表名)
        sqlite3_stmt* statement2;
        const char *getColumn = [[NSString stringWithFormat:@"PRAGMA table_info(%@)",weakSelf.tName] UTF8String];
        sqlite3_prepare_v2(*(weakSelf.sql_db), getColumn, -1, &statement2, nil);
        NSMutableArray* resultArray = [NSMutableArray arrayWithCapacity:weakSelf.types.count];
        while (sqlite3_step(statement2) == SQLITE_ROW) {
            char *nameData = (char *)sqlite3_column_text(statement2, 1);
            NSString *columnName = [[NSString alloc] initWithUTF8String:nameData];
            [resultArray addObject:columnName];
        }
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            if (namesCallback) {
                namesCallback(resultArray);
            }
        }];
        sqlite3_finalize(statement2);
    }];
    [self.tasks addObject:op];
    [self.taskQ addOperation:op];
}

#pragma mark - 获取多少记录 */
- (void)fetchTableRecords:(void(^)(int))countCallback{
    weakself();
    NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^{
        int count = 0;
        const char* sqlCount = [[NSString stringWithFormat:@"select count(rowid) from %@",weakSelf.tName] UTF8String];
        sqlite3_stmt* st = NULL;
        if (sqlite3_prepare_v2(*(weakSelf.sql_db), sqlCount, -1, &st, NULL) == SQLITE_OK) {
            if (sqlite3_step(st) == SQLITE_ROW) {
                count = sqlite3_column_int(st, 0);
            }
        }
        sqlite3_finalize(st);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (countCallback) {
                countCallback(count);
            }
        }];
    }];

    [self.tasks addObject:op];
    [self.taskQ addOperation:op];
}






#pragma mark - 状态清零
- (void)clearAllSate{
    if(_sqlPath.length == 0) _avaiable = false;
    _connect = false;
    if (!_avaiable) {
        return;
    }
    if (self.closeTask.finished){
        self.closeTask = nil;
        self.closeCallback = nil;
    }
}

- (void)assignAvaiable:(bool)sta{
    _avaiable = sta;
}


#pragma mark - 增删改公用的代码
- (void)sqlCommonCallback:(ToolSqlCallback)callback
                      sql:(NSString*)sql{
    [self checkSqlCallback:callback];

    if(sql.length == 0) callback(false);

    if(self.connect){
        weakself();
        NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^{
            if (sqlite3_exec(*(weakSelf.sql_db), sql.UTF8String, NULL, NULL, NULL) == SQLITE_OK) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    callback(true);
                }];
            }else{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    callback(false);
                }];
            }
        }];

        [self.tasks addObject:op];
        [self.taskQ addOperation:op];
        return;
    }

    callback(false);
}

#pragma mark - 后台去初始化一些数据
- (void)initializeData{
    _sql_db = malloc(sizeof(void*));
    *_sql_db = NULL;
    _taskQ = [[NSOperationQueue alloc] init];
}
#pragma mark - 检查block
- (void)checkSqlCallback:(ToolSqlCallInsert)callback{
    NSParameterAssert(callback != nil);
}

- (NSMutableArray<NSBlockOperation *> *)tasks{
    if (!_tasks) {
        _tasks = [NSMutableArray arrayWithCapacity:5];
    }
    return _tasks;
}

#pragma mark - lazy
- (NSBlockOperation*)closeTask{
    if (!_closeTask) {
        weakself();
        _closeTask = [NSBlockOperation blockOperationWithBlock:^{
            __block int result = sqlite3_close((*weakSelf.sql_db));
            if (result == SQLITE_OK) {
                [weakSelf clearAllSate];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if(weakSelf.closeCallback) weakSelf.closeCallback(result);
                }];
            }
        }];
    }
    return _closeTask;
}
@end
