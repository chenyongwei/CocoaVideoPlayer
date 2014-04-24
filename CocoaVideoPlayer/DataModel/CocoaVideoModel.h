//
//  CocoaVideoModel.h
//  CocoaVideoPlayer
//
//  Created by Yongwei.Chen on 4/24/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>
#import "CocoaVideoCueMarkModel.h"
#import "CocoaVideoScriptModel.h"

@interface CocoaVideoModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *imagePath;
@property (nonatomic, copy, readonly) NSString *videoPath;
@property (nonatomic, strong, readonly) NSArray *cueMarks;
@property (nonatomic, strong, readonly) NSArray *scripts;

@end
