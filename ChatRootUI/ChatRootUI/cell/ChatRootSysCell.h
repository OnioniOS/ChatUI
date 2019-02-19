//
//  ChatRootSysCell.h
//  chatApp
//
//  Created by Onion on 2018/11/22.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMessageModel.h"
#import "ChatRootCellDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface ChatRootSysCell : UITableViewCell
@property (nonatomic, weak) id<ChatRootCellDelegate> delegate;
- (void)viewWithModel:(BaseMessageModel *)model delegate:(id)delegate;
@end

NS_ASSUME_NONNULL_END
