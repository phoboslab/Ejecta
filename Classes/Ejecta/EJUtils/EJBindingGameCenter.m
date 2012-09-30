#import "EJBindingGameCenter.h"

@implementation EJBindingGameCenter

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		achievements = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[achievements release];
	[super dealloc];
}

- (void)loadAchievements {
	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *loadedAchievements, NSError *error) {
		if( !error ) {
			for (GKAchievement* achievement in loadedAchievements) {
				[achievements setObject:achievement forKey:achievement.identifier];
			}
		}
	}];
}

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
		authed = !error;

		if( authed ) {
			NSLog(@"GameKit: Authed.");
			[self loadAchievements];
		}
		else {
			NSLog(@"GameKit: Auth failed: %@", error );
		}
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:authed] forKey:kEJBindingGameCenterAutoAuth];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		if( callback ) {
			JSContextRef gctx = [EJApp instance].jsGlobalContext;
			JSValueRef params[] = { JSValueMakeBoolean(gctx, error) };
			[[EJApp instance] invokeCallback:callback thisObject:NULL argc:1 argv:params];
			JSValueUnprotect(gctx, callback);
		}
	}];
	return NULL;
}

EJ_BIND_FUNCTION( softAuthenticate, ctx, argc, argv ) {
	// Check if the last auth was successful and if so, auto auth this time
	NSNumber * autoAuth = [[NSUserDefaults standardUserDefaults] objectForKey:kEJBindingGameCenterAutoAuth];
	if( autoAuth && [autoAuth boolValue] ) {
		[self _func_authenticate:ctx argc:argc argv:argv];
	}
	else if( argc > 0 ) {
		NSLog(@"GameKit: Skipping soft auth.");
	}
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
	
	// Already reported with same percentage? Early out.
	GKAchievement * oldAchievement = [achievements objectForKey:identifier];
	if( oldAchievement && oldAchievement.percentComplete == percent ) {
		return NULL;
	}
	
	
	JSObjectRef callback = NULL;
	if( argc > 2 ) {
		callback = JSValueToObject(ctx, argv[2], NULL);
		JSValueProtect(ctx, callback);
	}
	
	GKAchievement * achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
	
	achievement.showsCompletionBanner = YES;
	achievement.percentComplete = percent;
	
	[achievement reportAchievementWithCompletionHandler:^(NSError *error) {
		[achievements setObject:achievement forKey:identifier];
		
		if( callback ) {
			JSContextRef gctx = [EJApp instance].jsGlobalContext;
			JSValueRef params[] = { JSValueMakeBoolean(gctx, error) };
			[[EJApp instance] invokeCallback:callback thisObject:NULL argc:1 argv:params];
			JSValueUnprotect(gctx, callback);
		}
	}];
	
	return NULL;
}

EJ_BIND_FUNCTION( showAchievements, ctx, argc, argv ) {
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't show achievements."); return NULL; }
	
	GKAchievementViewController *achievementView = [[[GKAchievementViewController alloc] init] autorelease];
    if( achievementView ) {
		achievementView.achievementDelegate = self;
		[[EJApp instance] presentModalViewController:achievementView animated:YES];
    }
	return NULL;
}

EJ_BIND_GET(authed, ctx) {
	return JSValueMakeBoolean(ctx, authed);
}

@end
