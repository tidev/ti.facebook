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
  return [[self loginButton] publishPermissions];
}

- (NSArray *_Nullable)readPermissions
{
  return [[self loginButton] readPermissions];
}

// The default audience to use, if publish permissions are requested at login time.
- (NSNumber *_Nonnull)audience
{
  return NUMUINTEGER([[self loginButton] defaultAudience]);
}

// Gets the desired tooltip behavior
- (NSNumber *_Nonnull)tooltipBehavior
{
  return NUMUINTEGER([[self loginButton] tooltipBehavior]);
}

// Gets the desired tooltip color style
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
