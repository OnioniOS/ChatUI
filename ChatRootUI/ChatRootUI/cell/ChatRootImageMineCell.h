//
//  ChatRootImageMineCell.h
//  chatApp
//
//  Created by Onion on 2018/11/14.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMessageModel.h"
#import "ChatRootCellDelegate.h"
#import "YSIndexBtn.h"
NS_ASSUME_NONNULL_BEGIN

@interface ChatRootImageMineCell : UITableViewCell
@property (nonatomic, weak) id<ChatRootCellDelegate> delegate;

- (void)viewWithModel:(BaseMessageModel *)mdoel indexpath:(NSIndexPath *)indexpath delegate:(id)chatRootvc selectMore:(BOOL)selectMore;
@end

NS_ASSUME_NONNULL_END
