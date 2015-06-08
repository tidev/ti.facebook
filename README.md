# Titanium Facebook Module [![Build Status](https://travis-ci.org/appcelerator-modules/ti.facebook.svg?branch=master)](https://travis-ci.org/appcelerator-modules/ti.facebook)

The Facebook module is used for connecting your application with Facebook. This module supports the following features:

* Logging in to Facebook and authorizing your application
* Requesting read and publish permissions
* Refreshing existing permission
* Making requests through the Facebook Graph API using the requestWithGraphPath method
* Posting web and native share dialogs
* Posting send request dialogs
* Like button

Getting Started
---------------
Note that this module is only available for Release 4.0.0 and later, and is included with the Titanium SDK. You do not need to download or unpack it.
Edit the modules section of your tiapp.xml file to include this module:
```xml
<modules>
    <module platform="android">facebook</module>
    <module platform="iphone">facebook</module>
</modules>
```
Also you will need a Facebook App ID ready. To create a Facebook App ID, go to the Facebook Developer App: developers.facebook.com/apps

On the iOS platform, add the following property to the \<ios\>\<plist\>\<dict\> section in tiapp.xml:
```xml
<key>FacebookAppID</key>
<string>1234567891011</string>
<key>FacebookDisplayName</key>
<string>SomeName</string>
```
where SomeName is exactly as appears in the Facebook developer settings page

Also make sure you have a URL Scheme in tiapp.xml that looks like fb1234567891010. See Facebook docs for details on this. Add an entry to \<ios\>\<plist\>\<dict\> that looks like this, modify it for your app:
```xml
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
On the android platform, in tiapp.xml or AndroidManifest.xml you must declare the following inside the \<application\> node 
```xml
<activity android:name="com.facebook.LoginActivity" android:theme="@android:style/Theme.Translucent.NoTitleBar" android:label="YourAppName"/>
```
You must also reference the string containing your Facebook app ID, inside the \<application\> node as well: 
```xml
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/app_id"/>
```
The app id goes into the the file /platform/android/res/values/strings.xml, where you should define 
```xml
<resources><string name="app_id">1234567890123456</string></resources>
```
where the number is of course the app ID. The app ID is not set programmatically.

Proxy required per Android activity
-----------------------------------

Unlike iOS, where the entire app is active in memory, in Android only a single Activity is active at any time. In Titanium, an Activity corresponds to a standalone (i.e. not a Tab window) Ti.UI.Window or Ti.UI.TabGroup. The Facebook SDK contains tools to synchronize state between the various activities in the app, and this module implements that functionality, but for this to work we need to tell the module which is the currently active Activity. Thus the following is required:

All Windows/TabGroup in your app must create a proxy, e.g. : 
```xml
win1.fbProxy = fb.createActivityWorker({lifecycleContainer: win1});
```
where fb is the required module.
We must pass to the proxy the Ti.UI.Window or Ti.UI.TabGroup that will be using the proxy, so that the proxy can attach itself to the window's or tabgroup's activity.
The proxy object must be created prior to calling open() on the window or tabgroup in order to make sure the Activity onCreate event is captured correctly.
This proxy has no APIs (new since version 3.20.05), its sole function is to signal the Facebook SDK for the various Activity transitions. So just create it and attach it to the window/tabgroup.

Facebook Login and Authorization
--------------------------------
To use Facebook, a user must log in to Facebook and explicitly authorize the application to perform certain actions, such as accessing profile information or posting status messages.

There are two ways to initiate the login process:

Create a Facebook LoginButton to allow the user to log in if desired. You can also add either readPermissions or publishPermissions, otherwise the default is request for `public_profile`. Doing so will let the LoginButton request for permissions when logging in. Note that Facebook does not support setting both parameters at the same time to the LoginButton. For a complete list of permissions, see the official Facebook Permissions Reference.

```javascript
    var fb = require('facebook');
    fb.initialize();
    var loginButton = fb.createLoginButton({
        readPermissions: ['read_stream','email']
    });
```

Call authorize to prompt the user to login and authorize the application. This method can be considered if you prefer to use custom UI instead of the loginButton.

```javascript
    var fb = require('facebook');
    fb.permissions = ['email'];
    fb.initialize(); 
    facebook.authorize();
```
Which approach you take depends on your UI and how central Facebook is to your application. Both approaches fire a `login` event.

Requesting read and publish permissions
---------------------------------------

For a complete list of permissions, see the official Facebook Permissions Reference.

requestNewReadPermissions

```javascript
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

You must use the audience constants from the module, either AUDIENCE_NONE, AUDIENCE_ONLY_ME, AUDIENCE_FRIENDS, or AUDIENCE_EVERYONE. Note that it is not an error for the user to 'Skip' your requested permissions, so you should check the module's permissions property following the call.

```javascript
var fb = require('facebook');
fb.requestNewPublishPermissions(['read_stream','user_hometown', etc...], fb.AUDIENCE_FRIENDS, function(e){
    if(e.success){
        fb.requestWithGraphPath(...);
    } else if (e.cancelled){
    ....
    } else {
        Ti.API.debug('Failed authorization due to: ' + e.error);
    }
});
```

Refreshing Permissions
----------------------

Facebook now grants total control over granted permissions, and if the user modified the permissions outside of your app your cached token may not be updated. To get the current permissions from Facebook's servers you can call fb.refreshPermissionsFromServer(). You may listen for the tokenUpdated event to be notified of this operation's successful completion.

Facebook Graph API
------------------

The Facebook Graph API is the preferred method for getting information about a user's friends, news feed, and so on. Each object in the Facebook social graph is represented by a graph API object, such as a user, photo, or status message. The Graph API allows you to make requests on behalf of the user, such as posting a picture or status message. Use the requestWithGraphPath method to make a request to the Graph API.

For details on each of the Graph API objects and the supported operations, see the official Facebook Graph API documentation.
Note: fql is no longer supported by Facebook beginning April 2015, so this module does not support fql. This module supports Facebook Graph API v2.2 and above.

Example 1:

```javascript
    var fb = require('facebook');
    fb.requestWithGraphPath('me/groups', {}, 'GET',  function(r)
    {
        if (!r.success) {
            if (r.error) {
                alert(r.error);
            } else {
                alert("call was unsuccessful");
            }
            return;
        }
        var result = JSON.parse(r.result).data;
    }
```
Example 2:

```javascript
    var fb = require('facebook');
    fb.requestWithGraphPath('me/picture', {'redirect': 'false'}, 'GET',  function(r)
    {
        if (!r.success) {
            if (r.error) {
                alert(r.error);
            } else {
                alert("call was unsuccessful");
            }
            return;
        }
        var result = JSON.parse(r.result)
    }
```

Share Dialog
------------

You don't need permissions, or even log in to use this. You can either use presentShareDialog which requires facebook app to be preinstalled, or presentWebStareDialog that uses the web browser instead. Both approaches fire a `shareCompleted` event.
To share a user's status just call fb.share({});
To share a link call fb.share({url: 'http://example.com' });
To share more information, example:

```javascript
    var fb = require('facebook');
    if(fb.getCanPresentShareDialog()) { //checks to see if facebook app installed
        fb.presentShareDialog({
            link: 'https://appcelerator.com/',
            name: 'great product',
            description: 'Titanium is a great product',
            caption: 'it rocks too',
            picture: 'http://www.appcelerator.com/wp-content/uploads/scale_triangle1.png'
        });
    } else {
        fb.presentWebShareDialog({ //
            link: 'https://appcelerator.com/',
            name: 'great product',
            description: 'Titanium is a great product',
            caption: 'it rocks too',
            picture: 'http://www.appcelerator.com/wp-content/uploads/scale_triangle1.png'
        });
    }
```

Send Requests Dialog
--------------------

Sends an application request. Fires a `sendRequestCompleted` event. You can optionally include a `title` key with the title string,
or customized parameters in the `data` dictionary. To preselect users to send the invite to, you can add a `to` key with values
containing the facebook ids, seperated by commas in the `data` dictionary. See below for example.
See official Facebook Dialogs documentation for more details.

```javascript
    var fb = require('facebook');
    fb.presentSendRequestDialog({
        message: 'Go to https://appcelerator.com/',
        title: 'Invitation to Appcelerator',
        data: {
            to: '123456789,123456788'
        }
    });
```

Like Button
-----------

We can create a Like button just like any other view, with specific parameters documented in Facebook docs. Note there is no completion callback or event, and Facebook policies state "If you use the Like button on iOS or Android, don’t collect or use any information from it."

```javascript
var likeButton = fb.createLikeButton({
    objectId: "https://www.facebook.com/appcelerator", // URL or Facebook ID
    foregroundColor: "white", // A color in Titanium format - see Facebook docs
    likeViewStyle: 'box_count', // standard, button, box_count - see FB docs
    auxiliaryViewPosition: 'inline', // bottom, inline, top - see FB docs
    horizontalAlignment: 'left', // center, left, right - see FB docs,
    objectType: 'page', // iOS only, 'page', 'openGraphObject', or 'unknown' - see FB docs
    soundEnabled: true // boolean, iOS only
});
win.add(likeButton);
```

Notes
------------
* Note that the FacebookSDK.framework directory is the prebuilt Facebook SDK directly downloaded from Facebook, zero modifications. 
* Facebook is moving away from the native iOS login, and towards login through the Facebook app. The default behavior of this module is the same as in the Facebook SDK: app login with a fallback to webview. The advantages of the app login are: user control over individual permissions, and a uniform login experience over iOS, Android, and web.
* AppEvents are automatically logged. Check out the app Insights on Facebook. We can also log custom events for Insights.
* Choose to use LogInButton, rather than a customized UI, since it's directly from facebook and it's easier in maintaining facebook sessions.


Events and error handling
-------------------------

The error handling adheres to the new Facebook guideline for events such as `login`, `shareCompleted` and `requestSendCompleted`. Here is how to handle `login` events:
```javascript
    var fb = require('facebook');
    fb.addEventListener('login',function(e) {
        // You *will* get this event if loggedIn == false below
        // Make sure to handle all possible cases of this event
        if (e.success) {
            alert('login from uid: '+e.uid+', name: '+JSON.parse(e.data).name);
            label.text = 'Logged In = ' + fb.loggedIn;
        }
        else if (e.cancelled) {
            // user cancelled 
            alert('cancelled');
        }
        else {
            alert(e.error);         
        }
    });
    fb.addEventListener('logout', function(e) {
        alert('logged out');
        label.text = 'Logged In = ' + fb.loggedIn;
    });
```
