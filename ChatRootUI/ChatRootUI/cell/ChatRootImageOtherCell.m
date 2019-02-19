//
//  ChatRootImageOtherCell.m
//  chatApp
//
//  Created by Onion on 2018/11/15.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import "ChatRootImageOtherCell.h"
#import "MessageTimeFormatter.h"
#import "SendImageHelper.h"
#import "PaddingLabels.h"
#import "YSIndexBtn.h"
#import "PaddingTimeLabel.h"
#import "ChatTempViewController.h"
@interface ChatRootImageOtherCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTop;
@property (weak, nonatomic) IBOutlet PaddingTimeLabel *timeL;
@property (weak, nonatomic) IBOutlet UIImageView *headImageV;
@property (weak, nonatomic) IBOutlet YSIndexBtn *imageImageBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBtnTop;
@property (weak, nonatomic) IBOutlet UILabel *nickNameL;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageV;

@end
@implementation ChatRootImageOtherCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = RGBACOLOR(240, 240, 240, 1);
    self.imageImageBtn.layer.cornerRadius = 3;
    self.imageImageBtn.layer.masksToBounds = YES;
    self.imageImageBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    UILongPressGestureRecognizer *longPressG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.imageImageBtn addGestureRecognizer:longPressG];

}
- (void)viewWithModel:(BaseMessageModel *)model delegate:(id)chatRootvc index:(NSIndexPath *)indexpath selectMore:(BOOL)selectMore {
    self.imageImageBtn.indexpath = indexpath;
    self.delegate = chatRootvc;
    if (model.listDate != 0) {
        self.timeTop.constant = 10;
        self.timeL.attributedText = [[MessageTimeFormatter sharedFormatter] attributedTimestampForDate:[TimeTool convertIOSTimestampToiOSDate:model.listDate]];
    }else {
        self.timeTop.constant = 0;
        self.timeL.text = @"";
    }

    if ([chatRootvc isKindOfClass:[ChatOTOViewController class]] || [chatRootvc isKindOfClass:ChatTempViewController.class]) {
        if ([chatRootvc isKindOfClass:ChatTempViewController.class]) {
            [self.headImageV sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:model.userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
        }else {
            [self.headImageV sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:[IMManger.friendsModelHelper getFriendInfoByUid:model.otherUid].userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
        }
        self.nickNameL.text = @"";
        self.nickNameHeight.constant = 0;
        self.imageBtnTop.constant = 0;
    }else if ([chatRootvc isKindOfClass:[ChatGroupViewController class]]) {
        [self.headImageV sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:model.userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
        self.nickNameL.text = model.memeberNickName;
        self.nickNameHeight.constant = 14;
        self.imageBtnTop.constant = 3;
    }
    if (selectMore) {
        self.selectImageV.hidden = NO;
        self.imageImageBtn.userInteractionEnabled = NO;
    }else {
        self.selectImageV.hidden = YES;
        self.imageImageBtn.userInteractionEnabled = YES;
    }
    if (model.isSelected) {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_yes"];
    }else {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_no"];
    }

    NSString *fileName = [NSString stringWithFormat:@"th_%@", model.message];
    NSString *imageFileDownloadPath = [SendImageHelper getImageDownloadURL:fileName];
    [self.imageImageBtn sd_setImageWithURL:[NSURL URLWithString:imageFileDownloadPath] forState:UIControlStateNormal];
    
}
- (IBAction)didClickImageBtn:(YSIndexBtn *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickItemIndexPath:status:)]) {
        [self.delegate didClickItemIndexPath:sender.indexpath status:NO];
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
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
