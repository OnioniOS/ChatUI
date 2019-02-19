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
//  【版权申明】：本类原作者为JSQ作者，因原工程已停止更新，当前由 YPTC修改并用于RainbowChat等工程中，感谢原作者。


#import "JSQMessagesComposerTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+JSQMessages.h"


@implementation JSQMessagesComposerTextView


#pragma mark - Initialization

- (void)jsq_configureTextView {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    CGFloat cornerRadius = 4.0f;

    // 输入框背景颜色
    self.backgroundColor = [UIColor whiteColor];

    // border设置
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = RGBCOLOR(204, 204, 204).CGColor;//[UIColor lightGrayColor].CGColor;

    // 圆角设置
    self.layer.cornerRadius = cornerRadius;

    // 取消滚条导致的空白内衬
    self.scrollIndicatorInsets = UIEdgeInsetsMake(cornerRadius, 0.0f, cornerRadius, 0.0f);

    self.textContainerInset = UIEdgeInsetsMake(4.0f, 2.0f, 4.0f, 2.0f);
    self.contentInset = UIEdgeInsetsMake(3.0f, 0.0f, 1.0f, 0.0f);

    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;

    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor blackColor];
    self.textAlignment = NSTextAlignmentNatural;

    self.contentMode = UIViewContentModeRedraw;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    // 以下代码会将输入法中的“return”按键显示成“发送”
    self.returnKeyType = UIReturnKeySend;//UIReturnKeyDefault;

    self.text = nil;

    _placeHolder = nil;
    _placeHolderTextColor = [UIColor lightGrayColor];

    [self jsq_addTextViewNotificationObservers];
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self jsq_configureTextView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self jsq_configureTextView];
}

- (void)dealloc {
    [self jsq_removeTextViewNotificationObservers];
}


#pragma mark - Composer text view

- (BOOL)hasText {
    return ([[self.text jsq_stringByTrimingWhitespace] length] > 0);
}


#pragma mark - Setters

- (void)setPlaceHolder:(NSString *)placeHolder {
    if ([placeHolder isEqualToString:_placeHolder]) {
        return;
    }

    _placeHolder = [placeHolder copy];
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor {
    if ([placeHolderTextColor isEqual:_placeHolderTextColor]) {
        return;
    }

    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}


#pragma mark - UITextView overrides

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

#pragma mark - Drawing
// 重写UIView的draw方法，实现placeHolderText在合适的时机显示
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    if ([self.text length] == 0 && self.placeHolder) {
        [self.placeHolderTextColor set];

        [self.placeHolder drawInRect:CGRectInset(rect, 7.0f, 7.0f)
                      withAttributes:[self jsq_placeholderTextAttributes]];
    }
}


#pragma mark - Notifications
// 本类中的Notifications作用是在文本输入事件触发时及时通知UI重绘（重绘时将自动决定是否显示placeHolderText，请见方法 drawRect: ）

- (void)jsq_addTextViewNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
}

- (void)jsq_removeTextViewNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:self];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:self];
}

- (void)jsq_didReceiveTextViewNotification:(NSNotification *)notification {
    [self setNeedsDisplay];
}


#pragma mark - Utilities

- (NSDictionary *)jsq_placeholderTextAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = self.textAlignment;

    return @{ NSFontAttributeName : self.font,
              NSForegroundColorAttributeName : self.placeHolderTextColor,
              NSParagraphStyleAttributeName : paragraphStyle };
}


@end
