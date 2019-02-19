//
//  ChatRootForwardOtherCell.h
//  chatApp
//
//  Created by Onion on 2018/12/19.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatRootCellDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatRootForwardOtherCell : UITableViewCell
- (void)viewWithModel:(BaseMessageModel *)model index:(NSIndexPath *)indexpath selectMore:(BOOL)selectMore delegate:(id)chatRootvc;
@property (nonatomic, weak) id<ChatRootCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
