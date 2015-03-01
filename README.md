Titanium Facebook Module for Android
=====================================

Note to users upgrading to 3.20.05 or above
------------------------------------------
The Facebook proxy must still be created for each Activity, but it no longer has a public API. All methods, properties, and events are on the module object. The proxy's usage is entirely internal to the module. This was done mostly to improve event handling - i.e. a module event can be received by all app activities, while a proxy event would only be received by the currently active Window/TabGroup. The rest of the APIs were migrated to simplify module usage.

Overview
------------
* See [the sample app](https://github.com/mokesmokes/facebook-titanium-sample) for usage examples.
* Please read thie carefully since this module is (by necessity) different from previous Facebook Android modules
* This module is based on Facebook's latest Android SDK (3.18.0, currently), and in accordance with Facebook's samples and recommendations.
* The API is similar to the iOS Facebook module I wrote, differing in some places where required.
* The module uses the Facebook SDK with no modifications
* AppEvents: activateApp can monitor app installs and usage patterns. All you need to do is create a proxy for each activity in your app, and view the data on Facebook Insights. Additionally we can log custom events.

Current Functionality
---------------------
* Login/logout (Read Facebook docs for changes in this space)
* Additional permissions requests
* Graph API (version 2.1, read Facebook's docs for the changes, in particular regarding the user_friends permission).
* Share dialog
* Like button
* Additional functionality will be implemented over time, pull requests greatly appreciated

Installation Details
--------------------
* The minimum required SDK version is 3.5.1 . The required functionality exists starting in 3.5.1.RC
* If you want to use the production 3_4_X branch, you may use this, which is kept current with Appcelerator's 3_4_X: https://github.com/mokesmokes/titanium_mobile/tree/3_4_M
* In tiapp.xml or AndroidManifest.xml you must declare the following inside the `<application>` node
`<activity android:name="com.facebook.LoginActivity" android:theme="@android:style/Theme.Translucent.NoTitleBar" 
	android:label="YourAppName"/>`
* You must also reference the string containing your Facebook app ID, inside the `<application>` node as well: 
`<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/app_id"/>`
* The app id goes into the the file `/platform/android/res/values/strings.xml`, where you should define
`<resources><string name="app_id">1234567890123456</string></resources>`, where the number is of course the app ID. The app ID is not set programmatically.

Module Versioning
-----------------

x.y.zt, where x.y.z is the Facebook iOS SDK version, t denotes the Titanium module version for this SDK.
For example, module version 3.18.01 uses Facebook Android SDK 3.18.0

Proxy required per Android activity
-----------------------------------
Unlike iOS, where the entire app is active in memory, in Android only a single Activity is active at any time. In Titanium, an Activity corresponds to a standalone (i.e. not a Tab window) Ti.UI.Window or Ti.UI.TabGroup. The Facebook SDK contains tools to synchronize state between the various activities in the app, and this module implements that functionality, but for this to work we need to tell the module which is the currently active Activity. Thus the following is required:
* All Windows/TabGroup in your app must create a proxy, e.g. : `win1.fbProxy = fb.createActivityWorker({lifecycleContainer: win1});`, where `fb` is the `require`ed module.
* We must pass to the proxy the Ti.UI.Window or Ti.UI.TabGroup that will be using the proxy, so that the proxy can attach itself to the window's or tabgroup's activity.
* The proxy object must be created prior to calling open() on the window or tabgroup in order to make sure the Activity onCreate event is captured correctly.
* This proxy ***has no APIs*** (new since version 3.20.05), its sole function is to signal the Facebook SDK for the various Activity transitions. So just create it and attach it to the window/tabgroup.

Module API
----------

* Require the module: `var fb = require('com.ti.facebook');`
* Create a proxy for each Activity (Window or TabGroup) in the app, and attach it to the window or tab group object so it doesn't get garbage collected, e.g.: `win.fbProxy = fbModule.createActivityWorker({lifecycleContainer: win);`
* The permissions array may be set by calling `setPermissions(['public_profile', 'email', etc])` on the module object. Note that these are just the requested read permissions, and not necessarily the permissions granted to the app. These permissions will only be used when initially authenticating with Facebook.
* The actual permissions granted to the app may be read at any time by checking `var permissions = fb.permissions;` 
* Add login and logout event listeners on the module object. The syntax and functionality is identical to the current Titanium Facebook module.
* After setting up the login and logout listeners, call `fb.initialize([optional timeout]);`. If there is a cached Facebook session available, the login event will be fired immediately.
* `fb.requestNewReadPermissions([new read permissions], function(e) {....});` The callback will indicate `success`, `error` or `cancelled`. If `success`, then you need to get `fb.permissions` to check the actually active permissions on the session.
* `requestNewPublishPermissions` - same as for requestNewReadPermissions. Note these functions take on added importance since users can decline individual permissions when initially logging in, except for `public_profile` which is mandatory.
* `fb.requestWithGraphPath` - same as in Appcelerator's Titanium module.
* `fb.authorize()` should be called to initiate the login process if the user is logged out and the user clicks on the login button
* Share Dialog: see below.

Events and error handling
-------------------------

The `login` event behavior is normalized to behave similarly to iOS. If you're logged in after initialization,
you *will* get a `login` event. It's important to understand the reason for this: The module checks the SDK for a cached token.
However, there is a possibility this token is invalid without the SDK's knowledge (e.g. the user changed her password, etc).
Thus, the only way to verify the token's and session's validity is to make a call to Facebook's servers. 
You will not get the `login` event if there was no cached session. 
See [the sample app](https://github.com/mokesmokes/facebook-titanium-sample) for a full example.

Refreshing Permissions
----------------------

Facebook now grants total control over granted permissions, and if the user modified the permissions
outside of your app your cached token may not be updated. To get the current permissions from
Facebook's servers you can call `fb.refreshPermissionsFromServer()`. You may listen for the `tokenUpdated`
event to be notified of this operation's successful completion.

Share Dialog
-------------

See the [Facebook docs](https://developers.facebook.com/docs/android/share-dialog/)
Use it! You don't need permissions, you don't even need the user to be logged into your app with Facebook!
*	First check if you can use it - check the properties `fb.canPresentShareDialog` or `fb.canPresentOpenGraphActionDialog`, depending upon your desired sharing action.
Unfortunately this is less concise than the iOS module, due to the SDK.
*	To share a user's status just call `fb.share({});` Note: this is documented for iOS but not Android, so use with caution.
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
	height: Ti.UI.SIZE,
	width: Ti.UI.SIZE, // just like any other view
	objectId: "https://www.facebook.com/NYKnicks", // URL or Facebook ID
	foregroundColor: "white", // A color in Titanium format - see Facebook docs
	likeViewStyle: 'box_count', // standard, button, box_count - see FB docs
	auxiliaryViewPosition: 'inline', // bottom, inline, top - see FB docs
	horizontalAlignment: 'left' // center, left, right - see FB docs
});
someView.add(likeButton);
```

Custom App Events
-----------------
```
fb.logCustomEvent('handsClapped'); // Pass a string for the event name, view the events on Facebook Insights
```

Feel free to comment and help out! :)
-------------------------------------
