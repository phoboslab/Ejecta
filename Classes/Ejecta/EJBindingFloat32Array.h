//
//  EJBindingFloat32Array.h
//  EjectaGL
//
//  Created by vikram on 11/25/12.
//
//

#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJTypedArray.h"

@interface EJBindingFloat32Array : EJBindingBase <EJTypedArray> {
    size_t length;
    float *array;
}

@end
