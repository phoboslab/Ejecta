//
//  EJTypedArray.h
//  EjectaGL
//
//  Created by vikram on 11/25/12.
//
//

#import <Foundation/Foundation.h>

@protocol EJTypedArray <NSObject>

@property (readonly, nonatomic) uint size;
@property (readonly, nonatomic) void *data;

@end
