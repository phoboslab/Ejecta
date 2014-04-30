#import <Foundation/Foundation.h>



@protocol EJInterceptor

@optional
- (NSMutableData *)interceptData:(NSMutableData *)data;
- (NSString *)interceptString:(NSString *)str;


@end
