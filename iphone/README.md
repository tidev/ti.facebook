Titanium Facebook Module
================================
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/mokesmokes/titanium-ios-facebook?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Notes
------------
* Note that the FacebookSDK.framework directory is the prebuilt Facebook SDK directly downloaded from Facebook, zero modifications. 
* Facebook is moving away from the native iOS login, and towards login through the Facebook app. The default behavior of this module is the same as in the Facebook SDK: app login with a fallback to webview. The advantages of the app login are: user control over individual permissions, and a uniform login experience over iOS, Android, and web. Additionally, the device login is quite prone to user error: for example, if the user declines to login initially with Facebook, then the next login will fail and the user needs to go into "Settings" on his phone and enable the app for Facebook. Many users will fail to do this. The only advantage of native device login is that it is faster. I recommend you leave the default as is, and if you do indeed elect nativeLogin then I recommend you do not request additional permissions beyond public_profile.
* AppEvents are automatically logged. Check out the app Insights on Facebook. We can also log custom events for Insights.
* Choose to use LogInButton, rather than a customized UI, since it's directly from facebook and it's easier in maintaining facebook sessions.

Module Goals
------------

* No hacking of Facebook SDK in order to enable easy upgrades. In fact, this module uses the pre-built SDK dropped in. Don't mess with that.
* Reliable Facebook authorization
* Proper error recovery mechanisms and user messaging - per Facebook's specs
* Use recent, preferably current, Facebook SDKs otherwise the above is unlikely....

Module API
----------

The module tries to stick to the original Titanium Facebook iOS module API (distributed with Ti SDK 3.1.0).
However, there are some differences, so read carefully.

*	`appid` - parameter unused. Instead, add the following to the `<ios><plist><dict>` section in tiapp.xml:
```
<key>FacebookAppID</key>
<string>1234567891011</string>
<key>FacebookDisplayName</key>
<string>SomeName</string>
```
where SomeName is exactly as appears in the Facebook developer settings page
*	Also make sure you have a URL Scheme in tiapp.xml that looks like fb1234567891010. See [Facebook docs](https://developers.facebook.com/docs/ios/getting-started/) for details on this. Add an entry to `<ios><plist><dict>` that looks like this, modify it for your app:
```
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.appcelerator.kitchensink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>kitchensink</string>
            <string>fb134793934930</string>
        </array>
    </dict>
</array>
```
*	`forceDialogAuth` - parameter unused.
*	The login button functionality is for now removed. It makes no sense to use a button besides the Facebook branded buttons in the SDK, and that is left for the future. 
*	Instead of "reauthorize" there is now requestNewReadPermissions and a separate requestNewPublishPermissions, as per the Facebook SDK. This provides much more flexibility and less nuisance to the users.

Initialization
--------------

```javascript
var fb = require('com.facebook');
// note that other than public_profile, the user can now reject any other permissions when logging in
// so you need to read fb.permissions to see what was actually granted
// The permissions you specify are requested of the user by the login interface.
// If a cached session exists, then no login UI is shown and a session is started with the previously granted permissions
fb.permissions = ['public_profile', 'email', 'user_friends', etc etc];
// if you read the permissions, e.g. perms = fb.permissions you get the actually approved permissions on the session, not those you requested from the user
fb.addEventListener('login, function(e) { ....
fb.addEventListener('logout', function(e) { .....

// We have a separate initialization function so that we can set up the event listeners in time
// Note that if a cached session exists, the login event will be fired immediately after initialize is called
fb.initialize(timeoutInMs, nativeLogin); // initialize requires a timeout value (ms) for the `/me` Graph request upon login,
// and an optional nativeLogin parameter (default: false) which if true enables iOS native login.
// If passing true to use nativeLogin, the native login will request the public_profile only. This is because the user cannot
// decline the other permissions in native login, and there are bugs such as this:
// https://developers.facebook.com/bugs/359391504210257/
```

Events and error handling
-------------------------

The `login` and `logout` events work as in the original module. 
However, the error handling is now adhering to the new Facebook guidelines. Here is how to handle `login` events:
```javascript
fb.addEventListener('login', function(e) {
	if(e.success) {
		// do your thang.... 
	} else if (e.cancelled) {
		// login was cancelled, just show your login UI again
	} else if (e.error) {
		if (Ti.Platform.name === 'iPhone OS') {
			var loginAlert = Ti.UI.createAlertDialog({title: 'Login Error'});
			if (e.error.indexOf('OTHER:') !== 0){
				// guaranteed a string suitable for display to user
				loginAlert.message = e.error;
			} else {
				//alert('Please check your network connection and try again.');
				// after "OTHER:" there may be useful error data, not suitable for user display
				loginAlert.message = 'Please check your network connection and try again';
			}
		}
	} else {
		// if not success, nor cancelled, nor error message then pop a generic message
		// e.g. "Check your network, etc" . This is per Facebook's instructions
```

Refreshing Permissions
----------------------

Facebook now grants total control over granted permissions, and if the user modified the permissions
outside of your app your cached token may not be updated. To get the current permissions from
Facebook's servers you can call `fb.refreshPermissionsFromServer()`. You may listen for the `tokenUpdated`
event to be notified of this operation's successful completion.

Share Dialog
-------------

See the [Facebook docs](https://developers.facebook.com/docs/ios/share-dialog/)
Use it! You don't need permissions, you don't even need the user to be logged into your app with Facebook!
*	First check if you can use it - call `fb.getCanPresentShareDialog()` which returns a boolean.
*	Currently the callback in the module just prints success or error to the debug log
*	To share a user's status just call `fb.share({});`
*	To share a link call `fb.share({url: 'http://example.com' });`
*	To post a graph action call:

```javascript
fb.share({url: someUrl, namespaceObject: 'myAppnameSpace:graphObject', objectName: 'graphObject', imageUrl: someImageUrl, 
		title: aTitle, description: blahBlah, namespaceAction: 'myAppnameSpace:actionType', placeId: facebookPlaceId}`
```
For the graph action apparently only placeId is optional.

Like Button
-----------

We can create a Like button just like any other view, with specific parameters documented in Facebook docs. Note there is no completion callback or event, and Facebook policies state "If you use the Like button on iOS or Android, don’t collect or use any information from it."
 
```
var likeButton = fbModule.createLikeButton({
	top: 10,
	height: "50%", // Note: on iOS setting Ti.UI.SIZE dimensions prevented the button click
	width: "50%",
	objectId: "https://www.facebook.com/NYKnicks", // URL or Facebook ID
	foregroundColor: "white", // A color in Titanium format - see Facebook docs
	likeViewStyle: 'box_count', // standard, button, box_count - see FB docs
	auxiliaryViewPosition: 'inline', // bottom, inline, top - see FB docs
	horizontalAlignment: 'left', // center, left, right - see FB docs,
	objectType: 'page', // iOS only, 'page', 'openGraphObject', or 'unknown' - see FB docs
	soundEnabled: true // boolean, iOS only
});
someView.add(likeButton);
```

requestNewReadPermissions
-------------------------

```
var fb = require('facebook');
fb.requestNewReadPermissions(['read_stream','user_hometown', etc...], function(e){
	if(e.success){
		fb.requestWithGraphPath(...);
 	} else if (e.cancelled){
 		....
 	} else {
 		Ti.API.debug('Failed authorization due to: ' + e.error);
 	}
});
```
 
requestNewPublishPermissions
----------------------------
 
 You must use the audience constants from the module, either `audienceNone`, `audienceOnlyMe`, `audienceFriends`, or `audienceEveryone`.
 Note that it is not an error for the user to 'Skip' your requested permissions, so you should check the module's permissions property following the call.

```
var fb = require('facebook');
fb.requestNewPublishPermissions(['read_stream','user_hometown', etc...], fb.audienceFriends, function(e){
	if(e.success){
		fb.requestWithGraphPath(...);
 	} else if (e.cancelled){
	....
	} else {
		Ti.API.debug('Failed authorization due to: ' + e.error);
	}
});
```

requestWithGraphPath
--------------------

Same as the original Titanium Facebook module. However, there is automatic error handling.
So in case of error only alert the user if `error == 'An unexpected error'`, everything else was already handled for you.

To do
-------
*	Facebook branded buttons - use the SDK implementation or don't do it.
*	[Share sheet](https://developers.facebook.com/docs/ios/ios-6/#nativepostcontroller) - it's more lightweight than the Share Dialog, but also with many less features. Some apps use Share Dialog (e.g. Pintrest), some the Share Sheet (e.g. Foodspotting).
*	Additional dialogs. But why?!?!??!? They are web based, require permissions, few good apps use them today. Just use the Share Dialog, or Share Sheet, or don't bother, in my opinion.

Custom App Events
-----------------
```
fb.logCustomEvent('handsClapped'); // Pass a string for the event name, view the events on Facebook Insights
```
	
Feel free to comment and help out! :)
-------------------------------------

