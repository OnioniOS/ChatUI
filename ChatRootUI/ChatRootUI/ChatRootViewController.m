//
//  ChatRootViewController.m
//  chatApp
//
//  Created by Onion on 2018/10/17.
//  Copyright © 2018年 com.youpin. All rights reserved.
//

#import "ChatRootViewController.h"
#import "ChatRootOtherCell.h"
#import "ChatRootMineCell.h"
#import "BaseMessageModel.h"
#import "ChatRoomView.h"
#import "RecodVoiceManager.h"
#import "ChatRootImageMineCell.h"
#import "ChatRootImageOtherCell.h"
#import "ChatRootVideoMineCell.h"
#import "ChatRootVideoOtherCell.h"
#import "ChatRootSysCell.h"
#import "ChatBrowserHelper.h"
#import "MessageOperatView.h"
#import "MessageOperatHelper.h"
#import "MessageForwardedViewController.h"
#import "BaseNaviViewController.h"
#import "ForwardOperatView.h"
#import "ChatRootForwardOtherCell.h"
#import "ChatRootForwardMineCell.h"
#import "ForwardMessageDetailViewController.h"
#import "AddFriendViewController.h"
@interface ChatRootViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, ChatRoomDelegate, ChatRootCellDelegate, MessageOperatViewDelegate, ForwardOperatViewDelegate, RecodVoiceManagerDelegate, RecodBtnDelegate>
@property (nonatomic, assign) CGFloat keyBoardHeight;
@property (nonatomic, strong) ChatRoomView *roomView;
@property (nonatomic, strong) ChatRootRecodView *recodView;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, strong) NSMutableDictionary *cellHeightDic;
@property (nonatomic, strong) NSMutableArray *forwardMsgArr;
@property (nonatomic, strong) MessageOperatView *operatView;
@property (nonatomic, assign) BOOL isSelectMore;
@property (nonatomic, strong) ForwardOperatView *forwardOperaV;
@property (nonatomic, strong) RecodVoiceManager *voiceManager;
@property (nonatomic, strong) NSIndexPath *clickSaveIndex;
@property (nonatomic, strong) NSIndexPath *longPressSaveIndex;
@end
@implementation ChatRootViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isLoaded = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeAllChatView];
    [self.voiceManager.timer invalidate];
    [self.voiceManager.player stop];
    [self.voiceManager.recorder stop];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.toolBarBottom.constant = 0;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self addListener];
}
- (void)addListener {
    [self.textView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:kJSQMessagesKeyValueObservingContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)initView {
    self.textView.textColor = [UIColor colorWithHexString:@"#333333"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.textView.delegate = self;
    self.textView.placeHolder = @"输入聊天内容";
    self.recordBtn.layer.borderWidth = 1;
    self.recordBtn.layer.borderColor = UIColorHex(0xCFCFCF).CGColor;
    self.recordBtn.layer.cornerRadius = 3;
    self.recordBtn.layer.masksToBounds = YES;
    self.recordBtn.delegate = self;
    [self.view addSubview:self.roomView];
    [self.roomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}
#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self getChatDatas] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseMessageModel *model = [self getChatDatas][indexPath.row];
    if (!self.isSelectMore) {
        model.isSelected = NO;
    }
    if (model.msgType==MsgType_TO_TEXT) {
        ChatRootMineCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatRootMineCell class]) forIndexPath:indexPath];
        [cell dataWithModel:model indexpath:indexPath delegate:self selectMore:self.isSelectMore];
        return cell;
    } else if (model.msgType==MsgType_COME_TEXT) {
        ChatRootOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatRootOtherCell class]) forIndexPath:indexPath];
        [cell dataWithModel:model delegate:self indexpath:indexPath selectMore:self.isSelectMore];
        return cell;
    } else if (model.msgType==MsgType_TO_IMAGE) {
        ChatRootImageMineCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatRootImageMineCell class]) forIndexPath:indexPath];
        [cell viewWithModel:model indexpath:indexPath delegate:self selectMore:self.isSelectMore];
        return cell;
    } else if (model.msgType==MsgType_COM_IMAGE) {
        ChatRootImageOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatRootImageOtherCell class]) forIndexPath:indexPath];
        [cell viewWithModel:model delegate:self index:indexPath selectMore:self.isSelectMore];
        return cell;
    } else if (model.msgType==MsgType_TO_VIDEO) {
        ChatRootVideoMineCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatRootVideoMineCell class]) forIndexPath:indexPath];
        [cell viewWithModel:model index:indexPath delegate:self selectMore:self.isSelectMore];
        return cell;
    } else if (model.msgType==MsgType_COME_VIDEO) {
        ChatRootVideoOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatRootVideoOtherCell class]) forIndexPath:indexPath];
        [cell viewWithModel:model delegate:self index:indexPath selectMore:self.isSelectMore];
        return cell;
    } else if (model.msgType==MsgType_SYSTEM_TEXT) {
        ChatRootSysCell *sysCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatRootSysCell class]) forIndexPath:indexPath];
        [sysCell viewWithModel:model delegate:self];
        return sysCell;
    }else if (model.msgType==MsgType_ALERT_TEXT) {
        ChatRootSysCell *sysCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatRootSysCell class]) forIndexPath:indexPath];
        [sysCell viewWithModel:model delegate:self];
        return sysCell;
    }else if (model.msgType==MsgType_TO_FORWARD) {
        ChatRootForwardMineCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatRootForwardMineCell class]) forIndexPath:indexPath];
        [cell viewWithModel:model index:indexPath selectMore:self.isSelectMore delegate:self];
        return cell;
    }else if (model.msgType==MsgType_COME_FORWARD) {
        ChatRootForwardOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatRootForwardOtherCell class]) forIndexPath:indexPath];
        [cell viewWithModel:model index:indexPath selectMore:self.isSelectMore delegate:self];
        return cell;
    }else if (model.msgType==MsgType_TO_VOICE) {
        ChatRootVoiceMineCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ChatRootVoiceMineCell.class) forIndexPath:indexPath];
        [cell viewWithModel:model index:indexPath selectMore:self.isSelectMore delegate:self];
        return cell;
    }else if (model.msgType==MsgType_COME_VOICE) {
        ChatRootVoiceOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ChatRootVoiceOtherCell.class) forIndexPath:indexPath];
        [cell viewWithModel:model index:indexPath selectMore:self.isSelectMore delegate:self];
        return cell;
    }else {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [self.cellHeightDic objectForKey:indexPath];
    if(height) {
        return height.floatValue;
    } else {
        return kScreenHeight/2;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = @(cell.frame.size.height);
    [self.cellHeightDic setObject:height forKey:indexPath];
    if (!self.isLoaded) {
        if (indexPath.row<[[self getChatDatas] count]-1) {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSelectMore) {
        BaseMessageModel *model = [self getChatDatas][indexPath.row];
        if (model.msgType ==MsgType_ALERT_TEXT||model.msgType==MsgType_SYSTEM_TEXT) {
            return;
        }
        if (model.isSelected) {
            if ([self.forwardMsgArr containsObject:model]) {
                [self.forwardMsgArr removeObject:model];
                model.isSelected = NO;
            }
        }else {
            if (![self.forwardMsgArr containsObject:model]) {
                [self.forwardMsgArr addObject:model];
                model.isSelected = YES;
            }
        }
        [self.tableView reloadData];
    }else {
        [self removeAllChatView];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeAllChatView];
}
#pragma mark - ChatRootCellDelegate
- (void)didClickSystemMsg:(NSInteger)type {
    if (type == 1) {
        AddFriendViewController *addF = [[AddFriendViewController alloc] init];
        addF.type = FriendInfoTypeAddFriend;
        FriendDBModel *friend = [[FriendDBModel alloc] init];
        friend.user_uid = self.currentUid;
        addF.friendModel = friend;
        [self.navigationController pushViewController:addF animated:YES];
    }
}
- (void)didClickItemIndexPath:(NSIndexPath *)indexpath status:(BOOL)status {
    BaseMessageModel *model = [self getChatDatas][indexpath.row];
    BaseMessageModel *beforeModel = self.clickSaveIndex?[self getChatDatas][self.clickSaveIndex.row]:nil;
    if (model.msgType == 10||model.msgType==11) {
        ForwardMessageDetailViewController *forwardDVC = [[ForwardMessageDetailViewController alloc] init];
        forwardDVC.locatMsg = model.message;
        [self.navigationController pushViewController:forwardDVC animated:YES];
    }else if (model.msgType == MsgType_TO_VOICE || model.msgType == MsgType_COME_VOICE) {
        if (([YSFileManager isExistsAtPath:[RecodVoiceManager getRecodVoicePath:model.message]])) {
            if (status) {
                if (indexpath.row!=self.clickSaveIndex.row && self.clickSaveIndex) {
                    beforeModel.isPlay = NO;
                }
                [self.voiceManager playVoice:model.message index:indexpath];
            }else {
                [self.voiceManager stopVoice];
            }
            model.isPlay = status;
            [self.tableView reloadData];
            self.clickSaveIndex = indexpath;
        }else {
            [BasicTool alertViewWithMessage:@"数据已被清理"];
        }
    }else {
        [ChatBrowserHelper showChatRootBrowserCurrentMessage:model.message currentUid:self.currentUid vc:self];
    }
}
- (void)viewNeedReload {
    [self.tableView reloadData];
}
- (void)didLongPressItemIndexPath:(NSIndexPath *)indexpath rect:(CGRect)rect {
    BaseMessageModel *model = [self getChatDatas][indexpath.row];
    self.longPressSaveIndex = indexpath;
    [MessageOperatHelper operatMessage:model rect:rect complete:^(CGRect frame, CGFloat rangX, NSArray * _Nonnull operaArr) {
        if (!self.operatView) {
            self.operatView = [[MessageOperatView alloc] initWithFrame:frame rangX:rangX operatArr:operaArr];
            self.operatView.delegate = self;
            [self.view.window addSubview:self.operatView];
        }else {
            [self.operatView removeFromSuperview];
            self.operatView = nil;
            self.operatView = [[MessageOperatView alloc] initWithFrame:frame rangX:rangX operatArr:operaArr];
            self.operatView.delegate = self;
            [self.view.window addSubview:self.operatView];
        }
    }];
}
#pragma mark - MessageOperatViewDelegate
- (void)didSelectOperatAtIndex:(NSString *)titleStr {
    BaseMessageModel *model = [self getChatDatas][self.longPressSaveIndex.row];
    if ([titleStr isEqualToString:@"复制"]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = model.message;
        [BasicTool alertViewWithMessage:@"已复制"];
        [self removeOperaView];
    }else if ([titleStr isEqualToString:@"转发"]) {
        MessageForwardedViewController *msgForwardVC = [[MessageForwardedViewController alloc] init];
        msgForwardVC.forwardMsgArr = [@[model] mutableCopy];
        msgForwardVC.type = ForwardToPeopleTypeOne;
        msgForwardVC.operatType = ForwardOperatTypeOneByOne;
        BaseNaviViewController *navi = [[BaseNaviViewController alloc] initWithRootViewController:msgForwardVC];
        [self presentViewController:navi animated:YES completion:nil];
    }else if ([titleStr isEqualToString:@"撤回"]) {
        [self cancelMsgWithIndex:self.longPressSaveIndex];
        [self removeOperaView];
    }else if ([titleStr isEqualToString:@"多选"]) {
        UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelAction:)];
        self.navigationItem.leftBarButtonItem = leftBtn;
        self.isSelectMore = YES;
        self.forwardBtn.hidden = NO;
        [self removeAllChatView];
        [self.tableView reloadData];
    }
}
- (void)handleCancelAction:(UIBarButtonItem *)sender {
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBackAction:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    self.isSelectMore = NO;
    self.forwardBtn.hidden = YES;
    [self.forwardMsgArr removeAllObjects];
    [self.tableView reloadData];
}
- (void)handleBackAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - ForwardOperatViewDelegate
- (void)didSelectForwardOperatAtIndex:(NSInteger)index {
    MessageForwardedViewController *msgForwardVC = [[MessageForwardedViewController alloc] init];
    [self.forwardMsgArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        BaseMessageModel *msg1 = (BaseMessageModel *)obj1;
        BaseMessageModel *msg2 = (BaseMessageModel *)obj2;
        if (msg1.date > msg2.date) {
            return NSOrderedDescending;
        }else {
            return NSOrderedAscending;
        }
    }];
    msgForwardVC.forwardMsgArr = self.forwardMsgArr;
    msgForwardVC.type = ForwardToPeopleTypemany;
    if (index) {//合并
        msgForwardVC.operatType = ForwardOperatTypeTogether;
    }else {//逐条
        msgForwardVC.operatType = ForwardOperatTypeOneByOne;
    }
    msgForwardVC.nickName = self.nickName;
    BaseNaviViewController *navi = [[BaseNaviViewController alloc] initWithRootViewController:msgForwardVC];
    [self presentViewController:navi animated:YES completion:nil];
    [self.forwardOperaV removeFromSuperview];
    self.forwardOperaV = nil;
}
#pragma mark - ChatRoomDelegate
- (void)didSelectWithSettingRoomWithIndexpath:(NSIndexPath *)path {
    [self didClickFunctionAtIndex:path.row];
}
- (void)didSelectWithWordRoomWithIndexpath:(NSIndexPath *)path word:(NSString *)word {
//    [self didClickKeyBoardSendBtn:word];
    self.textView.text = word;
    [self.textView becomeFirstResponder];
}
#pragma mark - Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kJSQMessagesKeyValueObservingContext) {
        if (object == self.textView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            CGFloat dy = newContentSize.height - oldContentSize.height;
            if (dy>=-6 && dy<=6) {
                return;
            }
            self.toolBarHeight.constant = self.toolBarHeight.constant+dy;
            [self.toolBar layoutIfNeeded];
        }
    }
}
#pragma mark - TextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        if (![ClientCoreSDK sharedInstance].localDeviceNetworkOk) {
            //网络未连接
            [BasicTool alertViewWithMessage:@"网络未连接!"];
            return NO;
        }
        [self didClickKeyBoardSendBtn:textView.text];
        textView.text = @"";
        return NO;
    }
    return YES;
}
#pragma mark - RecodVoiceManagerDelegate
- (void)voiceTooShort {
    [self.view addSubview:self.recodView];
    [self.recodView tooShort];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeRecodView];
    });
}
- (void)recodVoiceFinishWithFileName:(NSString *)fileName duration:(NSInteger)duration{
    [self recodVoiceFinish:fileName duration:duration];
}
- (void)voicePlayFinishIndex:(NSIndexPath *)indexpath {
    BaseMessageModel *model = [self getChatDatas][indexpath.row];
    model.isPlay = NO;
    [self.tableView reloadData];
}
#pragma mark - RecodBtnDelegate
- (void)didClickRecodBtnActionType:(NSInteger)type sender:(nonnull UIButton *)sender {
    switch (type) {
        case 1:
        {
            [self.voiceManager startRecordToUid:self.currentUid complete:^{
                [sender setBackgroundColor:UIColorHex(0xd6d6d6)];
                [sender setTitle:@"松开 结束" forState:UIControlStateNormal];
                [self.view addSubview:self.recodView];
            }];
        }
            break;
        case 2:
        {
            if (self.voiceManager.recodType) {
                [sender setBackgroundColor:UIColorHex(0xF6F6F6)];
                [sender setTitle:@"按住 说话" forState:UIControlStateNormal];
                [self removeRecodView];
                [self.voiceManager cancelRecord];
            }

        }
            break;
        case 3:
        {
                if (self.voiceManager.recodType) {
                    [sender setBackgroundColor:UIColorHex(0xF6F6F6)];
                    [sender setTitle:@"按住 说话" forState:UIControlStateNormal];
                    [self removeRecodView];
                    //发送语音
                    [self.voiceManager stopRecord];
                }

        }
            break;
        case 4:
        {
            if (self.voiceManager.recodType) {
                [sender setTitle:@"松开 结束" forState:UIControlStateNormal];
                [self.recodView dragInside];
            }

        }
            break;
        case 5:
        {
            if (self.voiceManager.recodType) {
                [sender setTitle:@"松开 取消" forState:UIControlStateNormal];
                [self.recodView dragUpside];
            }
        }
            break;
        default:
            break;
    }
}
#pragma mark - 需要子类实现的方法
- (void)cancelMsgWithIndex:(NSIndexPath *)index {
}
- (NSMutableArray *)getChatDatas {
    return [NSMutableArray arrayWithCapacity:1];
}
//点击发送按钮
- (void)didClickKeyBoardSendBtn:(NSString *)message {
}
//功能按钮数组
- (NSMutableArray *)getFunctionDatas {
    return [NSMutableArray arrayWithCapacity:1];
}
- (void)didClickFunctionAtIndex:(NSInteger)index {
}
- (void)recodVoiceFinish:(NSString *)fileName duration:(NSInteger)duration {
}
#pragma mark - Notify
- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self removeOperaView];
    [self.tableView scrollToBottomAnimated:NO];
    NSValue *aValue = [[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    self.keyBoardHeight = [aValue CGRectValue].size.height;
    self.roomView.keyBoardShow = NO;
    [self.tableView setContentInset:UIEdgeInsetsMake(self.keyBoardHeight, 0, 0, 0)];
    [UIView animateWithDuration:0.3 animations:^{
        self.toolBarBottom.constant = self.keyBoardHeight;
        [self.view layoutIfNeeded];
    }];
    self.roomView.hidden = YES;
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}
#pragma mark - Action
- (void)removeAllChatView {
    [self.view endEditing:YES];
    [self hideChatRoomBar];
    [self removeOperaView];
    [self removeRecodView];
}
- (void)removeOperaView {
    [self.operatView removeFromSuperview];
    self.operatView = nil;
}
- (void)removeRecodView {
    [self.recodView removeFromSuperview];
    self.recodView = nil;
}
//转发
- (IBAction)forwardAction:(UIButton *)sender {
    if (self.forwardMsgArr.count < 1) {
        [BasicTool alertViewWithMessage:@"至少一条消息哦"];
        return;
    }
    [self.view.window addSubview:self.forwardOperaV];
}
- (IBAction)vioceAction:(UIButton *)sender {
    [self.voiceManager getRecoderAuthor:^{}];
    self.textView.text = nil;
    self.toolBarHeight.constant = 50;
    [self.toolBar layoutIfNeeded];
    if (sender.selected) {
        [self.textView becomeFirstResponder];
        [self showTextView];
    }else {
        [self removeAllChatView];
        self.textView.hidden = YES;
        self.recordBtn.hidden = NO;
        [self.voiceBtn setImage:[UIImage imageNamed:@"chatRoot_voiceBtn_Select"] forState:UIControlStateNormal];
        sender.selected = YES;
    }
}
- (void)showTextView {
    self.textView.hidden = NO;
    self.recordBtn.hidden = YES;
    [self.voiceBtn setImage:[UIImage imageNamed:@"chatRoot_VoiceBtn"] forState:UIControlStateNormal];
    self.voiceBtn.selected = NO;
}
- (IBAction)moreSettingBtn:(id)sender {
    [self showTextView];
    if (self.roomView.keyBoardShow) {
        [self.roomView setRoomStatus:0];
    }else{
        [self showChatRoomBarWithStatus:ChatRoomStatusSetting];
    }
}
- (IBAction)wordBtn:(id)sender {
    [self showTextView];
    if (self.roomView.keyBoardShow) {
        [self.roomView setRoomStatus:ChatRoomStatusWord];
    }else{
        [self showChatRoomBarWithStatus:ChatRoomStatusWord];
    }
}
- (IBAction)faceBtn:(id)sender {
    [self showTextView];
    if (self.roomView.keyBoardShow) {
        [self.roomView setRoomStatus:ChatRoomStatusFace];
    }else{
        [self showChatRoomBarWithStatus:ChatRoomStatusFace];
    }
}
- (void)showChatRoomBarWithStatus:(NSInteger)status {
    [self removeOperaView];
    [self.view endEditing:YES];
    [self.tableView scrollToBottomAnimated:NO];
    [self.tableView setContentInset:UIEdgeInsetsMake(self.keyBoardHeight?self.keyBoardHeight:285, 0, 0, 0)];
    self.roomView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.toolBarBottom.constant = self.keyBoardHeight?self.keyBoardHeight:285;
        [self.view layoutIfNeeded];
    }];
    [self.roomView setRoomStatus:status];
    self.roomView.keyBoardShow = YES;
}
- (void)hideChatRoomBar {
    self.roomView.keyBoardShow = NO;
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [UIView animateWithDuration:0.3 animations:^{
        self.toolBarBottom.constant = 0;
        [self.view layoutIfNeeded];
    }];
    self.roomView.hidden = YES;
}
#pragma mark - Lazyload
- (ChatRoomView*)roomView {
    if (!_roomView) {
         NSString *str = IMManger.localUserInfo.quickWordArr;
        NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSArray *quickWordArr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        _roomView = [[ChatRoomView alloc] initWithFrame:CGRectZero functionArr:[self getFunctionDatas] quickWordArr:[[NSMutableArray alloc] initWithArray:quickWordArr]];
        _roomView.hidden = YES;
        _roomView.delegate = self;
    }
    return _roomView;
}
- (ChatRootRecodView *)recodView {
    if (!_recodView) {
        _recodView = [[ChatRootRecodView alloc] initWithFrame:CGRectMake(kScreenWidth/4, kScreenHeight/2-kScreenWidth/2, kScreenWidth/2, kScreenWidth/2)];
    }
    return _recodView;
}
- (NSMutableDictionary *)cellHeightDic {
    if (!_cellHeightDic) {
        _cellHeightDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _cellHeightDic;
}
- (NSMutableArray *)forwardMsgArr {
    if (!_forwardMsgArr) {
        _forwardMsgArr = [NSMutableArray arrayWithCapacity:1];
    }
    return _forwardMsgArr;
}
- (ForwardOperatView *)forwardOperaV {
    if (!_forwardOperaV) {
        _forwardOperaV = [[ForwardOperatView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _forwardOperaV.delegate = self;
    }
    return _forwardOperaV;
}
- (RecodVoiceManager *)voiceManager {
    if (!_voiceManager) {
        _voiceManager = [[RecodVoiceManager alloc] init];
        _voiceManager.delegate = self;
    }
    return _voiceManager;
}
- (void)dealloc {
    [self.textView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:kJSQMessagesKeyValueObservingContext];
}
@end
