/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiUIView.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief A Facebook login button.
 */
@interface FacebookLoginButton : TiUIView {
  FBSDKLoginButton *_loginButton;
}

/*!
 @brief Requested permissions when logging in. If set, do not set read permissions.
*/
- (void)setPublishPermissions_:(NSArray<NSString *> *_Nonnull)publishPermissions;

/*!
 @brief Returns the granted publish-permissions.
 */
- (NSArray *_Nullable)publishPermissions;

/*! 
 @brief Requested permissions when logging in. If set, do not set publish permissions.
 */
- (void)setReadPermissions_:(NSArray<NSString *> *_Nullable)readPermissions;

/*! 
 @brief Returns the granted read-permissions.
 */
- (NSArray *_Nullable)readPermissions;

/*!
 @brief The permissions to request.
 */
- (void)setPermissions_:(NSArray<NSString *> *_Nullable)permissions;

/*!
 @brief The permissions to request.
 */
- (NSArray *_Nullable)permissions;

/*! 
 @brief The default is AUDIENCE_ONLY_ME, only applicable to publish permissions.
 */
- (void)setAudience_:(NSNumber *_Nonnull)audience;

/*! 
 @brief The default audience to use, if publish permissions are requested at login time.
 */
- (NSNumber *_Nonnull)audience;

/*!
 @brief Returns the desired tooltip behavior.
 */
- (void)setTooltipBehavior_:(NSNumber *_Nonnull)tooltipBehavior;

/*!
 @brief Returns the desired tooltip behavior.
 */
- (NSNumber *_Nonnull)tooltipBehavior;

/*!
 @brief Sets the desired tooltip color style.
 */
- (void)setTooltipColorStyle_:(NSNumber *_Nonnull)tooltipColorStyle;

/*!
 @brief Returns the desired tooltip color style.
 */
- (NSNumber *_Nonnull)tooltipColorStyle;

@end

NS_ASSUME_NONNULL_END
