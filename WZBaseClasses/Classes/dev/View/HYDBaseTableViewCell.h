//
//  HYDBaseTableViewCell.h
//  HC-HYD
//
//  Created by 罗志超 on 2017/9/8.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYDBaseTableViewCell : UITableViewCell

+ (CGFloat)heightOfCell;

+ (instancetype)cellWithTableView:(UITableView *)tableView aIndexPath:(NSIndexPath *)indexPath;

@end
