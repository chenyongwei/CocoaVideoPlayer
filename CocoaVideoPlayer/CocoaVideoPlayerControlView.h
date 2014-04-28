//
//  CocoaVideoPlayerControlView.h
//  CocoaVideoPlayer
//
//  Created by Yongwei.Chen on 4/28/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaVideoPlayerControlViewConfiguration.h"
#import "CocoaVideoPlayerControlViewDelegate.h"
#import <CoreMedia/CoreMedia.h>

@interface CocoaVideoPlayerControlView : UIView

@property (nonatomic, strong) UISlider *scrubber;

@property (nonatomic, strong) CocoaVideoPlayerControlViewConfiguration *viewConfig;
@property (nonatomic, weak) id <CocoaVideoPlayerControlViewDelegate> delegate;

-(void)enableScrubber;
-(void)disableScrubber;
-(void)showPlayingButtons;
-(void)showPausedButtons;

-(void)resetScrubber;

@end