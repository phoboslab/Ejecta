//
//  GADNativeAdImage+Mediation.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google. All rights reserved.
//

#import "GADNativeAdImage.h"

@interface GADNativeAdImage (MediationAdditions)

/// Initializes and returns a native ad image object with the provided image.
- (instancetype)initWithImage:(UIImage *)image;

/// Initializes and returns a native ad image object with the provided image URL and image scale.
- (instancetype)initWithURL:(NSURL *)URL scale:(CGFloat)scale;

@end
