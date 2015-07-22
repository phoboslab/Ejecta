//
//  GADAdLoader.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GADRequest;
@class GADRequestError;
@protocol GADAdLoaderDelegate;

/// Loads ads. See GADAdLoaderAdTypes.h for available ad types.
@interface GADAdLoader : NSObject

/// Object notified when an ad request succeeds or fails. Must conform to requested ad types'
/// delegate protocols.
@property(nonatomic, weak) id<GADAdLoaderDelegate> delegate;

/// Returns an initialized ad loader configured to load the specified ad types.
///
/// @param rootViewController The root view controller is used to present ad click actions. Cannot
/// be nil.
/// @param adTypes An array of ad types. See GADAdLoaderAdTypes.h for available ad types.
/// @param options An array of GADAdLoaderOptions objects to configure how ads are loaded, or nil to
/// use default options. See each ad type's header for available GADAdLoaderOptions subclasses.
- (instancetype)initWithAdUnitID:(NSString *)adUnitID
              rootViewController:(UIViewController *)rootViewController
                         adTypes:(NSArray *)adTypes
                         options:(NSArray *)options;

/// Loads the ad and informs the delegate of the outcome.
- (void)loadRequest:(GADRequest *)request;

@end

/// Ad loader options base class. See each ad type's header for available GADAdLoaderOptions
/// subclasses.
@interface GADAdLoaderOptions : NSObject
@end
