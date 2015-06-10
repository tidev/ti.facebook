/**
 * FacebookIOS
 *
 * Copyright (c) 2014 by Mark Mokryn, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

BOOL temporarilySuspended = NO;

@implementation FacebookModule

#pragma mark Internal

NSTimeInterval meRequestTimeout = 180.0;

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
    RELEASE_TO_NIL(stateListeners);
    RELEASE_TO_NIL(permissions);
    RELEASE_TO_NIL(uid);
    [super dealloc];
}

-(BOOL)handleRelaunch
{
    NSDictionary *launchOptions = [[TiApp app] launchOptions];
    if (launchOptions!=nil) {
        NSString *urlString = [launchOptions objectForKey:@"url"];
        NSString *sourceApplication = [launchOptions objectForKey:@"source"];
        if (urlString != nil) {
            [FBSession.activeSession setStateChangeHandler:
             ^(FBSession *session, FBSessionState state, NSError *error) {
                 [self sessionStateChanged:session state:state error:error];
             }];
            return [FBAppCall handleOpenURL:[NSURL URLWithString:urlString] sourceApplication:sourceApplication];
        } else {
            return NO;
        }
    }
    return NO;
}

-(void)resumed:(id)note
{
    NSLog(@"[DEBUG] facebook resumed");
    if (!temporarilySuspended) {
        [self handleRelaunch];
    }
    [FBAppEvents activateApp];
}

-(void)activateApp:(NSNotification *)notification
{
    [FBAppCall handleDidBecomeActive];
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
    
    TiThreadPerformOnMainThread(^{
        [FBSession.activeSession close];
    }, NO);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super shutdown:sender];
}

-(void)suspend:(id)sender
{
//    NSLog(@"[DEBUG] facebook suspend");
    temporarilySuspended = YES; // to avoid crazy logic if user rejects a call or SMS
}

-(void)paused:(id)sender
{
//    NSLog(@"[DEBUG] facebook paused");
    temporarilySuspended = NO; // Since we are guaranteed full resume logic following this
}

#pragma mark Auth Internals

- (void)populateUserDetails {
    TiThreadPerformOnMainThread(^{
        if (FBSession.activeSession.isOpen) {
            FBRequestConnection *connection = [[[FBRequestConnection alloc] initWithTimeout:meRequestTimeout] autorelease];
            connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
            | FBRequestConnectionErrorBehaviorRetry;
            
            [connection addRequest:[FBRequest requestForMe]
                 completionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                     RELEASE_TO_NIL(uid);
                     if (!error) {
                         uid = [[user objectForKey:@"id"] copy];
                         [self fireLogin:user cancelled:NO withError:nil];
                     } else {
                         // Error on /me call
                         // In a future rev perhaps use stored user info
                         // But for now bail out
                         switch(error.fberrorCategory) {
                             case FBErrorCategoryAuthenticationReopenSession:
                                 // will be handled by authentication error handling
                                 DebugLog(@"[ERROR] /me FBErrorCategoryAuthenticationReopenSession");
                                 return;
                                 break;
                             case FBErrorCategoryInvalid:
                             case FBErrorCategoryServer:
                             case FBErrorCategoryThrottling:
                             case FBErrorCategoryFacebookOther:
                             case FBErrorCategoryBadRequest:
                             case FBErrorCategoryPermissions:
                             case FBErrorCategoryRetry:
                             case FBErrorCategoryUserCancelled:
                             default:
                                 DebugLog(@"[ERROR] /me error.description: ", error.description);
                                 TiThreadPerformOnMainThread(^{
                                     [FBSession.activeSession closeAndClearTokenInformation];
                                 }, YES);
                                 // We set error to nil since any useful message was already surfaced
                                 [self fireLogin:nil cancelled:NO withError:error];
                                 break;
                         }
                     }
                 }];
            [connection start];
        }
    }, NO);
}


- (void)handleAuthError:(NSError *)error
{
    BOOL cancelled = NO;
    NSString *errorMessage;
    long code = [error code];
    if (code == 0) {
        code = -1;
    }
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
        // Error requires people using you app to make an action outside your app to recover
        errorMessage = [FBErrorUtility userMessageForError:error];
    } else {
        // You need to find more information to handle the error within your app
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            //The user refused to log in into your app, either ignore or...
            cancelled = YES;
            errorMessage = @"User cancelled the login process.";
        } else {
            // All other errors that can happen need retries
            // Show the user a generic error message
            errorMessage = @"Please login again";
        }
    }
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(cancelled),@"cancelled",
                                  NUMBOOL(NO),@"success",
                                  NUMLONG(code),@"code",nil];
    
    [event setObject:errorMessage forKey:@"error"];
    [self fireEvent:@"login" withObject:event];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    RELEASE_TO_NIL(uid);
    if (error) {
        //DebugLog(@"[ERROR] sessionStateChanged error");
        [self handleAuthError:error];
    } else {
        switch (state) {
            case FBSessionStateOpen:
                //NSLog(@"[DEBUG] FBSessionStateOpen");
                [self populateUserDetails];
                break;
            case FBSessionStateClosed:
            case FBSessionStateClosedLoginFailed:
                //NSLog(@"[DEBUG] facebook session closed");
                [self fireEvent:@"logout"];
                break;
            default:
                //NSLog(@"[DEBUG] sessionStateChanged default case reached, state %d", state);
                break;
        }
    }
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
    return NUMBOOL(FBSession.activeSession.state == FBSessionStateOpenTokenExtended || FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded);
}

-(id)canPresentShareDialog
{
    return NUMBOOL([FBDialogs canPresentShareDialog]);
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
        perms = FBSession.activeSession.permissions;
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
        token = FBSession.activeSession.accessTokenData.accessToken;
    }, YES);
    
    return token;
}

-(id)AUDIENCE_NONE
{
    return [NSNumber numberWithInt:FBSessionDefaultAudienceNone];
}

-(id)AUDIENCE_ONLY_ME
{
    return [NSNumber numberWithInt:FBSessionDefaultAudienceOnlyMe];
}

-(id)AUDIENCE_FRIENDS
{
    return [NSNumber numberWithInt:FBSessionDefaultAudienceFriends];
}

-(id)AUDIENCE_EVERYONE
{
    return [NSNumber numberWithInt:FBSessionDefaultAudienceEveryone];
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
        expirationDate = FBSession.activeSession.accessTokenData.expirationDate;
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
 * facebook.logCustomEvent('clappedHands');
 *
 */
-(void)logCustomEvent:(id)args
{
    ENSURE_SINGLE_ARG(args, NSString);
    NSString* event = [args objectAtIndex:0];
    [FBAppEvents logEvent:event];
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

    TiThreadPerformOnMainThread(^{
        NSArray *permissions_ = permissions == nil ? [NSArray array] : permissions;
        BOOL sessionOpened = [FBSession openActiveSessionWithReadPermissions: allowUI ? permissions_ : FBSession.activeSession.permissions allowLoginUI:allowUI completionHandler:
                                  ^(FBSession *session,
                                    FBSessionState state, NSError *error) {
                                      [self sessionStateChanged:session state:state error:error];
            }];
            NSLog(@"[DEBUG] openActiveSessionWithReadPermissions returned: %d", sessionOpened);
        
    }, NO);
}

// We have this function so that you can set up your listeners and permissions whenever you want
// Call initialize when ready, you will get a login event if there was a cached token
// else loggedIn will be false
-(void)initialize:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSNumber);
    double timeoutInMs = [TiUtils intValue:args def:0];
    if (timeoutInMs == 0) {
        meRequestTimeout = 180.0;
    } else {
        meRequestTimeout = (double)timeoutInMs / 1000.0;
    }
    
    TiThreadPerformOnMainThread(^{
        NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(activateApp:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // Start with logged-in state, guaranteed no login UX is fired since logged-in
            //skipMeCall = [FBSession.activeSession.accessTokenData.accessToken isEqualToString:savedToken];
            [self authorize:NUMBOOL(YES)];
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
    RELEASE_TO_NIL(uid);
    TiThreadPerformOnMainThread(^{
        [FBSession.activeSession closeAndClearTokenInformation];
    }, NO);
}

//presents share dialog using existing facebook app. If no facebook app installed, does nothing.
-(void)presentShareDialog:(id)args
{
    id params = [args objectAtIndex:0];
    ENSURE_SINGLE_ARG(params, NSDictionary);
        
    TiThreadPerformOnMainThread(^{
        [FBDialogs presentShareDialogWithLink:[NSURL URLWithString:[params objectForKey:@"link"]] name:[params objectForKey:@"name"] caption:[params objectForKey:@"caption"] description:[params objectForKey:@"description"] picture:[NSURL URLWithString:[params objectForKey:@"picture"]] clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          BOOL success = NO;
                                          BOOL cancelled = NO;
                                          NSString *errorDescription = @"";
                                          if (error) {
                                              errorDescription = [FBErrorUtility userMessageForError:error];
                                          } else {
                                              success = YES;
                                              cancelled = NO;
                                              if ([results objectForKey:@"didComplete"] && [[results objectForKey:@"completionGesture"] isEqualToString:@"cancel"]) {
                                                  cancelled = YES;
                                                  success = NO;
                                              }

                                          }
                                          NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                        NUMBOOL(cancelled),@"cancelled",
                                                                        NUMBOOL(success),@"success",
                                                                        [error description], @"error", nil];
                                          [self fireEvent:@"shareCompleted" withObject:event];
                                      }];
    }, NO);
}
//presents share dialog using web dialog. Useful for devices with no facebook app installed.
-(void)presentWebShareDialog:(id)args
{
    id params = [args objectAtIndex:0];
    ENSURE_SINGLE_ARG(params, NSDictionary);
    TiThreadPerformOnMainThread(^{
        [FBWebDialogs presentFeedDialogModallyWithSession:FBSession.activeSession
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      BOOL cancelled = NO;
                                                      BOOL success = NO;
                                                      NSString *errorDescription = @"";
                                                      if (error) {
                                                          errorDescription = [FBErrorUtility userMessageForError:error];
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              cancelled = YES;
                                                              success = NO;
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  cancelled = YES;
                                                                  success = NO;
                                                              } else {
                                                                  cancelled = NO;
                                                                  success = YES;
                                                              }
                                                          }
                                                      }
                                                      NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                    NUMBOOL(cancelled),@"cancelled",
                                                                                    NUMBOOL(success),@"success",
                                                                                    errorDescription,@"error",nil];
                                                      [self fireEvent:@"shareCompleted" withObject:event];
                                                  }];
    }, NO);
}

//presents game request dialog.
-(void)presentSendRequestDialog:(id)args
{
    id params = [args objectAtIndex:0];
    ENSURE_SINGLE_ARG(params, NSDictionary);
    NSString *message = [params objectForKey:@"message"];
    NSString *title = [params objectForKey:@"title"];
    NSString *to = [params objectForKey:@"to"];
    id data = [params objectForKey:@"data"];
    ENSURE_SINGLE_ARG_OR_NIL(data, NSDictionary);
    NSMutableDictionary *additionalParams = nil;
    if (data != nil) {
        additionalParams = [NSMutableDictionary dictionaryWithDictionary:data];
        if (to != nil) {
            [additionalParams setObject:to forKey:@"to"];
        }
    }
    else {
        if (to != nil) {
            additionalParams = [NSMutableDictionary dictionaryWithObject:to forKey:@"to"];
        }
    }


    TiThreadPerformOnMainThread(^{
        [FBWebDialogs presentRequestsDialogModallyWithSession:FBSession.activeSession
                                                      message:message title:title parameters:additionalParams
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      BOOL cancelled = NO;
                                                      BOOL success = NO;
                                                      NSString *errorDescription = @"";
                                                      NSDictionary *urlParams = nil;
                                                      if (error) {
                                                          errorDescription = [FBErrorUtility userMessageForError:error];
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              cancelled = YES;
                                                              success = NO;
                                                          } else {
                                                              // Handle the publish feed callback
                                                              urlParams = [self parseURLParams:[resultURL query]];
                                                              if (![urlParams valueForKey:@"request"]) {
                                                                  // User cancelled.
                                                                  cancelled = YES;
                                                                  success = NO;
                                                              } else {
                                                                  cancelled = NO;
                                                                  success = YES;
                                                              }
                                                          }
                                                      }
                                                      NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                    NUMBOOL(cancelled),@"cancelled",
                                                                                    NUMBOOL(success),@"success",
                                                                                    errorDescription,@"error",
                                                                                    urlParams,@"data",nil];
                                                      [self fireEvent:@"requestDialogCompleted" withObject:event];
                                                  }];
    }, NO);
}

-(void)refreshPermissionsFromServer:(id)args
{
    TiThreadPerformOnMainThread(^{
        [FBSession.activeSession refreshPermissionsWithCompletionHandler:
         ^(FBSession *session, NSError *error) {
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
    
    TiThreadPerformOnMainThread(^{
        [FBSession.activeSession requestNewReadPermissions:readPermissions
                                         completionHandler:^(FBSession *session, NSError *error) {
                                             bool success = (error == nil);
                                             bool cancelled = NO;
                                             NSString * errorString = nil;
                                             long code = 0;
                                             if(!success) {
                                                 code = [error code];
                                                 if (code == 0) {
                                                     code = -1;
                                                 }
                                                 if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
                                                     cancelled = YES;
                                                 } else if (error.fberrorShouldNotifyUser) {
                                                     errorString = error.fberrorUserMessage;
                                                 } else {
                                                     errorString = @"An unexpected error";
                                                 }
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
    FBSessionDefaultAudience defaultAudience = [TiUtils intValue:arg1];
    id arg2 = [args objectAtIndex:2];
    ENSURE_SINGLE_ARG(arg2, KrollCallback);
    KrollCallback *callback = arg2;
    
    TiThreadPerformOnMainThread(^{
        [FBSession.activeSession requestNewPublishPermissions:writePermissions
                                              defaultAudience:defaultAudience
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                bool success = (error == nil);
                                                bool cancelled = NO;
                                                NSString * errorString = nil;
                                                long code = 0;
                                                if(!success) {
                                                    code = [error code];
                                                    if (code == 0) {
                                                        code = -1;
                                                    }
                                                    if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
                                                        cancelled = YES;
                                                    } else if (error.fberrorShouldNotifyUser) {
                                                        errorString = error.fberrorUserMessage;
                                                    } else {
                                                        errorString = @"An unexpected error";
                                                    }
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
        FBRequestConnection *connection = [[[FBRequestConnection alloc] init] autorelease];
        connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
        | FBRequestConnectionErrorBehaviorAlertUser
        | FBRequestConnectionErrorBehaviorRetry;
        
        FBRequest *request = [FBRequest requestWithGraphPath:path
                                                  parameters:params
                                                  HTTPMethod:httpMethod];
        
        [connection addRequest:request
             completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
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
                     DebugLog(@"requestWithGraphPath error for path, %@", path);
                     success = NO;
                     NSString * errorString;
                     if (error.fberrorShouldNotifyUser) {
                         errorString = error.fberrorUserMessage;
                     } else {
                         switch(error.fberrorCategory) {
                             case FBErrorCategoryAuthenticationReopenSession:
                                 // will be handled by authentication error handling
                                 DebugLog(@"[ERROR] requestWithGraphPath FBErrorCategoryAuthenticationReopenSession");
                                 errorString = @"authentication error";
                                 break;
                             case FBErrorCategoryInvalid:
                             case FBErrorCategoryServer:
                             case FBErrorCategoryThrottling:
                             case FBErrorCategoryFacebookOther:
                             case FBErrorCategoryRetry:
                             case FBErrorCategoryUserCancelled:
                                 errorString = @"Retry";
                                 break;
                             case FBErrorCategoryBadRequest:
                                 errorString = @"Bad request";
                                 break;
                             case FBErrorCategoryPermissions:
                                 errorString = @"Permission error";
                                 break;
                             default:
                                 DebugLog(@"[ERROR] requestWithGraphPath error.description: ", error.description);
                                 errorString = @"An unexpected error";
                                 break;
                         }
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
        [connection start];
    }, NO);
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
        NSString * errorMessage = @"OTHER:";
        if (error.fberrorShouldNotifyUser) {
            if ([[error userInfo][FBErrorLoginFailedReason] isEqualToString:FBErrorLoginFailedReasonSystemDisallowedWithoutErrorValue]) {
                // Show a different error message
                errorMessage = @"Go to Settings > Facebook and turn ON ";
            } else {
                // If the SDK has a message for the user, surface it.
                errorMessage = error.fberrorUserMessage;
            }
        } else {
            // For simplicity, this sample treats other errors blindly, but you should
            // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
            errorMessage = [errorMessage stringByAppendingFormat:@" %@", (NSString *) error];
        }
        [event setObject:errorMessage forKey:@"error"];
    }
    
    if(result != nil){
        NSString *resultString = [TiUtils jsonStringify:result];
        [event setObject:resultString forKey:@"data"];
        if (uid != nil){
            [event setObject:uid forKey:@"uid"];
        }
    }
    [self fireEvent:@"login" withObject:event];
}

#pragma mark Listeners

-(void)addListener:(id<TiFacebookStateListener>)listener
{
    if (stateListeners==nil){
        stateListeners = [[NSMutableArray alloc]init];
    }
    [stateListeners addObject:listener];
}

-(void)removeListener:(id<TiFacebookStateListener>)listener
{
    if (stateListeners!=nil){
        [stateListeners removeObject:listener];
        if ([stateListeners count]==0){
            RELEASE_TO_NIL(stateListeners);
        }
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
