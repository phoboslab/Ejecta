#import "EJBindingEventedBase.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVkit.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAsset.h>

@interface EJBindingVideo : EJBindingEventedBase <UIGestureRecognizerDelegate> {
	NSString *path;
	BOOL loaded;
	BOOL ended;
	BOOL loop;
	AVPlayerViewController *controller;
}

@end
