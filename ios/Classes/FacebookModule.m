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

#import "FacebookModule.h"
#import "FacebookConstants.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

NSDictionary *launchOptions = nil;

@implementation FacebookModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"7ac4bcd0-eb97-4e43-89fc-03f7f4d0a2a0";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"facebook";
}

#pragma mark Lifecycle

-(void)dealloc
{
    RELEASE_TO_NIL(permissions);
    [super dealloc];
}

-(BOOL)handleRelaunch
{
    TiApp * appDelegate = [TiApp app];
    launchOptions = [appDelegate launchOptions];
    NSString *urlString = [launchOptions objectForKey:@"url"];
    NSString *sourceApplication = [launchOptions objectForKey:@"source"];
    NSString *annotation;
    
    if ([TiUtils isIOS9OrGreater]) {
#ifdef __IPHONE_9_0
        annotation = [launchOptions objectForKey:UIApplicationOpenURLOptionsAnnotationKey];
#endif
    } else {
        annotation = nil;
    }
    
    if (urlString != nil) {
        FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
        NSSet* failed = token.declinedPermissions;
        return [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] openURL: [NSURL URLWithString:urlString] sourceApplication:sourceApplication annotation:annotation];
    } else {
        return NO;
    }
    return NO;
}

-(void)resumed:(id)note
{
//    NSLog(@"[DEBUG] facebook resumed");
    [self handleRelaunch];
    [FBSDKAppEvents activateApp];
}

-(void)activateApp
{
    TiApp * appDelegate = [TiApp app];
	launchOptions = [appDelegate launchOptions];
	[[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:launchOptions];
}

-(void)startup
{
//    NSLog(@"[DEBUG] startup: running FB sdk version: %@", [FBSettings sdkVersion]);
/* Uncomment to get a ton of debug prints
    [FBSettings setLoggingBehavior:
     [NSSet setWithObjects:FBLoggingBehaviorFBRequests, FBLoggingBehaviorFBURLConnections,
      FBLoggingBehaviorAccessTokens, FBLoggingBehaviorSessionStateTransitions, FBLoggingBehaviorAppEvents,
      FBLoggingBehaviorInformational, FBLoggingBehaviorCacheErrors, FBLoggingBehaviorDeveloperErrors, nil]];
*/
    [super startup];
}

-(void)shutdown:(id)sender
{
//    NSLog(@"[DEBUG] facebook shutdown");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super shutdown:sender];
}

-(void)suspend:(id)sender
{
//    NSLog(@"[DEBUG] facebook suspend");
}

-(void)paused:(id)sender
{
//    NSLog(@"[DEBUG] facebook paused");
}

#pragma mark Auth Internals

- (void)populateUserDetails {
    TiThreadPerformOnMainThread(^{
        if ([FBSDKAccessToken currentAccessToken] != nil) {
            FBSDKProfile *user = [FBSDKProfile currentProfile];
            uid = [user userID];
            [self fireLogin:user cancelled:NO withError:nil];
        }
        else {
//            DebugLog(@"[ERROR] Not logged in");
            [self fireLogin:nil cancelled:NO withError:nil];
        }
    }, NO);
}

#pragma mark Public APIs

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * alert(facebook.uid);
 *
 */
-(id)uid
{
    return uid;
}

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * if (facebook.loggedIn) {
 * }
 *
 */
-(id)loggedIn
{
    return NUMBOOL([FBSDKAccessToken currentAccessToken] != nil);
}

//TODO
-(id)canPresentShareDialog
{
    DEPRECATED_REMOVED(@"Facebook.canPresentShareDialog", @"5.0.0", @"5.0.0");
    return NULL;
}

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * facebook.permissions = ['read_stream'];
 * alert(facebook.permissions);
 *
 */
-(id)permissions
{
    __block NSArray *perms;
    TiThreadPerformOnMainThread(^{
        perms = [[[FBSDKAccessToken currentAccessToken] permissions] allObjects];
    }, YES);
    return perms;
}

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * alert(facebook.accessToken);
 *
 */

-(id)accessToken
{
    __block NSString * token;
    TiThreadPerformOnMainThread(^{
		token = [[FBSDKAccessToken currentAccessToken] tokenString];
    }, YES);
    return token;
}
//deprecated and removed
-(id)AUDIENCE_NONE
{
    DEPRECATED_REMOVED(@"Facebook.AUDIENCE_NONE",@"5.0.0",@"5.0.0")
    return NULL;
}

-(id)AUDIENCE_ONLY_ME
{
    return [NSNumber numberWithInt:FBSDKDefaultAudienceOnlyMe];
}

-(id)AUDIENCE_FRIENDS
{
    return [NSNumber numberWithInt:FBSDKDefaultAudienceFriends];
}

-(id)AUDIENCE_EVERYONE
{
    return [NSNumber numberWithInt:FBSDKDefaultAudienceEveryone];
}

-(id)ACTION_TYPE_NONE
{
    return [NSNumber numberWithInt:FBSDKGameRequestActionTypeNone];
}

-(id)ACTION_TYPE_SEND
{
    return [NSNumber numberWithInt:FBSDKGameRequestActionTypeSend];
}

-(id)ACTION_TYPE_ASK_FOR
{
    return [NSNumber numberWithInt:FBSDKGameRequestActionTypeAskFor];
}

-(id)ACTION_TYPE_TURN
{
    return [NSNumber numberWithInt:FBSDKGameRequestActionTypeTurn];
}

-(id)FILTER_NONE
{
    return [NSNumber numberWithInt:FBSDKGameRequestFilterNone];
}

-(id)FILTER_APP_USERS
{
    return [NSNumber numberWithInt:FBSDKGameRequestFilterAppUsers];
}

-(id)FILTER_APP_NON_USERS
{
    return [NSNumber numberWithInt:FBSDKGameRequestFilterAppNonUsers];
}

-(id)LOGIN_BEHAVIOR_BROWSER
{
    return [NSNumber numberWithUnsignedInteger:FBSDKLoginBehaviorBrowser];
}

-(id)LOGIN_BEHAVIOR_NATIVE
{
    return [NSNumber numberWithUnsignedInteger:FBSDKLoginBehaviorNative];
}

-(id)LOGIN_BEHAVIOR_SYTEM_ACCOUNT
{
    return [NSNumber numberWithUnsignedInteger:FBSDKLoginBehaviorSystemAccount];
}

-(id)LOGIN_BEHAVIOR_WEB
{
    return [NSNumber numberWithUnsignedInteger:FBSDKLoginBehaviorWeb];
}

-(id)MESSENGER_BUTTON_MODE_RECTANGULAR
{
    return [NSNumber numberWithInt:TiFacebookShareButtonModeRectangular];
}

-(id)MESSENGER_BUTTON_MODE_CIRCULAR
{
    return [NSNumber numberWithInt:TiFacebookShareButtonModeCircular];
}

-(id)MESSENGER_BUTTON_STYLE_BLUE
{
    return [NSNumber numberWithInt:FBSDKMessengerShareButtonStyleBlue];
}

-(id)MESSENGER_BUTTON_STYLE_WHITE
{
    return [NSNumber numberWithInt:FBSDKMessengerShareButtonStyleWhite];
}

-(id)MESSENGER_BUTTON_STYLE_WHITE_BORDERED
{
    return [NSNumber numberWithInt:FBSDKMessengerShareButtonStyleWhiteBordered];
}

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * alert(facebook.expirationDate);
 *
 */

-(id)expirationDate
{
    __block NSDate *expirationDate;
    TiThreadPerformOnMainThread(^{
        expirationDate = [[FBSDKAccessToken currentAccessToken] expirationDate];
    }, YES);
    return expirationDate;
}

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * facebook.permissions = ['publish_stream'];
 * alert(facebook.permissions);
 *
 */
-(void)setPermissions:(id)arg
{
    ENSURE_ARRAY(arg);
    RELEASE_TO_NIL(permissions);
    permissions = [arg retain];
}

/**
 * JS example:
 *
 * facebook.logPurchase(13.37, 'USD');
 *
 */
-(void)logPurchase:(id)args
{
    ENSURE_TYPE(args, NSArray);
    ENSURE_TYPE([args objectAtIndex:0], NSNumber);
    ENSURE_TYPE([args objectAtIndex:1], NSString);
    
    double amount = [TiUtils doubleValue:[args objectAtIndex:0]];
    NSString* currency = [TiUtils stringValue:[args objectAtIndex:1]];
    
    [FBSDKAppEvents logPurchase:amount currency:currency];
}

/**
 * JS example:
 *
 * facebook.logCustomEvent('clappedHands', 54.23, {"CONTENT TYPE": "shoes", "CONTENT ID": "HDFU-8452"});
 *
 */
-(void)logCustomEvent:(id)args
{
    id args0 = [args objectAtIndex:0];
    ENSURE_SINGLE_ARG(args0, NSString);
    NSString* event = args0;

    id args1 = [args count] > 1 ? [args objectAtIndex:1] : nil;
    ENSURE_SINGLE_ARG_OR_NIL(args1, NSNumber);
    double valueToSum = [TiUtils doubleValue:args1];

    id args2 = [args count] > 2 ? [args objectAtIndex:2] : nil;
    ENSURE_SINGLE_ARG_OR_NIL(args2, NSDictionary);
    NSDictionary *parameters = args2;

    [FBSDKAppEvents logEvent:event valueToSum:valueToSum parameters:parameters];
}

/**
 * JS example:
 * facebook.setLoginBehavior(facebook.LOGIN_BEHAVIOR_NATIVE);
 *
 */
-(void)setLoginBehavior:(id)arg
{
    ENSURE_TYPE(arg, NSNumber);
    loginBehavior = [arg unsignedIntegerValue];
}

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
 *    }
 *    else if (e.cancelled) {
 *      // user cancelled logout
 *    }
 *    else {
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

-(void)authorize:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSNumber);
    BOOL allowUI = args == nil ? YES : NO;
    NSArray *permissions_ = permissions == nil ? [NSArray array] : permissions;
    FBSDKLoginManager *loginManager = [[[FBSDKLoginManager alloc] init] autorelease];
    [loginManager setLoginBehavior:loginBehavior];
    TiThreadPerformOnMainThread(^{
        [loginManager logInWithReadPermissions: permissions_ fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                //DebugLog(@"[ERROR] Process error.");
                [self fireLogin:nil cancelled:NO withError:error];
            } else if (result.isCancelled) {
                //DebugLog(@"[ERROR] User cancelled");
                [self fireLogin:nil cancelled:YES withError:nil];
            } else {
                //DebugLog(@"[INFO] Logged in");
            }
        }];
    }, YES);
}

// We have this function so that you can set up your listeners and permissions whenever you want
// Call initialize when ready, you will get a login event if there was a cached token
// else loggedIn will be false
-(void)initialize:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSNumber);
    if (args != nil) {
        DEPRECATED_REMOVED(@"Facebook.initialize.timeout", @"5.0.0", @"5.0.0");
    }
    TiThreadPerformOnMainThread(^{
        [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
        NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(logEvents:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [nc addObserver:self selector:@selector(accessTokenChanged:) name:FBSDKAccessTokenDidChangeNotification object:nil];
		[nc addObserver:self selector:@selector(activateApp:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [nc addObserver:self selector:@selector(currentProfileChanged:) name:FBSDKProfileDidChangeNotification object:nil];
        
        loginBehavior = FBSDKLoginBehaviorBrowser;

        if ([FBSDKAccessToken currentAccessToken] == nil) {
            [self activateApp];
        } else {
            [self handleRelaunch];
        }
    }, YES);
}

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * facebook.logout();
 *
 */
-(void)logout:(id)args
{
    TiThreadPerformOnMainThread(^{
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logOut];
        RELEASE_TO_NIL(loginManager)
    }, NO);
}

//presents share dialog using existing facebook app. If no facebook app installed, does nothing.
-(void)presentShareDialog:(id)args
{
    id params = [args objectAtIndex:0];
    ENSURE_SINGLE_ARG(params, NSDictionary);
        
    TiThreadPerformOnMainThread(^{
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:[params objectForKey:@"link"]];
        content.contentDescription = [params objectForKey:@"description"];
        if ([params objectForKey:@"name"] != nil) {
            DEPRECATED_REPLACED_REMOVED(@"Facebook.presentShareDialog.name", @"5.0.0", @"5.0.0", @"Titanium.Facebook.presentShareDialog.title");
        }
        if ([params objectForKey:@"title"] != nil){
            content.contentTitle = [params objectForKey:@"title"];
        }
        if ([params objectForKey:@"caption"] != nil) {
            DEPRECATED_REMOVED(@"Facebook.presentShareDialog.caption", @"5.0.0", @"5.0.0");
        }
        content.imageURL = [NSURL URLWithString:[params objectForKey:@"picture"]];
        [FBSDKShareDialog showFromViewController:nil
                                     withContent:content
                                        delegate:self];
    }, NO);
}

// Presents a messenger dialog to share content using the Facebook messenger
-(void)presentMessengerDialog:(id)args
{
    id params = [args objectAtIndex:0];
    ENSURE_SINGLE_ARG(params, NSDictionary);
   
    TiThreadPerformOnMainThread(^{
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        [content setContentURL:[NSURL URLWithString:[params objectForKey:@"link"]]];
        [content setContentDescription:[params objectForKey:@"description"]];
        [content setContentTitle:[params objectForKey:@"title"]];
        [content setPlaceID:[params objectForKey:@"placeID"]];
        [content setRef:[params objectForKey:@"referal"]];
        [content setImageURL:[NSURL URLWithString:[params objectForKey:@"picture"]]];
        
        id to = [params objectForKey:@"to"];
        ENSURE_TYPE_OR_NIL(to, NSArray);
        
        if (to != nil) {
            [content setPeopleIDs:to];
        }
        
        [FBSDKMessageDialog showWithContent:content delegate:self];
    }, NO);
}

// Shares images, GIFs and videos to the messenger
-(void)shareMediaToMessenger:(id)args
{
    id params = [args objectAtIndex:0];
    ENSURE_SINGLE_ARG(params, NSDictionary);

    id media = [params valueForKey:@"media"];
    ENSURE_TYPE(media, TiBlob);

    TiThreadPerformOnMainThread(^{
        FBSDKMessengerShareOptions *options = [[FBSDKMessengerShareOptions alloc] init];
        options.metadata = [params objectForKey:@"metadata"];
        options.sourceURL = [NSURL URLWithString:[params objectForKey:@"link"]];
        options.renderAsSticker = [TiUtils boolValue:[params objectForKey:@"renderAsSticker"] def:NO];
        
        if ([[media mimeType]  isEqual: @"image/gif"]) {
            [FBSDKMessengerSharer shareAnimatedGIF:[NSData dataWithContentsOfFile:[(TiBlob*)media path]] withOptions:options];
        } else if ([[media mimeType] containsString:@"image/"]) {
            [FBSDKMessengerSharer shareImage:[TiUtils image:media proxy:self] withOptions:options];
        } else if ([[media mimeType] containsString:@"video/"]) {
            [FBSDKMessengerSharer shareVideo:[NSData dataWithContentsOfFile:[(TiBlob*)media path]] withOptions:options];
        } else {
            NSLog(@"[ERROR] Unknown media provided. Allowed media: Image, GIF and video.");
        }
    }, NO);
}

//presents share dialog using web dialog. Useful for devices with no facebook app installed.
-(void)presentWebShareDialog:(id)args
{
    DEPRECATED_REPLACED_REMOVED(@"Facebook.presentWebShareDialog", @"5.0.0", @"5.0.0", @"Titanium.Facebook.presentShareDialog");
}

// Presents an invite dialog using the native application. 
-(void)presentInviteDialog:(id)args
{
    id params = [args objectAtIndex:0];
    ENSURE_SINGLE_ARG(params, NSDictionary);

    TiThreadPerformOnMainThread(^{
        FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
        [content setAppLinkURL:[NSURL URLWithString:[params objectForKey:@"appLink"]]];
        [content setAppInvitePreviewImageURL:[NSURL URLWithString:[params objectForKey:@"appPreviewImageLink"]]];
        
        [FBSDKAppInviteDialog showFromViewController:nil withContent:content delegate:self];
    }, NO);
}

//presents game request dialog.
-(void)presentSendRequestDialog:(id)args
{
    id params = [args objectAtIndex:0];
    ENSURE_SINGLE_ARG(params, NSDictionary);
    NSString *message = [params objectForKey:@"message"];
    NSString *title = [params objectForKey:@"title"];
    NSArray *to = [params objectForKey:@"to"];
    NSArray *recipients = [params objectForKey:@"recipients"];
    if (to != nil) {
        DEPRECATED_REPLACED_REMOVED(@"Facebook.sendRequestDialog.to", @"5.0.0", @"5.0.0", @"Titanium.Facebook.sendRequestDialog.recipients");
    }
    NSArray *recipientSuggestions = [params objectForKey:@"recipientSuggestions"];
    FBSDKGameRequestFilter filters = [TiUtils intValue:[params objectForKey:@"filters"]];
    NSString *objectID = [params objectForKey:@"objectID"];
    NSString *data = [params objectForKey:@"data"];
    FBSDKGameRequestActionType actionType = [TiUtils intValue:[params objectForKey:@"actionType"]];

    TiThreadPerformOnMainThread(^{
        FBSDKGameRequestContent *gameRequestContent = [[[FBSDKGameRequestContent alloc] init] autorelease];
        gameRequestContent.message = message;
        gameRequestContent.recipients = recipients;
        gameRequestContent.objectID = objectID;
        gameRequestContent.data = data;
        gameRequestContent.recipientSuggestions = recipientSuggestions;
        gameRequestContent.filters = filters;
        gameRequestContent.actionType = actionType;
        [FBSDKGameRequestDialog showWithContent:gameRequestContent delegate:self];
    }, NO);
}

-(void)refreshPermissionsFromServer:(id)args
{
    TiThreadPerformOnMainThread(^{
        [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             [self fireEvent:@"tokenUpdated" withObject:nil];
        }];
    }, NO);
}

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * ...
 * facebook.requestNewReadPermissions(['read_stream','user_hometown', etc...], function(e){
 *     if(e.success){
 *         facebook.requestWithGraphPath(...);
 *     } else if (e.cancelled){
 *         .....
 *     } else {
 *         Ti.API.debug('Failed authorization due to: ' + e.error);
 *     }
 * });
 */
-(void)requestNewReadPermissions:(id)args
{
    id readPermissions = [args objectAtIndex:0];
    ENSURE_ARRAY(readPermissions);
    id arg1 = [args objectAtIndex:1];
    ENSURE_SINGLE_ARG(arg1, KrollCallback);
    KrollCallback *callback = arg1;
    FBSDKLoginManager *loginManager = [[[FBSDKLoginManager alloc] init] autorelease];
    TiThreadPerformOnMainThread(^{
        [loginManager logInWithReadPermissions: readPermissions fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            bool success = NO;
            bool cancelled = NO;
            NSString * errorString = nil;
            long code = 0;
            if (error) {
                code = [error code];
                errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
                if (errorString == nil) {
                    errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];
                }
            }
            else if (result.isCancelled) {
                cancelled = YES;
            } else {
                success = YES;
            }
            NSNumber * errorCode = [NSNumber numberWithInteger:code];
            NSDictionary * propertiesDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             [NSNumber numberWithBool:success],@"success",
                                             [NSNumber numberWithBool:cancelled],@"cancelled",
                                             errorCode,@"code", errorString,@"error", nil];
            
            KrollEvent * invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:propertiesDict thisObject:self];
            [[callback context] enqueue:invocationEvent];
            [invocationEvent release];
            [propertiesDict release];
        }];
    }, NO);
}

/**
 * JS example:
 *
 * var facebook = require('facebook');
 * ...
 * facebook.requestNewPublishPermissions(['read_stream','user_hometown', etc...], fb.audienceFriends, function(e){
 *     if(e.success){
 *         facebook.requestWithGraphPath(...);
 *     } else if (e.cancelled){
 *         .....
 *     } else {
 *         Ti.API.debug('Failed authorization due to: ' + e.error);
 *     }
 * });
 */
-(void)requestNewPublishPermissions:(id)args
{
    id writePermissions = [args objectAtIndex:0];
    ENSURE_ARRAY(writePermissions);
    id arg1 = [args objectAtIndex:1];
    ENSURE_SINGLE_ARG(arg1, NSNumber);
    FBSDKDefaultAudience defaultAudience = [TiUtils intValue:arg1];
    id arg2 = [args objectAtIndex:2];
    ENSURE_SINGLE_ARG(arg2, KrollCallback);
    KrollCallback *callback = arg2;
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    loginManager.defaultAudience = defaultAudience;
    TiThreadPerformOnMainThread(^{
        [loginManager logInWithPublishPermissions:writePermissions fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            bool success = NO;
            bool cancelled = NO;
            NSString * errorString = nil;
            long code = 0;
            if (error) {
                code = [error code];
                errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
                if (errorString == nil) {
                    errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];
                }
            }
            else if (result.isCancelled) {
                cancelled = YES;
            } else {
                success = YES;
            }
            NSNumber * errorCode = [NSNumber numberWithInteger:code];
            NSDictionary * propertiesDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             [NSNumber numberWithBool:success],@"success",
                                             [NSNumber numberWithBool:cancelled],@"cancelled",
                                             errorCode,@"code", errorString,@"error", nil];
            
            KrollEvent * invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:propertiesDict thisObject:self];
            [[callback context] enqueue:invocationEvent];
            [invocationEvent release];
            [propertiesDict release];
        }];
    }, YES);
}

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
-(void)requestWithGraphPath:(id)args
{
    id path = [args objectAtIndex:0];
    ENSURE_SINGLE_ARG(path, NSString);
    id args1 = [args objectAtIndex:1];
    ENSURE_SINGLE_ARG_OR_NIL(args1, NSMutableDictionary);
    NSMutableDictionary *params = args1;
    id httpMethod = [args objectAtIndex:2];
    ENSURE_SINGLE_ARG(httpMethod, NSString);
    id args3 = [args objectAtIndex:3];
    ENSURE_SINGLE_ARG(args3, KrollCallback);
    KrollCallback *callback = args3;
    for(NSString *key in params) {
        id value = [params objectForKey:key];
        if ([value isKindOfClass:[TiBlob class]]) {
            TiBlob *blob = (TiBlob*)value;
            [params setObject:[blob data] forKey:key];
        }
    }
    TiThreadPerformOnMainThread(^{
        if ([FBSDKAccessToken currentAccessToken]) {
            [[[FBSDKGraphRequest alloc] initWithGraphPath:path parameters:params HTTPMethod:httpMethod]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 NSDictionary * returnedObject;
                 BOOL success;
                 if (!error) {
                     success = YES;
                     //for parity with android, have to stringify json object
                     NSString *resultString = [TiUtils jsonStringify:result];
                     returnedObject = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       resultString,@"result", NUMBOOL(success), @"success",
                                       path, @"path",nil];
                 } else {
                     //DebugLog(@"requestWithGraphPath error for path, %@", path);
                     success = NO;
                     NSString *errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
                     if (errorString == nil) {
                         errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];
                     }
                     returnedObject = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       NUMBOOL(success), @"success",
                                       path, @"path", errorString, @"error", nil];
                     
                 }
                 KrollEvent * invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:returnedObject thisObject:self];
                 [[callback context] enqueue:invocationEvent];
                 [invocationEvent release];
                 [returnedObject release];
             }];
        }
    }, NO);
}

-(void)fetchDeferredAppLink:(id)args
{
    ENSURE_TYPE(args, NSArray);
    ENSURE_TYPE([args objectAtIndex:0], KrollCallback);
    KrollCallback *callback = [args objectAtIndex:0];

    TiThreadPerformOnMainThread(^{
        [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
            NSDictionary* returnedObject;

            if (url) {
                returnedObject = [[NSDictionary alloc] initWithObjectsAndKeys:[url absoluteURL],@"url", NUMBOOL(YES),@"success", nil];
            } else {
                NSString *errorString = @"An error occurred. Please try again.";
                if (error != nil) {
                    errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
                    if (errorString == nil) {
                        errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];
                    }
                }
                returnedObject = [[NSDictionary alloc] initWithObjectsAndKeys: errorString,@"error", NUMBOOL(NO),@"success", nil];
            }

            KrollEvent * invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:returnedObject thisObject:self];
            [[callback context] enqueue:invocationEvent];
            [invocationEvent release];
            [returnedObject release];
        }];
    }, YES);
}


#pragma mark Listener work

-(void)fireLogin:(id)result cancelled:(BOOL)cancelled withError:(NSError *)error
{
    BOOL success = (result != nil);
    long code = [error code];
    if ((code == 0) && !success) {
        code = -1;
    }
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(cancelled),@"cancelled",
                                  NUMBOOL(success),@"success",
                                  NUMLONG(code),@"code",nil];
    if(error != nil){
        NSString *errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
        if (errorString == nil) {
            errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];
        }
        [event setObject:errorString forKey:@"error"];
    }
    
    if(result != nil){
        FBSDKProfile *profile = (FBSDKProfile*)result;
        NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        profile.userID, @"userID",
                                        profile.firstName, @"firstName",
                                        profile.middleName == nil ? @"":profile.middleName, @"middleName",
                                        profile.lastName, @"lastName",
                                        profile.name, @"name",
                                        [profile.linkURL absoluteString], @"linkURL",
                                        nil];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
        NSString *resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [event setObject:resultString forKey:@"data"];
        if (uid != nil){
            [event setObject:uid forKey:@"uid"];
        }
    }
    [self fireEvent:@"login" withObject:event];
}

#pragma mark Listeners

-(void)logEvents:(NSNotification *)notification
{
    [FBSDKAppEvents activateApp];
}

-(void)accessTokenChanged:(NSNotification *)notification
{
    FBSDKAccessToken *token = notification.userInfo[FBSDKAccessTokenChangeNewKey];
    if (token == nil) {
        [self fireEvent:@"logout"];
    }
}

- (void)currentProfileChanged:(NSNotification *)notification
{
    FBSDKProfile *profile = notification.userInfo[FBSDKProfileChangeNewKey];
    if (profile != nil) {
        uid = [profile userID];
        [self fireLogin:profile cancelled:NO withError:nil];
    }
}

#pragma mark Share dialog delegates
-(void)sharer: (id<FBSDKSharing>)sharer didCompleteWithResults: (NSDictionary *)results
{
    [self fireDialogEventWithName:TiFacebookEventTypeShareCompleted success:YES andError:nil cancelled:NO];
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [self fireDialogEventWithName:TiFacebookEventTypeShareCompleted success:NO andError:error cancelled:NO];
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    [self fireDialogEventWithName:TiFacebookEventTypeShareCompleted success:NO andError:nil cancelled:YES];
}

#pragma Game request delegates
-(void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didCompleteWithResults:(NSDictionary *)results
{
    [self fireDialogEventWithName:TiFacebookEventTypeRequestDialogCompleted success:YES andError:nil cancelled:NO];
}

-(void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didFailWithError:(NSError *)error
{
    [self fireDialogEventWithName:TiFacebookEventTypeRequestDialogCompleted success:NO andError:error cancelled:NO];
}

-(void)gameRequestDialogDidCancel:(FBSDKGameRequestDialog *)gameRequestDialog
{
    [self fireDialogEventWithName:TiFacebookEventTypeRequestDialogCompleted success:NO andError:nil cancelled:YES];
}

#pragma mark Invite dialog delegates
-(void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    [self fireDialogEventWithName:TiFacebookEventTypeInviteCompleted success:YES andError:error cancelled:NO];
}

-(void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    BOOL cancelled = NO;
    if (results) {
        cancelled = [[results valueForKey:@"completionGesture"] isEqualToString:@"cancel"];
    }
    [self fireDialogEventWithName:TiFacebookEventTypeInviteCompleted success:!cancelled andError:nil cancelled:cancelled];
}

-(void)fireDialogEventWithName:(NSString*)name success:(BOOL)success andError:(NSError*)error cancelled:(BOOL)cancelled
{
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
        @"cancelled": NUMBOOL(cancelled),
        @"success": NUMBOOL(success)}
    ];
    
    if (error) {
        NSString *errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
        if (errorString == nil) {
            errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];
        }
        [event setValue:errorString forKey:@"error"];
    }
    
    if ([self _hasListeners:name]) {
        [self fireEvent:name withObject:event];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[[[[kv[0] stringByRemovingPercentEncoding] componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""]] = val;
    }
    return params;
}
@end
