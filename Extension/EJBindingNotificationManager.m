
#import "EJBindingNotificationManager.h"


@implementation EJBindingNotificationManager

EJ_BIND_FUNCTION(localNotify, ctx, argc, argv) {
    UILocalNotification* localNotif = [[[UILocalNotification alloc]init]autorelease];
    NSTimeInterval fireDateInterval = JSValueToNumberFast(ctx, argv[0]) / 1000;
    localNotif.fireDate = [NSDate dateWithTimeIntervalSince1970:fireDateInterval];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = JSValueToNSString(ctx, argv[1]);
    localNotif.alertAction = argc >= 2 ? JSValueToNSString(ctx, argv[2]) : NSLocalizedString(@"View", nil);
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    NSDictionary *infoDict = @{};
    localNotif.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];    
    return NULL;
}

EJ_BIND_FUNCTION(clearLocalNotifications, ctx, argc, argv) {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    return NULL;
}

EJ_BIND_SET(applicationIconBadgeNumber, ctx, value) {
    [UIApplication sharedApplication].applicationIconBadgeNumber = JSValueToNumberFast(ctx, value);
}



@end
