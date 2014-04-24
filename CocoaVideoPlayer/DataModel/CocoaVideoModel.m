//
//  CocoaVideoModel.m
//  CocoaVideoPlayer
//
//  Created by Yongwei.Chen on 4/24/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import "CocoaVideoModel.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation CocoaVideoModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"imagePath" : @"content.poster.url",
             @"videoPath" : @"content.video.url",
             @"cueMarks" : @"content.cueMarks",
             @"scripts" : @"content.scripts"
            };
}

+ (NSValueTransformer *)cueMarksJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CocoaVideoCueMarkModel class]];
}

+ (NSValueTransformer *)scriptsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CocoaVideoScriptModel class]];
}

@end
