//
//  FDImageAnalysisCache.m
//  FacePositions
//
//  Created by naru on 2015/12/21.
//  Copyright © 2015年 naru. All rights reserved.
//

#import "FDImageAnalysisCache.h"

@implementation FDImageAnalysisCache

static FDImageAnalysisCache *_sharedCache;

+ (instancetype)sharedCache {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _sharedCache = [FDImageAnalysisCache new];
    });
    return _sharedCache;
}

@end
