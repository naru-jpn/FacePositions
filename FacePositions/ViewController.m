//
//  ViewController.m
//  FacePositions
//
//  Created by naru on 2015/12/19.
//  Copyright © 2015年 naru. All rights reserved.
//

#import "ViewController.h"
#import "FDImageView.h"
#import "FDImageAnalyzer.h"

@interface ViewController ()
@property (nonatomic) FDImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self.view addSubview:self.imageView];
    UIImage *image = [UIImage imageNamed:@"image_sample"];
    [_imageView setImage:image cacheKey:@"sample" animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"!!!!!!!");
        [_imageView setImage:nil];
        [_imageView setImage:image cacheKey:@"sample" animated:YES];
    });
}

- (FDImageView *)imageView {
    if (_imageView) {
        return _imageView;
    }
    _imageView = [[FDImageView alloc] initWithFrame:(CGRect){.origin = CGPointZero, .size = CGSizeMake(340.0f, 100.0f)}];
    [_imageView setCenter:self.view.center];
    return _imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
