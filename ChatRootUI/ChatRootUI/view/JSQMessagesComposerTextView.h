//  ----------------------------------------------------------------------
//  Copyright (C) 2018  即时通讯网(52im.net) & Jack Jiang.
//  The RainbowChat Project. All rights reserved.
//
//  > 文档地址: http://www.52im.net/thread-19-1-1.html
//  > 即时通讯技术社区：http://www.52im.net/
//  > 即时通讯技术交流群：320837163 (http://www.52im.net/topic-qqgroup.html)
//
//  "即时通讯网(52im.net) - 即时通讯开发者社区!" 推荐IM工程。
//
//  如需联系作者，请发邮件至 jack.jiang@52im.net 或 jb2011@163.com.
//  ----------------------------------------------------------------------
//
//  【用途说明】：本类就是JSQ官方实现的聊天文本输入框组件实现类（可支持多行输入等）。
//  【版权申明】：本类原作者为JSQ作者，因原工程已停止更新，当前由 YPTC修改并用于RainbowChat等工程中，感谢原作者。


#import <UIKit/UIKit.h>

@interface JSQMessagesComposerTextView : UITextView
@property (copy, nonatomic) NSString *placeHolder;
@property (strong, nonatomic) UIColor *placeHolderTextColor;
- (BOOL)hasText;

@end
