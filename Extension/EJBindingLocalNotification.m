#import "EJBindingLocalNotification.h"

@implementation EJBindingLocalNotification


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
        //
    }
    return self;
}

-(void)cancelAlarm: (NSInteger) id {
    for (UILocalNotification *notification in [[[[UIApplication sharedApplication] scheduledLocalNotifications] copy]autorelease]){
        NSDictionary *userInfo = notification.userInfo;
        if (id == [[userInfo objectForKey:@"id"] intValue]){
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}


-(void)scheduleAlarm: (NSInteger) id title: (NSString*) title message: (NSString*) message delay:(NSInteger) delay showInGame:(BOOL) showInGame {
    [self cancelAlarm: id]; //clear any previous alarms
    
    NSInteger show = showInGame ? 1 : 0;
    
    UILocalNotification *localNotif = [[[UILocalNotification alloc] init]autorelease];
    
    localNotif.alertAction = title;
    localNotif.alertBody = message;
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow: delay];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInteger:id],    @"id",
                              title,                              @"title",
                              message,                            @"message",
                              [NSNumber numberWithInteger:show],  @"showInGame",
                              nil];
    localNotif.userInfo = userInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

-(void)dealloc {
    [super dealloc];
}

EJ_BIND_FUNCTION (schedule, ctx, argc, argv) {
    if (argc == 4 || argc == 5) {
        NSInteger id = JSValueToNumberFast(ctx, argv[0]);
        NSString* title = JSValueToNSString(ctx, argv[1]);
        NSString* message = JSValueToNSString(ctx, argv[2]);
        NSInteger delay = JSValueToNumberFast(ctx, argv[3]);
        
        if (argc == 4) {
            [self scheduleAlarm: id title: title message: message delay: delay showInGame: FALSE ];
        } else {
            BOOL showInGame = JSValueToBoolean(ctx, argv[4]);
            [self scheduleAlarm: id title: title message: message delay: delay showInGame: showInGame ];
        }
        
        NSLog(@"Notification: #%d %@. Show in %d seconds.", id, title, delay);
    }
    
    return 0;
}

EJ_BIND_FUNCTION (cancel, ctx, argc, argv) {
    if (argc == 1) {
        NSInteger id = JSValueToNumberFast(ctx, argv[0]);
        [self cancelAlarm: id];
        
        NSLog(@"Notification cancelled: #%d.", id);
    }
    
    return 0;
}

EJ_BIND_FUNCTION (showNotifications, ctx, argc, argv) {
    for (UILocalNotification *notification in [[[[UIApplication sharedApplication] scheduledLocalNotifications] copy]autorelease]){
        NSDictionary *userInfo = notification.userInfo;
        NSLog(@"Notification: #%d %@", [[userInfo objectForKey:@"id"] intValue], [userInfo objectForKey:@"title"]);
    }
    
    return 0;
}


EJ_BIND_FUNCTION(clearNotifications, ctx, argc, argv) {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    return NULL;
}

EJ_BIND_SET(applicationIconBadgeNumber, ctx, value) {
    [UIApplication sharedApplication].applicationIconBadgeNumber = JSValueToNumberFast(ctx, value);
}


@end
