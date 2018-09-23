//
//  HYDBaseTableViewCell.m
//  HC-HYD
//
//  Created by 罗志超 on 2017/9/8.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "HYDBaseTableViewCell.h"

@implementation HYDBaseTableViewCell

+ (CGFloat)heightOfCell
{
    return  50.0f;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView aIndexPath:(NSIndexPath *)indexPath
{
    HYDBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"k%@Identifier",[self class]]];
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"k%@Identifier",[self class]]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self setNeedsLayout];
    }
    return self;
}

@end
