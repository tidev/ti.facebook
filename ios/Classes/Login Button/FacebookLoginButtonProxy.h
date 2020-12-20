/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiViewProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface FacebookLoginButtonProxy : TiViewProxy {
}

/*!
 @brief The permissions to request.
 */
- (NSArray *_Nullable)permissions;

/*!
 @brief The default audience to use, if publish permissions are requested at login time.
 */
- (NSNumber *_Nonnull)audience;

/*!
 @brief Returns the desired tooltip behavior.
 */
- (NSNumber *_Nonnull)tooltipBehavior;

/*!
 @brief Returns the desired tooltip color style.
 */
- (NSNumber *_Nonnull)tooltipColorStyle;

@end

NS_ASSUME_NONNULL_END
