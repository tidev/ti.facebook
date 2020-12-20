/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookLoginButton.h"
#import "TiUtils.h"

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

// Requested permissions when logging in
- (void)setPermissions_:(NSArray<NSString *> *_Nullable)permissions
{
  [[self loginButton] setPermissions:permissions];
}

// The default is AUDIENCE_ONLY_ME, only applicable to publish permissions
- (void)setAudience_:(NSNumber *_Nonnull)audience
{
  [[self loginButton] setDefaultAudience:[TiUtils intValue:audience]];
}

// Sets the desired tooltip behavior
- (void)setTooltipBehavior_:(NSNumber *_Nonnull)tooltipBehavior
{
  [[self loginButton] setTooltipBehavior:[TiUtils intValue:tooltipBehavior]];
}

// Sets the desired tooltip color style
- (void)setTooltipColorStyle_:(NSNumber *_Nonnull)tooltipColorStyle
{
  [[self loginButton] setTooltipColorStyle:[TiUtils intValue:tooltipColorStyle]];
}

NS_ASSUME_NONNULL_END

@end
