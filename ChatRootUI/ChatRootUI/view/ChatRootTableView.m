//
//  ChatRootTableView.m
//  chatApp
//
//  Created by Onion on 2018/10/17.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import "ChatRootTableView.h"

#import "ChatRootOtherCell.h"
#import "ChatRootMineCell.h"
#import "ChatRootImageMineCell.h"
#import "ChatRootImageOtherCell.h"
#import "ChatRootVideoMineCell.h"
#import "ChatRootSysCell.h"
#import "ChatRootVideoOtherCell.h"
#import "ChatRootForwardMineCell.h"
#import "ChatRootForwardOtherCell.h"
#import "ChatRootVoiceMineCell.h"
#import "ChatRootVoiceOtherCell.h"

@implementation ChatRootTableView
- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backgroundColor = UIColorHex(0xF0F0F0);
    self.estimatedRowHeight = 0;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self registerNib:[UINib nibWithNibName:NSStringFromClass([ChatRootOtherCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChatRootOtherCell class])];
    [self registerNib:[UINib nibWithNibName:NSStringFromClass([ChatRootMineCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChatRootMineCell class])];
    [self registerNib:[UINib nibWithNibName:NSStringFromClass([ChatRootImageMineCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChatRootImageMineCell class])];
    [self registerNib:[UINib nibWithNibName:NSStringFromClass([ChatRootImageOtherCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChatRootImageOtherCell class])];
    [self registerNib:[UINib nibWithNibName:NSStringFromClass([ChatRootVideoMineCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChatRootVideoMineCell class])];
    [self registerNib:[UINib nibWithNibName:NSStringFromClass([ChatRootVideoOtherCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChatRootVideoOtherCell class])];
    [self registerNib:[UINib nibWithNibName:NSStringFromClass([ChatRootSysCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChatRootSysCell class])];
    [self registerNib:[UINib nibWithNibName:NSStringFromClass([ChatRootForwardMineCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChatRootForwardMineCell class])];
    [self registerNib:[UINib nibWithNibName:NSStringFromClass([ChatRootForwardOtherCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChatRootForwardOtherCell class])];
    [self registerNib:[UINib nibWithNibName:NSStringFromClass(ChatRootVoiceMineCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(ChatRootVoiceMineCell.class)];
    [self registerNib:[UINib nibWithNibName:NSStringFromClass(ChatRootVoiceOtherCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(ChatRootVoiceOtherCell.class)];

}

@end
