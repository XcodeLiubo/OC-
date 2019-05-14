//
//  SQLiteVC.m
//  数据存储
//
//  Created by 刘泊 on 2019/5/8.
//  Copyright © 2019 LB. All rights reserved.
//

#import "SQLiteVC.h"

#import <sqlite3.h>

@interface SQLiteVC ()

@end

@implementation SQLiteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self test];
}


- (void)test{

    /**
     sqlite3 是垮平台的数据库存储引擎, 因为是c语言写的,所以能垮平台
     优点:
     轻量级
     耗费资源小
     速度快

     缺点:
     纯C的API
     */

    NSString* documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, 1).firstObject;

    NSString* sqlPath = [documentPath stringByAppendingPathComponent:@"testSqlite.sqlite"];



    /**
        打开数据库文件
            如果文件不存在,会自动在这个目录下创建
            同时会初始化 数据库结构体sqlite3 *, 后面所有的增删改成都是通过这个结构体为前提的

     */
    sqlite3* db = NULL;

    typedef int SQLiteState;
    SQLiteState state = sqlite3_open(sqlPath.UTF8String,&db);
    if (state == SQLITE_OK) {
        NSLog(@"打开数据库文件成功");
    }else{

        NSLog(@"打开数据库文件失败");
    }





    ////建表
    SQLiteState createTableState = !SQLITE_OK;
    if (SQLITE_OK == state) {
        char* s = "CREATE TABLE IF NOT EXISTS t_car (id integer PRIMARY KEY AUTOINCREMENT,\
        name text NOT NULL,\
        money float NOT NULL,\
        time text NOT NULL,\
        brand text NOT NULL);";

        char* error = NULL;



        createTableState = sqlite3_exec(db, s, NULL, NULL, &error);

        if (SQLITE_OK == createTableState) {
            NSLog(@"建表成功");
        }else{
            NSLog(@"建表失败");
        }
    }






    /////获取数据库里的表名 可以获取到上面创建的t_car
    sqlite3_stmt *statement;
    const char *getTableInfo = "select * from sqlite_master where type='table' order by name";
    sqlite3_prepare_v2(db, getTableInfo, -1, &statement, nil);
    while (sqlite3_step(statement) == SQLITE_ROW) {
        char *nameData = (char *)sqlite3_column_text(statement, 1);
        NSString *tableName = [[NSString alloc] initWithUTF8String:nameData];
        NSLog(@"name:%@",tableName);
    }


    sqlite3_finalize(statement);



    /////获取表里的列的名字 sql: PRAGMA table_info(表名)
    sqlite3_stmt* statement2;
    const char *getColumn = "PRAGMA table_info(t_car)";
    sqlite3_prepare_v2(db, getColumn, -1, &statement2, nil);
    while (sqlite3_step(statement2) == SQLITE_ROW) {
        char *nameData = (char *)sqlite3_column_text(statement2, 1);
        NSString *columnName = [[NSString alloc] initWithUTF8String:nameData];
        NSLog(@"columnName:%@",columnName);
    }

    sqlite3_finalize(statement2);





    ////新增 insert
    if (SQLITE_OK == createTableState) {
        NSString* name = @"柯尼塞格one1";
        float price = 1.256e7;
        NSString* time = @"2001";
        NSString* brand = @"柯尼塞";
        NSString* insertSql = [NSString stringWithFormat:@"INSERT INTO t_car (name, money, time, brand) VALUES('%@', %.f, '%@', '%@');",name,price,time,brand];

        char* error = NULL;
        sqlite3_exec(db, insertSql.UTF8String, NULL, NULL, &error);
        if (!error) {
            NSLog(@"插入成功");
        }else{
            NSLog(@"插入失败 %s",error);
        }
    }





    ////前提是有表里有记录
    sqlite3_stmt *stmt = NULL;
    char sql[200];

    ////从零开始取1条数据
    sprintf(sql, "SELECT * FROM %s limit 0,1", "t_car");
    sqlite3_prepare_v2(db, sql,-1,&stmt,0);
    if(stmt)
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            int nCount = sqlite3_column_count(stmt);
            for (int i=0; i<nCount; i++)
            {
                int nType = sqlite3_column_type(stmt, i);
                switch (nType)
                {
                    case 1:
                        //SQLITE_INTEGER
                        NSLog(@"int");
                        break;
                    case 2:
                        //SQLITE_FLOAT
                        NSLog(@"float");
                        break;
                    case 3:
                        //SQLITE_TEXT
                        NSLog(@"text");
                        break;
                    case 4:
                        //SQLITE_BLOB
                        NSLog(@"blob");
                        break;
                    case 5:
                        //SQLITE_NULL
                        NSLog(@"null");
                        break;
                }
            }
            break;
        }
        sqlite3_finalize(stmt);
        stmt = NULL;
    }







    /////查询语句
    NSString* searchSql = @"select * from t_car;";
    sqlite3_stmt* sqlSt = NULL;

    if (sqlite3_prepare_v2(db, searchSql.UTF8String, -1, &sqlSt, NULL) == SQLITE_OK) {
        while (sqlite3_step(sqlSt) == SQLITE_ROW) {

            ////第一列的 值 因为是int 所以要调用相应的int函数
            int ID = sqlite3_column_int(sqlSt, 0);


            ////第二列name的值 注意调用相应的text函数
            const uint8_t* name = sqlite3_column_text(sqlSt, 1);


            ////第三列money的值 这里调用的是double函数
            float money = sqlite3_column_double(sqlSt, 2);

            ////第四列time的值 调用text
            const uint8_t* time = sqlite3_column_text(sqlSt, 3);


            ////第五列
            const uint8_t* brand = sqlite3_column_text(sqlSt, 4);

            NSLog(@"ID:%d   name: %s    money: %.f  time: %s    brand:%s",ID,name,money,time,brand);
        }
        sqlite3_finalize(sqlSt);
    }





    /////查询表里有多少记录
    {
        int count = 0;
        const char* sqlCount = @"select count(rowid) from t_car".UTF8String;
        sqlite3_stmt* st = NULL;
        if (sqlite3_prepare_v2(db, sqlCount, -1, &st, NULL) == SQLITE_OK) {
            if (sqlite3_step(st) == SQLITE_ROW) {
                count = sqlite3_column_int(st, 0);
            }
        }
        sqlite3_finalize(st);
        NSLog(@"count: %d",count);
    }






    ////更新数据的某条记录
    {
        /////从1开始计数的 不要搞错了
        const char* sql = @"update t_car set name = '布加迪' where id = 1;".UTF8String;

        if (sqlite3_exec(db, sql, NULL, NULL, NULL) == SQLITE_OK) {
            NSLog(@"更新成功");
        }else{
            NSLog(@"更新失败");
        }


    }





    /////删除某一条记录
    {
        /////从1开始计数的 不要搞错了
        const char* sql = @"delete from t_car where name = '布加迪';".UTF8String;

        if (sqlite3_exec(db, sql, NULL, NULL, NULL) == SQLITE_OK) {
            NSLog(@"删除成功");
        }else{
            NSLog(@"删除失败");
        }
    }







    /////删除表
    {
        /////从1开始计数的 不要搞错了
        const char* sql = @"drop table if exists t_car".UTF8String;

        if (sqlite3_exec(db, sql, NULL, NULL, NULL) == SQLITE_OK) {
            NSLog(@"删除表成功");
        }else{
            NSLog(@"删除表失败");
        }
    }






    sqlite3_close(db);


}


@end
