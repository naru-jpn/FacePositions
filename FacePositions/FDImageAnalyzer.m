//
//  FDImageAnalyzer.m
//  FacePositions
//
//  Created by naru on 2015/12/19.
//  Copyright © 2015年 naru. All rights reserved.
//

#import "FDImageAnalyzer.h"


@implementation FDImageAnalyzedUnit

+ (instancetype)unitWithRange:(FDRange)range point:(NSInteger)point {
    return [[FDImageAnalyzedUnit alloc] initWithRange:range point:point];
}

- (instancetype)initWithRange:(FDRange)range point:(NSInteger)point {
    if (self = [super init]) {
        self.range = range;
        self.point = point;
        self.endAnchor = nil;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, range(loc):%f, range(len):%f, point: %ld, endAnchor: %p>", self.class, self, _range.location, _range.length, (long)_point, _endAnchor];
}

@end


typedef NS_ENUM(NSInteger, FDImageAnalysisDirection) {
    FDImageAnalysisDirectionHorizontal,
    FDImageAnalysisDirectionVertical
};

@implementation FDImageAnalyzer {
    __block BOOL _canceled;
    FDImageAnalysisDirection _direction;
}

/// Return direction for analysis.
FDImageAnalysisDirection fd_direction(CGSize imageSize, CGFloat aspectRatio) {
    return (imageSize.width/imageSize.height > aspectRatio) ? FDImageAnalysisDirectionHorizontal : FDImageAnalysisDirectionVertical;
}

/// Return max length for analysis direction.
CGFloat fd_effectiveLength(CGSize imageSize, CGFloat aspectRatio, FDImageAnalysisDirection direction) {
    if (direction == FDImageAnalysisDirectionHorizontal) {
        return imageSize.height*aspectRatio;
    } else {
        return imageSize.width/aspectRatio;
    }
}

/// Return length of image for the direction.
CGFloat fd_totalLength(CGSize imageSize, FDImageAnalysisDirection direction) {
    if (direction == FDImageAnalysisDirectionHorizontal) {
        return imageSize.width;
    } else {
        return imageSize.height;
    }
}

CGRect fd_resultRect(FDRange resultRange, CGSize imageSize, FDImageAnalysisDirection direction) {
    if (direction == FDImageAnalysisDirectionHorizontal) {
        return CGRectMake(resultRange.location, 0.0f, resultRange.length, imageSize.height);
    } else {
        return CGRectMake(0.0f, resultRange.location, imageSize.width, resultRange.length);
    }
}

- (void)findSuitableRectWithImage:(UIImage *)image
                      aspectRatio:(CGFloat)aspectRatio
                           result:(void (^)(FDImageAnalysisResult, NSValue *))result
                          options:(FDFaceDetectionOptions)options {
    // Detect faces.
    [self detectFacesWithImage:image
                      Accuracy:(options & FDFaceDetectionOptionsAccuracyHigh) ? CIDetectorAccuracyHigh : CIDetectorAccuracyLow
                 resultHandler:^(NSArray <NSValue *> *frames) {
        
        // Return here if no face detected.
        if (frames.count == 0) {
            result(FDImageAnalysisResultNoFaceDetected, nil);
            return;
        }
        
        // Get paramters.
        FDImageAnalysisDirection direction = fd_direction(image.size, aspectRatio);
        CGFloat effectiveLength = fd_effectiveLength(image.size, aspectRatio, direction);
        CGFloat totalLength = fd_totalLength(image.size, direction);
        
        // Create array of range unit.
        NSArray *unitArray = [self analyzedUnitArrayWithValues:frames direction:direction options:options];
        // Calculate suitable range for the direction.
        FDRange range = [self suitableRangeWithUnitArray:unitArray effectiveLength:effectiveLength totalLength:totalLength];
                             
        // Pass result for the handler blocks.
        CGRect resultRect = fd_resultRect(range, image.size, direction);
        result(FDImageAnalysisResultSuccess, [NSValue valueWithCGRect:resultRect]);
    }];
}

/**
 Detect faces in background thread.
 @param image image to detect faces.
 @param accuracy CIDetectorAccuracyLow or CIDetectorAccuracyHigh.
 @param resultHandler Passes NSValues contain CGRect values.
 */
- (void)detectFacesWithImage:(UIImage *)image
                    Accuracy:(NSString * _Nonnull const)accuracy
               resultHandler:(void (^ _Nullable)(NSArray <NSValue *> * _Nullable frames))resultHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Create detector.
        CIImage *ciimage = [CIImage imageWithCGImage:image.CGImage];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{accuracy: CIDetectorAccuracy}];
        NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:@(image.imageOrientation) forKey:CIDetectorImageOrientation];
        NSArray *features = [detector featuresInImage:ciimage options:imageOptions];
        
        CGSize size = image.size;
        NSInteger count = features.count;
        CGFloat scale = [[UIScreen mainScreen] scale];
        NSMutableArray *frames = [NSMutableArray arrayWithCapacity:count];
        
        // Convert bounds to frames represented in the coordinate of Cocoa.
        for (CIFaceFeature *feature in features) {
            CGRect bounds = feature.bounds;
            CGRect frame = ({
                CGFloat y = size.height*scale - CGRectGetMaxY(bounds);
                CGRectMake(bounds.origin.x/scale, y/scale, bounds.size.width/scale, bounds.size.height/scale);
            });
            frames[[features indexOfObject:feature]] = [NSValue valueWithCGRect:frame];
        }
        if (resultHandler) resultHandler(frames);
    });
}

- (NSArray <FDImageAnalyzedUnit *> *)analyzedUnitArrayWithValues:(NSArray <NSValue *> *)values
                                                       direction:(FDImageAnalysisDirection)direction
                                                         options:(FDFaceDetectionOptions)options {
    // Sort values to put the point for each value.
    NSArray *sortedArray = nil;
    if (options & FDFaceDetectionOptionsFaceOrderLarge || options & FDFaceDetectionOptionsFaceOrderSmall) {
        sortedArray = [values sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2){
            CGFloat value1, value2;
            if (direction == FDImageAnalysisDirectionHorizontal) {
                value1 = CGRectGetWidth(obj1.CGRectValue);
                value2 = CGRectGetWidth(obj2.CGRectValue);
            } else {
                value1 = CGRectGetHeight(obj1.CGRectValue);
                value2 = CGRectGetHeight(obj2.CGRectValue);
            }
            if (value1 < value2) {
                return NSOrderedDescending;
            } else if (value1 > value2) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
    } else {
        sortedArray = values;
    }
    // Create unit array.
    NSMutableArray *unitArray = [NSMutableArray array];
    NSInteger count = sortedArray.count;
    for (NSValue *value in sortedArray) {
        NSInteger point;
        if (options & FDFaceDetectionOptionsFaceOrderLarge) {
            point = count - [sortedArray indexOfObject:value];
        } else if (options & FDFaceDetectionOptionsFaceOrderSmall) {
            point = [sortedArray indexOfObject:value] + 1;
        } else {
            point = 1;
        }
        CGRect frame = value.CGRectValue;
        FDRange range;
        if (direction == FDImageAnalysisDirectionHorizontal) {
            range = FDRangeMake(CGRectGetMinX(frame), CGRectGetWidth(frame));
        } else {
            range = FDRangeMake(CGRectGetMinY(frame), CGRectGetHeight(frame));
        }
        [unitArray addObject:[FDImageAnalyzedUnit unitWithRange:range point:point]];
    }
    return unitArray;
}

- (FDRange)suitableRangeWithUnitArray:(NSArray <FDImageAnalyzedUnit *> *)unitArray
                      effectiveLength:(CGFloat)effectiveLength
                          totalLength:(CGFloat)totalLength {
    
    // Find range containing some unit where total point for contained unit is the highest.
    NSInteger highestPoint = 0;
    FDImageAnalyzedUnit *anchorUnit = nil;
    for (FDImageAnalyzedUnit *unit in unitArray) {
        NSInteger totalPoint = unit.point;
        for (FDImageAnalyzedUnit *_unit in unitArray) {
            if (_unit == unit) {
                continue;
            }
            if ((unit.range.location < _unit.range.location) && (unit.range.location + effectiveLength) > FDRangeGetMaxValue(_unit.range)) {
                totalPoint = totalPoint + _unit.point;
                if (!unit.endAnchor || FDRangeGetMaxValue(unit.endAnchor.range) < FDRangeGetMaxValue(_unit.range)) {
                    unit.endAnchor = _unit;
                }
            }
        }
        if (highestPoint < totalPoint) {
            highestPoint = totalPoint;
            anchorUnit = unit;
        }
    }
    
    // Add extra space on both sides.
    FDRange range = FDRangeMake(anchorUnit.range.location, FDRangeGetMaxValue(anchorUnit.endAnchor.range)-anchorUnit.range.location);
    CGFloat space = (effectiveLength - range.length)/2.0f;
    range = ({
        CGFloat min = range.location - space;
        CGFloat max = range.location + range.length + space;
        if (0 > min) {
            max = max - min;
            min = 0.0f;
        }
        if (totalLength < max) {
            min = min - (max - totalLength);
            max = totalLength;
        }
        FDRangeMake(min, (max - min));
    });
    return range;
}

@end
