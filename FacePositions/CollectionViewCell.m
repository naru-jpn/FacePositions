//
//  CollectionViewCell.m
//  FacePositions
//
//  Created by naru on 2015/12/24.
//  Copyright © 2015年 naru. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.fd_imageView];
        [self.contentView setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    }
    return self;
}

- (FDImageView *)fd_imageView {
    if (_fd_imageView) {
        return _fd_imageView;
    }
    CGRect frame = CGRectInset(self.contentView.bounds, 0.0f, 0.0f);
    _fd_imageView = [[FDImageView alloc] initWithFrame:frame];
    [_fd_imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    return _fd_imageView;
}

@end
