//
//  EJBindingUint16Array.h
//  EjectaGL
//
//  Created by vikram on 11/26/12.
//
//

#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJTypedArray.h"

@interface EJBindingUint16Array : EJBindingBase <EJTypedArray> {
    size_t length;
    UInt16 *array;
}

@end
