//
//  ShopCell.h
//  MVP设计模式
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ShopVM;
@interface ShopCell : UITableViewCell
+ (instancetype)cellWithTable:(UITableView*)tableView
                          idx:(NSIndexPath*)indexPath
                           vm:(ShopVM*)vm;
@end

NS_ASSUME_NONNULL_END
