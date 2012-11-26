//
//  EJBindingShaderDOM.h
//  EjectaGL
//
//  Created by vikram on 11/26/12.
//
//

#import <Foundation/Foundation.h>
#import "EJBindingBase.h"

@interface EJBindingShaderDOM : EJBindingBase {
    NSString *script;
    NSString *type;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj
               script:(NSString *)scriptText type:(NSString *)typeText;

@end
