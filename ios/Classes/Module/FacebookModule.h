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

#import <TitaniumKit/TitaniumKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Social/Social.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief The root-namespace for the Facebook module
 */
@interface FacebookModule : TiModule <FBSDKSharingDelegate, FBSDKGameRequestDialogDelegate> {
  NSString *_userID;
  NSArray *_permissions;
  NSNumber *_loginTracking;
  NSDictionary *_launchOptions;
}

/*!
 @brief The user-id (if logged in).

 @code
 const fb = require('facebook');

 alert('User-ID: ' + fb.uid);
 @endcode
 
 @return NSString The user-id.
 */
- (NSString *_Nullable)uid;

/*!
 @brief A flag indicating if the user is currently logged in.
 
 @code
 const fb = require('facebook');

 if (fb.loggedIn === true) {
   alert('Logged in!');
 }
 @endcode
 
 @return NSNumber Indicating whether or not the user is currently logged in.
 */
- (NSNumber *_Nonnull)loggedIn;

/*!
 @brief The Facebook app-id returned either from the global settings or the tiapp.xml (fallback).
 
 @code
 const fb = require('facebook');
 
 alert('App-ID: ' + fb.appID);
 @endcode
 
 @return NSString The Facebook app-id.
 */
- (NSString *_Nonnull)appID;

/*!
 @brief Sets a new Facebook App-ID.
 
 @param appID The new Facebook app-id.

 @code
 const fb = require('facebook');
 
 fb.setAppID('<new-fb-app-id>')
 @endcode
 */
- (void)setAppID:(NSString *_Nonnull)appID;

/*!
 @brief Returns the known granted permissions.
 
 @code
 const fb = require('facebook');
 
 fb.permissions = ['read_stream'];
 alert(fb.permissions);
 @endcode
 
 @return NSArray The granted permissions.
 */
- (NSArray<NSString *> *_Nullable)permissions;

/*!
 @brief Returns the "global" access token that represents the currently logged in user.
 
 @code
 const fb = require('facebook');
 
 alert('Current Access-Token: \n\n' + fb.accessToken);
 @endcode
 
 @return NSString The current access-token.
 */
- (NSString *_Nullable)accessToken;

/*!
 @brief Returns whether the access token is expired by checking its `expirationDate` property.

 @code
 const fb = require('facebook');

 alert('Access-Token expiration status is: \n\n' + fb.accessTokenExpired);
 @endcode

 @return BOOL The expiration status of the token.
 */
- (NSNumber *)accessTokenExpired;

/*!
 @brief Returns `true` if the `accessToken` is not null AND not expired.

 @code
 const fb = require('facebook');

 alert('Access-Token active state is: \n\n' + fb.accessTokenActive);
 @endcode

 @return BOOL The status of the token.
 */
- (NSNumber *)accessTokenActive;

/*!
 @brief Sets the "global" access token that represents the currently logged in user.
 
 @param currentAccessToken The new access-token used for the user.
 
 @code
 const fb = require('facebook');
 
 fb.currentAccessToken = { accessToken: '<new-access-token>', permissions: ['read'] };
 alert('Current Access-Token: \n\n' + fb.accessToken);
 @endcode
 */
- (void)setCurrentAccessToken:(NSDictionary *_Nonnull)currentAccessToken;

/*!
 @brief Gets or sets the desired tracking preference to use for login attempts. Defaults to `LOGIN_TRACKING_ENABLED`
 
 @param loginTracking The tracking configuration to use
 
 @code
 const fb = require('facebook');
 
 fb.loginTracking = fb.LOGIN_TRACKING_LIMITED;
 fb.authorize();
 @endcode
 */
- (void)setLoginTracking_:(NSNumber *_Nonnull)loginTracking;

/*!
 @brief Returns the expiration date.
 
 @code
 const fb = require('facebook');
 
 alert('Access-Token expire: ' + fb.expirationDate);
 @endcode
 
 @return NSDate The expiration-date of the access-token.
 */
- (NSDate *_Nullable)expirationDate;

/*!
 @brief Sets the new permissions used to authenticate with Facebook.
 
 @param permissions The new permissions.
 
 @code
 const fb = require('facebook');
 
 fb.permissions = ['picture'];
 fb.authorize();
 @endcode
 */
- (void)setPermissions:(NSArray<NSString *> *_Nullable)permissions;

/*!
 @brief Log a purchase of the specified amount, in the specified currency.
 
 @param purchase The purchase object containing the amount and currency inside an object.
 
 @code
 const fb = require('facebook');
 
 fb.logPurchase(13.37, 'USD');
 @endcode
 */
- (void)logPurchase:(NSArray<id> *_Nonnull)purchase;

/*!
 @brief Log an event with an eventName, a numeric value and a set of key/value pairs in the parameters object.
 
 @param customEvent The custom event object containing the event-name, numeric value and additional parameters.
 
 @code
 const fb = require('facebook');
 
 fb.logCustomEvent('clappedHands', 54.23, {"CONTENT TYPE": "shoes", "CONTENT ID": "HDFU-8452"});
 @endcode
 */
- (void)logCustomEvent:(NSArray<id> *_Nonnull)customEvent;

/*!
 @brief Log an app event that tracks that a custom action was taken from a push notification.
 
 @param pushNotification The push-notification received from iOS by using the Ti.Network event-handler.

 @code
 const fb = require('facebook');
 
 Ti.Network.addEventListener('remote', function(e) {
   fb.logPushNotificationOpen(e.data, 'actionId');
 });
 @endcode
 */
- (void)logPushNotificationOpen:(NSArray<id> *_Nonnull)pushNotification;

/*!
 @brief Sets and sends a device token from `TiBlob` representation 
 
 @param deviceToken The device-token received from iOS using the Ti.Network API.
 
 @code
 const fb = require('facebook');

 Ti.Network.registerForPushNotifications({
   types: [Ti.Network.NOTIFICATION_TYPE_BADGE, Ti.Network.NOTIFICATION_TYPE_ALERT, Ti.Network.NOTIFICATION_TYPE_SOUND],
   success: function(e) {
     fb.setPushNotificationsDeviceToken(e.deviceToken);
   }
 });

 });
 @endcode
 */
- (void)setPushNotificationsDeviceToken:(NSString *_Nonnull)deviceToken;

/*!
 @brief Logs the user in or authorizes additional permissions.
 
 @param unused An used parameter for proxy-consistency. Permissions and login-behavior are set before.
 
 @code
 const fb = require('facebook');
 
 fb.addEventListener('login', function(e) {
   if (e.success) {
     alert('Login from User-ID: ' + e.uid);
   } else if (e.cancelled) {
     // user cancelled logout
   } else {
     alert(e.error);
   }
 });

 fb.addEventListener('logout',function(e) {
   alert('logged out');
 });

 fb.permissions = ['email'];
 fb.initialize();
 
 // Authorize if not logged in already
 if (!fb.getLoggedIn()) {
   fb.authorize();
 }
 @endcode
 */
- (void)authorize:(__unused id)unused;

/*!
 @brief Initialize the module and set the required event listeners.
 
 @param unused An unsed parameter for proxy consistency.
 
 @code
 const fb = require('facebook');
 
 fb.initialize();
 @endcode
 */
- (void)initialize:(__unused id)unused;

/*!
 @brief Log out the user and terminate the current session.
 
 @param unused An unsed parameter for proxy consistency.
 
 @code
 const fb = require('facebook');
 
 fb.logout();
 @endcode
 */
- (void)logout:(__unused id)unused;

/*!
 @brief Present a share-dialog.
 
 @param args The arguments passed to the share-dialog.
 
 @code
 const fb = require('facebook');
 
 fb.presentShareDialog({ 
   link: 'https://appcelerator.com',
   hashtag: '#codestrong'
 });
 @endcode
 */
- (void)presentShareDialog:(NSArray<NSDictionary<NSString *, id> *> *_Nonnull)args;

/*!
 @brief Present a photo share-dialog.
 
 @param args The arguments passed to the share-dialog.
 
 @code
 const fb = require('facebook');
 
 Titanium.Media.openPhotoGallery({
			success: function (event) {
				fb.presentPhotoShareDialog({
            photos: [{ photo: event.media, caption: 'B-e-a-utiful!' }] // An array of photos and optional captions
				});
			}
  });
 @endcode
 */
- (void)presentPhotoShareDialog:(NSArray<NSDictionary<NSString *, id> *> *_Nonnull)args;

/*!
 @brief Build up and present a game request.
 
 @param args The arguments passed to the send-request-dialog.
 
 @code
 const fb = require('facebook');
 
 fb.presentSendRequestDialog({
   title: 'New Game available',
   message: 'Check this new game!'
 });
 @endcode
 */
- (void)presentSendRequestDialog:(NSArray<NSDictionary<NSString *, id> *> *_Nonnull)args;

/*!
 @brief Refresh the current access token's permission state and extend the token's expiration date, if possible.
 
 @param unused An used parameter for proxy-consistency.
 
 @code
 const fb = require('facebook');
 
 fb.refreshPermissionsFromServer();
 @endcode
 */
- (void)refreshPermissionsFromServer:(__unused id)unused;

/*!
 @brief Authorize the user for additional read-permissions.
 
 @param args The arguments passed to the authorization-flow.
 
 @code
 const fb = require('facebook');
 
 fb.requestNewReadPermissions(['email'], function(e) {
   // Handle response, do graph requests, etc.
 });
 @endcode
 */
- (void)requestNewReadPermissions:(NSArray<id> *_Nonnull)args;

/*!
 @brief Authorize the user for additional public-permissions.
 
 @param args The arguments passed to the authorization-flow.
 
 @code
 const fb = require('facebook');
 
 fb.requestNewPublishPermissions(['read_stream'], fb.AUDIENCE_FRIENDS function(e) {
   // Handle response, do graph requests, etc.
 });
 @endcode
 */
- (void)requestNewPublishPermissions:(NSArray<id> *_Nonnull)args;

/*!
 @brief Represents a request to the Facebook Graph API.
 
 @param args The arguments passed to the Graph API.
 
 @code
 const fb = require('facebook');
 
 fb.requestWithGraphPath('me',{}, 'post', function(e) {
   if (e.success) {
     // e.path contains original path (e.g. 'me'), 
     // e.data contains the result
   } else {
     // note that we use new Facebook error handling
     // thus if there was any user action to take, 
     // since he was already notified
     // see https://developers.facebook.com/docs/ios/automatic-error-handling/
     alert(e.error);
   }
 });
 @endcode
 */
- (void)requestWithGraphPath:(NSArray<id> *_Nonnull)args;

/*!
 @brief Fetch deferred applink data if you use Mobile App Engagement Ads.
 
 @param args The arguments containing the callback passed to the Mobile App Engagement Ads API.
 
 @code
 const fb = require('facebook');
 
 fb.fetchDeferredAppLink(function(e) {
   if (!e.success) {
     Ti.API.error(e.error);
     return
   }
 
   alert('App-Link: ' + e.url);
 });
 @endcode
 */
- (void)fetchDeferredAppLink:(NSArray<KrollCallback *> *_Nonnull)args;

@end

NS_ASSUME_NONNULL_END
