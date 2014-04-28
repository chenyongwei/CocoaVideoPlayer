//
//  CocoaVideoPlayerControlViewDelegate.h
//  CocoaVideoPlayer
//
//  Created by Yongwei on 4/28/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CocoaVideoPlayerControlViewDelegate <NSObject>

-(void)play;
-(void)pause;

-(void)beginScrubbing:(id)sender;
-(void)scrub:(id)sender;
-(void)endScrubbing:(id)sender;

-(void)toggleSubtitle;

@end
