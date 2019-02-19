//
//  ChatRootVoiceOtherCell.h
//  chatApp
//
//  Created by Onion on 2018/12/24.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatRootCellDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface ChatRootVoiceOtherCell : UITableViewCell
@property (nonatomic, weak) id<ChatRootCellDelegate> delegate;
- (void)viewWithModel:(BaseMessageModel *)model index:(NSIndexPath *)indexpath selectMore:(BOOL)selectMore delegate:(id)chatRootvc;
@end

NS_ASSUME_NONNULL_END
