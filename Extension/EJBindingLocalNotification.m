#import "EJBindingLocalNotification.h"

@implementation EJBindingLocalNotification


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
        // 1
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        // 2
        [UIApplication.sharedApplication registerUserNotificationSettings:settings];
	}
	return self;
}

-(void)cancelAlarm: (NSInteger) id {
	for (UILocalNotification *notification in [[[[UIApplication sharedApplication] scheduledLocalNotifications] copy] autorelease]) {
		NSDictionary *userInfo = notification.userInfo;
		if (id == [[userInfo objectForKey:@"id"] intValue]) {
			[[UIApplication sharedApplication] cancelLocalNotification:notification];
		}
	}
}

-(void)scheduleAlarm: (NSInteger) id title: (NSString*) title message: (NSString*) message delay:(NSInteger) delay userInfo:(NSDictionary *)userInfo {
	[self cancelAlarm: id]; //clear any previous alarms

	UILocalNotification *localNotif = [[[UILocalNotification alloc] init]autorelease];

	localNotif.alertAction = title;
    localNotif.alertTitle = title;
	localNotif.alertBody = message;
	localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow: delay];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
	localNotif.soundName = UILocalNotificationDefaultSoundName;
	localNotif.timeZone = [NSTimeZone defaultTimeZone];
	localNotif.userInfo = userInfo;
    
    if (delay==0){
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }else{
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }

}

-(void)dealloc {
	[super dealloc];
}

EJ_BIND_FUNCTION (schedule, ctx, argc, argv) {
	if (argc >= 4) {
		NSInteger id = JSValueToNumberFast(ctx, argv[0]);
		NSString* title = JSValueToNSString(ctx, argv[1]);
		NSString* message = JSValueToNSString(ctx, argv[2]);
		NSInteger delay = JSValueToNumberFast(ctx, argv[3]);
        NSDictionary *userInfo = nil;
		if (argc > 4) {
            JSObjectRef jsUserInfo = JSValueToObject(ctx, argv[4], NULL);
            userInfo = (NSDictionary *)JSValueToNSObject(ctx, jsUserInfo);
		}
        [self scheduleAlarm: id title: title message: message delay: delay userInfo:userInfo ];
        
		NSLog(@"Notification: #%ld %@. Show in %ld seconds.", (long)id, title, (long)delay);
	}

	return NULL;
}

EJ_BIND_FUNCTION (cancel, ctx, argc, argv) {
	if (argc == 1) {
		NSInteger id = JSValueToNumberFast(ctx, argv[0]);
		[self cancelAlarm: id];

		NSLog(@"Notification cancelled: #%ld.", (long)id);
	}

	return NULL;
}


EJ_BIND_FUNCTION(clearAll, ctx, argc, argv) {
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	return NULL;
}

EJ_BIND_SET(applicationIconBadgeNumber, ctx, value) {
	[UIApplication sharedApplication].applicationIconBadgeNumber = JSValueToNumberFast(ctx, value);
}

EJ_BIND_FUNCTION (logNotifications, ctx, argc, argv) {
    for (UILocalNotification *notification in [[[[UIApplication sharedApplication] scheduledLocalNotifications] copy] autorelease]) {
        NSDictionary *userInfo = notification.userInfo;
        NSLog(@"Notification: #%d %@", [[userInfo objectForKey:@"id"] intValue], [userInfo objectForKey:@"title"]);
    }
    
    return NULL;
}



@end
