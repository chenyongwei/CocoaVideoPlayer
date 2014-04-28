//
//  CocoaVideoPlayerView.m
//  CocoaVideoPlayer
//
//  Created by Yongwei.Chen on 4/24/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import "CocoaVideoPlayerView.h"
#import "CocoaVideoPlayerNotification.h"
#import "CocoaVideoModel.h"
#import "FAKFontAwesome.h"
#import "CocoaVideoPlayerControlView.h"
#import "CocoaVideoPlayerControlViewDelegate.h"
#import "CocoaVideoPlayerControlViewConfiguration.h"

#define PROGRESS_CHECK_INTERVAL 0.2f

/* Asset keys */
NSString *const kTracksKey = @"tracks";
NSString *const kPlayableKey = @"playable";

/* PlayerItem keys */
NSString *const kStatusKey = @"status";

/* AVPlayer keys */
NSString *const kRateKey = @"rate";
NSString *const kCurrentItemKey = @"currentItem";

static void *AVPlayerPlaybackViewControllerRateObservationContext = &AVPlayerPlaybackViewControllerRateObservationContext;
static void *AVPlayerPlaybackViewControllerStatusObservationContext = &AVPlayerPlaybackViewControllerStatusObservationContext;
static void *AVPlayerPlaybackViewControllerCurrentItemObservationContext = &AVPlayerPlaybackViewControllerCurrentItemObservationContext;

@interface CocoaVideoPlayerView() <CocoaVideoPlayerControlViewDelegate>
{
    id timeObserver;
    float restoreAfterScrubbingRate;
    AVPlayerItem *playerItem;
    BOOL seekToZeroBeforePlay;
    BOOL showSubtitles;
}

@property (nonatomic, strong) UIImageView *posterView;
@property (nonatomic, strong) AVPlayer *videoPlayer;
@property (nonatomic, strong) UIButton *defaultButton;
@property (nonatomic, strong) CocoaVideoPlayerControlView *progressView;
//    @property (nonatomic, strong) UIButton *playButton;
//    @property (nonatomic, strong) UIButton *stopButton;
//    @property (nonatomic, strong) UISlider *scrubber;
//    @property (nonatomic, strong) UIButton *subtitleButton;

@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) UIView *subtitleView;

-(void)adjustSubtitleLabelSize;
-(void)handlePauseNotification:(NSNotification *)notification;

@end

@implementation CocoaVideoPlayerView

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CocoaVideoPlayerDidStartPlayNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupPlayerUI];
        [self initScrubberTimer];
        
        [self syncPlayPauseButtons];
        [self syncScrubber];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self setupPlayerUI];

        [self initScrubberTimer];
        [self syncPlayPauseButtons];
        [self syncScrubber];
    }
    
    return self;
}

-(void)setupPlayerUI
{
    // player UI configuration
    // TODO: move to interface
    CGSize playIconSize = CGSizeMake(80, 80);
    
    showSubtitles = YES;
    
    self.posterView = [[UIImageView alloc] initWithFrame:
                            CGRectMake(0,
                                       0,
                                       CGRectGetWidth(self.frame),
                                       CGRectGetHeight(self.frame))];
    [self addSubview:self.posterView];

    self.defaultButton = ({
        UIButton *btn = [[UIButton alloc] initWithFrame:
                            CGRectMake(CGRectGetWidth(self.frame) / 2 - playIconSize.width / 2,
                                       CGRectGetHeight(self.frame) / 2 - playIconSize.height / 2,
                                       playIconSize.width,
                                       playIconSize.height)];
        btn.backgroundColor = [UIColor clearColor];
        CGFloat iconSize = 100;
        FAKFontAwesome *playIcon = [FAKFontAwesome playCircleOIconWithSize:iconSize];
        [playIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        UIImage *playIconImage = [playIcon imageWithSize:CGSizeMake(iconSize, iconSize)];
        [btn setImage:playIconImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self insertSubview:self.defaultButton aboveSubview:self.posterView];
    
    self.progressView = ({
        CocoaVideoPlayerControlView *v = [[CocoaVideoPlayerControlView alloc] initWithFrame:
                        CGRectMake(0,
                                   CGRectGetHeight(self.frame) - 35,
                                   CGRectGetWidth(self.frame),
                                   35)];
        
        v.backgroundColor = [UIColor blackColor];
        v.alpha = 0.8;
        v.viewConfig = [[CocoaVideoPlayerControlViewConfiguration alloc] init];
        v.viewConfig.scrubberSize = CGSizeMake(CGRectGetHeight(self.frame) - 35 - 100, 30);
        v;
    });
    [self insertSubview:self.progressView aboveSubview:self.posterView];
    
    // progress sub views
    
    self.subtitleView = ({
        UIView *v = [[UIView alloc] initWithFrame:
         CGRectMake(0,
                    CGRectGetHeight(self.frame) - 65,
                    CGRectGetWidth(self.frame),
                    30)];
        v.backgroundColor = [UIColor blackColor];
        v.alpha = 0.5;
        v.hidden = YES;
        v;
    });
    [self insertSubview:self.subtitleView aboveSubview:self.posterView];
    
    self.subtitleLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                  CGRectGetHeight(self.frame) - 65,
                                                  CGRectGetWidth(self.frame) - 20,
                                                  30)];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"";
        label.hidden = YES;
        label;
    });
    [self insertSubview:self.subtitleLabel aboveSubview:self.subtitleView];
    
    self.videoPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = ({
        AVPlayerLayer *avLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
        [avLayer setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        avLayer.backgroundColor = [[UIColor grayColor] CGColor];
        avLayer;
    });
    [self.layer insertSublayer:playerLayer below:self.posterView.layer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePauseNotification:)
                                                 name:CocoaVideoPlayerDidStartPlayNotification
                                               object:nil];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tapRecognizer];

}

-(void)handleTap
{
    if (!self.posterView.hidden)
    {
        return;
    }
    
    if (!self.progressView.hidden)
    {
        self.progressView.hidden = YES;
        [self adjustSubtitleLabelSize];
        
        return;
    }
    
    self.progressView.hidden = NO;
    
    // reposition the subtitleLabel if the progress bar show up
    [self adjustSubtitleLabelSize];
    
    [self hideProgressViewWithDelay];
}


#pragma mark - Setters

-(void)setPoster:(NSURL *)poster
{
    _poster = poster;
    
    NSData *data = [NSData dataWithContentsOfURL:poster];
    self.posterView.image = [UIImage imageWithData:data];
}


-(void)setUrl:(NSURL *)url
{
    _url = url;
    
    /*
     Create an asset for inspection of a resource referenced by a given URL.
     Load the values for the asset keys "tracks", "playable".
     */
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
    
    /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                            [self prepareToPlayAsset:asset withKeys:requestedKeys];
                        });
     }];
}

#pragma mark - Video control

-(BOOL)isScrubbing
{
    return restoreAfterScrubbingRate != 0.f;
}

-(void)hideProgressView
{
    if ([self isScrubbing])
    {
        return;
    }
    else
    {
        self.progressView.hidden = YES;
        // reposition the subtitleLabel if the progress bar is hidden
        [self adjustSubtitleLabelSize];
    }
}


-(void)hideProgressViewWithDelay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideProgressView) object:nil];
    [self performSelector:@selector(hideProgressView) withObject:nil afterDelay:2.0];
}


-(void)play
{
    /* If we are at the end of the movie, we must seek to the beginning first
     before starting playback. */
    if (YES == seekToZeroBeforePlay)
    {
        seekToZeroBeforePlay = NO;
        [self.videoPlayer seekToTime:kCMTimeZero];
    }
    
    if (!self.defaultButton.hidden)
    {
        self.defaultButton.hidden = YES;
    }
    self.posterView.hidden = YES;
    [self.progressView showPlayingButtons];
    [self hideProgressViewWithDelay];
    
    [self.videoPlayer play];
    // Notifiy other media players with current playing url
    [[NSNotificationCenter defaultCenter] postNotificationName:CocoaVideoPlayerDidStartPlayNotification object:self.url];
}


-(void)pause
{
    if ([self isPlaying])
    {
        [self.videoPlayer pause];
        [self.progressView showPausedButtons];
        [self hideProgressViewWithDelay];
    }
}


-(void)syncWithCueMark
{
    CGFloat currentSeconds = floorf((CMTimeGetSeconds([self.videoPlayer currentTime]) * 100  + 0.5)) / 100;
    CGFloat minCurrentSeconds = currentSeconds - PROGRESS_CHECK_INTERVAL;
    CGFloat maxCurrentSeconds = currentSeconds + PROGRESS_CHECK_INTERVAL;
    
    // Cue marks
    for (int i = 0; i < [self.cueMarks count]; i++)
    {
        CGFloat cueMarkSeconds = [((NSNumber *)[self.cueMarks objectAtIndex:i])floatValue];
        
        if (cueMarkSeconds > minCurrentSeconds && cueMarkSeconds < maxCurrentSeconds)
        {
            if ([self.delegate respondsToSelector:@selector(videoPlayerDidChangeCueMarkIndex:)])
            {
                [self.delegate videoPlayerDidChangeCueMarkIndex:i];
            }
            
            break;
        }
    }
}


-(void)updateCueMarksDataSturcture
{
    if ([self.cueMarks count] <= 0 || [[self.cueMarks objectAtIndex:0] isKindOfClass:[NSNumber class]])
    {
        // no cueMarks in json data structre
        // or cueMarks data structure already be converted to seconds
        return;
    }
    
    for (int i = 0; i < [self.cueMarks count]; i++)
    {
//        NSString *timeline = ((CocoaVideoCueMarkModel *)[self.cueMarks objectAtIndex:i]).timeline;
        
        // Format NSString to NSDate
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setDateFormat:@"mm:ss:SSS"];
//        NSDate *date = [dateFormat dateFromString:timeline];
//        
//        // Get the Gregorian calendar
//        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//        NSDateComponents *dateComponents = [cal components:NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:date];
//        NSInteger seconds = dateComponents.minute * 60 + dateComponents.second;
        
//        self.cueMarks[i] = [[NSNumber alloc] initWithInt:seconds];
    }
}


/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
-(void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
		NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
		NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   localizedDescription, NSLocalizedDescriptionKey,
								   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
								   nil];
		NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
	
	/* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (playerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [playerItem removeObserver:self forKeyPath:kStatusKey];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:playerItem];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [playerItem addObserver:self
                 forKeyPath:kStatusKey
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                    context:AVPlayerPlaybackViewControllerStatusObservationContext];
    
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playerItem];
    
    seekToZeroBeforePlay = NO;
    
    /* Create new player, if we don't already have one. */
    if (!self.videoPlayer)
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setVideoPlayer:[AVPlayer playerWithPlayerItem:playerItem]];
		
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.videoPlayer addObserver:self
                           forKeyPath:kCurrentItemKey
                              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                              context:AVPlayerPlaybackViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.videoPlayer addObserver:self
                           forKeyPath:kRateKey
                              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                              context:AVPlayerPlaybackViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.videoPlayer.currentItem != playerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur*/
        [self.videoPlayer replaceCurrentItemWithPlayerItem:playerItem];
        
        [self syncPlayPauseButtons];
    }
	
    [self.progressView resetScrubber];
}


-(void)stop
{
    [self playerItemDidReachEnd:nil];
}


/* Called when the player item has played to its end time. */
-(void)playerItemDidReachEnd:(NSNotification *)notification
{
    // After the movie has played to its end time, seek back to time zero to play it again
    seekToZeroBeforePlay = YES;
    
    self.defaultButton.hidden = NO;
    self.posterView.hidden = NO;
    [self.progressView showPausedButtons];
    self.progressView.hidden = YES;
    [self.videoPlayer seekToTime:kCMTimeZero];
    self.subtitleView.hidden = YES;
    
    // Callback about finished playback
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidFinishPlaying:)])
    {
        [self.delegate videoPlayerDidFinishPlaying:self.videoPlayer];
    }
}


-(CMTime)playerItemDuration
{
    AVPlayerItem *thePlayerItem = [self.videoPlayer currentItem];
    
    if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([thePlayerItem duration]);
    }
    
    return(kCMTimeInvalid);
}


-(void)togglePosterViewWithTime:(double)time
{
    if (time == 0.0)
    {
        self.posterView.hidden = NO;
    }
    else
    {
        self.posterView.hidden = YES;
    }
}


#pragma mark - Subtitles

-(void)adjustSubtitleLabelSize
{
    if (!showSubtitles)
    {
        return;
    }
    
    if (self.subtitleLabel.text.length > 0)
    {
        [self.subtitleLabel sizeToFit];
        
        if (self.progressView.hidden)
        {
            self.subtitleLabel.frame = CGRectMake(10, CGRectGetHeight(self.frame) - 2 - CGRectGetHeight(self.subtitleLabel.frame), CGRectGetWidth(self.frame) - 20, CGRectGetHeight(self.subtitleLabel.frame));
        }
        else
        {
            self.subtitleLabel.frame = CGRectMake(10, CGRectGetHeight(self.frame) - 37 - CGRectGetHeight(self.subtitleLabel.frame), CGRectGetWidth(self.frame) - 20, CGRectGetHeight(self.subtitleLabel.frame));
        }
        
        self.subtitleLabel.hidden = NO;
        self.subtitleView.hidden = NO;
        self.subtitleView.frame = CGRectMake(0, self.subtitleLabel.frame.origin.y - 2, CGRectGetWidth(self.frame), CGRectGetHeight(self.subtitleLabel.frame) + 5);
    }
    else
    {
        self.subtitleLabel.hidden = YES;
        self.subtitleView.hidden = YES;
    }
}


#pragma mark - Scrubbing

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer
{
	double interval = .1f;
	
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		return;
	}
    
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		CGFloat width = self.progressView.viewConfig.scrubberSize.width;
		interval = 0.5f * duration / width;
	}
    
    __block __weak CocoaVideoPlayerView *weakSelf = self;
    
	/* Update the scrubber during normal playback. */
	timeObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                  queue:NULL /* If you pass NULL, the main queue is used. */
                                                             usingBlock:^(CMTime time)
                    {
                        [weakSelf syncScrubber];
                    }];
    
}


/* The user is dragging the movie controller thumb to scrub through the movie. */
-(void)beginScrubbing:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideProgressView) object:nil];
    
    restoreAfterScrubbingRate = [self.videoPlayer rate];
    [self.videoPlayer setRate:0.f];
    
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
}

/* Set the player current time to match the scrubber position. */
-(void)scrub:(id)sender
{
	if ([sender isKindOfClass:[UISlider class]])
	{
		UISlider* slider = sender;
		
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration)) {
			return;
		}
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			float value = [slider value];
			
			double time = duration * (value - minValue) / (maxValue - minValue);
			
			[self.videoPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
            [self togglePosterViewWithTime:time];
		}
	}
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
-(void)endScrubbing:(id)sender
{
	if (!timeObserver)
	{
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration))
		{
			return;
		}
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			CGFloat width = self.progressView.viewConfig.scrubberSize.width;
			double tolerance = 0.5f * duration / width;
            
            __block __weak CocoaVideoPlayerView *weakSelf = self;
			timeObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
                            ^(CMTime time)
                            {
                                [weakSelf syncScrubber];
                            }];
		}
	}
    
	if (restoreAfterScrubbingRate)
	{
		[self.videoPlayer setRate:restoreAfterScrubbingRate];
		restoreAfterScrubbingRate = 0.f;
	}
    
    [self hideProgressViewWithDelay];
}


/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (timeObserver)
    {
        [self.videoPlayer removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
}



#pragma mark - KVO for player rate, currentItem, player item status

/* ---------------------------------------------------------
 **  Called when the value at the specified key path relative
 **  to the given object has changed.
 **  Adjust the movie play and pause button controls when the
 **  player item "status" value changes. Update the movie
 **  scrubber control when the player item is ready to play.
 **  Adjust the movie scrubber control when the player item
 **  "rate" value changes. For updates of the player
 **  "currentItem" property, set the AVPlayer for which the
 **  player layer displays visual output.
 **  NOTE: this method is invoked on the main queue.
 ** ------------------------------------------------------- */
-(void)observeValueForKeyPath:(NSString*) path
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context
{
	/* AVPlayerItem "status" property value observer. */
	if (context == AVPlayerPlaybackViewControllerStatusObservationContext)
	{
		[self syncPlayPauseButtons];
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                
                [self.progressView disableScrubber];
                [self.progressView disablePlayerButtons];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                [self initScrubberTimer];
                
                [self.progressView enableScrubber];
                [self.progressView enablePlayerButtons];
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *failedPlayerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:failedPlayerItem.error];
            }
                break;
        }
    }
    /* AVPlayer "rate" property value observer. */
    else if (context == AVPlayerPlaybackViewControllerRateObservationContext)
    {
        [self syncPlayPauseButtons];
    }
    /* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
    else if (context == AVPlayerPlaybackViewControllerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
            [self.progressView disablePlayerButtons];
            [self.progressView disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            
            [self syncPlayPauseButtons];
        }
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}


/* If the media is playing, show the stop button; otherwise, show the play button. */
-(void)syncPlayPauseButtons
{
    if ([self isPlaying])
    {
        [self.progressView showPlayingButtons];
    }
    else
    {
        [self.progressView showPausedButtons];
    }
}


/* Set the scrubber based on the player current time. */
-(void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
    
    if (CMTIME_IS_INVALID(playerDuration))
    {
        self.progressView.scrubber.minimumValue = 0.0;
        
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    
    if (isfinite(duration))
    {
        float minValue = [self.progressView.scrubber minimumValue];
        float maxValue = [self.progressView.scrubber maximumValue];
        double time = CMTimeGetSeconds([self.videoPlayer currentTime]);
        
        [self togglePosterViewWithTime:time];
        [self.progressView.scrubber setValue:(maxValue - minValue) * time / duration + minValue];
        
        // show subtitle
        for (int i = 0; i < [self.subtitles count]; i++)
        {
            CocoaVideoScriptModel *script = (CocoaVideoScriptModel *)self.subtitles[i];
            
            if (time >= script.startTime && time <= script.endTime)
            {
                if (self.subtitleLabel.text != script.txt)
                {
                    self.subtitleLabel.text = script.txt;
                    [self adjustSubtitleLabelSize];
                }
                break;
            }
            else
            {
                self.subtitleLabel.text = @"";
            }
            
            [self adjustSubtitleLabelSize];
        }
    }
}



-(BOOL)isPlaying
{
    return restoreAfterScrubbingRate != 0.f || [self.videoPlayer rate] != 0.f;
}


-(void)toggleSubtitle
{
    showSubtitles = !showSubtitles;
    self.subtitleLabel.hidden = !showSubtitles;
    self.subtitleView.hidden = !showSubtitles;
}

#pragma mark - Error Handling

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 ** ----------------------------------------------------------- */
-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self.progressView disableScrubber];
    [self.progressView disablePlayerButtons];
    
    /* Display the error. */
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
														message:[error localizedFailureReason]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

#pragma mark - Notification Handling

-(void)handlePauseNotification:(NSNotification *)notification
{
    NSURL *notifiedPlayerUrl = notification.object;
    
    if (![notifiedPlayerUrl.absoluteString isEqualToString:self.url.absoluteString])
    {
        [self pause];
    }
}

@end
