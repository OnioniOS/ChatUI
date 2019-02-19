//
//  ChatRootVideoMineCell.m
//  chatApp
//
//  Created by Onion on 2018/11/19.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import "ChatRootVideoMineCell.h"
#import "MessageTimeFormatter.h"
#import "YSUploadFile.h"
#import "PaddingLabels.h"
#import "YSIndexBtn.h"
#import "PaddingTimeLabel.h"
@interface ChatRootVideoMineCell ()
@property (weak, nonatomic) IBOutlet UIButton *sendFailedBtn;
@property (weak, nonatomic) IBOutlet PaddingTimeLabel *timeL;
@property (weak, nonatomic) IBOutlet UIImageView *headImageV;
@property (weak, nonatomic) IBOutlet YSIndexBtn *imageBtn;
@property (weak, nonatomic) IBOutlet UIView *grayView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@property (weak, nonatomic) IBOutlet UIImageView *playImageV;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightContant;
@end
@implementation ChatRootVideoMineCell

- (IBAction)didClickImageBtn:(YSIndexBtn *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickItemIndexPath:status:)]) {
        [self.delegate didClickItemIndexPath:sender.indexpath status:NO];
    }
}

- (void)viewWithModel:(BaseMessageModel *)model index:(NSIndexPath *)indexpath delegate:(id)chatRootvc selectMore:(BOOL)selectMore {
    self.imageBtn.indexpath = indexpath;
    self.delegate = chatRootvc;
    if (model.listDate != 0) {
        self.timeTop.constant = 10;
        self.timeL.attributedText = [[MessageTimeFormatter sharedFormatter] attributedTimestampForDate:[TimeTool convertIOSTimestampToiOSDate:model.listDate]];
    }else {
        self.timeTop.constant = 0;
        self.timeL.text = @"";
    }
    [self.headImageV sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:IMManger.localUserInfo.userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
    NSString *md5 = [[model.message componentsSeparatedByString:@"."] firstObject];
    [self.imageBtn sd_setImageWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.jpg", [YSUploadFile getVideoSendFilePath], md5]] forState:UIControlStateNormal];
    if (model.sendStatus == SendStatus_SNEDING) {
        [self.progressView startAnimating];
        self.grayView.hidden = NO;
        self.sendFailedBtn.hidden = YES;
        self.playImageV.hidden = YES;
        self.imageBtn.userInteractionEnabled = NO;
    }else if (model.sendStatus == SendStatus_BE_RECEIVED) {
        [self.progressView stopAnimating];
        self.grayView.hidden = YES;
        self.sendFailedBtn.hidden = YES;
        self.playImageV.hidden = NO;
        self.imageBtn.userInteractionEnabled = YES;
    }else if (model.sendStatus==SendStatus_SEND_FAILD){
        //发送失败
        self.sendFailedBtn.hidden = NO;
        [self.progressView stopAnimating];
        self.grayView.hidden = YES;
        self.playImageV.hidden = NO;
        self.imageBtn.userInteractionEnabled = NO;
    }
    if (model.vertical) {
        self.width.constant = 87;
        self.height.constant = 150;
    }else {
        self.width.constant = 150;
        self.height.constant = 87;
    }
    if (selectMore) {
        self.selectImageV.hidden = NO;
        self.rightContant.constant = 48;
        self.imageBtn.userInteractionEnabled = NO;
    }else {
        self.selectImageV.hidden = YES;
        self.rightContant.constant = 8;
        self.imageBtn.userInteractionEnabled = YES;
    }
    if (model.isSelected) {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_yes"];
    }else {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_no"];
    }

}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = RGBACOLOR(240, 240, 240, 1);
    self.imageBtn.layer.cornerRadius = 3;
    self.imageBtn.layer.masksToBounds = YES;
    self.imageBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    UILongPressGestureRecognizer *longPressG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.imageBtn addGestureRecognizer:longPressG];

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
