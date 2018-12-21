//
//  KBMainTableViewCell.m
//  KeyBoardTest
//
//  Created by 谢立颖 on 2018/12/21.
//  Copyright © 2018 谢立颖. All rights reserved.
//

#import "KBMainTableViewCell.h"
#import "UIView+CustomAutoLayout.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface KBMainTableViewCell ()

@property(nonatomic,strong) UIImageView *imgView;
@property(nonatomic,strong) UILabel *label;

@end

@implementation KBMainTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self drawView];
        [self layoutSubViews];
    }
    return self;
}

- (void)drawView {
    _imgView = [[UIImageView alloc] init];
    _imgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [self.contentView addSubview:_imgView];
    
    _label = [[UILabel alloc] init];
    _label.textColor = [UIColor blackColor];
    _label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    [self.contentView addSubview:_label];
}

- (void)layoutSubViews {
    [_imgView sizeWith:CGSizeMake(40, 40)];
    [_imgView alignParentLeftWithMargin:18];
    [_imgView alignParentTopWithMargin:10];
    
    [_label sizeWith:CGSizeMake(100, 20)];
    [_label alignTop:_imgView];
    [_label alignLeft:_imgView margin:54];
    
}

- (void)configData:(NSDictionary *)data {
    NSString *iconUrl = [data objectForKey:@"icon"];
    NSString *title = [data objectForKey:@"title"];
    
    [_imgView sd_setImageWithURL:[NSURL URLWithString:iconUrl]];
    _label.text = title;
}

@end
