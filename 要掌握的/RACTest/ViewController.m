//
//  ViewController.m
//  RACTest
//
//  Created by 刘泊 on 2019/5/4.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>

#import <RACReturnSignal.h>

#import "RACTModel.h"


#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import <Masonry/Masonry.h>
@interface ViewController ()
@property (nonatomic,strong) UITextField* tf;
@property (nonatomic,strong) UILabel* lab;

@property (nonatomic,weak) NSString* tfText;

@property (nonatomic,weak) UIButton* btn;

@property (nonatomic,strong) RACTModel* model;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITextField* tf = [UITextField new];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.placeholder = @"输入...";
    [self.view addSubview:tf];
    _tf = tf;
    [_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(50);
        make.height.equalTo(40);
        make.left.offset(15);
        make.right.offset(-15);
    }];



    UILabel* lab = [UILabel new];
    lab.backgroundColor = UIColor.grayColor;
    lab.text = @"";
    lab.textAlignment = 1;
    lab.textColor = UIColor.redColor;
    [self.view addSubview:lab];
    _lab = lab;
    [_lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(self.tf.bottom).offset(10);
        make.left.offset(15);
        make.height.equalTo(30);
    }];


    UIButton* btn = [UIButton buttonWithType:0];
    [btn setTitle:@"选中" forState:1<<2];
    [btn setTitle:@"未选中" forState:0];
    [btn setTitleColor:UIColor.redColor forState:1<<2];
    [btn setTitleColor:UIColor.grayColor forState:0];
    [self.view addSubview:btn];
    _btn = btn;
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(lab.bottom).offset(20);
    }];

//    [self coldSignal];

//    [self hotSignal];


//    [self coldConvertToHot];


//    [self mapAndFilter];

//    [self concat];

//    [self merge];

//    [self singleBind];

//    [self eachBind];


    [self command];

}



#pragma mark - 冷信号
- (void)coldSignal{
    /** 冷信号
        除开 RACSubject 及其子类 RACSingal的其它子类都是冷信号
     */

    ////创建冷信号
    RACSignal* signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {


       /**
            记住这是一个block, 说白了就是我们要做的操作, 这个block操作肯定被signal记录了, 等待将来的 某个时间\某个动作 来被调用的(即触发)

            在block参数里 传回了一个遵循 RACSubscriber协议 的对象, 我们做的操作是 在主线程不同的时间点 发送了值

            当block被触发, 也就是被调用的时候, 我们的操作就会被执行
        */



        ////立即发送 通过源码可以看到内部 找到了之前存下来的block 然后取出来调用了
        [subscriber sendNext:@"1"];


        ////0.5秒后发送
        [[RACScheduler mainThreadScheduler]afterDelay:.5f schedule:^{
            [subscriber sendNext:@"2"];
        }];



        ////2秒后主线程再发送一个信号
        [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
            [subscriber sendNext:@"3"];
        }];


        return nil;
    }];
    



    /**
        订阅信号, 效果上实现了接收block1内的 sendNext的事件
       调用冷信号的 subscribeNext 方法, 触发了 当初被记录的block(block被调用了), 然后当初block内部的操作就会被触发
        subscribeNext方法也传递了一个block, 当然这个block也需要被调用, 这个block被调用的时机就是 当初创建信号时block内部的操作sendNext

        take:表示取信号的次数 从头开始取 这里的效果是指取了block1的第一次send
     */
    [[signal take:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];


    /**
     ps:如果我们要实现这样的效果

     1> 创建信号signal的时候, 将我们的操作block1 保存起来
     2> 调用signal的subscribeNext方法时, 内部找到当时存取的block1, 然后创建subscriber作为block1的参数, 调用一下block1
     3> block1被调用, 我们在block1内部的动作 sendNext也会随之调用
     4> 要想继续实现 sendNext: 将发送的结果传出来(比如@3) 要做的就是 内部再调用一次block, 将@3通过block的形式传出来
        4.1 所以第2步 subscribeNext:的参数block2就是用来被 block1内部 sendNext:来调用的

     事实上rac也是如此
        之所以成为冷信号, 是因为信号的发送(block1内部的操作 sendNext:objc)需要外界来先订阅(即-[RACSignal subscribeNext:block2])才能被触发
        事实上RACSignal也没有 sendXXX之类的方法

        所以只有到外界手动订阅(-[RACSignal subscribeNext:block]), block1里才会执行, 即从block1触发的时候, 里面3个时间点不同的发送事件,外界都能一一获取到
     */



}


#pragma mark - 热信号
- (void)hotSignal{
    /**
        RACSubject 及其子类, 他们也是继承RACSignal类

     */

    ////测试一下 通过父类的方法创建出来的实例是否也 类似RACSignal冷信号的特性
    RACSubject* sub = [RACSubject createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {

        ////订阅者发送
        [subscriber sendNext:@"1"];

        return nil;
    }];

    @try {
        [sub sendNext:@1];
    } @catch (NSException *exception) {
        NSLog(@"error class: %@",sub.class);
        ///-[RACDynamicSignal sendNext:]: unrecognized selector
        NSLog(@"error reason: %@",exception.reason);
    } @finally {
        [sub subscribeNext:^(id  _Nullable x) {
            NSLog(@"xxx: %@",x);
        }];
    }


    ////PS:上面的测试说明了 通过父类的方法创建的信号都是被动触发block的, 所以都是所谓的冷信号






    ////真正的热信号

    ///通过本身的类方法创建的对象
    sub = [RACSubject subject];

    ///自己发送
    [sub sendNext:@2];


    ////自己订阅(接收)
    [sub subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    ////上面这3步 并没有接收到, 是因为在订阅之前就主动send了, 这个时候并没有订阅者, 所以要将订阅的代码放到发送的前面




    ////先发送,再订阅也可以收到信号 RACReplaySubject ---> RACSubject
    RACReplaySubject* rSub = [RACReplaySubject subject];
    [rSub sendNext:@"rsub"];
    [rSub subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];






}



#pragma mark - 冷信号转热信号
- (void)coldConvertToHot{


    ////创建一个冷信号
    RACSignal* signal = [RACSubject createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@1];

        [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
            [subscriber sendNext:@2];
        }];

        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
            [subscriber sendNext:@3];
        }];

        return nil;
    }];

    ////冷信号的输出结果 依次输出
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"%@",x);
        }];
    }];




    NSLog(@"convert after ....");
    ///将冷信号转为热信号
    RACMulticastConnection* con = [signal publish];
    [con connect];

    ///指数从了 3这个结果 变成了热信号
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [con.signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"after: %@",x);
        }];
    }];


    ////当多次订阅同一个信号的时候, 利用RACMulticastConnection可以防止block执行多次
    __block int num = 0;
    NSLog(@"block out num:%p",&num);
    RACSignal* signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"num block value: %d",++num);
        NSLog(@"block in num:%p",&num);
        return nil;
    }];

#if 0
    ///如果直接singnal2 在不同的时间点 去订阅(subscribeNext), 那么block会执行多次
    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
        [signal2 subscribeNext:^(id  _Nullable x) {

        }];
    }];

    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [signal2 subscribeNext:^(id  _Nullable x) {

        }];
    }];
#elif 1

    ////只会执行一次block
    RACMulticastConnection* con2 = [signal2 publish];
    [con2.signal subscribeNext:^(id  _Nullable x) {

    }];

    [con2.signal subscribeNext:^(id  _Nullable x) {

    }];
    [con2 connect];


#endif


}


#pragma mark - map
- (void)mapAndFilter{

#if 0
    /**
     实现的效果是 文本框输入什么, RAC里监听的就会被赋值什么 注意类型匹配
     */
    RAC(_lab,text) = [_tf.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return value;
    }];

    ////这里测试
    [[_tf.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return value;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@ %@",x,self.tfText);
    }];

#elif 1
    RAC(_lab,text) = [[_tf rac_textSignal] filter:^BOOL(NSString * _Nullable value) {
        return [value isEqualToString:@"1"];
    }];

#endif




}


#pragma mark - concat
- (void)concat{
    //NSLog(@"%@", [@[] arrayByAddingObjectsFromArray:@[@1]]);
    RACSequence* seque1 = @[@1,@3,@5].rac_sequence;
    RACSequence* seque2 = @[@2,@4,@6].rac_sequence;
    RACSequence* seque = [seque1 concat:seque2];
    [seque.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    

}


#pragma mark - 合并相关
- (void)merge{

    ///当多个信号的操作是同样的代码时
    RACSubject* subject1 = [RACSubject subject];
    RACSubject* subject2 = [RACSubject subject];


#if 0
    ////合并成一个
    [[subject1 merge:subject2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"merge: %@",x);
    }];
    ////sub1 和sub2 都是公用一份操作
    [subject1 sendNext:@1];
    [subject2 sendNext:@2];
#elif 0



    ////当2个信号合并后, 操作的执行 只有等2个信号都发送了 才会执行

    [[subject1 zipWith:subject2] subscribeNext:^(id  _Nullable x) {
        ///x会被包装成一个RACTwoTuple, 这里会等到 sub1 和 sub2 都发送完毕后才回来
        NSLog(@"zipWith: %@",x);
    }];

    [subject1 sendNext:@1];
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [subject2 sendNext:@2];
    }];



#elif 0


    ////合并多个信号 和2一样, 这里是2个以上
    RACSubject* sub3 = [RACSubject subject];
    [[RACSignal combineLatest:@[sub3,subject1,subject2] reduce:^id _Nonnull(id arg3, id arg1, id arg2){
        return arg1;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"most sub zipWith %@",x);
    }];


    [sub3 sendNext:@3];
    [[RACScheduler mainThreadScheduler]afterDelay:2 schedule:^{
        [subject1 sendNext:@1];
    }];

    [[RACScheduler mainThreadScheduler]afterDelay:4 schedule:^{
        [subject2 sendNext:@2];
    }];
#elif 1

//    [self rac_liftSelector:@selector(description) withSignalsFromArray:@[subject1,subject2]];


#endif


}

#pragma mark - 单项绑定
- (void)singleBind{


    @weakify(self);

#if 0

    ///tf的文本改变影响 lab
    [[self.tf.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        if ([value isEqualToString:@"123"])return @"999";
        return value;
    }]subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.lab.text = x;
    }];


    ///tf的文本改变影响 model
    [self.tf.rac_textSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.model.text = x;
        NSLog(@"model: %@",self.model.text);
    }];

    /////上面实现了 tf单向改变lab和model, 2者结合起来就是一对多 当然可以合起来写 即将2步的处理放到同一个订阅的代码里

#elif 0
    /**
        将 tf.rac_textSignal 转换成热信号, 然后通过热信号去订阅不同的行为

     */
    RACMulticastConnection* mucon = [self.tf.rac_textSignal publish];

    ///这个订阅 表示 tf的文本改变了 就会改变lab的text
    [mucon.signal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.lab.text = x;
    }];

    ///这个订阅 表示 tf的文本改变了 就会改变 model的text
    [mucon.signal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.model.text = x;
        NSLog(@"model: %@",x);
    }];


    ////一定要调用 connect
    [mucon connect];

    ///最后的效果 也可以避免 signal 订阅的时候 多次调用block的问题

#elif 1

    ////model的text变化 影响lab的text


    /**
     方案1 model提供一个信号的属性在.h, 内部KVO text, 然后内部发送

     */

    ////model的改变 触发text的改变 其实就是block 只不过通过rac的方式来写
    [self.model.textSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.tf.text = x;
    }];




    /**
        方案2
        直接在外部绑定 效果是model的card改变后, lab的文本也跟着变化
     */
    RAC(self.lab,text) = RACObserve(self.model, card);





    /////按钮点击切换状态 然后改变model的bool值
    [[self.btn rac_signalForControlEvents:1<<6]subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        x.selected = !x.isSelected;

        ////或者外部再用 kvo绑定
        //self.model.userSel = x.selected;
    }];

    ///
    RAC(self.model,userSel) = RACObserve(self.btn, selected);






    

#endif

}

#pragma mark - 双向绑定
- (void)eachBind{
    /**
        RACChannel 可以被理解为一个双向链接, 这个链接的两端都是 RACSignal的实例, 彼此可以互通消息
     */

    RACChannelTerminal* a = RACChannelTo(self.model,text);



#if 0
    [[a map:^id _Nullable(id  _Nullable value) {
        return value;
    }]subscribe:b];


    RACChannelTerminal* b = RACChannelTo(self.tf,text);
    [[b map:^id _Nullable(id  _Nullable value) {
        if ([value isEqualToString:@"123"]) {
            return @"999999";
        }
        return value;
    }]subscribe:a];
#elif 1


    [[a map:^id _Nullable(id  _Nullable value) {
        return value;
    }]subscribe:self.tf.rac_newTextChannel];

    [[self.tf.rac_newTextChannel map:^id _Nullable(NSString * _Nullable value) {
        if ([value isEqualToString:@"123"]) {
            return @"999999";
        }
        return value;
    }] subscribe:a];

    @weakify(self);
    [self.tf.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        NSLog(@"input after model's text:   %@",self.model.text);
    }];
#endif
}


#pragma mark - RACCommand
- (void)command{

#if 0
    RACCommand* command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {

            ////command execute:的时候发送的参数
            NSLog(@"%@",input);

            return [RACDisposable disposableWithBlock:^{
                NSLog(@"被销毁");
            }];
        }];
    }];

    [command execute:@"123"];

#elif 0
    ///里面创建的信号 如果发送信号了, 要怎么接收呢? extute 返回了这个信号
    RACCommand* cmd2 = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"input: %@",input);
        RACSignal* signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"excute after 发送123"];
            return nil;
        }];
        /// [RACSubject subject]: create signal: 0x600003ccd4a0 RACSubject
        /// [RACSignal createSignal:  create signal: 0x6000038612a0 RACDynamicSignal
        NSLog(@"create signal: %p %@",signal, signal.class);
        return signal;
    }];



    ////执行
    RACSignal* reciveSignal = [cmd2 execute:@"excute"];




    ////[RACSubject subject]  reciveSignal: 0x6000029ee780 RACReplaySubject
    ////[RACSignal createSignal reciveSignal: 0x600002d4efc0 RACReplaySubject
    NSLog(@"reciveSignal: %p %@",reciveSignal,reciveSignal.class);

    ///这里订阅一下excute里发送的信号
    [reciveSignal subscribeNext:^(id  _Nullable x) {
        ///excute after 发送123
        NSLog(@"%@",x);
    }];


    ////没有效果了
    [cmd2 execute:@"excute2"];


#elif 0
    RACCommand* cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {

        RACSignal* signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {

            [subscriber sendNext:@"123"];

            return nil;
        }];

        NSLog(@"excute after %p",signal);
        return signal;

    }];

//    [[cmd executionSignals] subscribeNext:^(id  _Nullable x) {
//        ///excutionSignals after :<RACDynamicSignal: 0x600003be40a0> name:
//        NSLog(@"excutionSignals after :%@",x);
//
//
//        ///这里的x是cmd创建的时候 里面创建的signal
//        RACSignal* signal = x;
//        [signal subscribeNext:^(id  _Nullable x) {
//            NSLog(@"recive %@",x);
//        }];
//
//
//    }];


    ////这种写法比上面那个简洁一些, 不用转换, 直接拿到之前创建的信号 接收最新的信号
    [cmd.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];


    ////必须在执行 excute之前执行
    [cmd execute:@"excute"];

#elif 0
    RACCommand* cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"%@",input);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSLog(@"send before");
            [subscriber sendNext:@"send123"];
            NSLog(@"send end");

            return nil;
        }];
    }];

    [cmd.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"recive: %@",x);
    }];

    [cmd.executing subscribeNext:^(NSNumber * _Nullable x) {
        if (x.boolValue) {
            NSLog(@"执行中....");
        }else{
            NSLog(@"执行完毕");
        }
    }];

    [cmd execute:@"excute"]; ///这里会打印顺序  执行完毕 ---> excute ----> 执行中.... ----> send before ----> recive: send123 ---> send end

    ///发现 最开始的时候 就执行完毕了 改进看下一个if


#elif 1
    RACCommand* cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"%@",input);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSLog(@"send before");
            [subscriber sendNext:@"send123"];
            NSLog(@"send end");
            [subscriber sendCompleted];

            return nil;
        }];
    }];

    [cmd.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"recive: %@",x);
    }];

    [[cmd.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        if (x.boolValue) {
            NSLog(@"执行中....");
        }else{
            NSLog(@"执行完毕");
        }
    }];

    [cmd execute:@"excute"]; ////excute --> 执行中.... --> send before ---> recive: send123  ---> send end -> 执行完毕

#endif





}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
#if 0
    self.model.text = @(arc4random_uniform(999)).stringValue;
    self.model.card = @(arc4random_uniform(0xffffffff)).stringValue;

    NSLog(@"%d",_model.userSel);
    NSLog(@"改变model的text后 %@",self.model.text);
#endif
}



- (RACTModel *)model{
    if (_model)
        return _model;
    _model = [RACTModel new];
    return _model;
}
@end
