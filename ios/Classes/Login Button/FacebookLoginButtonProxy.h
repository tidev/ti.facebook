/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <TitaniumKit/TiViewProxy.h>

NS_ASSUME_NONNULL_BEGIN

@interface FacebookLoginButtonProxy : TiViewProxy {
}

/*!
 @brief Returns the granted publish-permissions.
 */
- (NSArray *_Nullable)publishPermissions;

/*!
 @brief Returns the granted read-permissions.
 */
- (NSArray *_Nullable)readPermissions;

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

/*!
 @brief Returns the nonce.
 */
- (NSString *_Nullable)nonce;
@end

NS_ASSUME_NONNULL_END
