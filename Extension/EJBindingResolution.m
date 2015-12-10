#import "EJBindingResolution.h"
#include <sys/utsname.h>


@implementation EJBindingResolution

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
    
    if (self = [super initWithContext:ctx argc:argc argv:argv]) {
        struct utsname sysinfo;
    
        if (uname(&sysinfo) == 0) {
            NSString *identifier = [NSString stringWithUTF8String:sysinfo.machine];
            
            // group devices with same dots-density
            NSArray *iDevices = @[
                                  
                  @{@"identifiers": @[
                            @"iPad1,1",                                       // iPad
                            @"iPad2,1", @"iPad2,2", @"iPad2,3", @"iPad2,4",   // iPad 2
                            ],
                    @"dotsPerCentimeter":  @52.0f,
                    @"dotsPerInch":       @132.0f},

                  
                  @{@"identifiers": @[
                            @"iPad3,1", @"iPad3,2", @"iPad3,3",              // iPad 3
                            @"iPad3,4", @"iPad3,5", @"iPad3,6",              // iPad 4
                            @"iPad4,1", @"iPad4,2", @"iPad4,3",              // iPad Air
                            @"iPad5,3", @"iPad5,4",                          // iPad Air 2
                            ],
                    @"dotsPerCentimeter":  @104.0f,
                    @"dotsPerInch":       @264.0f},
                  

                  @{@"identifiers": @[
                            @"iPad2,5", @"iPad2,6", @"iPad2,7",              // iPad Mini
                            ],
                    @"dotsPerCentimeter":  @64.0f,
                    @"dotsPerInch":       @163.0f},
                  
                  
                  @{@"identifiers": @[
                            @"iPad4,4", @"iPad4,5",  @"iPad4,6",             // iPad Mini Retina (2)
                            @"iPad4,7", @"iPad4,8",  @"iPad4,9",             // iPad Mini 3
                            @"iPad5,1", @"iPad5,2",                          // iPad Mini 4
                            ],
                    @"dotsPerCentimeter":  @128.0f,
                    @"dotsPerInch":       @326.0f},
                  
                  
                  @{@"identifiers": @[
                            @"iPad6,7", @"iPad6,8",                          // iPad Pro
                            ],
                    @"dotsPerCentimeter":  @104.0f,
                    @"dotsPerInch":       @264.0f},
                  
                  
                  @{@"identifiers": @[
                            @"iPod1,1",                                      // iPod Touch 1
                            @"iPod2,1",                                      // iPod Touch 2
                            @"iPod3,1",                                      // iPod Touch 3
                            @"iPhone1,1",                                    // iPhone 2G
                            @"iPhone1,2",                                    // iPhone 3G
                            @"iPhone2,1",                                    // iPhone 3GS
                            ],
                    @"dotsPerCentimeter":  @64.0f,
                    @"dotsPerInch":       @163.0f},

                  
                  @{@"identifiers": @[
                            @"iPod4,1",                                      // iPod Touch 4
                            @"iPhone3,1", @"iPhone3,2", @"iPhone3,3",        // iPhone 4
                            @"iPhone4,1",                                    // iPhone 4S
                            ],
                    @"dotsPerCentimeter":  @128.0f,
                    @"dotsPerInch":       @326.0f},
                  

                  @{@"identifiers": @[
                            @"iPod5,1",                                      // iPod Touch 5
                            @"iPod7,1",                                      // iPod Touch 6
                            @"iPhone5,1", @"iPhone5,2",                      // iPhone 5
                            @"iPhone5,3", @"iPhone5,4",                      // iPhone 5C
                            @"iPhone6,1", @"iPhone6,2",                      // iPhone 5S
                            ],
                    @"dotsPerCentimeter":  @128.0f,
                    @"dotsPerInch":       @326.0f},
                  
                  
                  @{@"identifiers": @[
                            @"iPhone7,1",                                    // iPhone 6 Plus
                            @"iPhone8,2",                                    // iPhone 6s Plus
                            ],
                    @"dotsPerCentimeter":  @158.0f,
                    @"dotsPerInch":       @401.0f},
                  
                  
                  @{@"identifiers": @[
                            @"iPhone7,2",                                    // iPhone 6
                            @"iPhone8,1",                                    // iPhone 6s
                            ],
                    @"dotsPerCentimeter":  @128.0f,
                    @"dotsPerInch":       @326.0f},
                  
                  
                  @{@"identifiers": @[
                            @"i386", @"x86_64",                              // iOS simulator
                            ],
                    @"dotsPerCentimeter":  @128.0f,
                    @"dotsPerInch":       @326.0f},
                  
                  ];
            
            
            for (id deviceClass in iDevices) {
                for (NSString *deviceId in [deviceClass objectForKey:@"identifiers"]) {
                    if ([identifier isEqualToString:deviceId]) {
                        dotsPerCentimeter = [[deviceClass objectForKey:@"dotsPerCentimeter"] floatValue];
                        dotsPerInch = [[deviceClass objectForKey:@"dotsPerInch"] floatValue];
                        break;
                    }
                }
            }
            
            NSLog(@"Device name: %s", sysinfo.machine);
            if (dotsPerInch == 0){
                NSLog(@"Unknow device, use default values");
                // Default values
                dotsPerCentimeter = 104.0f;
                dotsPerInch = 264.0f;
            }

        }
    }
    
    return self;
}


EJ_BIND_GET(dpi, ctx) {
    return JSValueMakeNumber(ctx, dotsPerInch);
}
EJ_BIND_GET(dpc, ctx) {
    return JSValueMakeNumber(ctx, dotsPerCentimeter);
}


EJ_BIND_GET(ppc, ctx) {
    return JSValueMakeNumber(ctx, dotsPerCentimeter);
}

EJ_BIND_GET(ppi, ctx) {
    return JSValueMakeNumber(ctx, dotsPerInch);
}

@end
