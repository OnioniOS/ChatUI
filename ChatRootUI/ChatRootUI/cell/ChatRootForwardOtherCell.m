//
//  ChatRootForwardOtherCell.m
//  chatApp
//
//  Created by Onion on 2018/12/19.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import "ChatRootForwardOtherCell.h"
#import "YSIndexBtn.h"
#import "PaddingTimeLabel.h"
#import "MessageTimeFormatter.h"
#import "ChatOTOViewController.h"
#import "ChatGroupViewController.h"
#import "ForwardDetailModel.h"
#import "ChatTempViewController.h"
@interface ChatRootForwardOtherCell ()
@property (weak, nonatomic) IBOutlet UIImageView *selectImageV;
@property (weak, nonatomic) IBOutlet YSIndexBtn *paopaoImageBtn;
@property (weak, nonatomic) IBOutlet PaddingTimeLabel *timeL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTop;
@property (weak, nonatomic) IBOutlet UIImageView *headImageV;
@property (weak, nonatomic) IBOutlet UILabel *messageL;

@property (weak, nonatomic) IBOutlet UILabel *nickNameL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paopaoTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTop;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressV;
@property (weak, nonatomic) IBOutlet UIButton *msgFaildAlertBtn;
@end
@implementation ChatRootForwardOtherCell
- (void)viewWithModel:(BaseMessageModel *)model index:(NSIndexPath *)indexpath selectMore:(BOOL)selectMore delegate:(id)chatRootvc {
    self.paopaoImageBtn.indexpath = indexpath;
    self.delegate = chatRootvc;
    if ([chatRootvc isKindOfClass:[ChatOTOViewController class]] || [chatRootvc isKindOfClass:ChatTempViewController.class]) {
        if ([chatRootvc isKindOfClass:ChatTempViewController.class]) {
            [self.headImageV sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:model.userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
        }else {
            [self.headImageV sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:[IMManger.friendsModelHelper getFriendInfoByUid:model.otherUid].userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
        }
        self.nickNameL.text = @"";
        self.nickNameHeight.constant = 0;
        self.paopaoTop.constant = 0;
        self.messageTop.constant = 10;
        [self.paopaoImageBtn setBackgroundImage:[UIImage imageNamed:@"chatRoot_Forward_OTOLeft"] forState:UIControlStateNormal];
    }else if ([chatRootvc isKindOfClass:[ChatGroupViewController class]]) {
        [self.headImageV sd_setImageWithURL:[NSURL URLWithString:[FriendsModelHelper getUserURLfileName:model.userAvatarFileName]] placeholderImage:[UIImage imageNamed:Default_headImage]];
        self.nickNameL.text = model.memeberNickName;
        self.nickNameHeight.constant = 14;
        self.paopaoTop.constant = 3;
        self.messageTop.constant = 13;
        [self.paopaoImageBtn setBackgroundImage:[UIImage imageNamed:@"chatRoot_Forward_GroupLeft"] forState:UIControlStateNormal];
    }
    if (model.listDate != 0) {
        self.timeTop.constant = 10;
        self.timeL.attributedText = [[MessageTimeFormatter sharedFormatter] attributedTimestampForDate:[TimeTool convertIOSTimestampToiOSDate:model.listDate]];
    }else {
        self.timeTop.constant = 0;
        self.timeL.text = @"";
    }
    [self.progressV startAnimating];
    self.msgFaildAlertBtn.hidden = YES;
    self.paopaoImageBtn.userInteractionEnabled = NO;
    NSData *jsonDicData = [model.message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonDicData options:NSJSONReadingMutableContainers error:nil];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSArray *listArr = dic[@"list"];
        self.messageL.text = @"消息加载中...";
        if (listArr.count) {
            NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
            paraStyle.lineSpacing = 5.0;
            if (listArr && [listArr isKindOfClass:[NSArray class]]) {
                NSString *title = dic[@"title"];
                NSString *viewStr = title;
                for (NSDictionary *tempDic in listArr) {
                    ForwardDetailModel *frowardDetailModel = [ForwardDetailModel modelWithDictionary:tempDic];
                    NSString *msgStr = @"";
                    switch (frowardDetailModel.msg_type) {
                        case 0:
                            msgStr = frowardDetailModel.msg_content;
                            break;
                        case 1:
                            msgStr = @"[图片]";
                            break;
                        case 2:
                            msgStr = @"[语音]";
                            break;
                        case 5:
                            msgStr = @"[文件]";
                            break;
                        case 6:
                            msgStr = @"[视频]";
                            break;
                        case 7:
                            msgStr = @"[聊天记录]";
                            break;
                        default:
                            break;
                    }
                    viewStr = [NSString stringWithFormat:@"%@\n%@:%@", viewStr, frowardDetailModel.src_name, msgStr];
                }
                NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:viewStr attributes:@{NSParagraphStyleAttributeName:paraStyle}];
                [attStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:UIColorHex(0x333333)} range:NSMakeRange(0, title.length)];
                self.messageL.attributedText = attStr;
            }
            self.msgFaildAlertBtn.hidden = YES;
            [self.progressV stopAnimating];
            self.paopaoImageBtn.userInteractionEnabled = YES;
        }else {
            [YSHttpRestHelper getTogetherMessage:dic[@"id"] type:@"1" complete:^(NSMutableArray *msgArr, BOOL sucess) {
                if (sucess) {
                    [dic setValue:msgArr.count<=3?msgArr:[msgArr subarrayWithRange:NSMakeRange(0, 3)] forKey:@"list"];
                    model.message = [dic modelToJSONString];
                    MessageOTODBModel *OTOModel = (MessageOTODBModel *)model;
                    [MessageOTODBModel updateMessage:OTOModel];
                    if ([self.delegate respondsToSelector:@selector(viewNeedReload)]) {
                        [self.delegate viewNeedReload];
                    }
                }else {
                    self.msgFaildAlertBtn.hidden = NO;
                    [self.progressV stopAnimating];
                    self.paopaoImageBtn.userInteractionEnabled = NO;
                }
            } hudView:nil];
        }
    }else {
        self.msgFaildAlertBtn.hidden = NO;
        [self.progressV stopAnimating];
        self.paopaoImageBtn.userInteractionEnabled = NO;
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
- (IBAction)didClickPPAction:(YSIndexBtn *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickItemIndexPath:status:)]) {
        [self.delegate didClickItemIndexPath:sender.indexpath status:NO];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = RGBACOLOR(240, 240, 240, 1);
    UILongPressGestureRecognizer *longPressG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.paopaoImageBtn addGestureRecognizer:longPressG];
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
