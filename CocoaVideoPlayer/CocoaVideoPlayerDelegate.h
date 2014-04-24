//
//  CocoaVideoPlayerDelegate.h
//  CocoaVideoPlayer
//
//  Created by Yongwei.Chen on 4/24/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"

@protocol CocoaVideoPlayerDelegate <NSObject>

@optional
-(void)videoPlayerDidStartPlaying:(AVPlayer *)player;

-(void)videoPlayerDidFinishPlaying:(AVPlayer *)player;

-(void)videoPlayerDidChangeCueMarkIndex:(int)cueMarkIndex;

@end
