//
//  CocoaVideoScriptModel.m
//  CocoaVideoPlayer
//
//  Created by Yongwei.Chen on 4/24/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import "CocoaVideoScriptModel.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "MTLValueTransformer.h"

@implementation CocoaVideoScriptModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            };
}

+ (NSValueTransformer *)startTimeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id str) {
        return [NSNumber numberWithLong:([CocoaVideoScriptModel getMilliSecondsFromString:str] / 1000)];
    } reverseBlock:^id(id milliseconds) {
        return [CocoaVideoScriptModel getDateStringFromMilliSeconds:((NSNumber *)milliseconds).longValue];
    }];
}

+ (NSValueTransformer *)endTimeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id str) {
        return [NSNumber numberWithLong:([CocoaVideoScriptModel getMilliSecondsFromString:str] / 1000)];
    } reverseBlock:^id(id milliseconds) {
        return [CocoaVideoScriptModel getDateStringFromMilliSeconds:((NSNumber *)milliseconds).longValue];
    }];
}

+ (long)getMilliSecondsFromString:(NSString *)dateString
{
    NSArray *dateComponents = [dateString componentsSeparatedByString:@":"];
    int minuteValue = ((NSString *)dateComponents[0]).intValue;
    int secondValue = ((NSString *)dateComponents[1]).intValue;
    int millisecondValue = ((NSString *)dateComponents[2]).intValue;

    return (millisecondValue + secondValue * 1000 + minuteValue * 60000);
}

+ (NSString *)getDateStringFromMilliSeconds:(long)milliSeconds
{
    int minuteValue = ceil(milliSeconds / 60000);
    NSString *minuteStr = minuteValue >= 10 ? [NSString stringWithFormat:@"%d", minuteValue] : [NSString stringWithFormat:@"0%d", minuteValue];
    
    int secondValue = ceil((milliSeconds - minuteValue * 60000) / 1000);
    NSString *secondStr = secondValue >= 10 ? [NSString stringWithFormat:@"%d", secondValue] : [NSString stringWithFormat:@"0%d", secondValue];
    
    int millisecondValue = milliSeconds - minuteValue * 60000 - secondValue * 1000;
    NSString *millisecondStr = millisecondValue >= 100 ? [NSString stringWithFormat:@"%d", millisecondValue] : (millisecondValue >= 10 ? [NSString stringWithFormat:@"0%d", millisecondValue] : [NSString stringWithFormat:@"%00d", millisecondValue]);
    
    return [NSString stringWithFormat:@"%@:%@:%@", minuteStr, secondStr, millisecondStr];
}

@end
