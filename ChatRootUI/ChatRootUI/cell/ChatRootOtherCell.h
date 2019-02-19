//
//  ChatRootOtherCell.h
//  chatApp
//
//  Created by Onion on 2018/10/17.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMessageModel.h"
#import "ChatRootViewController.h"
#import "ChatOTOViewController.h"
#import "ChatGroupViewController.h"
#import "ChatRootCellDelegate.h"
@interface ChatRootOtherCell : UITableViewCell
@property (nonatomic, weak) id<ChatRootCellDelegate> delegate;
- (void)dataWithModel:(BaseMessageModel *)model delegate:(id)chatRootvc indexpath:(NSIndexPath *)indexpath selectMore:(BOOL)selectMore;
@end
