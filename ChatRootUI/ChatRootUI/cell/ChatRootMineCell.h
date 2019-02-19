//
//  ChatRootMineCell.h
//  chatApp
//
//  Created by Onion on 2018/10/17.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMessageModel.h"
#import "ChatRootCellDelegate.h"
@interface ChatRootMineCell : UITableViewCell
@property (nonatomic, weak) id<ChatRootCellDelegate> delegate;
- (void)dataWithModel:(BaseMessageModel *)model indexpath:(NSIndexPath *)indexpath delegate:(id)delegate selectMore:(BOOL)selectMore;
@end
