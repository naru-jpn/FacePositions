//
//  FDImageView.m
//
//  Created by naru on 2015/12/19.
//  Copyright © 2015年 naru. All rights reserved.
//

#import "FDImageView.h"
#import "FDImageAnalysisCache.h"

@interface FDImageView ()
@property (nonatomic) NSValue *detectedRectValue;
@property (nonatomic) FDImageAnalyzer *analyzer;
@property (nonatomic) NSString *cacheKey;
@end

@implementation FDImageView {
    BOOL _animated;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setClipsToBounds:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        _analyzer = [[FDImageAnalyzer alloc] init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setClipsToBounds:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        _analyzer = [[FDImageAnalyzer alloc] init];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    [self setImage:image cacheKey:nil animated:NO];
}

- (void)setImage:(UIImage *)image cacheKey:(NSString *)cacheKey animated:(BOOL)animated {
    
    // Clear if image is nil.
    if (nil == image) {
        _image = nil;
        _detectedRectValue = nil;
        [self setNeedsDisplay];
    }
    
    // Get key for caching.
    CGFloat aspectRatio = CGRectGetWidth(self.frame)/CGRectGetHeight(self.frame);
    NSString *key = cacheKey ? ({
        NSString *ratio = [NSString stringWithFormat:@"%5.2f", aspectRatio];
        [NSString stringWithFormat:@"%@_%@", cacheKey, ratio];
    }) : nil;
    
    _image = image;
    _cacheKey = key;
    _detectedRectValue = nil;
    if (_image) {
        
        // Search cached value.
        if (_cacheKey) {
            NSValue *cachedValue = [[FDImageAnalysisCache sharedCache] objectForKey:_cacheKey];
            if (cachedValue) {
                _detectedRectValue = cachedValue;
                [self setNeedsDisplay];
                return;
            }
        }
        
        // Find suitable rect.
        CGFloat aspectRatio = CGRectGetWidth(self.frame)/CGRectGetHeight(self.frame);
        [_analyzer findSuitableRectWithImage:_image aspectRatio:aspectRatio result:^(FDImageAnalysisResult result, NSValue *value) {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Return here if detection cancelled.
                if (result == FDImageAnalysisResultCancelled) {
                    return;
                }
                _detectedRectValue = value;
                [self setNeedsDisplay];
                
                // Execute fade-in animation if animated is true.
                if (animated) {
                    [self setAlpha:0.0f];
                    [UIView animateWithDuration:0.4f animations:^{
                        [self setAlpha:1.0f];
                    }];
                }
                
                // Save cache value if needed.
                if (_cacheKey) {
                    [[FDImageAnalysisCache sharedCache] setObject:_detectedRectValue forKey:_cacheKey];
                }
            });
            
        } options:FDFaceDetectionOptionsFaceOrderLarge];
    }
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Fill background color.
    CGContextClearRect(context, rect);
    if (nil != self.backgroundColor) {
        NSInteger num = CGColorGetNumberOfComponents(self.backgroundColor.CGColor);
        const CGFloat *comps = CGColorGetComponents(self.backgroundColor.CGColor);
        if (num == 2) {
            CGFloat color[4] = {comps[0], comps[0], comps[0], comps[1]};
            CGContextSetFillColor(context, color);
        } else {
            CGFloat color[4] = {comps[0], comps[1], comps[2], comps[3]};
            CGContextSetFillColor(context, color);
        }
        CGContextFillRect(context, self.bounds);
    }
    
    // Draw image.
    CGContextSetAllowsAntialiasing(context, false);
    if (_image && _detectedRectValue) {
        CGRect detectedRect = _detectedRectValue.CGRectValue;
        CGFloat rate = self.imageReductionRate;
        CGRect imageRect = CGRectMake(-detectedRect.origin.x*rate, -detectedRect.origin.y*rate, _image.size.width*rate, _image.size.height*rate);
        [_image drawInRect:imageRect];
    }
}

- (CGFloat)imageReductionRate {
    if (_image) {
        if (_image.size.width/_image.size.height > self.frame.size.width/self.frame.size.height) {
            return self.frame.size.height/_image.size.height;
        } else {
            return self.frame.size.width/_image.size.width;
        }
    }
    return 0.0f;
}

- (void)cancelDetecting {
    [_analyzer cancel];
    _analyzer = [[FDImageAnalyzer alloc] init];
}

@end
