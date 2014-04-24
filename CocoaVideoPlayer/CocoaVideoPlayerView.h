//
//  CocoaVideoPlayerView.h
//  CocoaVideoPlayer
//
//  Created by Yongwei.Chen on 4/24/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaVideoPlayerDelegate.h"

@interface CocoaVideoPlayerView : UIView

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) NSURL *poster;

@property (nonatomic, strong) NSArray *cueMarks;

@property (nonatomic, strong) NSArray *subtitles;

@property (nonatomic, weak) id <CocoaVideoPlayerDelegate> delegate;

-(void)pause;

-(void)stop;

@end
