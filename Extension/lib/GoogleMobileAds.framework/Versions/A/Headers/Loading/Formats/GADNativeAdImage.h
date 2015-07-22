//
//  GADNativeAdImage.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// Native ad image.
@interface GADNativeAdImage : NSObject

/// The image. If image autoloading is disabled, this property will be nil.
@property(nonatomic, readonly, strong) UIImage *image;

/// The image's URL.
@property(nonatomic, readonly, strong) NSURL *imageURL;

@end
