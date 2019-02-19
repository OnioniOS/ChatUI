//
//  ChatRootVideoOtherCell.h
//  chatApp
//
//  Created by Onion on 2018/11/20.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMessageModel.h"
#import "ChatRootViewController.h"
#import "ChatOTOViewController.h"
#import "ChatGroupViewController.h"
#import "ChatRootCellDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface ChatRootVideoOtherCell : UITableViewCell
@property (nonatomic, weak) id<ChatRootCellDelegate> delegate;
- (void)viewWithModel:(BaseMessageModel *)model delegate:(id)chatRootvc index:(NSIndexPath *)indexpath selectMore:(BOOL)selectMore;
@end

NS_ASSUME_NONNULL_END
