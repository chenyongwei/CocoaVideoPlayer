//
//  ViewController.m
//  CocoaVideoPlayerDemo
//
//  Created by Yongwei.Chen on 4/22/14.
//  Copyright (c) 2014 Kingway. All rights reserved.
//

#import "ViewController.h"
#import "CocoaVideoPlayerView.h"
#import "CocoaVideoModel.h"

@interface ViewController () <CocoaVideoPlayerDelegate>

@property (nonatomic, weak) IBOutlet CocoaVideoPlayerView *videoPlayerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CocoaVideoModel *testModel = [self getCocoaVideoModelFromJSON];
    [self setupVideoPlayerView:testModel];
}

-(void)setupVideoPlayerView:(CocoaVideoModel *)videoModel
{
        self.videoPlayerView.delegate = self;
        self.videoPlayerView.poster = [NSURL URLWithString:videoModel.imagePath];
    
        NSString *videoPath = [[NSBundle mainBundle] pathForResource:[videoModel.videoPath stringByReplacingOccurrencesOfString:@".mp4" withString:@""] ofType:@"mp4" inDirectory:@"content/"];
        self.videoPlayerView.url = [NSURL fileURLWithPath:videoPath];
        self.videoPlayerView.cueMarks = videoModel.cueMarks;
        self.videoPlayerView.subtitles = videoModel.scripts;
    
        // Always reset the old videoPlayerView
        [self.videoPlayerView stop];
}

-(CocoaVideoModel *)getCocoaVideoModelFromJSON
{
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"cocoa-video" ofType:@"json" inDirectory:@"content/"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    
    CocoaVideoModel *model = [MTLJSONAdapter modelOfClass:[CocoaVideoModel class] fromJSONDictionary:jsonDict error:nil];
    return model;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
