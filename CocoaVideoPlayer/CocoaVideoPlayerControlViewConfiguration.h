//
//  CocoaVideoPlayerControlViewConfiguration.h
//  CocoaVideoPlayer
//
//  Created by Yongwei on 4/28/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CocoaVideoPlayerControlViewConfiguration : NSObject

// ControlView itself
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic) CGFloat alpha;

// Scrubber
@property (nonatomic) CGSize scrubberSize;

// Subtitle button
@property (nonatomic) BOOL enableSubtitleButton;
@property (nonatomic) BOOL highlightSubtitleButton;

@end
