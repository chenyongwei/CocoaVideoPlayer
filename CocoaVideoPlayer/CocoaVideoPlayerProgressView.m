//
//  CocoaVideoPlayerProgressView.m
//  CocoaVideoPlayer
//
//  Created by Yongwei.Chen on 4/28/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import "CocoaVideoPlayerProgressView.h"

@implementation CocoaVideoPlayerProgressView

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
    

}

@end
