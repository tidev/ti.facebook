/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-present by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiUIView.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FacebookLoginButton : TiUIView {
    FBSDKLoginButton *_loginButton;
}

// Requested permissions when logging in. If set, do not set read permissions
// The audience defaults to AUDIENCE_ONLY_ME if not specifically set
- (void)setPublishPermissions_:(NSArray<NSString *> * _Nonnull)publishPermissions;

// Returns the granted publish-permissions
- (NSArray * _Nullable)publishPermissions;

// Requested permissions when logging in. If set, do not set publish permissions
- (void)setReadPermissions_:(NSArray<NSString *> * _Nullable)readPermissions;

// Returns the granted read-permissions
- (NSArray * _Nullable)readPermissions;

// The default is AUDIENCE_ONLY_ME, only applicable to publish permissions
- (void)setAudience_:(NSNumber * _Nonnull)audience;

// The default audience to use, if publish permissions are requested at login time.
- (NSNumber * _Nonnull)audience;

// Sets the desired tooltip behavior
- (void)setTooltipBehavior_:(NSNumber * _Nonnull)tooltipBehavior;

// Gets the desired tooltip behavior
- (NSNumber * _Nonnull)tooltipBehavior;

// Sets the desired tooltip color style
- (void)setTooltipColorStyle_:(NSNumber * _Nonnull)tooltipColorStyle;

// Gets the desired tooltip color style
- (NSNumber * _Nonnull)tooltipColorStyle;

@end

NS_ASSUME_NONNULL_END
