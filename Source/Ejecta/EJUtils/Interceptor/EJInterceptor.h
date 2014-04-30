#import <Foundation/Foundation.h>


@protocol EJInterceptor

@required
- (void)interceptData:(NSMutableData *)data;


@end
