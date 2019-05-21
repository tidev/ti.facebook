/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiUIView.h"

#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FacebookMessengerButton : TiUIView {
  @private
  UIButton *_messengerButton;
  NSUInteger _mode;
  NSUInteger _style;
}

- (NSUInteger)mode;
- (NSUInteger)style;
- (UIButton *)messengerButton;

@end

NS_ASSUME_NONNULL_END
