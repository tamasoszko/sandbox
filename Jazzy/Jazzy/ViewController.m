//
//  ViewController.m
//  Jazzy
//
//  Created by Oszkó Tamás on 02/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

#import "ViewController.h"
#import "Jazzy-Swift.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+Animating.h"

static void * AVPlayerContext = &AVPlayerContext;

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *playItemLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end


@implementation ViewController
{
@private
    AVPlayer* _player;

    PlayListImageProvider* _playListInfoProvider;
    PlayListUpdater* _playListUpdater;
    NSDateFormatter* _dateFormatter;
    PlayListItem* _currItem;
    UIImage* _logo;
    LabelAnimator * _playItemLabelAnimator;
    LabelAnimator * _statusLabelAnimator;
    NSInteger _initSubViewsCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _player = [AVPlayer playerWithURL:[NSURL URLWithString:@"http://online.jazzy.hu/jazzy.mp3.m3u"]];
    [_player addObserver:self forKeyPath:@"status" options:0 context:&AVPlayerContext];
    
    _playListUpdater = [[PlayListUpdater alloc] initWithUrl:[NSURL URLWithString:@"http://www.jazzy.hu/playlist.php"]];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"HH:mm"];
    
    _logo = [UIImage imageNamed:@"jazzylogo"];
    
    self.playItemLabel.textColor = [UIColor blackColor];
    self.tableView.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayListItemChanged:) name:@"PlayListItemChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onViewAnimationEnded:) name:UIViewAnimationEnded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayListItemInfoChanged:) name:[PlayListImageProvider ItemsChanged] object:nil];
    _playItemLabelAnimator = [[LabelAnimator alloc] initWithLabel:self.playItemLabel];
    _playItemLabelAnimator.blinkOnTextChange = YES;
    
    _statusLabelAnimator = [[LabelAnimator alloc] initWithLabel:self.statusLabel];
    _statusLabelAnimator.blinkOnTextChange = YES;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) onPlayListItemChanged:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_playListUpdater.currentPlayListItem) {
            _playListInfoProvider = [[PlayListImageProvider alloc] initWithItem:_playListUpdater.currentPlayListItem];
            [_playListInfoProvider searchForImages];
        }
        [self updateUI];
    });
}

-(void) onViewAnimationEnded:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animateLogo];
    });
}

-(void) onPlayListItemInfoChanged:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUI];
    });
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateUI];
    _initSubViewsCount = self.view.subviews.count;
}

-(void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    for(UIPress* press in presses) {
        if(press.type == UIPressTypePlayPause) {
            NSLog(@"playpause pressed");
            [self handlePlayPausePresses];
            break;
        }
    }
}

-(BOOL)isPlaying {
    if(_player.rate > 0 && _player.error == nil) {
        return YES;
    }
    return NO;
}

-(void)handlePlayPausePresses {
    if([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
    [self updateUI];
}

-(void) play {
    [_player play];
    [_playListUpdater startUpdate];
    [self updateUI];
}

-(void) pause {
    [_player pause];
    [_playListUpdater stopUpdate];
    [self updateUI];
}


-(void)updateStatusLabel {
    if(_player.status == AVPlayerStatusUnknown) {
        self.statusLabel.text = @"Initializing...";
        self.statusLabel.textColor = [UIColor blackColor];
    } else if(_player.status == AVPlayerStatusReadyToPlay){
        if([self isPlaying]) {
            self.statusLabel.text = [NSString stringWithFormat:@"Playing"];
            
        } else {
            self.statusLabel.text = @"Paused";
        }
        self.statusLabel.textColor = [UIColor grayColor];
    } else {
        self.statusLabel.text = [NSString stringWithFormat:@"Error: %@", _player.error];
        self.statusLabel.textColor = [UIColor redColor];
    }
}

-(void) updateUI {
    PlayListItem* item = _playListUpdater.currentPlayListItem;
    if(item == nil) {
        self.playItemLabel.text = @"<Jazzy>";
    } else {
        self.playItemLabel.text = [self formatPlaylistItem];
    }
    [self animateLogo];
    [self updateStatusLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if(context == AVPlayerContext) {
        if([keyPath isEqualToString:@"status"]) {
            [self updateUI];
            if(_player.status == AVPlayerStatusReadyToPlay) {
                [self play];
            } else {
                NSLog(@"Error: %@", _player.error);
            }
        }
    }
}


-(void)animateLogo {
    
    if(self.view.subviews.count >= _initSubViewsCount + 2) {
        return;
    }
    NSArray<UIImage*>* images = _playListInfoProvider.items;
    int r = arc4random_uniform(2);
    UIView* view;
    CGFloat fromAlpha;
    CGFloat toAlpha;
    fromAlpha = 0.9f;
    toAlpha = 0.1f;
    NSTimeInterval duration = 45;
    if(images.count > 0) {
        if(r == 0) {
            r = arc4random_uniform(2);
            if(r == 0) {
                UIImageView* imgView = [[UIImageView alloc] initWithImage:_logo];
                view = imgView;
                duration = 60;
            } else {
                UILabel* label = [[UILabel alloc] init];
                label.text = [self formatPlaylistItem];
                label.font = [UIFont fontWithName:@"Helvetica" size:48];
                [label sizeToFit];
                view = label;
                fromAlpha = 1.0f;
                toAlpha = 0.75f;
            }
        } else {
            int imgIndex = arc4random_uniform(images.count);
            UIImageView* imgView = [[UIImageView alloc] initWithImage:images[imgIndex]];
            view = imgView;
            duration = 30;
        }
    } else {
        if(r == 0) {
            UIImageView* imgView = [[UIImageView alloc] initWithImage:_logo];
            view = imgView;
            duration = 60;
        } else {
            UILabel* label = [[UILabel alloc] init];
            label.text = [self formatPlaylistItem];
            label.font = [UIFont fontWithName:@"Helvetica" size:48];
            [label sizeToFit];
            view = label;
            fromAlpha = 1.0f;
            toAlpha = 0.75f;
            duration = 15;
        }
    }
    [self.view insertSubview:view belowSubview:self.playItemLabel];
    CGRect fromRect = [self randomPosition:[self randomScaleUp:view.frame minScale:100 maxScale:200]];
    CGRect toRect = [self randomPosition:[self randomScaleUp:fromRect minScale:200 maxScale:300]];
    [view startFadeAnimationFromRect:fromRect toRect:toRect fromAlpha:fromAlpha toAlpha:toAlpha duration:duration];
}

-(CGRect)randomScaleUp:(CGRect)rect minScale:(NSInteger)minScale maxScale:(NSInteger)maxScale {
    
    int scale = arc4random_uniform(maxScale - minScale) + minScale;
    int dx = rect.size.width * scale / 100 - rect.size.width;
    int dy = rect.size.height * scale / 100 - rect.size.height;
    
    rect.size.width += rect.size.width;
    rect.size.height += rect.size.height;
    rect.origin.x -= dx / 2;
    rect.origin.y -= dy / 2;
    return rect;
}

-(CGRect)randomPosition:(CGRect)rect {
    int dx = arc4random_uniform(MAX(0,self.view.frame.size.width - rect.size.width));
    int dy = arc4random_uniform(MAX(0, self.view.frame.size.height - rect.size.height));
    rect.origin.x += dx;
    rect.origin.y += dy;
    return rect;
}

-(NSString*) formatPlaylistItem {
    PlayListItem* item = _playListUpdater.currentPlayListItem;
    if(!item) {
        return @"";
    }
    NSString* txt = [NSString stringWithFormat:@"%@ %@ - %@", [_dateFormatter stringFromDate:item.date],
                     item.artist, item.title];
    return txt;
}



@end
