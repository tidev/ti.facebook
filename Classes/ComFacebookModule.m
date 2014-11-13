/**
 * FacebookIOS
 *
 * Created by Mark Mokryn
 * Copyright (c) 2014 Your Company. All rights reserved.
 */

#import "ComFacebookModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

BOOL temporarilySuspended = NO;

@implementation ComFacebookModule

#pragma mark Internal

BOOL nativeLogin = false;

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"7ac4bcd0-eb97-4e43-89fc-03f7f4d0a2a0";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.facebook";
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
    if (launchOptions!=nil)
    {
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
    NSLog(@"[DEBUG] startup: running FB sdk version: %@", [FBSettings sdkVersion]);
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
    NSLog(@"[DEBUG] facebook shutdown");
    
    TiThreadPerformOnMainThread(^{
        [FBSession.activeSession close];
    }, NO);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super shutdown:sender];
}

-(void)suspend:(id)sender
{
    NSLog(@"[DEBUG] facebook suspend");
    temporarilySuspended = YES; // to avoid crazy logic if user rejects a call or SMS
}

-(void)paused:(id)sender
{
    NSLog(@"[DEBUG] facebook paused");
    temporarilySuspended = NO; // Since we are guaranteed full resume logic following this
}

#pragma mark Auth Internals

- (void)populateUserDetails {
    TiThreadPerformOnMainThread(^{
        if (FBSession.activeSession.isOpen) {
            FBRequestConnection *connection = [[FBRequestConnection alloc] init];
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
                                 NSLog(@"[ERROR] /me FBErrorCategoryAuthenticationReopenSession");
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
                                 NSLog(@"[ERROR] /me error.description: ", error.description);
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
        NSLog(@"[ERROR] sessionStateChanged error");
        [self handleAuthError:error];
    } else {
        switch (state) {
            case FBSessionStateOpen:
                NSLog(@"[DEBUG] FBSessionStateOpen");
                [session refreshPermissionsWithCompletionHandler:
                 ^(FBSession *session, NSError *error) {
                     if (error != nil) {
                         NSLog(@"[DEBUG] refreshPermissionsWithCompletionHandler error");
                         TiThreadPerformOnMainThread(^{
                             [FBSession.activeSession closeAndClearTokenInformation];
                         }, YES);
                         [self fireLogin:nil cancelled:NO withError:error];
                     } else {
                        [self populateUserDetails];
                     }
                 }];
                break;
            case FBSessionStateClosed:
            case FBSessionStateClosedLoginFailed:
                NSLog(@"[DEBUG] facebook session closed");
                [self fireEvent:@"logout"];
                break;
            default:
                NSLog(@"[DEBUG] sessionStateChanged default case reached, state %d", state);
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
    NSLog(@"[DEBUG] BSession.activeSession.state: %d", FBSession.activeSession.state);
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

-(id)audienceNone
{
    return [NSNumber numberWithInt:FBSessionDefaultAudienceNone];
}

-(id)audienceOnlyMe
{
    return [NSNumber numberWithInt:FBSessionDefaultAudienceOnlyMe];
}

-(id)audienceFriends
{
    return [NSNumber numberWithInt:FBSessionDefaultAudienceFriends];
}

-(id)audienceEveryone
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
    NSLog(@"[DEBUG] facebook authorize");
    BOOL allowUI = args == nil ? YES : NO;

    TiThreadPerformOnMainThread(^{
        NSArray *permissions_ = permissions == nil ? [NSArray array] : permissions;
        BOOL hasIntegratedFacebookAtAll = ([SLComposeViewController class] != nil);
        BOOL userHasIntegratedFacebookAccountSetup = hasIntegratedFacebookAtAll && ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]);

        if (nativeLogin && userHasIntegratedFacebookAccountSetup) {
            NSArray *deviceLoginPerms = @[ @"public_profile"];
            FBSession *session = [[[FBSession alloc] initWithPermissions:allowUI ? deviceLoginPerms : FBSession.activeSession.permissions] autorelease];
            [FBSession setActiveSession:session];
            [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                completionHandler:^(FBSession *fbsession,
                                    FBSessionState state, NSError *error) {
                    [self sessionStateChanged:fbsession state:state error:error];
                }];
        } else {
            BOOL sessionOpened = [FBSession openActiveSessionWithReadPermissions: allowUI ? permissions_ : FBSession.activeSession.permissions allowLoginUI:allowUI completionHandler:
                                  ^(FBSession *session,
                                    FBSessionState state, NSError *error) {
                                      [self sessionStateChanged:session state:state error:error];
            }];
            NSLog(@"[DEBUG] openActiveSessionWithReadPermissions returned: %d", sessionOpened);
        }
    }, NO);
}

// We have this function so that you can set up your listeners and permissions whenever you want
// Call initialize when ready, you will get a login event if there was a cached token
// else loggedIn will be false
-(void)initialize:(id)args
{
    id arg = [args objectAtIndex:0];
    nativeLogin = [TiUtils boolValue:arg def:NO];
    
    TiThreadPerformOnMainThread(^{
        NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
        //NSString * savedToken = [TiUtils stringValue:args];
        
        [nc addObserver:self selector:@selector(activateApp:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
        params.link = [NSURL URLWithString:@"http://developers.facebook.com/ios"];
        
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // Start with logged-in state, guaranteed no login UX is fired since logged-in
            //skipMeCall = [FBSession.activeSession.accessTokenData.accessToken isEqualToString:savedToken];
            [self authorize:YES];
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
    NSLog(@"[DEBUG] facebook logout");

    RELEASE_TO_NIL(uid);
    TiThreadPerformOnMainThread(^{
        [FBSession.activeSession closeAndClearTokenInformation];
    }, NO);
}

-(void)share:(id)args
{
    NSLog(@"[DEBUG] facebook share");
    if ([FBDialogs canPresentShareDialog]){
        
        NSDictionary* params = [args objectAtIndex:0];
        NSString* urlStr = [params objectForKey:@"url"];
        NSURL* linkUrl = [NSURL URLWithString:urlStr];
        NSString* namespaceObject = [params objectForKey:@"namespaceObject"];
        NSString* namespaceAction = [params objectForKey:@"namespaceAction"];
        NSString* objectName = [params objectForKey:@"objectName"];
        NSString* placeId = [params objectForKey:@"placeId"];
        NSString* imageUrl = [params objectForKey:@"imageUrl"];
        NSString* openGraphTitle = [params objectForKey:@"title"];
        NSString* openGraphDescription = [params objectForKey:@"description"];
        
        TiThreadPerformOnMainThread(^{
            if (objectName == nil || namespaceObject == nil || namespaceAction == nil){
                [FBDialogs presentShareDialogWithLink:linkUrl
                                              handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                  if(error) {
                                                      NSLog(@"[DEBUG] Facebook share error %@", error.description);
                                                  } else {
                                                      NSLog(@"Facebook share success!");
                                                  }
                                              }];
            } else {
                id<FBGraphObject> openGraphObject =
                [FBGraphObject openGraphObjectForPostWithType:namespaceObject
                                                        title:openGraphTitle
                                                        image:imageUrl
                                                          url:urlStr
                                                  description:openGraphDescription];
                
                id<FBOpenGraphAction> openGraphAction = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
                [openGraphAction setObject:openGraphObject forKey:objectName];
                
                if (placeId != nil){
                    id<FBGraphPlace> place = (id<FBGraphPlace>)[FBGraphObject graphObject];
                    [place setObjectID:placeId];
                    
                    [openGraphAction setPlace:place];
                }
                
                [FBDialogs presentShareDialogWithOpenGraphAction:openGraphAction
                                                      actionType:namespaceAction
                                             previewPropertyName:objectName
                                                         handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                             if(error) {
                                                                 NSLog(@"Error: %@", error.description);
                                                             } else {
                                                                 NSLog(@"Success!");
                                                             }
                                                         }];
            }
        }, NO);
    } else {
        NSLog(@"[ERROR] must have Facebook app installed to present Share Dialog");
    }
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
    NSArray * readPermissions = [args objectAtIndex:0];
    KrollCallback * callback = [args objectAtIndex:1];
    
    TiThreadPerformOnMainThread(^{
        [FBSession.activeSession requestNewReadPermissions:readPermissions
                                         completionHandler:^(FBSession *session, NSError *error) {
                                             bool success = (error == nil);
                                             bool cancelled = NO;
                                             NSString * errorString = nil;
                                             long code = 0;
                                             if(!success)
                                             {
                                                 code = [error code];
                                                 if (code == 0)
                                                 {
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
    NSArray * writePermissions = [args objectAtIndex:0];
    FBSessionDefaultAudience defaultAudience = [TiUtils intValue:[args objectAtIndex:1]];
    KrollCallback * callback = [args objectAtIndex:2];
    
    TiThreadPerformOnMainThread(^{
        [FBSession.activeSession requestNewPublishPermissions:writePermissions
                                              defaultAudience:defaultAudience
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                bool success = (error == nil);
                                                bool cancelled = NO;
                                                NSString * errorString = nil;
                                                long code = 0;
                                                if(!success)
                                                {
                                                    code = [error code];
                                                    if (code == 0)
                                                    {
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
    VerboseLog(@"[DEBUG] facebook requestWithGraphPath");
    
    NSString* path = [args objectAtIndex:0];
    NSMutableDictionary* params = [args objectAtIndex:1];
    NSString* httpMethod = [args objectAtIndex:2];
    KrollCallback* callback = [args objectAtIndex:3];
    
    TiThreadPerformOnMainThread(^{
        FBRequestConnection *connection = [[FBRequestConnection alloc] init];
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
                     returnedObject = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       result,@"result", NUMBOOL(success), @"success",
                                       path, @"path",nil];
                 } else {
                     NSLog(@"requestWithGraphPath error for path, ", path);
                     success = NO;
                     NSString * errorString;
                     if (error.fberrorShouldNotifyUser) {
                         errorString = error.fberrorUserMessage;
                     } else {
                         switch(error.fberrorCategory) {
                             case FBErrorCategoryAuthenticationReopenSession:
                                 // will be handled by authentication error handling
                                 NSLog(@"[ERROR] requestWithGraphPath FBErrorCategoryAuthenticationReopenSession");
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
                                 NSLog(@"[ERROR] requestWithGraphPath error.description: ", error.description);
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
    if ((code == 0) && !success)
    {
        code = -1;
    }
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(cancelled),@"cancelled",
                                  NUMBOOL(success),@"success",
                                  NUMLONG(code),@"code",nil];
    if(error != nil){
        NSString * errorMessage = @"OTHER:";
        if (error.fberrorShouldNotifyUser) {
            if ([[error userInfo][FBErrorLoginFailedReason]
                 isEqualToString:FBErrorLoginFailedReasonSystemDisallowedWithoutErrorValue]) {
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
    
    if(result != nil)
    {
        [event setObject:result forKey:@"data"];
        if (uid != nil)
        {
            [event setObject:uid forKey:@"uid"];
        }
    }
    [self fireEvent:@"login" withObject:event];
}


#pragma mark Listeners

-(void)addListener:(id<TiFacebookStateListener>)listener
{
    if (stateListeners==nil)
    {
        stateListeners = [[NSMutableArray alloc]init];
    }
    [stateListeners addObject:listener];
}

-(void)removeListener:(id<TiFacebookStateListener>)listener
{
    if (stateListeners!=nil)
    {
        [stateListeners removeObject:listener];
        if ([stateListeners count]==0)
        {
            RELEASE_TO_NIL(stateListeners);
        }
    }
}

@end
