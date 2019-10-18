/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookLoginButtonProxy.h"
#import "FacebookLoginButton.h"
#import "TiUtils.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>

NS_ASSUME_NONNULL_BEGIN

@implementation FacebookLoginButtonProxy

- (NSString *)apiName
{
  return @"Ti.Facebook.LoginButton";
}

- (NSArray *_Nullable)publishPermissions
{
  DEPRECATED_REPLACED(@"Facebook.LoginButton.publishPermissions", @"7.0.0", @"Facebook.LoginButton.permissions");
  return [[self loginButton] permissions];
}

- (NSArray *_Nullable)readPermissions
{
  DEPRECATED_REPLACED(@"Facebook.LoginButton.readPermissions", @"7.0.0", @"Facebook.LoginButton.permissions");
  return [[self loginButton] permissions];
}

- (NSArray *_Nullable)permissions
{
  return [[self loginButton] permissions];
}

- (NSNumber *_Nonnull)audience
{
  return NUMUINTEGER([[self loginButton] defaultAudience]);
}

- (NSNumber *_Nonnull)tooltipBehavior
{
  return NUMUINTEGER([[self loginButton] tooltipBehavior]);
}

- (NSNumber *_Nonnull)tooltipColorStyle
{
  return NUMUINTEGER([[self loginButton] tooltipColorStyle]);
}

#pragma Utility

- (FBSDKLoginButton *)loginButton
{
  return [(FacebookLoginButton *)self.view loginButton];
}

@end

NS_ASSUME_NONNULL_END
