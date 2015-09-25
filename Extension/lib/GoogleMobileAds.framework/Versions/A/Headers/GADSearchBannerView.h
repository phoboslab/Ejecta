//
//  GADSearchBannerView.h
//  Google Mobile Ads SDK
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import <GoogleMobileAds/GADBannerView.h>

// A view that displays search ads.
// To show search ads:
//   1) Create a GADSearchBannerView and add it to your view controller's view hierarchy.
//   2) Create a GADSearchRequest ad request object to hold the search query and other search data.
//   3) Call GADSearchBannerView's -loadRequest: method with the GADSearchRequest object.
@interface GADSearchBannerView : GADBannerView
@end
