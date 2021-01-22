/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookLoginButton.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FacebookLoginButton

#pragma mark Internal

- (FBSDKLoginButton *)loginButton
{
  if (_loginButton == nil) {
    _loginButton = [[FBSDKLoginButton alloc] init];
    [self addSubview:_loginButton];
  }

  return _loginButton;
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
  [TiUtils setView:[self loginButton] positionRect:bounds];
}

#pragma mark Public API's

- (void)setPublishPermissions_:(NSArray<NSString *> *_Nonnull)publishPermissions
{
  DEPRECATED_REPLACED(@"Facebook.LoginButton.publishPermissions", @"7.0.0", @"Facebook.LoginButton.permissions");
  [[self loginButton] setPermissions:publishPermissions];
}

- (void)setReadPermissions_:(NSArray<NSString *> *_Nullable)readPermissions
{
  DEPRECATED_REPLACED(@"Facebook.LoginButton.readPermissions", @"7.0.0", @"Facebook.LoginButton.permissions");
  [[self loginButton] setPermissions:readPermissions];
}

- (void)setPermissions_:(NSArray<NSString *> *_Nullable)permissions
{
  [[self loginButton] setPermissions:permissions];
}

- (void)setAudience_:(NSNumber *_Nonnull)audience
{
  [[self loginButton] setDefaultAudience:[TiUtils intValue:audience]];
}

- (void)setTooltipBehavior_:(NSNumber *_Nonnull)tooltipBehavior
{
  [[self loginButton] setTooltipBehavior:[TiUtils intValue:tooltipBehavior]];
}

- (void)setTooltipColorStyle_:(NSNumber *_Nonnull)tooltipColorStyle
{
  [[self loginButton] setTooltipColorStyle:[TiUtils intValue:tooltipColorStyle]];
}

- (void)setLoginTracking_:(NSNumber *_Nonnull)loginTracking
{
  [[self loginButton] setLoginTracking:[TiUtils intValue:loginTracking]];
}

- (void)setNonce_:(NSString *_Nonnull)nonce
{
  [[self loginButton] setNonce:[TiUtils stringValue:nonce]];
}

NS_ASSUME_NONNULL_END

@end
