//
//  CocoaVideoPlayerControlView.m
//  CocoaVideoPlayer
//
//  Created by Yongwei.Chen on 4/28/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import "CocoaVideoPlayerControlView.h"
#import "FAKFontAwesome.h"
#import "CocoaVideoPlayerControlViewConfiguration.h"

@interface CocoaVideoPlayerControlView()

@property (nonatomic, strong) UISlider *scrubber;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *subtitleButton;
@property (nonatomic, strong) UIButton *fullscreenButton;

@property (nonatomic, strong) CocoaVideoPlayerControlViewConfiguration *config;

@end

@implementation CocoaVideoPlayerControlView

- (id)initWithFrame:(CGRect)frame configuration:(CocoaVideoPlayerControlViewConfiguration *)aConfig
{
    self = [super initWithFrame:frame];
    if (self) {
        self.config = aConfig;
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.backgroundColor = self.config.backgroundColor;
    self.alpha = self.config.alpha;
    
    self.playButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(-8, 3, 85, 30);
        FAKFontAwesome *playIcon = [FAKFontAwesome playIconWithSize:30];
        [playIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        UIImage *playIconImage = [playIcon imageWithSize:CGSizeMake(30, 30)];
        [btn setImage:playIconImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self addSubview:self.playButton];
    
    self.stopButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(-8, 3, 85, 30);
        FAKFontAwesome *stopIcon = [FAKFontAwesome pauseIconWithSize:30];
        [stopIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        UIImage *stopIconImage = [stopIcon imageWithSize:CGSizeMake(30, 30)];
        [btn setImage:stopIconImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self addSubview:self.stopButton];
    
    self.scrubber = ({
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(60, 3, self.config.scrubberSize.width, self.config.scrubberSize.height)];
        [slider addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [slider addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside | UIControlEventValueChanged];
        slider;

    });
    [self addSubview:self.scrubber];
    
    if (self.config.enableSubtitleButton) {
        self.subtitleButton = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(CGRectGetWidth(self.frame) - 80, 0, 30, 30);
            
            FAKFontAwesome *subTitleIcon = [FAKFontAwesome subscriptIconWithSize:30];
            [subTitleIcon addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor]];
            UIImage *subTitleOffImage = [subTitleIcon imageWithSize:CGSizeMake(30, 30)];
            [btn setImage:subTitleOffImage forState:UIControlStateNormal];
            
            [subTitleIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor]];
            UIImage *subTitleOnImage = [subTitleIcon imageWithSize:CGSizeMake(30, 30)];
            [btn setImage:subTitleOnImage forState:UIControlStateSelected];
            
            [btn addTarget:self action:@selector(toggleSubtitleButton) forControlEvents:UIControlEventTouchUpInside];
            btn.selected = self.config.highlightSubtitleButton;
            btn;
        });
        [self addSubview:self.subtitleButton];
    }
    
    self.fullscreenButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(CGRectGetWidth(self.frame) - 35, 4, 30, 30);
        
        FAKFontAwesome *icon = [FAKFontAwesome expandIconWithSize:20];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor]];
        UIImage *iconImage = [icon imageWithSize:CGSizeMake(20, 20)];
        [btn setImage:iconImage forState:UIControlStateNormal];
        
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor]];
        iconImage = [icon imageWithSize:CGSizeMake(20, 20)];
        [btn setImage:iconImage forState:UIControlStateSelected];
        
        [btn addTarget:self action:@selector(toggleFullscreen) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self addSubview:self.fullscreenButton];
    
    
    
}

-(void)beginScrubbing:(id)sender
{
    [self.delegate beginScrubbing:sender];
}

-(void)scrub:(id)sender
{
    [self.delegate scrub:sender];
}

-(void)endScrubbing:(id)sender
{
    [self.delegate endScrubbing:sender];
}

-(void)play:(id)sender
{
    [self.delegate play];
}

-(void)pause:(id)sender
{
    [self.delegate pause];
}

-(void)enableScrubber
{
    self.scrubber.enabled = YES;
    self.playButton.enabled = YES;
    self.stopButton.enabled = YES;
}


-(void)disableScrubber
{
    self.scrubber.enabled = NO;
    self.playButton.enabled = NO;
    self.stopButton.enabled = NO;
}

-(void)showPlayingButtons
{
    self.playButton.hidden = YES;
    self.stopButton.hidden = NO;
}

-(void)showPausedButtons
{
    self.playButton.hidden = NO;
    self.stopButton.hidden = YES;   
}

-(void)setScrubberValue:(float)value
{
    // the value is from 0 to 1
    [self.scrubber setValue:value];
}

-(void)toggleSubtitleButton
{
    self.config.highlightSubtitleButton = !self.config.highlightSubtitleButton;
    
    self.subtitleButton.selected = self.config.highlightSubtitleButton;
    [self.delegate toggleSubtitle];
}

-(void)toggleFullscreen
{
    [self.delegate toggleFullscreen];
}

@end
