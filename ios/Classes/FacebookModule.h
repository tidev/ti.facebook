/**
 * FacebookIOS
 *
 * Copyright (c) 2014 by Mark Mokryn, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 * Copyright (c) 2009-present by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiModule.h"

#import <Social/Social.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>

@interface FacebookModule : TiModule <FBSDKSharingDelegate, FBSDKGameRequestDialogDelegate, FBSDKAppInviteDialogDelegate>
{
    NSString *_userID;
    NSArray *_permissions;
    FBSDKLoginBehavior _loginBehavior;
}

- (NSString * _Nullable)uid;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * if (facebook.loggedIn) {
 * }
 *
 */
- (NSNumber * _Nonnull)loggedIn;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * alert(facebook.appID);
 *
 */
- (NSString * _Nonnull)appID;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * facebook.setAppID('my-custom-appid');
 *
 */
- (void)setAppID:(NSString * _Nonnull)value;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * facebook.permissions = ['read_stream'];
 * alert(facebook.permissions);
 *
 */
- (NSArray<NSString *> * _Nullable)permissions;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * alert(facebook.accessToken);
 *
 */
- (NSString * _Nullable)accessToken;

- (void)setCurrentAccessToken:(NSDictionary * _Nonnull)currentAccessToken;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * alert(facebook.expirationDate);
 *
 */
- (NSDate * _Nullable)expirationDate;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * facebook.permissions = ['publish_stream'];
 * alert(facebook.permissions);
 *
 */
- (void)setPermissions:(NSArray<NSString *> * _Nullable)permissions;

/**
 * JS example:
 *
 * facebook.logPurchase(13.37, 'USD');
 *
 */
- (void)logPurchase:(NSArray<id> * _Nonnull)purchase;

/**
 * JS example:
 *
 * facebook.logCustomEvent('clappedHands', 54.23, {"CONTENT TYPE": "shoes", "CONTENT ID": "HDFU-8452"});
 *
 */
- (void)logCustomEvent:(NSArray<id> * _Nonnull)customEvent;

/**
 * JS example:
 *
 * Ti.Network.addEventListener('remote', function(e) {
 *     facebook.logPushNotificationOpen(e.data,"actionId");
 * });
 *
 */
- (void)logPushNotificationOpen:(NSArray<id> * _Nonnull)pushNotification;

/**
 * JS example:
 *
 * Ti.Network.registerForPushNotifications({
 *     types: [ Ti.Network.NOTIFICATION_TYPE_BADGE, Ti.Network.NOTIFICATION_TYPE_ALERT, Ti.Network.NOTIFICATION_TYPE_SOUND ],
 *     success: function(e) {
 *         facebook.setPushNotificationsDeviceToken(e.deviceToken);
 *     }
 * });
 *
 */
- (void)setPushNotificationsDeviceToken:(NSString * _Nonnull)deviceToken;

/**
 * JS example:
 * facebook.setLoginBehavior(facebook.LOGIN_BEHAVIOR_NATIVE);
 *
 */
- (void)setLoginBehavior:(NSNumber * _Nonnull)loginBehavior;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 *
 * facebook.addEventListener('login',function(e) {
 *    // You *will* get this event if loggedIn == false below
 *    // Make sure to handle all possible cases of this event
 *    if (e.success) {
 *		alert('login from uid: '+e.uid+', name: '+e.data.name);
 *    } else if (e.cancelled) {
 *      // user cancelled logout
 *    } else {
 *      alert(e.error);
 *    }
 * });
 *
 * facebook.addEventListener('logout',function(e) {
 *    alert('logged out');
 * });
 *
 * facebook.permissions = ['email'];
 * facebook.initialize(); // after you set up login/logout listeners and permissions
 * if (!fb.getLoggedIn()) {
 * // then you want to show a login UI
 * // where you should have a button that when clicked calls
 * // facebook.authorize();
 *
 */
- (void)authorize:(id _Nullable)unused;

// We have this function so that you can set up your listeners and permissions whenever you want
// Call initialize when ready, you will get a login event if there was a cached token
// else loggedIn will be false
- (void)initialize:(id _Nullable)unused;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * facebook.logout();
 *
 */
- (void)logout:(id _Nullable)unused;

// presents share dialog using existing facebook app. If no facebook app installed, does nothing.
- (void)presentShareDialog:(NSArray<NSDictionary<NSString *, id> *> * _Nonnull)args;

// Presents a messenger dialog to share content using the Facebook messenger
- (void)presentMessengerDialog:(NSArray<NSDictionary<NSString *, id> *> * _Nonnull)args;

// Shares images, GIFs and videos to the messenger
- (void)shareMediaToMessenger:(NSArray<NSDictionary<NSString *, id> *> * _Nonnull)args;

// Presents a share dialog using web dialog. Useful for devices with no facebook app installed.
- (void)presentWebShareDialog:(id _Nullable)unused;

// Presents an invite dialog using the native application.
- (void)presentInviteDialog:(NSArray<NSDictionary<NSString *, id> *> * _Nonnull)args;

// Presents a game request dialog.
- (void)presentSendRequestDialog:(NSArray<NSDictionary<NSString *, id> *> * _Nonnull)args;

- (void)refreshPermissionsFromServer:(id _Nullable)unused;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * ...
 * facebook.requestNewReadPermissions(['read_stream','user_hometown', etc...], function(e) {
 *     if (e.success) {
 *         facebook.requestWithGraphPath(...);
 *     } else if (e.cancelled) {
 *         .....
 *     } else {
 *         Ti.API.debug('Failed authorization due to: ' + e.error);
 *     }
 * });
 */
- (void)requestNewReadPermissions:(NSArray<id> * _Nonnull)args;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * ...
 * facebook.requestNewPublishPermissions(['read_stream','user_hometown', etc...], fb.audienceFriends, function(e) {
 *     if (e.success) {
 *         facebook.requestWithGraphPath(...);
 *     } else if (e.cancelled) {
 *         .....
 *     } else {
 *         Ti.API.debug('Failed authorization due to: ' + e.error);
 *     }
 * });
 */
- (void)requestNewPublishPermissions:(NSArray<id> * _Nonnull)args;

/**
 * JS example:
 *
 * var facebook = require('facebook');
 *
 * facebook.requestWithGraphPath('me',{}, 'post', function(e) {
 *    if (e.success) {
 *      // e.path contains original path (e.g. 'me'), e.data contains the result
 *    }
 *    else {
 *      // note that we use new Facebook error handling
 *      // thus if there was any user action to take - he was already notified
 *      // see https://developers.facebook.com/docs/ios/automatic-error-handling/
 *      alert(e.error);
 *    }
 * });
 *
 */
- (void)requestWithGraphPath:(NSArray<id> * _Nonnull)args;

- (void)fetchDeferredAppLink:(NSArray<KrollCallback *> * _Nonnull)args;

- (void)fetchNearbyPlacesForCurrentLocation:(NSArray<NSDictionary<NSString *, id> *> * _Nonnull)args;

- (void)fetchNearbyPlacesForSearchTearm:(NSArray<NSDictionary<NSString *, id> *> * _Nonnull)args;

@end
