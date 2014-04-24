//
//  CocoaVideoScriptModel.m
//  CocoaVideoPlayer
//
//  Created by Yongwei.Chen on 4/24/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import "CocoaVideoScriptModel.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation CocoaVideoScriptModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
            };
}

//+ (NSValueTransformer *)startJSONTransformer {
//    
//    NSValueTransformer *NSNumberValueTransformer = [NSValueTransformer
//                                                reversibleTransformerWithForwardBlock:^ id (NSString *str) {
//                                                    if (![str isKindOfClass:NSString.class]) return nil;
//                                                    return [NSURL URLWithString:str];
//                                                }
//                                                reverseBlock:^ id (NSURL *URL) {
//                                                    if (![URL isKindOfClass:NSURL.class]) return nil;
//                                                    return URL.absoluteString;
//                                                }];
//    
//    [NSValueTransformer setValueTransformer:URLValueTransformer forName:MTLURLValueTransformerName];]
//    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
//}

@end
