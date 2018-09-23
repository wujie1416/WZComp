//
//  Target_VoiceCheck.m
//  AFNetworking
//
//  Created by wujie on 2018/5/25.
//

#import "Target_VoiceCheck.h"
#import "VoiceCheckViewController.h"
#import "VoiceCheckGetUserAuthStatusManager.h"
#import "MBProgressHUD+WZ.h"
#import "VoiceCheckDetailViewController.h"

@interface Target_VoiceCheck() <HYDBaseRequestManagerCallBackDelegate>
@property (nonatomic, strong) VoiceCheckGetUserAuthStatusManager *getUserAuthStatusManager;
@property (nonatomic, strong) id controller;
@end

@implementation Target_VoiceCheck
- (void)Action_pushVoiceCheckViewController:(NSDictionary *)params
{
    self.controller = [params objectForKey:@"fromController"];
    [self.getUserAuthStatusManager startTask];
}

- (void)manager:(HYDBaseRequestManager *)manager didSuccessWithResponse:(APIURLResponse *)response
{
    if (manager == self.getUserAuthStatusManager) {
        if (self.getUserAuthStatusManager.status == 0) {
            VoiceCheckViewController *vc = [[VoiceCheckViewController alloc] init];
            if (self.controller && [self.controller isKindOfClass:[UIViewController class]]) {
                [((UIViewController *)self.controller).navigationController pushViewController:vc animated:YES];
            }
        } else if (self.getUserAuthStatusManager.status == 1) {
            VoiceCheckDetailViewController *vc = [[VoiceCheckDetailViewController alloc] init];
            if (self.controller && [self.controller isKindOfClass:[UIViewController class]]) {
                [((UIViewController *)self.controller).navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

- (void)manager:(HYDBaseRequestManager *)manager didFailedWithError:(NSError *)error
{
    [MBProgressHUD showMessage:manager.retModel.showMsg];
}

- (VoiceCheckGetUserAuthStatusManager *)getUserAuthStatusManager
{
    if (!_getUserAuthStatusManager) {
        _getUserAuthStatusManager = [[VoiceCheckGetUserAuthStatusManager alloc] initWithCallBackDelegate:self];
    }
    return _getUserAuthStatusManager;
}
@end
