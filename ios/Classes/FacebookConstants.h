/**
 * FacebookIOS
 *
 * Copyright (c) 2014 by Mark Mokryn, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

/*!
 @abstract
 Defines what visual mode a UIButton should have
 */
typedef NS_ENUM(NSUInteger, TiFacebookShareButtonMode) {
    TiFacebookShareButtonModeRectangular = 0,
    TiFacebookShareButtonModeCircular = 1
};

/*!
 @abstract
 Used to fire share-events from fb.presentShareDialog()
 */
extern NSString* const TiFacebookEventTypeShareCompleted;


/*!
 @abstract
 Used to fire invite-events from fb.presentInviteDialog()
 */
extern NSString* const TiFacebookEventTypeInviteCompleted;

/*!
 @abstract
 Used to fire game-request-events from fb.presentSendRequestDialog()
 */
extern NSString* const TiFacebookEventTypeRequestDialogCompleted;