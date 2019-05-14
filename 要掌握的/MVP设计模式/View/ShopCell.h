//
//  ShopCell.h
//  MVP设计模式
//
//  Created by 刘泊 on 2019/5/5.
//  Copyright © 2019 LB. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^ShopCellAssignBlock)(UILabel*, UIButton*);

@interface ShopCell : UITableViewCell
/** VC2里的调用流程 */
+ (instancetype)cellWithTable:(UITableView*)table
                          idx:(NSIndexPath*)idx
                  assignBlock:(ShopCellAssignBlock)assignBlock
                 userSelBlock:(void(^)(bool userSelState,NSIndexPath* indexP))block;


/** VC里的调用流程 */
+ (instancetype)cellWithTable:(UITableView*)table
                          idx:(NSIndexPath*)idx
                       source:(id)source
                 userSelBlock:(void(^)(bool userSelState,NSIndexPath* indexP))block;



@end

NS_ASSUME_NONNULL_END
