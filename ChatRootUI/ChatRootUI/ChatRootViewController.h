//
//  ChatRootViewController.h
//  chatApp
//
//  Created by Onion on 2018/10/17.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import "BaseViewController.h"
#import "ChatRootTableView.h"
#import "ChatToolBar.h"
#import "JSQMessagesComposerTextView.h"
#import "ChatRootRecodView.h"
#import "ChatRootVoiceMineCell.h"
#import "ChatRootVoiceOtherCell.h"
#import "RecodBtn.h"
#import "MessageGroupSendHelper.h"
static void * kJSQMessagesKeyValueObservingContext = &kJSQMessagesKeyValueObservingContext;

@interface ChatRootViewController : BaseViewController
@property (weak, nonatomic) IBOutlet ChatRootTableView *tableView;
@property (weak, nonatomic) IBOutlet ChatToolBar *toolBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarHeight;
@property (weak, nonatomic) IBOutlet JSQMessagesComposerTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *shutupL;
@property (weak, nonatomic) IBOutlet RecodBtn *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *emojBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *wordBtn;
@property (weak, nonatomic) IBOutlet UIButton *forwardBtn;
@property (nonatomic, strong) NSString *currentUid;
@property (nonatomic, strong) NSString *nickName;
//隐藏功能bar
- (void)hideChatRoomBar;
//返回数据
- (NSMutableArray *)getChatDatas;
//点击发送按钮
- (void)didClickKeyBoardSendBtn:(NSString *)message;
//功能按钮数组
- (NSMutableArray *)getFunctionDatas;
//点击功能按钮
- (void)didClickFunctionAtIndex:(NSInteger)index;
//语音
- (void)recodVoiceFinish:(NSString *)fileName duration:(NSInteger)duration;
//撤回
- (void)cancelMsgWithIndex:(NSIndexPath *)index;
@end
