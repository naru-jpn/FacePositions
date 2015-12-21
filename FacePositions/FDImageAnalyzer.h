//
//  FDImageAnalyzer.h
//  FacePositions
//
//  Created by naru on 2015/12/19.
//  Copyright © 2015年 naru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef struct {
    CGFloat location;
    CGFloat length;
} FDRange;

static inline FDRange FDRangeMake(CGFloat location, CGFloat length) { return (FDRange){location, length}; }

static inline CGFloat FDRangeGetMaxValue(FDRange range) { return range.location + range.length; }

#define FDRangeZero (FDRange){0.0f,0.0f}

/**
 Options to determine order of faces.
 */
typedef NS_OPTIONS(NSInteger, FDFaceDetectionOptions) {
    /// None.
    FDFaceDetectionOptionsNone = 0,
    /// Face occupying wider area has higher order.
    FDFaceDetectionOptionsFaceOrderLarge,
    /// Face occupying smaller area has higher order.
    FDFaceDetectionOptionsFaceOrderSmall,
    /// Detect faces with accuracy high.
    FDFaceDetectionOptionsAccuracyHigh,
};

/** Result of analysis. */
typedef NS_ENUM(NSInteger, FDImageAnalysisResult) {
    /** Success. */
    FDImageAnalysisResultSuccess,
    /** No faces detected. */
    FDImageAnalysisResultNoFaceDetected
};

@interface FDImageAnalyzedUnit : NSObject
@property (nonatomic) FDRange range;
@property (nonatomic) NSInteger point;
@property (nonatomic, weak) FDImageAnalyzedUnit * _Nullable endAnchor;
+ (instancetype _Nonnull)unitWithRange:(FDRange)range point:(NSInteger)point;
@end

/**
 Analyze image contains faces.
 */
@interface FDImageAnalyzer : NSObject

/**
 Find suitable rect to show image from image and aspect ratio of the image view.
 @param image image to show.
 @param aspectRatio aspect ratio for the view showing image (width/height).
 @param result handler of result.
 @param options options to determine faces and find suitable rect.
 */
- (void)findSuitableRectWithImage:(UIImage * _Nonnull)image
                      aspectRatio:(CGFloat)aspectRatio
                           result:(void (^ _Nonnull)(FDImageAnalysisResult result, NSValue * _Nullable value))result
                          options:(FDFaceDetectionOptions)options;

@end
