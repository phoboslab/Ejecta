//
//  GADSearchRequest.h
//  Google Mobile Ads SDK
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <GoogleMobileAds/GADRequest.h>

/// Search ad border types.
typedef NS_ENUM(NSUInteger, GADSearchBorderType) {
  kGADSearchBorderTypeNone,
  kGADSearchBorderTypeDashed,
  kGADSearchBorderTypeDotted,
  kGADSearchBorderTypeSolid
};

typedef NS_ENUM(NSUInteger, GADSearchCallButtonColor) {
  kGADSearchCallButtonLight,
  kGADSearchCallButtonMedium,
  kGADSearchCallButtonDark
};

// Specifies parameters for search ads.
@interface GADSearchRequest : GADRequest

@property(nonatomic, copy) NSString *query;
@property(nonatomic, copy, readonly) UIColor *backgroundColor;
@property(nonatomic, copy, readonly) UIColor *gradientFrom;
@property(nonatomic, copy, readonly) UIColor *gradientTo;
@property(nonatomic, copy) UIColor *headerColor;
@property(nonatomic, copy) UIColor *descriptionTextColor;
@property(nonatomic, copy) UIColor *anchorTextColor;
@property(nonatomic, copy) NSString *fontFamily;
@property(nonatomic, assign) NSUInteger headerTextSize;
@property(nonatomic, copy) UIColor *borderColor;
@property(nonatomic, assign) GADSearchBorderType borderType;
@property(nonatomic, assign) NSUInteger borderThickness;
@property(nonatomic, copy) NSString *customChannels;
@property(nonatomic, assign) GADSearchCallButtonColor callButtonColor;

// A solid background color for rendering the ad. The background of the ad
// can either be a solid color, or a gradient, which can be specified through
// setBackgroundGradientFrom:toColor: method. If both solid and gradient
// background is requested, only the latter is considered.
- (void)setBackgroundSolid:(UIColor *)color;

// A linear gradient background color for rendering the ad. The background of
// the ad can either be a linear gradient, or a solid color, which can be
// specified through setBackgroundSolid method. If both solid and gradient
// background is requested, only the latter is considered.
- (void)setBackgroundGradientFrom:(UIColor *)from toColor:(UIColor *)toColor;

@end
