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
{

}

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *stopButton;

@property (nonatomic, strong) UIButton *subtitleButton;

@end

@implementation CocoaVideoPlayerControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self setup];
}

-(void)setup
{
    if (CGRectGetWidth(self.frame) == 0 || CGRectGetHeight(self.frame)) {
        return;
    }
    
    self.playButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(8, 30, 85, 30);
        FAKFontAwesome *playIcon = [FAKFontAwesome playCircleOIconWithSize:30];
        [playIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        UIImage *playIconImage = [playIcon imageWithSize:CGSizeMake(30, 30)];
        [btn setImage:playIconImage  forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self addSubview:self.playButton];
    
    self.stopButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(-8, 3, 85, 30);
        FAKFontAwesome *stopIcon = [FAKFontAwesome stopIconWithSize:50];
        [stopIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        UIImage *stopIconImage = [stopIcon imageWithSize:CGSizeMake(50, 50)];
        [self.stopButton setImage:stopIconImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self addSubview:self.stopButton];
    
    self.scrubber = ({
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(60, 3, self.viewConfig.scrubberSize.width, self.viewConfig.scrubberSize.height)];
        [slider addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchCancel];
        [slider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
        [slider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
        [slider addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
        [slider addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
        slider;
    });
    [self addSubview:self.scrubber];
    
    if (self.viewConfig.enableSubtitleButton) {
        self.subtitleButton = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(CGRectGetWidth(self.frame) - 65, 3, 85, 30);
            
            FAKFontAwesome *subTitleIcon = [FAKFontAwesome subscriptIconWithSize:20];
            [subTitleIcon addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor]];
            UIImage *subTitleOffImage = [subTitleIcon imageWithSize:CGSizeMake(20, 20)];
            [btn setImage:subTitleOffImage forState:UIControlStateNormal];
            
            [subTitleIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor]];
            UIImage *subTitleOnImage = [subTitleIcon imageWithSize:CGSizeMake(20, 20)];
            [btn setImage:subTitleOnImage forState:UIControlStateSelected];
            
            [btn addTarget:self action:@selector(toggleSubtitleButton) forControlEvents:UIControlEventTouchUpInside];
            btn.selected = self.viewConfig.highSubtitleButton;
            btn;
        });
        [self addSubview:self.subtitleButton];
    }
    
}




-(void)enableScrubber
{
    self.scrubber.enabled = YES;
}


-(void)disableScrubber
{
    self.scrubber.enabled = NO;
}


-(void)enablePlayerButtons
{
    self.playButton.enabled = YES;
    self.stopButton.enabled = YES;
}


-(void)disablePlayerButtons
{
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

-(void)resetScrubber
{
    [self.scrubber setValue:0.0];
}


-(void)toggleSubtitleButton
{
    self.viewConfig.highSubtitleButton = !self.viewConfig.highSubtitleButton;
    
    self.subtitleButton.selected = self.viewConfig.highSubtitleButton;
    [self.delegate toggleSubtitle];
}


@end
