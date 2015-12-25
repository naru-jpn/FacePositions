//
//  ViewController.m
//  FacePositions
//
//  Created by naru on 2015/12/19.
//  Copyright © 2015年 naru. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "FDImageView.h"
#import "FDImageAnalyzer.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic) UICollectionView *collectionView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.collectionView];
}

- (UICollectionView *)collectionView {
    if (_collectionView) {
        return _collectionView;
    }
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    [layout setItemSize:CGSizeMake(self.view.bounds.size.width-8.0f, 100.0f)];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setMinimumLineSpacing:4.0f];
    [layout setMinimumInteritemSpacing:0.0f];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    return _collectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImage *image = [UIImage imageNamed:@"image_sample"];
    NSString *cacheKey = [NSString stringWithFormat:@"%ld.%ld", (long)indexPath.section, (long)indexPath.row];
    [cell.fd_imageView setImage:nil];
    [cell.fd_imageView cancelDetecting];
    [cell.fd_imageView setImage:image cacheKey:cacheKey animated:YES];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
