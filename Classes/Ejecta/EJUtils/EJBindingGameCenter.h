#import "EJBindingBase.h"
#import <GameKit/GameKit.h>

@interface EJBindingGameCenter : EJBindingBase <GKLeaderboardViewControllerDelegate,GKAchievementViewControllerDelegate> {
	BOOL authed;
}

@end
