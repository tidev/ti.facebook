/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookMessengerButtonProxy.h"
#import "FacebookMessengerButton.h"
#import "TiUtils.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FacebookMessengerButtonProxy

- (NSString *)apiName
{
  return @"Ti.Facebook.MessengerButton";
}

- (NSNumber *_Nonnull)mode
{
  return NUMUINTEGER([(FacebookMessengerButton *)[self view] mode]);
}

- (NSNumber *_Nonnull)style
{
  return NUMUINTEGER([(FacebookMessengerButton *)[self view] style]);
}

#pragma mark Layout Helper

- (UIViewAutoresizing)verifyAutoresizing:(UIViewAutoresizing)suggestedResizing
{
  return suggestedResizing & ~(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
}

- (void)viewDidAttach
{
  [(FacebookMessengerButton *)[self view] messengerButton];
}

- (TiDimension)defaultAutoWidthBehavior:(id)unused
{
  return TiDimensionAutoSize;
}

- (TiDimension)defaultAutoHeightBehavior:(id)unused
{
  return TiDimensionAutoSize;
}

USE_VIEW_FOR_VERIFY_HEIGHT

USE_VIEW_FOR_VERIFY_WIDTH

@end

NS_ASSUME_NONNULL_END
