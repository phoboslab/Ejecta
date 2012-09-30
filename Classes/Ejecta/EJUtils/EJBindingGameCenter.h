#import "EJBindingBase.h"
#import <GameKit/GameKit.h>

static NSString * kEJBindingGameCenterAutoAuth = @"EJBindingGameCenter.AutoAuth";

@interface EJBindingGameCenter : EJBindingBase <GKLeaderboardViewControllerDelegate,GKAchievementViewControllerDelegate> {
	BOOL authed;
	NSMutableDictionary * achievements;
}

- (void)loadAchievements;

@end
