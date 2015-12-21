//
//  FDImageView.h
//
//  Created by naru on 2015/12/19.
//  Copyright © 2015年 naru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDImageAnalyzer.h"

/**
 Detect faces and adjustment image drawn place.
 */
@interface FDImageView : UIView

/**
 Drawn image.
 @discussion Image is automatically drawn when set this property if image is not nil.
 */
@property (nonatomic) UIImage * _Nullable image;

/**
 Options to determine order of faces.
 @discussion Image is automatically drawn when set this property if image is not nil.
 */
@property (nonatomic) FDFaceDetectionOptions detectionOptions;

/**
 Set image, detect faces (and cache result if needed).
 */
- (void)setImage:(UIImage * _Nullable)image cacheKey:(NSString * _Nullable)cacheKey animated:(BOOL)animated;

@end
