//
//  ChatRootVoiceMineCell.m
//  chatApp
//
//  Created by Onion on 2018/12/24.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import "ChatRootVoiceMineCell.h"
#import "YSIndexBtn.h"
#import "PaddingTimeLabel.h"
#import "MessageTimeFormatter.h"
#import "LineView.h"
#import "RecodVoiceManager.h"
#define maxHeight 26

@interface ChatRootVoiceMineCell ()
@property (weak, nonatomic) IBOutlet YSIndexBtn *paopaoBtn;
@property (weak, nonatomic) IBOutlet PaddingTimeLabel *timeL;
@property (weak, nonatomic) IBOutlet UIImageView *headImageV;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageV;
@property (weak, nonatomic) IBOutlet UIButton *sendFaildBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressV;
@property (weak, nonatomic) IBOutlet UILabel *secondL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paopaoWidth;

@property (nonatomic, assign) NSInteger lineCount;

@property (nonatomic, strong) BaseMessageModel *saveModel;
@end
@implementation ChatRootVoiceMineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = RGBACOLOR(240, 240, 240, 1);
    UILongPressGestureRecognizer *longPressG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.paopaoBtn addGestureRecognizer:longPressG];
    for (int i = 0; i < 25; i++) {
        CGFloat height = 0;
        if (i % 4 == 0) {
            height = 0.3 * maxHeight;
        }else if (i % 4 == 1) {
            height = 0.7 * maxHeight;
        }else if (i % 4 == 2) {
            height = maxHeight;
        }else if (i % 4 == 3) {
            height = 0.7 * maxHeight;
        }
        LineView *lineV = [[LineView alloc] init];
        lineV.bounds = CGRectMake(0, 0, 3, height);
        lineV.center = CGPointMake(0, 20);
        lineV.backgroundColor = UIColorHex(0x9E9E9E);
        lineV.layer.cornerRadius = 1.5;
        lineV.layer.masksToBounds = YES;
        lineV.userInteractionEnabled = NO;
        lineV.tag = i + 400;
        [self.paopaoBtn addSubview:lineV];
    }
}
- (void)viewWithModel:(BaseMessageModel *)model index:(NSIndexPath *)indexpath selectMore:(BOOL)selectMore delegate:(id)chatRootvc {
    self.paopaoBtn.indexpath = indexpath;
    self.delegate = chatRootvc;
    self.saveModel = model;
    if (model.listDate != 0) {
        self.timeTop.constant = 10;
        self.timeL.attributedText = [[MessageTimeFormatter sharedFormatter] attributedTimestampForDate:[TimeTool convertIOSTimestampToiOSDate:model.listDate]];
    }else {
        self.timeTop.constant = 0;
        self.timeL.text = @"";
    }
    [self.headImageV sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:IMManger.localUserInfo.userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
    
    if (model.sendStatus == SendStatus_SNEDING) {
        [self.progressV startAnimating];
        self.sendFaildBtn.hidden = YES;
        self.paopaoBtn.userInteractionEnabled = NO;
    }else if (model.sendStatus == SendStatus_BE_RECEIVED) {
        [self.progressV stopAnimating];
        self.sendFaildBtn.hidden = YES;
        self.paopaoBtn.userInteractionEnabled = YES;
    }else if (model.sendStatus == SendStatus_SEND_FAILD) {
        [self.progressV stopAnimating];
        self.sendFaildBtn.hidden = NO;
        self.paopaoBtn.userInteractionEnabled = NO;
    }
    
    if (selectMore) {
        self.selectImageV.hidden = NO;
        self.headRight.constant = 40;
        self.paopaoBtn.userInteractionEnabled = NO;
    }else {
        self.selectImageV.hidden = YES;
        self.headRight.constant = 8;
        self.paopaoBtn.userInteractionEnabled = YES;
    }
    
    if (model.isSelected) {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_yes"];
    }else {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_no"];
    }
    if (model.duration<10) {
        self.secondWidth.constant = 25;
    }else {
        self.secondWidth.constant = 30;
    }
    self.secondL.text = [NSString stringWithFormat:@"%ld″", model.duration];

    //line
    if (model.duration > 0 && model.duration < 10) {
        self.lineCount = 5;
    }else if (model.duration >= 10 && model.duration < 20) {
        self.lineCount = 9;
    }else if (model.duration >= 20 && model.duration < 30) {
        self.lineCount = 13;
    }else if (model.duration >= 30 && model.duration < 40) {
        self.lineCount = 17;
    }else if (model.duration >= 40 && model.duration < 50) {
        self.lineCount = 21;
    }else {
        self.lineCount = 25;
    }
    if (model.duration<10) {
        self.paopaoWidth.constant = 20 + self.lineCount * 3 + (self.lineCount-1) * 2 + 30;
    }else {
        self.paopaoWidth.constant = 20 + self.lineCount * 3 + (self.lineCount-1) * 2 + 35;
    }

    for (int i = 0; i < 25; i++) {
        LineView *lineV = [self viewWithTag:i+400];
        if (i<self.lineCount) {
            lineV.hidden = NO;
            lineV.center = CGPointMake(self.paopaoWidth.constant - 20 - i*5, 20);
        }else {
            lineV.hidden = YES;
        }
    }
    if (model.isPlay) {
        [self startAnimation];
        self.paopaoBtn.currentStatus = YES;
    }else {
        [self removeAnimation];
        self.paopaoBtn.currentStatus = NO;
    }
}
- (IBAction)paopaoAction:(YSIndexBtn *)sender {
    if (!sender.currentStatus) {
        if ([YSFileManager isExistsAtPath:[RecodVoiceManager getRecodVoicePath:self.saveModel.message]]) {
            sender.currentStatus = YES;
            [self startAnimation];
        }
        if ([self.delegate respondsToSelector:@selector(didClickItemIndexPath:status:)]) {
            [self.delegate didClickItemIndexPath:sender.indexpath status:YES];
        }
        
    }else {
        sender.currentStatus = NO;
        [self removeAnimation];
        if ([self.delegate respondsToSelector:@selector(didClickItemIndexPath:status:)]) {
            [self.delegate didClickItemIndexPath:sender.indexpath status:NO];
        }
    }
}
- (void)startAnimation {
    for (int i = 0; i < self.lineCount; i++) {
        LineView *lineV = [self viewWithTag:i+400];
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
        if (i % 4 == 0) {
            animation.values = @[[NSValue valueWithCGRect:CGRectMake(0, 0, 3, 0.1*maxHeight)], [NSValue valueWithCGRect:CGRectMake(0, 0, 3, maxHeight)], [NSValue valueWithCGRect:CGRectMake(0, 0, 3, 0.1*maxHeight)]];
        }else if (i % 4 == 1) {
            animation.values = @[[NSValue valueWithCGRect:CGRectMake(0, 0, 3, 0.7*maxHeight)], [NSValue valueWithCGRect:CGRectMake(0, 0, 3, maxHeight)], [NSValue valueWithCGRect:CGRectMake(0, 0, 3, 0.1*maxHeight)], [NSValue valueWithCGRect:CGRectMake(0, 0, 3, 0.7*maxHeight)]];
        }else if (i % 4 == 2) {
            animation.values = @[[NSValue valueWithCGRect:CGRectMake(0, 0, 3, maxHeight)], [NSValue valueWithCGRect:CGRectMake(0, 0, 3, 0.1*maxHeight)], [NSValue valueWithCGRect:CGRectMake(0, 0, 3, maxHeight)]];
        }else if (i % 4 == 3) {
            animation.values = @[[NSValue valueWithCGRect:CGRectMake(0, 0, 3, 0.7*maxHeight)], [NSValue valueWithCGRect:CGRectMake(0, 0, 3, 0.1*maxHeight)], [NSValue valueWithCGRect:CGRectMake(0, 0, 3, maxHeight)], [NSValue valueWithCGRect:CGRectMake(0, 0, 3, 0.7*maxHeight)]];
        }
        animation.duration = 0.25;
        animation.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.autoreverses = NO;
        animation.beginTime = CACurrentMediaTime() + i*0.1f;
        animation.repeatCount = HUGE_VALF;
        [lineV.layer addAnimation:animation forKey:[NSString stringWithFormat:@"animation%d", i]];
    }
}
- (void)removeAnimation {
    for (int i = 0; i < self.lineCount; i++) {
        LineView *lineV = [self viewWithTag:i+400];
        [lineV.layer removeAnimationForKey:[NSString stringWithFormat:@"animation%d", i]];
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        YSIndexBtn *button = (YSIndexBtn *)sender.view;
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        CGRect rect1 = [sender.view convertRect:sender.view.frame fromView:self.contentView];
        CGRect rect2 = [sender.view convertRect:rect1 toView:window];
        CGRect rect = CGRectMake(rect2.origin.x, rect2.origin.y, rect2.size.width, rect2.size.height);
        if ([self.delegate respondsToSelector:@selector(didLongPressItemIndexPath:rect:)]) {
            [self.delegate didLongPressItemIndexPath:button.indexpath rect:rect];
        }
    }
}

@end
