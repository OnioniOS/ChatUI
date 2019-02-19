//
//  ChatRootOtherCell.m
//  chatApp
//
//  Created by Onion on 2018/10/17.
//  Copyright © 2018年 com.youpin. All rights reserved.
//
#import "NSString+StringSize.h"
#import "ChatRootOtherCell.h"
#import "MessageTimeFormatter.h"
#import "PaddingLabel.h"
#import "YSIndexBtn.h"
#import "ChatTempViewController.h"
@interface ChatRootOtherCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet PaddingLabel *messageL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLHeight;
@property (weak, nonatomic) IBOutlet YSIndexBtn *paopaoImageBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTop;
@property (weak, nonatomic) IBOutlet UILabel *groupNickL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupNickBottom;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageV;
@end
@implementation ChatRootOtherCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = RGBACOLOR(240, 240, 240, 1);
    UILongPressGestureRecognizer *longPressG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.paopaoImageBtn addGestureRecognizer:longPressG];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)dataWithModel:(BaseMessageModel *)model delegate:(id)chatRootvc indexpath:(NSIndexPath *)indexpath selectMore:(BOOL)selectMore {
    self.paopaoImageBtn.indexpath = indexpath;
    self.delegate = chatRootvc;
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
        self.timeLabel.attributedText = [[MessageTimeFormatter sharedFormatter] attributedTimestampForDate:[TimeTool convertIOSTimestampToiOSDate:model.listDate]];
    }else {
        self.timeTop.constant = 0;
        self.timeLHeight.constant = 0;
        self.timeLabel.text = @"";
    }
    if ([chatRootvc isKindOfClass:[ChatOTOViewController class]] || [chatRootvc isKindOfClass:ChatTempViewController.class]) {
        if ([chatRootvc isKindOfClass:ChatTempViewController.class]) {
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:model.userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
        }else {
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:[IMManger.friendsModelHelper getFriendInfoByUid:model.otherUid].userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
        }
        self.groupNickL.text = @"";
        self.groupNickBottom.constant = 0;
        self.nickHeight.constant = 0;
        [self.paopaoImageBtn setBackgroundImage:[UIImage imageNamed:@"chatRoot_paopaoLeft"] forState:UIControlStateNormal];
    }else if ([chatRootvc isKindOfClass:[ChatGroupViewController class]]) {
        [self.paopaoImageBtn setBackgroundImage:[UIImage imageNamed:@"chatRoot_groupPP"] forState:UIControlStateNormal];
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:model.userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
        self.groupNickL.text = model.memeberNickName;
        self.groupNickBottom.constant = 3;
        self.nickHeight.constant = 14;
    }
    if (selectMore) {
        self.selectImageV.hidden = NO;
        self.paopaoImageBtn.userInteractionEnabled = NO;
    }else {
        self.selectImageV.hidden = YES;
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
@end
