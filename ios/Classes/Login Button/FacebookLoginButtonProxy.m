/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookLoginButtonProxy.h"
#import "FacebookLoginButton.h"
#import "TiUtils.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FacebookLoginButtonProxy

- (NSString *)apiName
{
  return @"Ti.Facebook.LoginButton";
}

- (NSNumber *_Nonnull)audience
{
  return ((FacebookLoginButton *)self.view).audience;
}

- (NSNumber *_Nonnull)tooltipBehavior
{
  return ((FacebookLoginButton *)self.view).tooltipBehavior;
}

- (NSNumber *_Nonnull)tooltipColorStyle
{
  return ((FacebookLoginButton *)self.view).tooltipColorStyle;
}

@end

NS_ASSUME_NONNULL_END
