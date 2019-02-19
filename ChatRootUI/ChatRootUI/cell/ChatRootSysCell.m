//
//  ChatRootSysCell.m
//  chatApp
//
//  Created by Onion on 2018/11/22.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import "ChatRootSysCell.h"
#import "MessageTimeFormatter.h"
#import "PaddingLabels.h"
#import "SysMsgModel.h"
@interface ChatRootSysCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTop;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet PaddingLabels *sysLabel;
@property (nonatomic, strong) SysMsgModel *saveMsgModel;
@end
@implementation ChatRootSysCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = RGBACOLOR(240, 240, 240, 1);
    self.sysLabel.layer.cornerRadius = 3;
    self.sysLabel.layer.masksToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
    [self addGestureRecognizer:tap];
}
- (void)viewWithModel:(BaseMessageModel *)model delegate:(id)delegate {
    if (model.msgType==MsgType_ALERT_TEXT) {
        self.sysLabel.textColor = UIColorHex(0x333333);
        self.sysLabel.backgroundColor = UIColorHex(0xF7F7CF);
    }else if (model.msgType==MsgType_SYSTEM_TEXT) {
        self.delegate = delegate;
        self.sysLabel.textColor = UIColorHex(0xFFFFFF);
        self.sysLabel.backgroundColor = UIColorHex(0xCED2D2);
    }
    if (model.listDate != 0) {
        self.timeHeight.constant = 20;
        self.timeTop.constant = 10;
        self.timeL.attributedText = [[MessageTimeFormatter sharedFormatter] attributedTimestampForDate:[TimeTool convertIOSTimestampToiOSDate:model.listDate]];
    }else {
        self.timeTop.constant = 0;
        self.timeHeight.constant = 0;
        self.timeL.text = @"";
    }
    NSData *jsonDicData = [model.message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonDicData options:NSJSONReadingMutableContainers error:nil];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        SysMsgModel *msg = [SysMsgModel modelWithDictionary:dic];
        self.saveMsgModel = msg;
        if (msg.type == 1) {
            NSString *subStr = [msg.rightArr firstObject];
            NSString *str = [NSString stringWithFormat:@"%@%@", msg.middleTitle, subStr];
            
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];

            [attStr setTextHighlightRange:NSMakeRange(msg.middleTitle.length, subStr.length) color:UIColorHex(0x507DAF) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                NSLog(@"点击了哦");
            }];
            self.sysLabel.attributedText = attStr;

        }
    }else {
        self.sysLabel.text = model.message;
    }
}

- (void)handleTapAction:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickSystemMsg:)]) {
        [self.delegate didClickSystemMsg:self.saveMsgModel.type];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
