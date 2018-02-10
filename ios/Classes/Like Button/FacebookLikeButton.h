/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiUIView.h"

#import <FBSDKShareKit/FBSDKShareKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief A Facebook like button.
 */
@interface FacebookLikeButton : TiUIView {
  FBSDKLikeControl *_likeButton;
}

/*!
 @brief Set the object type. Removed in 5.0.0 and later.
 
 @param unused An unused parameter for proxy consistency.
 */
- (void)setObjectType_:(__unused id)unused;

/*!
 @brief Set the object ID. Removed in 5.0.0 and later, use "setObjectID" instead.
 
 @param unused An unused parameter for proxy consistency.
 */
- (void)setObjectId_:(__unused id)unused;

/*!
 @brief Set the objectID for the object to like.
 
 @param objectID May be an Open Graph object ID or a string representation of an URL 
 that describes an Open Graph object
 
 @code
 const fb = require('ti.facebook');
 
 fb.objectID = '<generic-object-id>';
 @endcode
 */
- (void)setObjectID_:(NSString *_Nonnull)objectID;

/*!
 @brief The foreground color to use for the content of the receiver.
 
 @param foregroundColor The new foreground color.
 
 @code
 const fb = require('ti.facebook');
 
 fb.foregroundColor = 'red';
 @endcode
 */
- (void)setForegroundColor_:(NSString *_Nonnull)foregroundColor;

/*!
 @brief The style to use for the receiver.
 
 @param likeViewStyle The new style to use. Either "box_count" or "standard".
 
 @code
 const fb = require('ti.facebook');
 
 fb.likeViewStyle = 'box_count';
 @endcode
 */
- (void)setLikeViewStyle_:(NSString *_Nonnull)likeViewStyle;

/*!
 @brief The position for the auxiliary view for the receiver.
 
 @param auxiliaryViewPosition The new position. One of "top", "bottom" or "inline".
 
 @code
 const fb = require('ti.facebook');
 
 fb.auxiliaryViewPosition = 'inline';
 @endcode
 */
- (void)setAuxiliaryViewPosition_:(NSString *_Nonnull)auxiliaryViewPosition;

/*!
 @brief The text alignment of the social sentence.
 
 @param horizontalAlignment The new text alignment. One of "center", "left" or "right".
 
 @code
 const fb = require('ti.facebook');
 
 fb.horizontalAlignment = 'center';
 @endcode
 */
- (void)setHorizontalAlignment_:(NSString *_Nonnull)horizontalAlignment;

/*!
 @brief Set the sound of the like button. If enabled, a sound is played when the receiver is toggled.
 
 @param soundEnabled Whether or not the sound should be enabled.
 
 @code
 const fb = require('ti.facebook');
 
 fb.soundEnabled = true;
 @endcode
 */
- (void)setSoundEnabled_:(NSNumber *_Nonnull)soundEnabled;

@end

NS_ASSUME_NONNULL_END
