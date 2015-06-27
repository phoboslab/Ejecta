#import "EJBindingLocalNotification.h"

@implementation EJBindingLocalNotification


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		// for iOS 8
        if ( [UIUserNotificationSettings class] ){
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
            [UIApplication.sharedApplication registerUserNotificationSettings:settings];
        }
	}
	return self;
}

-(void)cancelAlarm: (NSInteger) id {
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notify in notificaitons) {
        if (id == [[notify.userInfo objectForKey:@"_id"] intValue]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
            NSLog(@"Notification cancel: %ld.", id);
            break;
        }
    }
}

-(void)scheduleAlarm: (NSInteger) id title: (NSString*) title message: (NSString*) message delay:(NSInteger) delay userInfo:(NSDictionary *)userInfo {
    
	[self cancelAlarm: id]; //clear any previous alarms

	UILocalNotification *localNotif = [[[UILocalNotification alloc] init]autorelease];

    
    // for iOS 8
    if ( [localNotif respondsToSelector:@selector(alertTitle)] ){
        localNotif.alertTitle = title;
    }
	localNotif.alertAction = title;
    localNotif.alertBody = message;
	localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow: delay];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
	localNotif.soundName = UILocalNotificationDefaultSoundName;
	localNotif.timeZone = [NSTimeZone defaultTimeZone];
	localNotif.userInfo = userInfo;

    if (delay==0){
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }else{
        
        localNotif.applicationIconBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count ] + 1 ;

        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }

}

-(void)dealloc {
	[super dealloc];
}

EJ_BIND_FUNCTION (schedule, ctx, argc, argv) {
	if (argc >= 4) {
		NSInteger id = JSValueToNumberFast(ctx, argv[0]);
        NSString* idStr= [NSString stringWithFormat:@"%ld", id ];
		NSString* title = JSValueToNSString(ctx, argv[1]);
		NSString* message = JSValueToNSString(ctx, argv[2]);
		NSInteger delay = JSValueToNumberFast(ctx, argv[3]);
        NSDictionary *userInfo = nil;
		if (argc > 4) {
            JSObjectRef jsUserInfo = JSValueToObject(ctx, argv[4], NULL);
            userInfo = (NSMutableDictionary *)JSValueToNSObject(ctx, jsUserInfo);
            [userInfo setValue:idStr forKey:@"_id"];
        }else{
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:idStr, @"_id", nil];
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

//EJ_BIND_SET(applicationIconBadgeNumber, ctx, value) {
//	[UIApplication sharedApplication].applicationIconBadgeNumber = JSValueToNumberFast(ctx, value);
//}

EJ_BIND_FUNCTION (logNotifications, ctx, argc, argv) {
    for (UILocalNotification *notification in [[[[UIApplication sharedApplication] scheduledLocalNotifications] copy] autorelease]) {
        NSDictionary *userInfo = notification.userInfo;
        NSLog(@"Notification: #%d %@", [[userInfo objectForKey:@"id"] intValue], [notification alertAction]);
    }
    
    return NULL;
}



@end
