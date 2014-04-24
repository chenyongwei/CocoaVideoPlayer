//
//  CocoaVideoScriptModel.h
//  CocoaVideoPlayer
//
//  Created by Yongwei.Chen on 4/24/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@interface CocoaVideoScriptModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *txt;
@property (nonatomic, copy, readonly) NSString *startTime;
@property (nonatomic, copy, readonly) NSString *endTime;
@property (nonatomic, strong, readonly) NSNumber *start;
@property (nonatomic, strong, readonly) NSNumber *end;

@end
