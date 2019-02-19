//
//  ChatRootVideoOtherCell.m
//  chatApp
//
//  Created by Onion on 2018/11/20.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import "ChatRootVideoOtherCell.h"
#import "MessageTimeFormatter.h"
#import <AVFoundation/AVFoundation.h>
#import "YSUploadFile.h"
#import "PaddingLabels.h"
#import "YSIndexBtn.h"
#import "PaddingTimeLabel.h"
#import "ChatTempViewController.h"
@interface ChatRootVideoOtherCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTop;
@property (weak, nonatomic) IBOutlet PaddingTimeLabel *timeL;
@property (weak, nonatomic) IBOutlet UIImageView *headImageV;
@property (weak, nonatomic) IBOutlet YSIndexBtn *imageBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@property (weak, nonatomic) IBOutlet UILabel *nickNameL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBtnTop;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageV;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressV;
@property (weak, nonatomic) IBOutlet UIImageView *playImageV;

@end
@implementation ChatRootVideoOtherCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
- (IBAction)didClickImageBtn:(YSIndexBtn *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickItemIndexPath:status:)]) {
        [self.delegate didClickItemIndexPath:sender.indexpath status:NO];
    }
}

- (void)viewWithModel:(BaseMessageModel *)model delegate:(id)chatRootvc index:(NSIndexPath *)indexpath selectMore:(BOOL)selectMore {
    self.imageBtn.indexpath = indexpath;
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
    [self.progressV startAnimating];
    self.playImageV.hidden = YES;
    self.imageBtn.userInteractionEnabled = NO;
    NSString *md5 = [[model.message componentsSeparatedByString:@"."] firstObject];
    NSString *imageFilePath = [NSString stringWithFormat:@"%@/%@.jpg", [YSUploadFile getVideoSendFilePath], md5];
    BOOL isExit = [FileTool fileExists:imageFilePath];
    [self.progressV startAnimating];
    self.playImageV.hidden = YES;
    if (isExit) {
        [self.progressV stopAnimating];
        self.playImageV.hidden = NO;
        [self.imageBtn sd_setImageWithURL:[NSURL fileURLWithPath:imageFilePath] forState:UIControlStateNormal];
        self.imageBtn.userInteractionEnabled = YES;
    }else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *videoURL = [NSString stringWithFormat:@"%@video/%@", SERVER_URL, model.message];
            UIImage *videoImage = [self thumbnailImageForVideo:[NSURL URLWithString:videoURL]];
            NSData *imageData = UIImageJPEGRepresentation(videoImage, 1);
            [imageData writeToFile:imageFilePath atomically:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(viewNeedReload)]) {
                    [self.delegate viewNeedReload];
                }
            });
        });
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
        self.imageBtn.userInteractionEnabled = NO;
    }else {
        self.selectImageV.hidden = YES;
        self.imageBtn.userInteractionEnabled = YES;
    }
    if (model.isSelected) {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_yes"];
    }else {
        self.selectImageV.image = [UIImage imageNamed:@"icon_sel_no"];
    }

}
- (UIImage *)thumbnailImageForVideo:(NSURL *)path {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
    
}
@end
