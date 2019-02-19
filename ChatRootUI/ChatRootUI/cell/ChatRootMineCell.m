//
//  ChatRootMineCell.m
//  chatApp
//
//  Created by Onion on 2018/10/17.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import "ChatRootMineCell.h"
#import "NSString+StringSize.h"
#import "MessageTimeFormatter.h"
#import "PaddingLabel.h"
#import "YSIndexBtn.h"
@interface ChatRootMineCell ()
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UIImageView *headImageview;
@property (weak, nonatomic) IBOutlet PaddingLabel *messageL;
@property (weak, nonatomic) IBOutlet YSIndexBtn *paopaoImageBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLHeight;
@property (weak, nonatomic) IBOutlet UIButton *msgFailAlertBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTop;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressV;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstant;
@end

@implementation ChatRootMineCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = RGBACOLOR(240, 240, 240, 1);
    UILongPressGestureRecognizer *longPressG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.paopaoImageBtn addGestureRecognizer:longPressG];
}

- (void)dataWithModel:(BaseMessageModel *)model indexpath:(NSIndexPath *)indexpath delegate:(id)delegate selectMore:(BOOL)selectMore {
    self.paopaoImageBtn.indexpath = indexpath;
    self.delegate = delegate;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    if ([model.message ys_height] < ([@"测试" ys_height]+8)) {
        paraStyle.lineSpacing = 0.0;
    }else {
        paraStyle.lineSpacing = 8.0;
    }
    self.messageL.attributedText = [[NSMutableAttributedString alloc] initWithString:model.message attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSParagraphStyleAttributeName:paraStyle}];
    if (model.listDate != 0) {
        self.timeLHeight.constant = 20;
        self.timeTop.constant = 10;
        self.timeL.attributedText = [[MessageTimeFormatter sharedFormatter] attributedTimestampForDate:[TimeTool convertIOSTimestampToiOSDate:model.listDate]];
    }else {
        self.timeTop.constant = 0;
        self.timeLHeight.constant = 0;
        self.timeL.text = @"";
    }
    if (model.sendStatus==SendStatus_SEND_FAILD) {
        self.msgFailAlertBtn.hidden = NO;
        [self.progressV stopAnimating];
    }else if (model.sendStatus==SendStatus_SNEDING){
        self.msgFailAlertBtn.hidden = YES;
        [self.progressV startAnimating];
    }else if (model.sendStatus==SendStatus_BE_RECEIVED) {
        self.msgFailAlertBtn.hidden = YES;
        [self.progressV stopAnimating];
    }
    [self.headImageview sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:IMManger.localUserInfo.userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
    if (selectMore) {
        self.selectImageV.hidden = NO;
        self.rightConstant.constant = 48;
        self.paopaoImageBtn.userInteractionEnabled = NO;
    }else {
        self.selectImageV.hidden = YES;
        self.rightConstant.constant = 8;
        self.paopaoImageBtn.userInteractionEnabled = YES;
    }
    if (model.isSelected) {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_yes"];
    }else {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_no"];
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
/**
 
 // 将rect由rect所在视图转换到目标视图view中，返回在目标视图view中的rect
 - (CGRect)convertRect:(CGRect)rect toView:(UIView *)view;
 
 // 将rect从view中转换到当前视图中，返回在当前视图中的rect
 - (CGRect)convertRect:(CGRect)rect fromView:(UIView *)view;
 
 */


@end
