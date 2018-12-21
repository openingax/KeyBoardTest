//
//  KBMainViewController.m
//  KeyBoardTest
//
//  Created by 谢立颖 on 2018/12/19.
//  Copyright © 2018 谢立颖. All rights reserved.
//

#import "KBMainViewController.h"
#import "UIView+CustomAutoLayout.h"
#import "KBMainTableViewCell.h"
#import <KVOController/NSObject+FBKVOController.h>

#define kIsiPhoneX [UIScreen mainScreen].bounds.size.width == 375 && [UIScreen mainScreen].bounds.size.height == 812

@interface KBMainViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,assign) CGFloat contentHeight;
@property(nonatomic,strong) UIView *toolBar;
@property(nonatomic,strong) UITextView *textView;
@property(nonatomic,assign) BOOL isTextViewEditing;

@end

@implementation KBMainViewController

#define RGBOF(rgbValue)     [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentHeight = kIsiPhoneX ? 84 : 50;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    [self addOwnViews];
    [self layoutSubViews];
    [self layoutRefreshScrollView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)addOwnViews {
    
    _tableView = [[UITableView alloc] init];
    _tableView.frame = self.view.bounds;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_tableView registerClass:[KBMainTableViewCell class] forCellReuseIdentifier:@"KBMainTableViewCell"];
    [self.view addSubview:_tableView];
    
    _toolBar = [[UIView alloc] init];
    _toolBar.backgroundColor = [UIColor colorWithRed:238/255.f green:238/255.f blue:238/255.f alpha:1];
    [self.view addSubview:_toolBar];
    
    _textView = [[UITextView alloc] init];
    _textView.layer.borderColor = RGBOF(0x00A3B4).CGColor;
    _textView.layer.borderWidth = 0.6;
    _textView.layer.cornerRadius = 6;
    [_toolBar addSubview:_textView];
    
    self.KVOController = [FBKVOController controllerWithObserver:self];
    __weak typeof(self) ws = self;
    [self.KVOController observe:self keyPath:@"contentHeight" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//        NSLog(@"change: %@", change);
        [ws onToolBarContentHeightChanged:change];
    }];
}

- (void)layoutSubViews {
    [_toolBar sizeWith:CGSizeMake([UIScreen mainScreen].bounds.size.width, _contentHeight)];
    [_toolBar layoutParentHorizontalCenter];
    [_toolBar alignParentBottom];
    
    [_textView sizeWith:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, 32)];
    [_textView alignParentTopWithMargin:6];
    [_textView layoutParentHorizontalCenter];
}

- (void)onToolBarContentHeightChanged:(NSDictionary *)change {
    NSInteger newValue = [change[NSKeyValueChangeNewKey] integerValue];
    NSInteger oldValue = [change[NSKeyValueChangeOldKey] integerValue];
    
    if (newValue != oldValue) {
        NSInteger off = newValue - oldValue;
        CGRect rect = self.tableView.frame;
//        rect.origin.y -= off;
        
        if (rect.origin.y == 0) {
            rect.size.height -= off;
            _tableView.frame = rect;
        } else {
            rect.origin.y -= off;
            _tableView.frame = rect;
        }
        

        if (off > 0) {
            // 弹出键盘
            
            _tableView.contentOffset = CGPointMake(0, _tableView.contentSize.height - (kScreenHeight - _contentHeight));
            
        } else {
            // 收起键盘
//            CGFloat yOffset = _tableView.contentOffset.y;
//            if (yOffset < -64) {
//                yOffset = -64;
//            } else if (yOffset > _tableView.contentSize.heigh) {
//                yOffset = _tableView.contentSize.height - (kScreenHeight - _contentHeight);
//            }
//            CGFloat newYOffset = yOffset + off;
            
//            _tableView.contentOffset = CGPointMake(0, newYOffset);
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (self.isTextViewEditing) {
//        if ([_textView isFirstResponder]) {
//            [_textView resignFirstResponder];
//            self.isTextViewEditing = NO;
//        }
//    }
}

- (void)layoutRefreshScrollView {
    CGSize size = self.view.bounds.size;
    _tableView.frame = CGRectMake(0, 0, size.width, size.height - _contentHeight);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KBMainTableViewCell *cell = [[KBMainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KBMainTableViewCell"];
    
    if (indexPath.row % 2 == 0) {
        NSDictionary *data = @{@"icon" : @"http://lc-2qF4yFo6.cn-n1.lcfile.com/8958b8980432e685b4d1.JPG",
                               @"title" : [NSString stringWithFormat:@"标题 -- %ld", indexPath.row]};
        [cell configData:data];
    } else {
        NSDictionary *data = @{@"icon" : @"http://lc-2qF4yFo6.cn-n1.lcfile.com/QTeHivAJVIyEAT0wjv6kN2C",
                               @"title" : [NSString stringWithFormat:@"标题 -- %ld", indexPath.row]};
        [cell configData:data];
    }
    
    return cell;
}


- (void)hideKeyboard {
    [self.view endEditing:YES];
}

/*
 typedef NS_ENUM(NSInteger, UIViewAnimationCurve) {
 UIViewAnimationCurveEaseInOut,         // slow at beginning and end
 UIViewAnimationCurveEaseIn,            // slow at beginning
 UIViewAnimationCurveEaseOut,           // slow at end
 UIViewAnimationCurveLinear,
 };
 */

- (void)onKeyboardWillShow:(NSNotification *)noti {
    NSLog(@"1: onKeyboardWillShow");
    
    NSDictionary *userInfo = noti.userInfo;
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGRect rect = _toolBar.frame;
    
    
//    if (kIsiPhoneX) {
//        rect.origin.y = self.view.frame.size.height - endFrame.size.height - 50;
//        rect.size.height = endFrame.size.height + 50;
//    } else {
        rect.origin.y = self.view.frame.size.height - endFrame.size.height - 50;
        rect.size.height = endFrame.size.height + 50;
//    }
    
//    NSLog(@"\n\n\n\n\nkeyboard endFrame\ny: %f height: %f\n\n\n\n\n", endFrame.origin.y, endFrame.size.height);

    [UIView animateWithDuration:duration animations:^{
        self.toolBar.frame = rect;
        self.contentHeight = rect.size.height;
    } completion:^(BOOL finished) {
        self.isTextViewEditing = YES;
    }];
}

- (void)onKeyboardDidShow:(NSNotification *)noti {
    NSLog(@"2: onKeyboardDidShow");
    
    NSDictionary *userInfo = noti.userInfo;
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    NSLog(@"\n\n\n\n\nkeyboard endFrame\ny: %f height: %f\n\n\n\n\n", endFrame.origin.y, endFrame.size.height);
    
    
    
}

- (void)onKeyboardWillHide:(NSNotification *)noti {
    NSLog(@"3: onKeyboardWillHide");
    
    NSDictionary *userInfo = noti.userInfo;
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
//    NSLog(@"\n\n\n\n\nkeyboard endFrame\ny: %f height: %f\n\n\n\n\n", endFrame.origin.y, endFrame.size.height);
    
    CGRect rect = self.toolBar.frame;
    rect.origin.y = kIsiPhoneX ? (self.view.frame.size.height - 84) : (self.view.frame.size.height - 50);
    rect.size.height = kIsiPhoneX ? 84 : 50;
    [UIView animateWithDuration:duration animations:^{
        self.toolBar.frame = rect;
        self.contentHeight = rect.size.height;
        self.isTextViewEditing = NO;
    }];
}

- (void)onKeyboardDidHide:(NSNotification *)noti {
    NSLog(@"4: onKeyboardDidHide");
    
    NSDictionary *userInfo = noti.userInfo;
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    NSLog(@"\n\n\n\n\nkeyboard endFrame\ny: %f height: %f\n\n\n\n\n", endFrame.origin.y, endFrame.size.height);
}

- (void)onKeyboardWillChangeFrame:(NSNotification *)noti {
    NSLog(@"5: onKeyboardWillChangeFrame");
    
    NSDictionary *userInfo = noti.userInfo;
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    NSLog(@"\n\n\n\n\nkeyboard endFrame\ny: %f height: %f\n\n\n\n\n", endFrame.origin.y, endFrame.size.height);
}

- (void)onKeyboardDidChangeFrame:(NSNotification *)noti {
    NSLog(@"6: onKeyboardDidChangeFrame");
    
    NSDictionary *userInfo = noti.userInfo;
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    NSLog(@"\n\n\n\n\nkeyboard endFrame\ny: %f height: %f\n\n\n\n\n", endFrame.origin.y, endFrame.size.height);
}

@end
