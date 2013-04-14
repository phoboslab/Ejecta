#import "EJBindingGameCenter.h"
#import "EJJavaScriptView.h"

@implementation EJBindingGameCenter

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
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
				achievements[achievement.identifier] = achievement;
			}
		}
	}];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
	[viewController.presentingViewController dismissModalViewControllerAnimated:YES];
	viewIsActive = false;
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
	[viewController.presentingViewController dismissModalViewControllerAnimated:YES];
	viewIsActive = false;
}


EJ_BIND_FUNCTION( authenticate, ctx, argc, argv ) {
	JSObjectRef callback = NULL;
	if( argc > 0 && JSValueIsObject(ctx, argv[0]) ) {
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
		
		int autoAuth = authed
			? kEJGameCenterAutoAuthSucceeded
			: kEJGameCenterAutoAuthFailed;
		[[NSUserDefaults standardUserDefaults] setObject:@(autoAuth) forKey:kEJGameCenterAutoAuth];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		if( callback ) {
			JSContextRef gctx = scriptView.jsGlobalContext;
			JSValueRef params[] = { JSValueMakeBoolean(gctx, error) };
			[scriptView invokeCallback:callback thisObject:NULL argc:1 argv:params];
			JSValueUnprotectSafe(gctx, callback);
		}
	}];
	return NULL;
}

EJ_BIND_FUNCTION( softAuthenticate, ctx, argc, argv ) {
	// Check if the last auth was successful or never tried and if so, auto auth this time
	int autoAuth = [[[NSUserDefaults standardUserDefaults] objectForKey:kEJGameCenterAutoAuth] intValue];
	if(
		autoAuth == kEJGameCenterAutoAuthNeverTried ||
		autoAuth == kEJGameCenterAutoAuthSucceeded
	) {
		[self _func_authenticate:ctx argc:argc argv:argv];
	}
	else if( argc > 0 && JSValueIsObject(ctx, argv[0]) ) {
		NSLog(@"GameKit: Skipping soft auth.");
		
		JSObjectRef callback = JSValueToObject(ctx, argv[0], NULL);
		JSValueRef params[] = { JSValueMakeBoolean(ctx, true) };
		[scriptView invokeCallback:callback thisObject:NULL argc:1 argv:params];
	}
	return NULL;
}

EJ_BIND_FUNCTION( reportScore, ctx, argc, argv ) {
	if( argc < 2 ) { return NULL; }
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't report score."); return NULL; }
	
	NSString *category = JSValueToNSString(ctx, argv[0]);
	int64_t score = JSValueToNumberFast(ctx, argv[1]);
	
	JSObjectRef callback = NULL;
	if( argc > 2 && JSValueIsObject(ctx, argv[2]) ) {
		callback = JSValueToObject(ctx, argv[2], NULL);
		JSValueProtect(ctx, callback);
	}
	
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
	if( scoreReporter ) {
		scoreReporter.value = score;

		[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
			if( callback ) {
				JSContextRef gctx = scriptView.jsGlobalContext;
				JSValueRef params[] = { JSValueMakeBoolean(gctx, error) };
				[scriptView invokeCallback:callback thisObject:NULL argc:1 argv:params];
				JSValueUnprotectSafe(gctx, callback);
			}
		}];
	}
	
	return NULL;
}

EJ_BIND_FUNCTION( showLeaderboard, ctx, argc, argv ) {
	if( argc < 1 || viewIsActive ) { return NULL; }
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't show leaderboard."); return NULL; }
	
	GKLeaderboardViewController *leaderboard = [[[GKLeaderboardViewController alloc] init] autorelease];
	if( leaderboard ) {
		viewIsActive = true;
		leaderboard.leaderboardDelegate = self;
		leaderboard.category = JSValueToNSString(ctx, argv[0]);
		
		[scriptView.window.rootViewController presentModalViewController:leaderboard animated:YES];
	}
	
	return NULL;
}

- (void)reportAchievementWithIdentifier:(NSString *)identifier
	percentage:(float)percentage isIncrement:(BOOL)isIncrement
	ctx:(JSContextRef)ctx callback:(JSObjectRef)callback
{
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't report achievment."); return; }
	
	GKAchievement *achievement = achievements[identifier];
	if( achievement ) {		
		// Already reported with same or higher percentage or already at 100%?
		if(
			achievement.percentComplete == 100.0f ||
			(!isIncrement && achievement.percentComplete >= percentage)
		) {
			return;
		}
		
		if( isIncrement ) {
			percentage = MIN( achievement.percentComplete + percentage, 100.0f );
		}
	}
	else {
		achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
	}
	
	achievement.showsCompletionBanner = YES;
	achievement.percentComplete = percentage;
	
	if( callback ) {
		JSValueProtect(ctx, callback);
	}
	
	[achievement reportAchievementWithCompletionHandler:^(NSError *error) {
		achievements[identifier] = achievement;
		
		if( callback ) {
			JSContextRef gctx = scriptView.jsGlobalContext;
			JSValueRef params[] = { JSValueMakeBoolean(gctx, error) };
			[scriptView invokeCallback:callback thisObject:NULL argc:1 argv:params];
			JSValueUnprotectSafe(gctx, callback);
		}
	}];
}

EJ_BIND_FUNCTION( reportAchievement, ctx, argc, argv ) {
	if( argc < 2 ) { return NULL; }
	
	NSString *identifier = JSValueToNSString(ctx, argv[0]);
	float percent = JSValueToNumberFast(ctx, argv[1]);
	
	JSObjectRef callback = NULL;
	if( argc > 2 && JSValueIsObject(ctx, argv[2]) ) {
		callback = JSValueToObject(ctx, argv[2], NULL);
	}
	
	[self reportAchievementWithIdentifier:identifier percentage:percent isIncrement:NO ctx:ctx callback:callback];
	return NULL;
}

EJ_BIND_FUNCTION( reportAchievementAdd, ctx, argc, argv ) {
	if( argc < 2 ) { return NULL; }
	
	NSString *identifier = JSValueToNSString(ctx, argv[0]);
	float percent = JSValueToNumberFast(ctx, argv[1]);
	
	JSObjectRef callback = NULL;
	if( argc > 2 && JSValueIsObject(ctx, argv[2]) ) {
		callback = JSValueToObject(ctx, argv[2], NULL);
	}
	
	[self reportAchievementWithIdentifier:identifier percentage:percent isIncrement:YES ctx:ctx callback:callback];
	return NULL;
}

EJ_BIND_FUNCTION( showAchievements, ctx, argc, argv ) {
	if( viewIsActive ) { return NULL; }
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't show achievements."); return NULL; }
	
	GKAchievementViewController *achievementView = [[[GKAchievementViewController alloc] init] autorelease];
	if( achievementView ) {
		viewIsActive = true;
		achievementView.achievementDelegate = self;
		[scriptView.window.rootViewController presentModalViewController:achievementView animated:YES];
	}
	return NULL;
}

EJ_BIND_GET(authed, ctx) {
	return JSValueMakeBoolean(ctx, authed);
}

@end
