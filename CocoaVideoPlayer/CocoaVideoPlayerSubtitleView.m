//
//  CocoaVideoPlayerSubtitleView.m
//  CocoaVideoPlayer
//
//  Created by Yongwei on 4/29/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import "CocoaVideoPlayerSubtitleView.h"

@interface CocoaVideoPlayerSubtitleView()

@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation CocoaVideoPlayerSubtitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.5;

    self.subtitleLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"";
        label;
    });
    [self addSubview:self.subtitleLabel];
}


-(void)setSubtitle:(NSString *)subtitle
{
    if (_subtitle == subtitle) {
        return;
    }
    _subtitle = subtitle;
    NSLog(@"subtitle was set to: %@", subtitle);
    self.subtitleLabel.text = subtitle;
    [self.subtitleLabel sizeToFit];
    
    self.frame = CGRectMake(0, CGRectGetHeight(self.frame) + self.frame.origin.y - CGRectGetHeight(self.subtitleLabel.frame) , CGRectGetWidth(self.frame), CGRectGetHeight(self.subtitleLabel.frame));
}


@end
