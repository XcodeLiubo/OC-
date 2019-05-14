//
//  CoreDataVC.m
//  数据存储
//
//  Created by 刘泊 on 2019/5/8.
//  Copyright © 2019 LB. All rights reserved.
//

#import "CoreDataVC.h"

#import "SQLTool.h"

#define weakSelf() __weak typeof(self) weakself = self

#import <CoreData/CoreData.h>

@interface CoreDataVC ()
@property (nonatomic,strong) SQLTool* tool;
@end

@implementation CoreDataVC

- (void)viewDidLoad {
    [super viewDidLoad];

    /**
     coreData 是ios5后, 苹果提供的原生的用于对象化管理数据并持久化的框架
        本质是将底层数据库封装成对象就行管理
        数据库只是他的一个功能, 还有别的功能


     存储方式
        sqlite和二进制2种

     优点:
        1 苹果原生支持
        2 面向对象
        3 性能好



     概念 图(coredata1.png)
        > PersistentStore
            store是存储\仓库的意思
            Persistent是持久的意思
            所以PersistentStore就是持久仓库的意思, 也就是数据正在存储的地方

        PS:上面说的coredata有2种存储方式(sql和二进制), 就是有操作他的调度器来指定的




        > DataModel
            字面是数据模型, 对应的类为NSManagedObjectModel
            NSManagedObjectModel创建后会将指定的bundle下所有的 .xcdatamodeld文件里的 entitles 关联起来
            entitles是定义了数据结构,但不是数据, 就想新建了一个表,给了表字段, 他对应在代码里的类是NSManagedObject(包括子类)





        > PersistentStoreCoordinate
            对应的类是NSPersistentStoreCoordinate
            用来操作 读写存储仓库(PersistentStore)
            创建类的时候, 指定用存储方式(sql\二进制)来读写




        > ManagedObjects
            1.对应的类为NSManagedObject

            2.上面提出的 DataModel(NSManagedObjectModel)里关联的 .xcdatamodeld文件里的 entitles就对应NSManagedObject和他其子类

            3. 一个ManagedObject对应entitle下一条记录,ManagedObject支持kvc
                eg entitle下有个字段叫 name, 则 [mgrObjInstance setValue:value forKey:@"name"]

            4.如果有关联(Relationship)
                eg Employer(entitle)老板 和 Employee(entitle)员工, Employee员工表里有一个字段WhereFromWork, 这个字段用Rrelationship链接到了对应的Employer老板, 那么要查询Employer里的某个字段, 就可以通过
                [employeeInstance valueForKeyPath: @"WhereFromWork.name"]




        > ManagedObjectContext
            1. 对应的类为 NSManagedObjectContext

            2. 从图(coredata1.png)可以看到
                NSManagedObjectContext包含了所有的ManagedObjects
                连接着调度器

            3. 记录了ManagedObjects的所有改变

            4. 要存储数据的时候, 就是通过这个对象来进行的

            5. 一个应用至少存在一个NSManagedObjectContext, 也可以多个(多线程), 当然多个的时候并不是线程安全的, 自己做好处理

            6. 调用对象的save即可保存





        > FetchRequest(FetchRequestController)





        > Fetched Results Controller
            1. 对应的类是NSFetchedResultsController, 这个类用来管理CoreData FetchReuqest返回的对象

            2. 创建NSFetchedResultsController, 必须先创建Fetch Request
                Fetch Request描述了详细的查询规则,也可以添加查询结果的排序描述

            3. FetchResultController根据已经创建的FetchRequest来创建
                使用FetchRequest来保证他所关联的数据的新鲜性
                创建FetchResultController要做一下初始化 即发送 PerformFetch








     使用步骤
        >创建数据模型文件
            方案1 创建工程的时候勾选 CoreData选项
                1. 创建好的工程会有一个 "你工程的名字".xcdatamodeld
                2. 这种方式 appdelegate里会有一些初始化的代码

            方案2 手动创建文件
                但是要注意的是 创建好的xxx.xcdatamodeld 要注意选择对应的语言环境
                    点击xxx.xcdatamodeld, 然后目标转移到编译器代码区域的右边的区域内(就是xib里设置view属性的区域, 选择文件说明, 然后将对应的语言环境改为当前工程的环境, 是oc就选oc否则就是swift)






        > 设置CoreData堆栈相关的类
            1 PersistentContainer(NSPersistentContainer)
            2 Model(NSManagedObjectModel)
            3 Context(NSManagedObjectContext)
            4 StoreCoordinator(NSPersistentContainer)


            


     */

//    [[NSPersistentContainer new] viewContext] updatedObjects
}



@end
