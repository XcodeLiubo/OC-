//
//  ShopCell.m
//  MVP设计模式
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ShopCell.h"

#import "ShopModel.h"

#import "ShopVM.h"



@interface ShopCell ()
@property (nonatomic,copy) void(^callback)(bool,NSIndexPath*);

@property (nonatomic,weak) NSIndexPath* idx;
@property (nonatomic,weak) UILabel* shopLab;
@property (nonatomic,weak) UIButton* userSelBtn;

@property (nonatomic,weak)  ShopVM* vm;

@end

@implementation ShopCell
+ (instancetype)cellWithTable:(UITableView*)tableView
                          idx:(NSIndexPath*)indexPath
                           vm:(ShopVM*)vm{

    NSString* cellID = NSStringFromClass(self);
    ShopCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil){
        cell = [[self alloc] initWithStyle:0 reuseIdentifier:cellID];
    }

    cell.idx = indexPath;
    cell.source = [vm models][indexPath.row];
    cell.vm = vm;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUPUI];
    }
    return self;
}

- (void)setUPUI{
    UILabel* lab = [UILabel new];
    lab.font = [UIFont systemFontOfSize:15];
    lab.textColor = UIColor.blueColor;
    [self.contentView addSubview:lab];
    _shopLab = lab;
    _shopLab.translatesAutoresizingMaskIntoConstraints = false;

    [lab.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:15].active = 1;
    [lab.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = 1;


    UIButton* btn = [UIButton buttonWithType:0];
    [btn setTitle:@"未选中" forState:0];
    [btn setTitleColor:UIColor.blackColor forState:0];

    [btn setTitle:@"已选中" forState:1<<2];
    [btn setTitleColor:UIColor.redColor forState:1<<2];
    [btn addTarget:self action:@selector(userSel:) forControlEvents:1<<6];
    [self.contentView addSubview:btn];
    _userSelBtn = btn;
    _userSelBtn.translatesAutoresizingMaskIntoConstraints = false;
    [btn.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-15].active = 1;
    [btn.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = 1;
}

- (void)userSel:(UIButton*)btn{
    btn.selected = !btn.isSelected;
    self.vm.updateModelBlock(_idx.row, btn.selected);
}

- (void)setSource:(id)source{
    if(source){
        ShopModel* model = source;
        _shopLab.text = model.shopName;
        _userSelBtn.selected = model.shopUseSelect;
    }
}

@end
