/**
 * Ti.Facebook
 *
 * Copyright (c) 2014 by Mark Mokryn, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

/*!
 @brief Defines what visual mode a UIButton should have
 */
typedef NS_ENUM(NSUInteger, TiFacebookShareButtonMode) {
  TiFacebookShareButtonModeRectangular = 0,
  TiFacebookShareButtonModeCircular = 1
};

/*!
 @brief Used to fire share-events from fb.presentShareDialog()
 */
extern NSString *const TiFacebookEventTypeShareCompleted;

/*!
 @brief Used to fire invite-events from fb.presentInviteDialog()
 */
extern NSString *const TiFacebookEventTypeInviteCompleted;

/*!
 @brief Used to fire game-request-events from fb.presentSendRequestDialog()
 */
extern NSString *const TiFacebookEventTypeRequestDialogCompleted;

/*!
 @brief Error message used to indicate a login-error caused by keychain-issues.
 */
extern NSString *const TiFacebookErrorMessageKeychainAccess;
