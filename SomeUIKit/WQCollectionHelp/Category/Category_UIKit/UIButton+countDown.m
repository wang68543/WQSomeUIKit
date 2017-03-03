//
//  UIButton+countDown.m
//  LiquoriceDoctorProject
//
//  Created by HenryCheng on 15/12/4.
//  Copyright © 2015年 iMac. All rights reserved.
//

#import "UIButton+countDown.h"


@implementation UIButton (countDown)

- (void)startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color {

    self.enabled = NO;
   
    __weak typeof(self) weakSelf = self;
    //倒计时时间
    __block NSInteger timeOut = timeLine;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
     [self setTitleColor:color forState:UIControlStateNormal];
    dispatch_source_set_event_handler(_timer, ^{
        //倒计时结束，关闭
        if (timeOut <= 0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf setTitle:title forState:UIControlStateNormal];
                [weakSelf setTitleColor:mColor forState:UIControlStateNormal];
                weakSelf.enabled = YES;
            });
        } else {
            int allTime = (int)timeLine + 1;
            int seconds = timeOut % allTime;
            NSString *timeStr = [NSString stringWithFormat:@"%02d", seconds];
        
            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.titleLabel.text = [NSString stringWithFormat:@"%@s",timeStr];
                NSString *leftTime = [NSString stringWithFormat:@"%@s",timeStr];
                [weakSelf setTitle:leftTime forState:UIControlStateNormal];
            });
            timeOut--;
        }
    });
    dispatch_resume(_timer);
}
-(void)stopCountDown{//暂时不知道怎么弄
    
}
@end