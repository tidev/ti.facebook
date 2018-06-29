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

#import "FacebookModule.h"
#import "FacebookConstants.h"
#import "TiApp.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

#import <FBSDKPlacesKit/FBSDKPlacesKit.h>

NS_ASSUME_NONNULL_BEGIN

@implementation FacebookModule

#pragma mark Internal

// this is generated for your module, please do not change it
- (id)moduleGUID
{
  return @"7ac4bcd0-eb97-4e43-89fc-03f7f4d0a2a0";
}

// this is generated for your module, please do not change it
- (NSString *)moduleId
{
  return @"facebook";
}

#pragma mark Lifecycle

- (void)handleRelaunch:(NSNotification *_Nullable)notification
{
  _launchOptions = [[TiApp app] launchOptions];
  NSString *urlString = [_launchOptions objectForKey:@"url"];
  NSString *sourceApplication = [_launchOptions objectForKey:@"source"];
  id annotation = nil;

#ifdef __IPHONE_9_0
  if ([TiUtils isIOS9OrGreater]) {
    annotation = [_launchOptions objectForKey:UIApplicationOpenURLOptionsAnnotationKey];
  }
#endif

  if (urlString != nil) {
    [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication]
                                                   openURL:[NSURL URLWithString:urlString]
                                         sourceApplication:sourceApplication
                                                annotation:annotation];
  }
}

- (void)resumed:(id)note
{
  [self handleRelaunch:nil];
  [FBSDKAppEvents activateApp];
}

- (void)activateApp:(NSNotification *_Nullable)notification
{
  [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication]
                           didFinishLaunchingWithOptions:[notification userInfo]];
}

- (void)shutdown:(id)sender
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super shutdown:sender];
}

#pragma mark Public APIs

- (NSString *_Nullable)uid
{
  return _userID;
}

- (NSNumber *_Nonnull)loggedIn
{
  return NUMBOOL([FBSDKAccessToken currentAccessToken] != nil);
}

- (NSString *_Nonnull)appID
{
  return [FBSDKSettings appID];
}

- (void)setAppID:(NSString *_Nonnull)appID
{
  [FBSDKSettings setAppID:[TiUtils stringValue:appID]];
}

- (NSArray<NSString *> *_Nullable)permissions
{
  return [[[FBSDKAccessToken currentAccessToken] permissions] allObjects];
}

- (NSString *_Nullable)accessToken
{
  __block NSString *token;
  TiThreadPerformOnMainThread(^{
    token = [[FBSDKAccessToken currentAccessToken] tokenString];
  },
      YES);
  return token;
}

- (NSNumber *)accessTokenExpired
{
  return @([[FBSDKAccessToken currentAccessToken] isExpired]);
}

- (NSNumber *)accessTokenActive
{
  return @([FBSDKAccessToken currentAccessTokenIsActive]);
}

- (void)setCurrentAccessToken:(NSDictionary *_Nonnull)currentAccessToken
{
  [FBSDKAccessToken setCurrentAccessToken:[[FBSDKAccessToken alloc] initWithTokenString:[TiUtils stringValue:@"accessToken" properties:currentAccessToken]
                                                                            permissions:[currentAccessToken objectForKey:@"permissions"]
                                                                    declinedPermissions:[currentAccessToken objectForKey:@"declinedPermissions"]
                                                                                  appID:[TiUtils stringValue:@"appID" properties:currentAccessToken]
                                                                                 userID:[TiUtils stringValue:@"userID" properties:currentAccessToken]
                                                                         expirationDate:[currentAccessToken objectForKey:@"exipirationDate"]
                                                                            refreshDate:[currentAccessToken objectForKey:@"refreshDate"]]];
}

- (NSDate *_Nullable)expirationDate
{
  __block NSDate *expirationDate = nil;

  TiThreadPerformOnMainThread(^{
    expirationDate = [[FBSDKAccessToken currentAccessToken] expirationDate];
  },
      YES);

  return expirationDate;
}

- (void)setPermissions:(NSArray<NSString *> *_Nullable)permissions
{
  _permissions = permissions;
}

- (void)logPurchase:(NSArray<id> *_Nonnull)purchase
{
  ENSURE_TYPE([purchase objectAtIndex:0], NSNumber);
  ENSURE_TYPE([purchase objectAtIndex:1], NSString);

  NSNumber *amount = [purchase objectAtIndex:0];
  NSString *currency = [TiUtils stringValue:[purchase objectAtIndex:1]];

  [FBSDKAppEvents logPurchase:[amount doubleValue] currency:currency];
}

- (void)logCustomEvent:(NSArray<id> *_Nonnull)customEvent
{
  // Event
  id args0 = [customEvent objectAtIndex:0];
  ENSURE_SINGLE_ARG(args0, NSString);
  NSString *event = args0;

  // Value
  id args1 = [customEvent count] > 1 ? [customEvent objectAtIndex:1] : nil;
  ENSURE_SINGLE_ARG_OR_NIL(args1, NSNumber);
  double valueToSum = [TiUtils doubleValue:args1];

  // Parameters
  id args2 = [customEvent count] > 2 ? [customEvent objectAtIndex:2] : nil;
  ENSURE_SINGLE_ARG_OR_NIL(args2, NSDictionary);
  NSDictionary *parameters = args2;

  [FBSDKAppEvents logEvent:event valueToSum:valueToSum parameters:parameters];
}

- (void)logPushNotificationOpen:(NSArray<id> *_Nonnull)pushNotification
{
  if ([pushNotification count] == 1) {
    NSDictionary *payload = [pushNotification objectAtIndex:0];
    [FBSDKAppEvents logPushNotificationOpen:payload];
  } else if ([pushNotification count] == 2) {
    id payload = [pushNotification objectAtIndex:0];
    id action = [pushNotification objectAtIndex:1];

    ENSURE_TYPE(payload, NSDictionary);
    ENSURE_TYPE(action, NSString);

    [FBSDKAppEvents logPushNotificationOpen:payload action:action];
  } else {
    NSLog(@"[ERROR] Invalid number of arguments provided, please check the docs for 'logPushNotificationOpen' and try again!");
  }
}

- (void)setPushNotificationsDeviceToken:(NSString *_Nonnull)deviceToken
{
  ENSURE_TYPE(deviceToken, NSString);
  [FBSDKAppEvents setPushNotificationsDeviceToken:[FacebookModule dataFromHexString:deviceToken]];
}

- (void)setLoginBehavior:(NSNumber *_Nonnull)loginBehavior
{
  ENSURE_TYPE(loginBehavior, NSNumber);
  _loginBehavior = [loginBehavior unsignedIntegerValue];
}

- (void)authorize:(__unused id)unused
{
  __block FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
  [loginManager setLoginBehavior:_loginBehavior];

  TiThreadPerformOnMainThread(^{
    [loginManager logInWithReadPermissions:_permissions
                        fromViewController:nil
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                     // Handle error
                                     if (error != nil) {
                                       [self fireLogin:nil cancelled:NO withError:error];
                                       return;
                                     }

                                     // Login cancelled
                                     if (result.isCancelled) {
                                       [self fireLogin:nil cancelled:YES withError:nil];
                                       return;
                                     }

                                     // Logged In
                                   }];
  },
      YES);
}

- (void)initialize:(__unused id)unused
{
  TiThreadPerformOnMainThread(^{
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    _loginBehavior = FBSDKLoginBehaviorBrowser;

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(logEvents:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [nc addObserver:self selector:@selector(accessTokenChanged:) name:FBSDKAccessTokenDidChangeNotification object:nil];
    [nc addObserver:self selector:@selector(activateApp:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [nc addObserver:self selector:@selector(currentProfileChanged:) name:FBSDKProfileDidChangeNotification object:nil];

    // Only triggered by Titanium SDK 5.5.0+
    // Older SDK's get notified by the `resumed:` delegate
    [nc addObserver:self selector:@selector(handleRelaunch:) name:@"TiApplicationLaunchedFromURL" object:nil];

    if ([FBSDKAccessToken currentAccessToken] == nil) {
      [self activateApp:nil];
    } else {
      [self handleRelaunch:nil];
    }
  },
      YES);
}

- (void)logout:(__unused id)unused
{
  TiThreadPerformOnMainThread(^{
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
  },
      NO);
}

- (void)presentShareDialog:(NSArray<NSDictionary<NSString *, id> *> *_Nonnull)args
{
  NSDictionary *_Nonnull params = [args objectAtIndex:0];

  TiThreadPerformOnMainThread(^{
    FBSDKShareLinkContent *content = [FacebookModule shareLinkContentFromDictionary:params];
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];

    [dialog setMode:[TiUtils intValue:[params objectForKey:@"mode"] def:FBSDKShareDialogModeAutomatic]];
    [dialog setFromViewController:nil];
    [dialog setShareContent:content];
    [dialog setDelegate:self];

    [dialog show];
  },
      NO);
}

- (void)presentPhotoShareDialog:(NSArray<NSDictionary<NSString *, id> *> *_Nonnull)args
{
  NSDictionary *_Nonnull params = [args objectAtIndex:0];

  TiThreadPerformOnMainThread(^{
    FBSDKSharePhotoContent *content = [FacebookModule sharePhotoContentFromDictionary:params];
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];

    [dialog setMode:[TiUtils intValue:[params objectForKey:@"mode"] def:FBSDKShareDialogModeAutomatic]];
    [dialog setFromViewController:nil];
    [dialog setShareContent:content];
    [dialog setDelegate:self];

    [dialog show];
  },
      NO);
}

- (void)presentMessengerDialog:(NSArray<NSDictionary<NSString *, id> *> *)args
{
  NSDictionary *_Nonnull params = [args objectAtIndex:0];

  TiThreadPerformOnMainThread(^{
    FBSDKShareLinkContent *content = [FacebookModule shareLinkContentFromDictionary:params];
    [FBSDKMessageDialog showWithContent:content delegate:self];
  },
      NO);
}

- (void)shareMediaToMessenger:(NSArray<NSDictionary<NSString *, id> *> *)args
{
  NSDictionary *_Nonnull params = [args objectAtIndex:0];

  id media = [params valueForKey:@"media"];
  ENSURE_TYPE(media, TiBlob);

  TiThreadPerformOnMainThread(^{
    FBSDKMessengerShareOptions *options = [[FBSDKMessengerShareOptions alloc] init];
    options.metadata = [params objectForKey:@"metadata"];
    options.sourceURL = [NSURL URLWithString:[params objectForKey:@"link"]];
    options.renderAsSticker = [TiUtils boolValue:[params objectForKey:@"renderAsSticker"] def:NO];

    if ([[media mimeType] isEqual:@"image/gif"]) {
      [FBSDKMessengerSharer shareAnimatedGIF:[NSData dataWithContentsOfFile:[(TiBlob *)media path]] withOptions:options];
    } else if ([[media mimeType] containsString:@"image/"]) {
      [FBSDKMessengerSharer shareImage:[TiUtils image:media proxy:self] withOptions:options];
    } else if ([[media mimeType] containsString:@"video/"]) {
      [FBSDKMessengerSharer shareVideo:[NSData dataWithContentsOfFile:[(TiBlob *)media path]] withOptions:options];
    } else {
      NSLog(@"[ERROR] Unknown media provided. Allowed media: Image, GIF and video.");
    }
  },
      NO);
}

- (void)presentWebShareDialog:(id _Nullable)unused
{
  DEPRECATED_REPLACED_REMOVED(@"Facebook.presentWebShareDialog", @"5.0.0", @"5.0.0", @"Facebook.presentShareDialog");
  DebugLog(@"[WARN] Facebook removed the ShareDialog API via Web in SDK 4.28.0");
}

- (void)presentInviteDialog:(NSArray<NSDictionary<NSString *, id> *> *)args
{
  DEPRECATED_REMOVED(@"Facebook.presentInviteDialog", @"5.7.0", @"5.7.0");
  DebugLog(@"[WARN] Facebook removed the InviteDialog API in SDK 4.28.0");
}

- (void)presentSendRequestDialog:(NSArray<NSDictionary<NSString *, id> *> *)args
{
  NSDictionary *_Nonnull params = [args objectAtIndex:0];

  NSString *message = [params objectForKey:@"message"];
  NSString *title = [params objectForKey:@"title"];
  NSArray *to = [params objectForKey:@"to"];
  NSArray *recipients = [params objectForKey:@"recipients"];
  NSArray *recipientSuggestions = [params objectForKey:@"recipientSuggestions"];
  FBSDKGameRequestFilter filters = [TiUtils intValue:[params objectForKey:@"filters"]];
  NSString *objectID = [params objectForKey:@"objectID"];
  NSString *data = [params objectForKey:@"data"];
  FBSDKGameRequestActionType actionType = [TiUtils intValue:[params objectForKey:@"actionType"]];

  if (to != nil) {
    DEPRECATED_REPLACED_REMOVED(@"Facebook.sendRequestDialog.to", @"5.0.0", @"5.0.0", @"Titanium.Facebook.sendRequestDialog.recipients");
  }

  TiThreadPerformOnMainThread(^{
    FBSDKGameRequestContent *gameRequestContent = [[FBSDKGameRequestContent alloc] init];

    gameRequestContent.title = title;
    gameRequestContent.message = message;
    gameRequestContent.recipients = recipients;
    gameRequestContent.objectID = objectID;
    gameRequestContent.data = data;
    gameRequestContent.recipientSuggestions = recipientSuggestions;
    gameRequestContent.filters = filters;
    gameRequestContent.actionType = actionType;

    [FBSDKGameRequestDialog showWithContent:gameRequestContent delegate:self];
  },
      NO);
}

- (void)refreshPermissionsFromServer:(__unused id)unused
{
  TiThreadPerformOnMainThread(^{
    [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
      [self fireEvent:@"tokenUpdated" withObject:nil];
    }];
  },
      NO);
}

- (void)requestNewReadPermissions:(NSArray<id> *_Nonnull)args
{
  NSArray<NSString *> *readPermissions = [args objectAtIndex:0];
  ENSURE_ARRAY(readPermissions);

  KrollCallback *callback = [args objectAtIndex:1];
  ENSURE_TYPE(callback, KrollCallback);

  FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];

  TiThreadPerformOnMainThread(^{
    [loginManager logInWithReadPermissions:readPermissions
                        fromViewController:nil
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                     BOOL success = NO;
                                     BOOL cancelled = NO;
                                     NSString *errorString = nil;
                                     NSInteger code = 0;

                                     if (error != nil) {
                                       code = [error code];
                                       errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
                                       if (errorString == nil) {
                                         errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];

                                         if (errorString == nil) {
                                           if (code == 308) {
                                             errorString = TiFacebookErrorMessageKeychainAccess;
                                           } else {
                                             errorString = [error localizedDescription];
                                           }
                                         }
                                       }
                                     } else if (result.isCancelled) {
                                       cancelled = YES;
                                     } else {
                                       success = YES;
                                     }

                                     NSDictionary *propertiesDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                                              NUMBOOL(success), @"success",
                                                                                          NUMBOOL(cancelled), @"cancelled",
                                                                                          NUMINTEGER(code), @"code",
                                                                                          errorString, @"error", nil];

                                     KrollEvent *invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:propertiesDict thisObject:self];
                                     [[callback context] enqueue:invocationEvent];
                                   }];
  },
      NO);
}

- (void)requestNewPublishPermissions:(NSArray<id> *_Nonnull)args
{
  NSArray<NSString *> *publishPermissions = [args objectAtIndex:0];
  ENSURE_ARRAY(publishPermissions);

  NSNumber *_defaultAudience = [args objectAtIndex:1];
  ENSURE_TYPE(_defaultAudience, NSNumber);
  FBSDKDefaultAudience defaultAudience = [TiUtils intValue:_defaultAudience];

  KrollCallback *callback = [args objectAtIndex:2];
  ENSURE_TYPE(callback, KrollCallback);

  FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
  loginManager.defaultAudience = defaultAudience;

  TiThreadPerformOnMainThread(^{
    [loginManager logInWithPublishPermissions:publishPermissions
                           fromViewController:nil
                                      handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                        BOOL success = NO;
                                        BOOL cancelled = NO;
                                        NSString *errorString = nil;
                                        NSInteger code = 0;

                                        if (error != nil) {
                                          code = [error code];
                                          errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
                                          if (errorString == nil) {
                                            errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];

                                            if (errorString == nil) {
                                              if (code == 308) {
                                                errorString = TiFacebookErrorMessageKeychainAccess;
                                              } else {
                                                errorString = [error localizedDescription];
                                              }
                                            }
                                          }
                                        } else if (result.isCancelled) {
                                          cancelled = YES;
                                        } else {
                                          success = YES;
                                        }

                                        NSDictionary *propertiesDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                                                 NUMBOOL(success), @"success",
                                                                                             NUMBOOL(cancelled), @"cancelled",
                                                                                             NUMINTEGER(code), @"code",
                                                                                             errorString, @"error", nil];

                                        KrollEvent *invocationEvent = [[KrollEvent alloc] initWithCallback:callback
                                                                                               eventObject:propertiesDict thisObject:self];
                                        [[callback context] enqueue:invocationEvent];
                                      }];
  },
      YES);
}

- (void)requestWithGraphPath:(NSArray<id> *_Nonnull)args
{
  NSString *path = [args objectAtIndex:0];
  ENSURE_TYPE(path, NSString);

  NSMutableDictionary *params = [args objectAtIndex:1];
  ENSURE_TYPE_OR_NIL(params, NSMutableDictionary);

  NSString *httpMethod = [args objectAtIndex:2];
  ENSURE_TYPE(httpMethod, NSString);

  KrollCallback *callback = [args objectAtIndex:3];
  ENSURE_TYPE(callback, KrollCallback);

  for (NSUInteger i = 0; i < [[params allKeys] count]; i++) {
    NSString *key = [[params allKeys] objectAtIndex:i];
    id value = [params objectForKey:key];

    if ([value isKindOfClass:[TiBlob class]]) {
      TiBlob *blob = (TiBlob *)value;
      [params setObject:[blob data] forKey:key];
    }
  }

  TiThreadPerformOnMainThread(^{
    if ([FBSDKAccessToken currentAccessToken]) {
      [[[FBSDKGraphRequest alloc] initWithGraphPath:path parameters:params HTTPMethod:httpMethod]
          startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            NSDictionary *returnedObject;
            BOOL success = NO;

            if (!error) {
              success = YES;
              //for parity with android, have to stringify json object
              NSString *resultString = [TiUtils jsonStringify:result];
              returnedObject = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                         resultString, @"result", NUMBOOL(success), @"success",
                                                     path, @"path", nil];
            } else {
              //DebugLog(@"requestWithGraphPath error for path, %@", path);
              success = NO;
              NSString *errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
              if (errorString == nil) {
                errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];

                if (errorString == nil) {
                  if ([error code] == 308) {
                    errorString = TiFacebookErrorMessageKeychainAccess;
                  } else {
                    errorString = [error localizedDescription];
                  }
                }
              }
              returnedObject = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                         NUMBOOL(success), @"success",
                                                     path, @"path", errorString, @"error", nil];
            }

            KrollEvent *invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:returnedObject thisObject:self];
            [[callback context] enqueue:invocationEvent];
          }];
    }
  },
      NO);
}

- (void)fetchDeferredAppLink:(NSArray<KrollCallback *> *_Nonnull)args
{
  KrollCallback *callback = [args objectAtIndex:0];

  TiThreadPerformOnMainThread(^{
    [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
      NSDictionary *returnedObject;

      if (url != nil) {
        returnedObject = [[NSDictionary alloc] initWithObjectsAndKeys:[url absoluteURL], @"url", NUMBOOL(YES), @"success", nil];
      } else {
        NSString *errorString = @"An error occurred. Please try again.";
        if (error != nil) {
          errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
          if (errorString == nil) {
            errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];

            if (errorString == nil) {
              if ([error code] == 308) {
                errorString = [NSString stringWithFormat:@"Error 308 detected: Please enable keychain-sharing in your project by creating an Entitlements file. For more information check the \"Migrate to iOS 10\" section in https://docs.appcelerator.com/platform/latest/#!/api/Modules.Facebook"];
              } else {
                errorString = [error localizedDescription];
              }
            }
          }
        }
        returnedObject = [[NSDictionary alloc] initWithObjectsAndKeys:errorString, @"error", NUMBOOL(NO), @"success", nil];
      }

      KrollEvent *invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:returnedObject thisObject:self];
      [[callback context] enqueue:invocationEvent];
    }];
  },
      YES);
}

- (void)fetchNearbyPlacesForCurrentLocation:(NSArray<NSDictionary<NSString *, id> *> *_Nonnull)args
{
  NSDictionary *params = [args objectAtIndex:0];

  FBSDKPlaceLocationConfidence confidenceLevel = [TiUtils intValue:[params objectForKey:@"confidenceLevel"]
                                                               def:FBSDKPlaceLocationConfidenceNotApplicable];
  NSArray *fields = [params objectForKey:@"fields"];
  KrollCallback *successCallback = [params objectForKey:@"success"];
  KrollCallback *errorCallback = [params objectForKey:@"error"];

  ENSURE_TYPE(successCallback, KrollCallback);
  ENSURE_TYPE(errorCallback, KrollCallback);

  __block FBSDKPlacesManager *placesManager = [[FBSDKPlacesManager alloc] init];

  [placesManager generateCurrentPlaceRequestWithMinimumConfidenceLevel:confidenceLevel
                                                                fields:fields
                                                            completion:^(FBSDKGraphRequest *_Nullable graphRequest, NSError *_Nullable error) {

                                                              if (graphRequest) {
                                                                [graphRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *requestError) {

                                                                  if (requestError != nil) {
                                                                    NSDictionary *errorEvent = @{
                                                                      @"error" : [requestError localizedDescription],
                                                                      @"success" : @NO
                                                                    };
                                                                    [errorCallback call:@[ errorEvent ] thisObject:self];
                                                                    return;
                                                                  }

                                                                  NSDictionary *successEvent = @{
                                                                    @"success" : @YES,
                                                                    @"places" : result[FBSDKPlacesResponseKeyData]
                                                                  };
                                                                  [successCallback call:@[ successEvent ] thisObject:self];
                                                                }];
                                                              } else {
                                                                NSDictionary *errorEvent = @{
                                                                  @"error" : [error localizedDescription],
                                                                  @"success" : @NO
                                                                };
                                                                [errorCallback call:@[ errorEvent ] thisObject:self];
                                                              }
                                                            }];
}

- (void)fetchNearbyPlacesForSearchTearm:(NSArray<NSDictionary<NSString *, id> *> *_Nonnull)args
{
  NSDictionary *params = [args objectAtIndex:0];

  NSString *searchTearm = [params objectForKey:@"searchTearm"];
  NSArray *categories = [params objectForKey:@"categories"];
  NSArray *fields = [params objectForKey:@"fields"];
  CLLocationDistance distance = [TiUtils doubleValue:[params objectForKey:@"distance"] def:0];
  NSString *cursor = [params objectForKey:@"cursor"];

  KrollCallback *successCallback = [params objectForKey:@"success"];
  KrollCallback *errorCallback = [params objectForKey:@"error"];

  ENSURE_TYPE(successCallback, KrollCallback);
  ENSURE_TYPE(errorCallback, KrollCallback);

  __block FBSDKPlacesManager *placesManager = [[FBSDKPlacesManager alloc] init];

  [placesManager generatePlaceSearchRequestForSearchTerm:searchTearm
                                              categories:categories
                                                  fields:fields
                                                distance:distance
                                                  cursor:cursor
                                              completion:^(FBSDKGraphRequest *_Nullable graphRequest, CLLocation *_Nullable location, NSError *_Nullable error) {

                                                if (graphRequest) {
                                                  [graphRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *requestError) {

                                                    if (requestError != nil) {
                                                      NSDictionary *errorEvent = @{
                                                        @"error" : [requestError localizedDescription],
                                                        @"success" : @NO
                                                      };
                                                      [errorCallback call:@[ errorEvent ] thisObject:self];
                                                      return;
                                                    }

                                                    NSDictionary *successEvent = @{
                                                      @"success" : @YES,
                                                      @"places" : result[FBSDKPlacesResponseKeyData],
                                                      @"paging" : [result objectForKey:@"paging"]
                                                    };
                                                    [successCallback call:@[ successEvent ] thisObject:self];
                                                  }];
                                                } else {
                                                  NSDictionary *errorEvent = @{
                                                    @"error" : [error localizedDescription],
                                                    @"success" : @NO
                                                  };
                                                  [errorCallback call:@[ errorEvent ] thisObject:self];
                                                }
                                              }];
}

#pragma mark Event Listeners

- (void)fireLogin:(id _Nullable)result cancelled:(BOOL)cancelled withError:(NSError *_Nullable)error
{
  BOOL success = (result != nil);
  NSInteger code = [error code];

  if ((code == 0) && !success) {
    code = -1;
  }

  NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                        NUMBOOL(cancelled), @"cancelled",
                                                    NUMBOOL(success), @"success",
                                                    NUMINTEGER(code), @"code", nil];
  if (error != nil) {
    NSString *errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
    if (errorString == nil) {
      errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];

      if (errorString == nil) {
        if ([error code] == 308) {
          errorString = TiFacebookErrorMessageKeychainAccess;
        } else {
          errorString = [error localizedDescription];
        }
      }
    }
    [event setObject:errorString forKey:@"error"];
  }

  if (result != nil) {
    FBSDKProfile *profile = (FBSDKProfile *)result;
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     profile.userID, @"userID",
                                                 profile.firstName, @"firstName",
                                                 profile.middleName ?: @"", @"middleName",
                                                 profile.lastName, @"lastName",
                                                 profile.name, @"name",
                                                 [profile.linkURL absoluteString], @"linkURL",
                                                 nil];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
    NSString *resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [event setObject:resultString forKey:@"data"];
    if (_userID != nil) {
      [event setObject:_userID forKey:@"uid"];
    }
  }

  [self fireEvent:@"login" withObject:event];
}

- (void)logEvents:(NSNotification *)notification
{
  [FBSDKAppEvents activateApp];
}

- (void)accessTokenChanged:(NSNotification *)notification
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
    _userID = [profile userID];
    [self fireLogin:profile cancelled:NO withError:nil];
  }
}

#pragma mark Share dialog delegates

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
  [self fireDialogEventWithName:TiFacebookEventTypeShareCompleted andSuccess:YES error:nil cancelled:NO];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
  [self fireDialogEventWithName:TiFacebookEventTypeShareCompleted andSuccess:NO error:error cancelled:NO];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
  [self fireDialogEventWithName:TiFacebookEventTypeShareCompleted andSuccess:NO error:nil cancelled:YES];
}

#pragma Game request delegates

- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didCompleteWithResults:(NSDictionary *)results
{
  [self fireDialogEventWithName:TiFacebookEventTypeRequestDialogCompleted andSuccess:YES error:nil cancelled:NO];
}

- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didFailWithError:(NSError *)error
{
  [self fireDialogEventWithName:TiFacebookEventTypeRequestDialogCompleted andSuccess:NO error:error cancelled:NO];
}

- (void)gameRequestDialogDidCancel:(FBSDKGameRequestDialog *)gameRequestDialog
{
  [self fireDialogEventWithName:TiFacebookEventTypeRequestDialogCompleted andSuccess:NO error:nil cancelled:YES];
}

#pragma mark Invite dialog delegates

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
  [self fireDialogEventWithName:TiFacebookEventTypeInviteCompleted andSuccess:YES error:error cancelled:NO];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
  BOOL cancelled = NO;
  if (results != nil) {
    cancelled = [[results valueForKey:@"completionGesture"] isEqualToString:@"cancel"];
  }
  [self fireDialogEventWithName:TiFacebookEventTypeInviteCompleted andSuccess:!cancelled error:nil cancelled:cancelled];
}

- (void)fireDialogEventWithName:(NSString *_Nonnull)name andSuccess:(BOOL)success error:(NSError *_Nullable)error cancelled:(BOOL)cancelled
{
  if (![self _hasListeners:name]) {
    return;
  }

  NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
    @"cancelled" : NUMBOOL(cancelled),
    @"success" : NUMBOOL(success)
  }];

  if (error != nil) {
    NSString *errorString = [[error userInfo] objectForKey:FBSDKErrorLocalizedDescriptionKey];
    if (errorString == nil) {
      errorString = [[error userInfo] objectForKey:FBSDKErrorDeveloperMessageKey];

      if (errorString == nil) {
        if ([error code] == 308) {
          errorString = TiFacebookErrorMessageKeychainAccess;
        } else {
          errorString = [error localizedDescription];
        }
      }
    }
    [event setValue:errorString forKey:@"error"];
  }

  [self fireEvent:name withObject:event];
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary *)parseURLParams:(NSString *)query
{
  NSArray *pairs = [query componentsSeparatedByString:@"&"];
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
  for (NSString *pair in pairs) {
    NSArray *kv = [pair componentsSeparatedByString:@"="];
    NSString *val = [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    params[[[[kv[0] stringByRemovingPercentEncoding] componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""]] = val;
  }
  return params;
}

#pragma mark Utilities

- (void)populateUserDetails
{
  TiThreadPerformOnMainThread(^{
    if ([FBSDKAccessToken currentAccessToken] != nil) {
      FBSDKProfile *user = [FBSDKProfile currentProfile];
      _userID = [user userID];
      [self fireLogin:user cancelled:NO withError:nil];
    } else {
      [self fireLogin:nil cancelled:NO withError:nil];
    }
  },
      NO);
}

+ (FBSDKShareLinkContent *_Nonnull)shareLinkContentFromDictionary:(NSDictionary *)dictionary
{
  FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];

  // Deprecated
  NSString *description = [dictionary objectForKey:@"description"];
  NSString *title = [dictionary objectForKey:@"title"];
  NSString *picture = [dictionary objectForKey:@"picture"];

  NSString *hashtag = [dictionary objectForKey:@"hashtag"];
  NSString *quote = [dictionary objectForKey:@"quote"];
  NSArray *to = [dictionary objectForKey:@"to"];
  NSURL *link = [NSURL URLWithString:[dictionary objectForKey:@"link"]];
  NSString *placeID = [dictionary objectForKey:@"placeID"];
  NSString *referal = [dictionary objectForKey:@"referal"];

  if (description != nil) {
    NSLog(@"[WARN] Setting the \"description\" is no longer possible in Ti.Facebook 5.5.0 as part of the Graph v2.9 changes.");
    NSLog(@"[WARN] It's information is scraped from the 'link' property instead, so setting it is no longer supported and will be ignored!");
  }

  if (title != nil) {
    NSLog(@"[WARN] Setting the \"title\" parameter is no longer possible in Ti.Facebook 5.5.0 as part of the Graph v2.9 changes.");
    NSLog(@"[WARN] It's information is scraped from the 'link' property instead, so setting it is no longer supported and will be ignored!");
  }

  if (picture != nil) {
    NSLog(@"[WARN] Setting the \"picture\" is no longer possible in Ti.Facebook 5.5.0 as part of the Graph v2.9 changes.");
    NSLog(@"[WARN] It's information is scraped from the 'link' property instead, so setting it is no longer supported and will be ignored!");
  }
  
  if (link == nil) {
    NSLog(@"[ERROR] Missing required parameter \"link\"!");
  }
  
  [content setContentURL:link];

  if (hashtag != nil) {
    [content setHashtag:[FBSDKHashtag hashtagWithString:hashtag]];
  }

  if (quote != nil) {
    [content setQuote:quote];
  }

  if (to != nil) {
    [content setPeopleIDs:to];
  }

  if (placeID != nil) {
    [content setPlaceID:placeID];
  }

  if (referal != nil) {
    [content setRef:referal];
  }

  return content;
}

+ (FBSDKSharePhotoContent *_Nonnull)sharePhotoContentFromDictionary:(NSDictionary *)dictionary
{  
  FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];

  NSArray<NSDictionary<NSString *, id> *> *photos = [dictionary objectForKey:@"photos"];
  NSMutableArray<FBSDKSharePhoto *> *nativePhotos = [NSMutableArray arrayWithCapacity:photos.count];
  
  for (NSDictionary<NSString *, id> *photoDictionary in photos) {
    id photo = photoDictionary[@"photo"];
    NSString *caption = photoDictionary[@"caption"];
    FBSDKSharePhoto *nativePhoto = [FBSDKSharePhoto new];
    BOOL userGenerated = [TiUtils boolValue:photoDictionary[@"userGenerated"]];
  
    // A photo can either be a Blob or String
    if ([photo isKindOfClass:[TiBlob class]]) {
      nativePhoto.image = [(TiBlob *)photo image];
    } else if ([photo isKindOfClass:[NSString class]]) {
      nativePhoto.imageURL = [NSURL URLWithString:(NSString *)photo];
    } else {
      NSLog(@"[ERROR] Required \"photo\" not found or of unknown type: %@", NSStringFromClass([photo class]));
    }

    // An optional caption
    if (caption != nil) {
      nativePhoto.caption = caption;
    }

    // An optional flag indicating if the photo was user generated
    nativePhoto.userGenerated = userGenerated;
  }

  content.photos = nativePhotos;

  return content;
}

// http://stackoverflow.com/a/41555957/5537752
+ (NSData *)dataFromHexString:(NSString *)string
{
  NSMutableData *stringData = [[NSMutableData alloc] init];
  unsigned char whole_byte;
  char byte_chars[3] = { '\0', '\0', '\0' };
  int i;

  for (i = 0; i < [string length] / 2; i++) {
    byte_chars[0] = [string characterAtIndex:i * 2];
    byte_chars[1] = [string characterAtIndex:i * 2 + 1];
    whole_byte = strtol(byte_chars, NULL, 16);
    [stringData appendBytes:&whole_byte length:1];
  }

  return stringData;
}

#pragma mark Constants

MAKE_SYSTEM_PROP_DEPRECATED_REPLACED_REMOVED(AUDIENCE_NONE, -1, @"Facebook.AUDIENCE_NONE", @"5.0.0", @"5.0.0", @"Facebook.AUDIENCE_ONLY_ME");
MAKE_SYSTEM_PROP(AUDIENCE_ONLY_ME, FBSDKDefaultAudienceOnlyMe);
MAKE_SYSTEM_PROP(AUDIENCE_FRIENDS, FBSDKDefaultAudienceFriends);
MAKE_SYSTEM_PROP(AUDIENCE_EVERYONE, FBSDKDefaultAudienceEveryone);

MAKE_SYSTEM_PROP(ACTION_TYPE_NONE, FBSDKGameRequestActionTypeNone);
MAKE_SYSTEM_PROP(ACTION_TYPE_SEND, FBSDKGameRequestActionTypeSend);
MAKE_SYSTEM_PROP(ACTION_TYPE_ASK_FOR, FBSDKGameRequestActionTypeAskFor);
MAKE_SYSTEM_PROP(ACTION_TYPE_TURN, FBSDKGameRequestActionTypeTurn);

MAKE_SYSTEM_PROP(FILTER_NONE, FBSDKGameRequestFilterNone);
MAKE_SYSTEM_PROP(FILTER_APP_USERS, FBSDKGameRequestFilterAppUsers);
MAKE_SYSTEM_PROP(FILTER_APP_NON_USERS, FBSDKGameRequestFilterAppNonUsers);

MAKE_SYSTEM_PROP(LOGIN_BEHAVIOR_BROWSER, FBSDKLoginBehaviorBrowser);
MAKE_SYSTEM_PROP(LOGIN_BEHAVIOR_NATIVE, FBSDKLoginBehaviorNative);
MAKE_SYSTEM_PROP(LOGIN_BEHAVIOR_SYSTEM_ACCOUNT, FBSDKLoginBehaviorSystemAccount);
MAKE_SYSTEM_PROP(LOGIN_BEHAVIOR_WEB, FBSDKLoginBehaviorWeb);

MAKE_SYSTEM_PROP(MESSENGER_BUTTON_MODE_RECTANGULAR, TiFacebookShareButtonModeRectangular);
MAKE_SYSTEM_PROP(MESSENGER_BUTTON_MODE_CIRCULAR, TiFacebookShareButtonModeCircular);

MAKE_SYSTEM_PROP(MESSENGER_BUTTON_STYLE_BLUE, FBSDKMessengerShareButtonStyleBlue);
MAKE_SYSTEM_PROP(MESSENGER_BUTTON_STYLE_WHITE, FBSDKMessengerShareButtonStyleWhite);
MAKE_SYSTEM_PROP(MESSENGER_BUTTON_STYLE_WHITE_BORDERED, FBSDKMessengerShareButtonStyleWhiteBordered);

MAKE_SYSTEM_PROP(SHARE_DIALOG_MODE_AUTOMATIC, FBSDKShareDialogModeAutomatic);
MAKE_SYSTEM_PROP(SHARE_DIALOG_MODE_NATIVE, FBSDKShareDialogModeNative);
MAKE_SYSTEM_PROP(SHARE_DIALOG_MODE_SHARE_SHEET, FBSDKShareDialogModeShareSheet);
MAKE_SYSTEM_PROP(SHARE_DIALOG_MODE_BROWSER, FBSDKShareDialogModeBrowser);
MAKE_SYSTEM_PROP(SHARE_DIALOG_MODE_WEB, FBSDKShareDialogModeWeb);
MAKE_SYSTEM_PROP(SHARE_DIALOG_MODE_FEED_BROWSER, FBSDKShareDialogModeFeedBrowser);
MAKE_SYSTEM_PROP(SHARE_DIALOG_MODE_FEED_WEB, FBSDKShareDialogModeFeedWeb);

MAKE_SYSTEM_PROP(LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC, FBSDKLoginButtonTooltipBehaviorAutomatic);
MAKE_SYSTEM_PROP(LOGIN_BUTTON_TOOLTIP_BEHAVIOR_FORCE_DISPLAY, FBSDKLoginButtonTooltipBehaviorForceDisplay);
MAKE_SYSTEM_PROP(LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE, FBSDKLoginButtonTooltipBehaviorDisable);

MAKE_SYSTEM_PROP(LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY, FBSDKTooltipColorStyleNeutralGray);
MAKE_SYSTEM_PROP(LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE, FBSDKTooltipColorStyleFriendlyBlue);

MAKE_SYSTEM_PROP(PLACE_LOCATION_CONFIDENCE_NOT_APPLICABLE, FBSDKPlaceLocationConfidenceNotApplicable);
MAKE_SYSTEM_PROP(PLACE_LOCATION_CONFIDENCE_LOW, FBSDKPlaceLocationConfidenceLow);
MAKE_SYSTEM_PROP(PLACE_LOCATION_CONFIDENCE_MEDIUM, FBSDKPlaceLocationConfidenceMedium);
MAKE_SYSTEM_PROP(PLACE_LOCATION_CONFIDENCE_HIGH, FBSDKPlaceLocationConfidenceHigh);

@end

NS_ASSUME_NONNULL_END
