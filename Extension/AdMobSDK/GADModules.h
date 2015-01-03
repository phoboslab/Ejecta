//
//  GADModules.h
//  Google Mobile Ads SDK
//
//  Copyright 2014 Google Inc. All rights reserved.
//

// If your target uses modules, importing this file will automatically link the frameworks used by
// the Google Mobile Ads library.

#if __has_feature(objc_modules)
@import AdSupport;
@import AudioToolbox;
@import AVFoundation;
@import CoreGraphics;
@import CoreTelephony;
@import EventKit;
@import EventKitUI;
@import Foundation;
@import MessageUI;
@import StoreKit;
@import SystemConfiguration;
@import UIKit;
#endif
