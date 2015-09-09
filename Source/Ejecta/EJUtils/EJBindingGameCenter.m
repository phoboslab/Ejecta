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
			for( GKAchievement *achievement in loadedAchievements ) {
				achievements[achievement.identifier] = achievement;
			}
		}
	}];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)viewController {
	[viewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	viewIsActive = false;
}

// authenticate( callback(error){} )
EJ_BIND_FUNCTION( authenticate, ctx, argc, argv ) {
	__block JSObjectRef callback = NULL;
	if( argc > 0 && JSValueIsObject(ctx, argv[0]) ) {
		callback = JSValueToObject(ctx, argv[0], NULL);
		JSValueProtect(ctx, callback);
	}
	
	GKLocalPlayer.localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
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
			
			// Make sure this callback is only called once
			callback = NULL;
		}
	};
	return NULL;
}

// softAuthenticate( callback(error){} )
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


// reportScore( category, score, [contextNum], cb )
EJ_BIND_FUNCTION( reportScore, ctx, argc, argv ) {
	if (argc < 2) {
		return NULL;
	}
	if (!authed) {
		NSLog(@"GameKit Error: Not authed. Can't report score."); return NULL;
	}
	NSString *category = JSValueToNSString(ctx, argv[0]);
	int64_t score = JSValueToNumberFast(ctx, argv[1]);
	uint64_t contextNum = 0;
	JSObjectRef callback = NULL;
	if (argc > 3) {
		contextNum = JSValueToNumberFast(ctx, argv[2]);
		if (JSValueIsObject(ctx, argv[3])) {
			callback = JSValueToObject(ctx, argv[2], NULL);
		}
	}
	else if (argc == 3) {
		if (JSValueIsObject(ctx, argv[2])) {
			callback = JSValueToObject(ctx, argv[2], NULL);
		}
		else {
			contextNum = JSValueToNumberFast(ctx, argv[2]);
		}
	}
	if (callback) {
		JSValueProtect(ctx, callback);
	}
	
	GKScore *s = [[[GKScore alloc] initWithLeaderboardIdentifier:category] autorelease];
	s.value = score;
	s.context = contextNum;
	[GKScore reportScores:@[s] withCompletionHandler:^(NSError *error) {
		if( callback ) {
			JSContextRef gctx = scriptView.jsGlobalContext;
			JSValueRef params[] = { JSValueMakeBoolean(gctx, error) };
			[scriptView invokeCallback:callback thisObject:NULL argc:1 argv:params];
			JSValueUnprotectSafe(gctx, callback);
		}
	}];
	
	return NULL;
}

// showLeaderboard( category )
EJ_BIND_FUNCTION( showLeaderboard, ctx, argc, argv ) {
	if( argc < 1 || viewIsActive ) { return NULL; }
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't show leaderboard."); return NULL; }
	
	GKGameCenterViewController* vc = [[GKGameCenterViewController alloc] init];
    vc.viewState = GKGameCenterViewControllerStateLeaderboards;
	vc.leaderboardIdentifier = JSValueToNSString(ctx, argv[0]);
    vc.gameCenterDelegate = self;
    [scriptView.window.rootViewController presentViewController:vc animated:YES completion:nil];
	viewIsActive = true;
	
	return NULL;
}

- (void)reportAchievementWithIdentifier:(NSString *)identifier
                             percentage:(float)percentage isIncrement:(BOOL)isIncrement
                                    ctx:(JSContextRef)ctx callback:(JSObjectRef)callback {
	if (!authed) {
		NSLog(@"GameKit Error: Not authed. Can't report achievment."); return;
	}

	GKAchievement *achievement = achievements[identifier];
	if (achievement) {
		// Already reported with same or higher percentage or already at 100%?
		if (
		    achievement.completed || achievement.percentComplete == 100.0f ||
		    (!isIncrement && achievement.percentComplete >= percentage)
		    ) {
			return;
		}

		if (isIncrement) {
			percentage = MIN(achievement.percentComplete + percentage, 100.0f);
		}
	}
	else {
		achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
	}

	achievement.showsCompletionBanner = YES;
	achievement.percentComplete = percentage;

	if (callback) {
		JSValueProtect(ctx, callback);
	}
	
	[GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
		achievements[identifier] = achievement;
		
		if( callback ) {
			JSContextRef gctx = scriptView.jsGlobalContext;
			JSValueRef params[] = { JSValueMakeBoolean(gctx, error) };
			[scriptView invokeCallback:callback thisObject:NULL argc:1 argv:params];
			JSValueUnprotectSafe(gctx, callback);
		}
	}];
}

// reportAchievement( identifier, percentage )
EJ_BIND_FUNCTION(reportAchievement, ctx, argc, argv)
{
	if (argc < 2) {
		return NULL;
	}

	NSString *identifier = JSValueToNSString(ctx, argv[0]);
	float percent = JSValueToNumberFast(ctx, argv[1]);
	
	JSObjectRef callback = NULL;
	if( argc > 2 && JSValueIsObject(ctx, argv[2]) ) {
		callback = JSValueToObject(ctx, argv[2], NULL);
	}
	
	[self reportAchievementWithIdentifier:identifier percentage:percent isIncrement:NO ctx:ctx callback:callback];
	return NULL;
}

// reportAchievementAdd( identifier, percentage )
EJ_BIND_FUNCTION(reportAchievementAdd, ctx, argc, argv)
{
	if (argc < 2) {
		return NULL;
	}

	NSString *identifier = JSValueToNSString(ctx, argv[0]);
	float percent = JSValueToNumberFast(ctx, argv[1]);
	
	JSObjectRef callback = NULL;
	if( argc > 2 && JSValueIsObject(ctx, argv[2]) ) {
		callback = JSValueToObject(ctx, argv[2], NULL);
	}
	
	[self reportAchievementWithIdentifier:identifier percentage:percent isIncrement:YES ctx:ctx callback:callback];
	return NULL;
}

// showAchievements()
EJ_BIND_FUNCTION( showAchievements, ctx, argc, argv ) {
	if( viewIsActive ) { return NULL; }
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't show achievements."); return NULL; }
	
	GKGameCenterViewController* vc = [[GKGameCenterViewController alloc] init];
    vc.viewState = GKGameCenterViewControllerStateAchievements;
    vc.gameCenterDelegate = self;
    [scriptView.window.rootViewController presentViewController:vc animated:YES completion:nil];
	viewIsActive = true;
	
	return NULL;
}

EJ_BIND_GET(authed, ctx)
{
	return JSValueMakeBoolean(ctx, authed);
}



#define InvokeAndUnprotectCallback(callback, error, object) \
	[scriptView invokeCallback:callback thisObject:NULL argc:2 argv: \
		(JSValueRef[]){ \
			JSValueMakeBoolean(scriptView.jsGlobalContext, error), \
			(object ? NSObjectToJSValue(scriptView.jsGlobalContext, object) : scriptView->jsUndefined) \
		} \
	]; \
	JSValueUnprotect(scriptView.jsGlobalContext, callback);

#define ExitWithCallbackOnError(callback, error) \
	if( error ) { \
		InvokeAndUnprotectCallback(callback, error, NULL); \
		return; \
	}

#define GKPlayerToNSDict(player) @{ \
		@"alias": player.alias, \
		@"displayName": player.displayName, \
		@"playerID": player.playerID \
	}

// loadFriends( callback(error, players[]){} )
EJ_BIND_FUNCTION( loadFriends, ctx, argc, argv ) {
	if( argc < 1 || !JSValueIsObject(ctx, argv[0]) ) { return NULL; }
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't load Friends."); return NULL; }

	JSObjectRef callback = (JSObjectRef)argv[0];
	JSValueProtect(ctx, callback);

	GKLocalPlayer *player = [GKLocalPlayer localPlayer];
	[player loadFriendPlayersWithCompletionHandler:^(NSArray *friendIds, NSError *error) {
		ExitWithCallbackOnError(callback, error);
		
		[GKPlayer loadPlayersForIdentifiers:friendIds withCompletionHandler:^(NSArray *players, NSError *error) {
			ExitWithCallbackOnError(callback, error);
			
			// Transform GKPlayers Array to Array of NSDictionary so InvokeAndUnprotectCallback
			// is happy to convert it to JSON
			NSMutableArray *playersArray = [NSMutableArray arrayWithCapacity:players.count];
			for( GKPlayer *player in players ) {
				[playersArray addObject: GKPlayerToNSDict(player)];
			}
			InvokeAndUnprotectCallback(callback, error, playersArray);
		}];
	}];

	return NULL;
}


// loadPlayers( playerIds[], callback(error, players[]){} )
EJ_BIND_FUNCTION( loadPlayers, ctx, argc, argv ) {
	if( argc < 2 || !JSValueIsObject(ctx, argv[1]) ) { return NULL; }
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't load Players."); return NULL; }

	NSArray *players = (NSArray *)JSValueToNSObject(ctx, argv[0]);
	if( !players || ![players isKindOfClass:NSArray.class] ) {
		return NULL;
	}
	
	JSObjectRef callback = (JSObjectRef)argv[0];
	JSValueProtect(ctx, callback);

	[GKPlayer loadPlayersForIdentifiers:players withCompletionHandler:^(NSArray *players, NSError *error) {
		ExitWithCallbackOnError(callback, error);
		
		// Transform GKPlayers Array to Array of NSDictionary so InvokeAndUnprotectCallback
		// is happy to convert it to JSON
		NSMutableArray *playersArray = [NSMutableArray arrayWithCapacity:players.count];
		for( GKPlayer *player in players ) {
			[playersArray addObject: GKPlayerToNSDict(player)];
		}
		InvokeAndUnprotectCallback(callback, error, playersArray);
	}];
	return NULL;
}


// loadScores( category, rangeStart, rangeEnd, callback(error, scores[]){} )
EJ_BIND_FUNCTION( loadScores, ctx, argc, argv ) {
	if( argc < 4 || !JSValueIsObject(ctx, argv[3]) ) { return NULL; }
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't load Scores."); return NULL; }
	
	NSString *category = JSValueToNSString(ctx, argv[0]);
	int start = JSValueToNumberFast(ctx, argv[1]);
	int end = JSValueToNumberFast(ctx, argv[2]);
	JSObjectRef callback = (JSObjectRef)argv[3];
	JSValueProtect(ctx, callback);
		
	GKLeaderboard *request = [[GKLeaderboard alloc] init];
	request.playerScope = GKLeaderboardPlayerScopeGlobal;
	request.timeScope = GKLeaderboardTimeScopeAllTime;
	request.identifier = category;
	request.range = NSMakeRange(start, end);
	
	[request loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
		ExitWithCallbackOnError(callback, error);
		
	    NSArray *playerIds = [scores valueForKey:@"playerID"];
	    [GKPlayer loadPlayersForIdentifiers:playerIds withCompletionHandler: ^(NSArray *players, NSError *error) {
	            ExitWithCallbackOnError(callback, error);

	            // Create a Dict to map playerID -> player
	            NSDictionary *playersDict = [NSDictionary dictionaryWithObjects:players
	                                                                    forKeys:[players valueForKey:@"playerID"]];

	            // Build an Array of NSDictionaries for the scores and attach the loaded player
	            // info.
	            NSMutableArray *scoresArray = [NSMutableArray arrayWithCapacity:players.count];
	            for (GKScore * score in scores) {
	                GKPlayer *playerForScore = playersDict[score.player.playerID];
	                [scoresArray addObject:@{
//	                     @"category": score.category,
						 @"leaderboardIdentifier": score.leaderboardIdentifier,
	                     @"player": GKPlayerToNSDict(playerForScore),
	                     @"date": score.date,
	                     @"formattedValue": score.formattedValue,
	                     @"value": @(score.value),
	                     @"rank": @(score.rank)
					 }];
				}

	            InvokeAndUnprotectCallback(callback, error, scoresArray);
			}];
	}];
	return NULL;
}

// getLocalPlayerInfo()
EJ_BIND_FUNCTION( getLocalPlayerInfo, ctx, argc, argv ) {
	if( !authed ) { NSLog(@"GameKit Error: Not authed. Can't get Player info."); return NULL; }
	
	GKLocalPlayer * player = [GKLocalPlayer localPlayer];
	return NSObjectToJSValue(ctx, GKPlayerToNSDict(player));
}


// showGameCenter()
EJ_BIND_FUNCTION(showGameCenter, ctx, argc, argv)
{
	if (viewIsActive) {
		return NULL;
	}
	if (!authed) {
		NSLog(@"GameKit Error: Not authed. Can't show GameCenter."); return NULL;
	}

	GKGameCenterViewController *gameCenterController = [[[GKGameCenterViewController alloc] init] autorelease];
	if (gameCenterController) {
		viewIsActive = true;
		gameCenterController.gameCenterDelegate = self;
		gameCenterController.viewState = GKGameCenterViewControllerStateDefault;
		[scriptView.window.rootViewController presentViewController:gameCenterController animated:YES completion:nil];
	}

	return NULL;
}


// get friends base info
EJ_BIND_FUNCTION(retrieveFriends, ctx, argc, argv)
{
	JSObjectRef callback = JSValueToObject(ctx, argv[0], NULL);
	if (callback) {
		JSValueProtect(ctx, callback);
	}

	if (authed) {
		GKLocalPlayer *player = [GKLocalPlayer localPlayer];
		[player loadFriendPlayersWithCompletionHandler: ^(NSArray *friends, NSError *error) {
		    [self loadPlayers:friends callback:callback];
		}];
	}
	else {
		JSValueRef params[] = { NULL, NULL };
		[scriptView invokeCallback:callback thisObject:NULL argc:2 argv:params];
		JSValueUnprotectSafe(ctx, callback);
	}
	return NULL;
}

// get players base info
//      args: playerIdentifiers (array)
EJ_BIND_FUNCTION(retrievePlayers, ctx, argc, argv)
{
	JSObjectRef jsIdentifiers = JSValueToObject(ctx, argv[0], NULL);
	int length = JSValueToNumber(ctx, JSObjectGetProperty(ctx, jsIdentifiers, JSStringCreateWithUTF8CString("length"), NULL), NULL);
	NSMutableArray *identifiers = [[NSMutableArray alloc] init];
	for (int i = 0; i < length; i++) {
		[identifiers addObject:JSValueToNSString(ctx, JSObjectGetPropertyAtIndex(ctx, jsIdentifiers, i, NULL))];
	}

	JSObjectRef callback = JSValueToObject(ctx, argv[1], NULL);
	if (callback) {
		JSValueProtect(ctx, callback);
	}

	[self loadPlayers:identifiers callback:callback];

	return NULL;
}

// get scores in range
//      args: category, options(timeScope,friendsOnly,withLocalPlayer,localPlayerOnly, start,end), callback
EJ_BIND_FUNCTION(retrieveScores, ctx, argc, argv)
{
	GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
	if (leaderboardRequest != nil) {
		NSString *category = JSValueToNSString(ctx, argv[0]);
		JSObjectRef jsOptions = JSValueToObject(ctx, argv[1], NULL);
		JSObjectRef callback = JSValueToObject(ctx, argv[2], NULL);
		if (callback) {
			JSValueProtect(ctx, callback);
		}

		NSDictionary *options = (NSDictionary *)JSValueToNSObject(ctx, jsOptions);
		NSInteger start = [options[@"start"] integerValue];
		NSInteger end = [options[@"end"] integerValue];
		NSInteger timeScope = [options[@"timeScope"] integerValue];
		BOOL friendsOnly = [options[@"friendsOnly"] boolValue];
		BOOL localPlayerOnly = [options[@"localPlayerOnly"] boolValue];
		BOOL withLocalPlayer = [options[@"withLocalPlayer"] boolValue];

		if (localPlayerOnly) {
			friendsOnly = false;
			start = 1;
			end = 1;
		}
		else {
			if (!start) {
				start = 1;
			}
			if (!end) {
				end = start + 100 - 1;
			}
		}

		switch (timeScope) {
			case 0:
				leaderboardRequest.timeScope = GKLeaderboardTimeScopeToday;
				break;

			case 1:
				leaderboardRequest.timeScope = GKLeaderboardTimeScopeWeek;
				break;

			case 2:
				leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
				break;
		}

		if (friendsOnly) {
			leaderboardRequest.playerScope = GKLeaderboardPlayerScopeFriendsOnly;
		}
		else {
			leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
		}

//		leaderboardRequest.category = category;
		leaderboardRequest.identifier = category;
		leaderboardRequest.range = NSMakeRange(start, end);

		[leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
		    NSMutableArray *identifiers = [[NSMutableArray alloc] init];
		    NSMutableArray *scoreList = [[NSMutableArray alloc] init];
		    if (scores != NULL && !localPlayerOnly) {
		        for (GKScore * obj in leaderboardRequest.scores) {
		            [identifiers addObject:obj.player.playerID];
		            [scoreList addObject:obj];
				}
			}
		    if (localPlayerOnly || withLocalPlayer) {
		        // Notice: Append the localPlayer's score-info to the array.
		        //         So the array.length == (end-start+1)+1
		        GKScore *localPlayer = leaderboardRequest.localPlayerScore;
		        if (localPlayer) {
		            [identifiers addObject:localPlayer.player.playerID];
		            [scoreList addObject:localPlayer];
				}
			}

		    [self loadPlayersAndScores:identifiers scores:scoreList callback:callback];
		}];
	}
	return NULL;
}

- (void)loadPlayersAndScores:(NSArray *)identifiers scores:(NSArray *)scores callback:(JSObjectRef)callback {
	[GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler: ^(NSArray *players, NSError *error)
	{
	    JSObjectRef jsScores = NULL;
	    JSContextRef gctx = scriptView.jsGlobalContext;
	    if (players != nil) {
	        NSUInteger size = players.count;
	        JSValueRef *jsArrayItems = malloc(sizeof(JSValueRef) * size);
	        int count = 0;
	        for (GKPlayer * player in players) {
	            GKScore *score = [scores objectAtIndex:count];
	            jsArrayItems[count++] = NSObjectToJSValue(gctx,
	                                                      @{
	                                                          @"alias": player.alias,
	                                                          @"displayName": player.displayName,
	                                                          @"playerID": player.playerID,
//	                                                          @"category": score.category,
															  @"leaderboardIdentifier": score.leaderboardIdentifier,
	                                                          @"date": score.date,
	                                                          @"formattedValue": score.formattedValue,
	                                                          @"value": @(score.value),
	                                                          @"rank": @(score.rank)
														  });
			}
	        jsScores = JSObjectMakeArray(gctx, count, jsArrayItems, NULL);
		}
	    JSValueRef params[] = { jsScores, JSValueMakeBoolean(gctx, error) };
	    [scriptView invokeCallback:callback thisObject:NULL argc:2 argv:params];
	    JSValueUnprotectSafe(gctx, callback);
	}];
}

- (void)loadPlayers:(NSArray *)identifiers callback:(JSObjectRef)callback {
	[GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler: ^(NSArray *players, NSError *error)
	{
	    JSObjectRef jsPlayers = NULL;
	    JSContextRef gctx = scriptView.jsGlobalContext;
	    if (players != nil) {
	        NSUInteger size = players.count;
	        JSValueRef *jsArrayItems = malloc(sizeof(JSValueRef) * size);
	        int count = 0;
	        for (GKPlayer * player in players) {
	            jsArrayItems[count++] = NSObjectToJSValue(gctx, GKPlayerToNSDict(player));
			}
	        jsPlayers = JSObjectMakeArray(gctx, count, jsArrayItems, NULL);
		}
	    JSValueRef params[] = { jsPlayers, JSValueMakeBoolean(gctx, error) };
	    [scriptView invokeCallback:callback thisObject:NULL argc:2 argv:params];
	    JSValueUnprotectSafe(gctx, callback);
	}];
}

#undef InvokeAndUnprotectCallback
#undef ExitWithCallbackOnError
#undef GKPlayerToNSDict

@end
