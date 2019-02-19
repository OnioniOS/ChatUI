//
//  ChatRootImageMineCell.m
//  chatApp
//
//  Created by Onion on 2018/11/14.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import "ChatRootImageMineCell.h"
#import "MessageTimeFormatter.h"
#import "SendImageHelper.h"
#import "PaddingLabels.h"
#import "PaddingTimeLabel.h"
@interface ChatRootImageMineCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTop;
@property (weak, nonatomic) IBOutlet PaddingTimeLabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageV;
@property (weak, nonatomic) IBOutlet UIView *grayView;
@property (weak, nonatomic) IBOutlet UIButton *sendFailedBtn;
@property (weak, nonatomic) IBOutlet YSIndexBtn *imageBtn;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstant;
@end
@implementation ChatRootImageMineCell
- (void)viewWithModel:(BaseMessageModel *)mdoel indexpath:(NSIndexPath *)indexpath delegate:(id)chatRootvc selectMore:(BOOL)selectMore {
    self.imageBtn.indexpath = indexpath;
    self.delegate = chatRootvc;
    if (mdoel.listDate != 0) {
        self.timeTop.constant = 10;
        self.timeLabel.attributedText = [[MessageTimeFormatter sharedFormatter] attributedTimestampForDate:[TimeTool convertIOSTimestampToiOSDate:mdoel.listDate]];
    }else {
        self.timeTop.constant = 0;
        self.timeLabel.text = @"";
    }
    if ([YSFileManager isExistsAtPath:[NSString stringWithFormat:@"%@/%@", [SendImageHelper getSendImageFilePath], mdoel.message]]) {
        [self.imageBtn sd_setImageWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [SendImageHelper getSendImageFilePath], mdoel.message]] forState:UIControlStateNormal];
    }else {
        NSString *fileName = [NSString stringWithFormat:@"th_%@", mdoel.message];
        NSString *imageFileDownloadPath = [SendImageHelper getImageDownloadURL:fileName];
        [self.imageBtn sd_setImageWithURL:[NSURL URLWithString:imageFileDownloadPath] forState:UIControlStateNormal];
    }
    
    [self.headImageV sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:IMManger.localUserInfo.userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
    if (mdoel.sendStatus == SendStatus_SNEDING) {
        [self.progressView startAnimating];
        self.grayView.hidden = NO;
        self.sendFailedBtn.hidden = YES;
        self.imageBtn.userInteractionEnabled = NO;
    }else if (mdoel.sendStatus == SendStatus_BE_RECEIVED){
        [self.progressView stopAnimating];
        self.grayView.hidden = YES;
        self.sendFailedBtn.hidden = YES;
        self.imageBtn.userInteractionEnabled = YES;
    }else if (mdoel.sendStatus == SendStatus_SEND_FAILD){
        //发送失败
        self.imageBtn.userInteractionEnabled = NO;
        self.sendFailedBtn.hidden = NO;
        [self.progressView stopAnimating];
        self.grayView.hidden = YES;
    }
    if (selectMore) {
        self.selectImageV.hidden = NO;
        self.rightConstant.constant = 48;
        self.imageBtn.userInteractionEnabled = NO;
    }else {
        self.selectImageV.hidden = YES;
        self.rightConstant.constant = 8;
        self.imageBtn.userInteractionEnabled = YES;
    }
    if (mdoel.isSelected) {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_yes"];
    }else {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_no"];
    }

}
- (IBAction)didClickImage:(YSIndexBtn *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickItemIndexPath:status:)]) {
        [self.delegate didClickItemIndexPath:sender.indexpath status:NO];
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
