//
//  GoogleMobileAdsDefines.h
//  Google Mobile Ads SDK
//
//  Copyright (c) 2015 Google Inc. All rights reserved.
//

#if defined(__cplusplus)
#define GAD_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define GAD_EXTERN extern __attribute__((visibility("default")))
#endif  // defined(__cplusplus)

#if defined(__has_feature) && defined(__has_attribute)
#if __has_feature(attribute_GAD_DEPRECATED_with_message)
#define GAD_DEPRECATED_MSG_ATTRIBUTE(s) __attribute__((deprecated(s)))
#elif __has_attribute(deprecated)
#define GAD_DEPRECATED_MSG_ATTRIBUTE(s) __attribute__((deprecated))
#else
#define GAD_DEPRECATED_MSG_ATTRIBUTE(s)
#endif  // __has_feature(attribute_GAD_DEPRECATED_with_message)
#if __has_attribute(deprecated)
#define GAD_DEPRECATED_ATTRIBUTE __attribute__((deprecated))
#else
#define GAD_DEPRECATED_ATTRIBUTE
#endif  // __has_attribute(deprecated)
#else
#define GAD_DEPRECATED_ATTRIBUTE
#define GAD_DEPRECATED_MSG_ATTRIBUTE(s)
#endif  // defined(__has_feature) && defined(__has_attribute)
