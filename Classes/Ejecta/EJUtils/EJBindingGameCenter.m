#import "EJBindingGameCenter.h"

@implementation EJBindingGameCenter

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
	[[EJApp instance] dismissModalViewControllerAnimated:YES];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
	[[EJApp instance] dismissModalViewControllerAnimated:YES];
}


EJ_BIND_FUNCTION( authenticate, ctx, argc, argv ) {
	JSObjectRef callback = NULL;
	if( argc > 0 ) {
		callback = JSValueToObject(ctx, argv[0], NULL);
		JSValueProtect(ctx, callback);
	}
	
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
		authed = true;
		if( callback ) {
			JSContextRef gctx = [EJApp instance].jsGlobalContext;
			JSValueRef params[] = { JSValueMakeBoolean(gctx, error) };
			[[EJApp instance] invokeCallback:callback thisObject:NULL argc:1 argv:params];
			JSValueUnprotect(gctx, callback);
		}
	}];
	return NULL;
}

EJ_BIND_FUNCTION( reportScore, ctx, argc, argv ) {
	if( argc < 2 ) { return NULL; }
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't report score."); return NULL; }
	
	NSString *category = JSValueToNSString(ctx, argv[0]);
	int64_t score = JSValueToNumberFast(ctx, argv[1]);
	
	JSObjectRef callback = NULL;
	if( argc > 2 ) {
		callback = JSValueToObject(ctx, argv[2], NULL);
		JSValueProtect(ctx, callback);
	}
	
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
	if( scoreReporter ) {
		scoreReporter.value = score;

		[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
			if( callback ) {
				JSContextRef gctx = [EJApp instance].jsGlobalContext;
				JSValueRef params[] = { JSValueMakeBoolean(gctx, error) };
				[[EJApp instance] invokeCallback:callback thisObject:NULL argc:1 argv:params];
				JSValueUnprotect(gctx, callback);
			}
		}];
	}
	
	return NULL;
}

EJ_BIND_FUNCTION( showLeaderboard, ctx, argc, argv ) {
	if( argc < 1 ) { return NULL; }
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't show leaderboard."); return NULL; }
	
    GKLeaderboardViewController * leaderboard = [[[GKLeaderboardViewController alloc] init] autorelease];
    if( leaderboard ) {
        leaderboard.leaderboardDelegate = self;
		leaderboard.category = JSValueToNSString(ctx, argv[0]);
		[[EJApp instance] presentModalViewController:leaderboard animated:YES];
    }
	
	return NULL;
}

EJ_BIND_FUNCTION( reportAchievement, ctx, argc, argv ) {
	if( argc < 2 ) { return NULL; }
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't report achievment."); return NULL; }
	
	NSString *identifier = JSValueToNSString(ctx, argv[0]);
	float percent = JSValueToNumberFast(ctx, argv[1]);
	
	JSObjectRef callback = NULL;
	if( argc > 2 ) {
		callback = JSValueToObject(ctx, argv[2], NULL);
		JSValueProtect(ctx, callback);
	}
	
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
    if( achievement ) {
		achievement.showsCompletionBanner = YES;
		achievement.percentComplete = percent;
		
		[achievement reportAchievementWithCompletionHandler:^(NSError *error) {
			if( callback ) {
				JSContextRef gctx = [EJApp instance].jsGlobalContext;
				JSValueRef params[] = { JSValueMakeBoolean(gctx, error) };
				[[EJApp instance] invokeCallback:callback thisObject:NULL argc:1 argv:params];
				JSValueUnprotect(gctx, callback);
			}
		}];
    }
	return NULL;
}

EJ_BIND_FUNCTION( showAchievements, ctx, argc, argv ) {
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't show achievements."); return NULL; }
	
	GKAchievementViewController *achievements = [[[GKAchievementViewController alloc] init] autorelease];
    if( achievements ) {
		achievements.achievementDelegate = self;
		[[EJApp instance] presentModalViewController:achievements animated:YES];
    }
	return NULL;
}

EJ_BIND_GET(authed, ctx) {
	return JSValueMakeBoolean(ctx, authed);
}

@end
