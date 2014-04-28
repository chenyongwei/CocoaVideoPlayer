//
//  CocoaVideoPlayerControlViewConfiguration.h
//  CocoaVideoPlayer
//
//  Created by Yongwei on 4/28/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CocoaVideoPlayerControlViewConfiguration : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic) CGFloat alpha;
@property (nonatomic) CGSize scrubberSize;
@property (nonatomic) BOOL enableSubtitleButton;
@property (nonatomic) BOOL highSubtitleButton;


@end
