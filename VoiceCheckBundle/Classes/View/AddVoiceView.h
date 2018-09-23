//
//  AddVoiceView.h
//  AFNetworking
//
//  Created by wujie on 2018/5/17.
//

#import <UIKit/UIKit.h>

@interface AddVoiceView : UIView
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, copy) void(^btnClickBlock)(void);
@end
