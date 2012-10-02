#import "EJBindingBase.h"
#import <GameKit/GameKit.h>

static NSString * kEJBindingGameCenterAutoAuth = @"EJBindingGameCenter.AutoAuth";

@interface EJBindingGameCenter : EJBindingBase <GKLeaderboardViewControllerDelegate,GKAchievementViewControllerDelegate> {
	BOOL authed;
	NSMutableDictionary * achievements;
}

- (void)loadAchievements;
- (void)reportAchievementWithIdentifier:(NSString *)identifier
	percentage:(float)percentage isIncrement:(BOOL)isIncrement
	ctx:(JSContextRef)ctx callback:(JSObjectRef)callback;

@end
