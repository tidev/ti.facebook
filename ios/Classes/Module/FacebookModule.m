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

#import "FacebookConstants.h"
#import "FacebookModule.h"

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

- (NSString *)apiName
{
  return @"Ti.Facebook";
}

#pragma mark Lifecycle

- (void)handleRelaunch:(NSNotification *_Nullable)notification
{
  _launchOptions = [[TiApp app] launchOptions];
  NSString *urlString = [_launchOptions objectForKey:@"url"];
  id annotation = nil;
  NSString *sourceApplication = [_launchOptions objectForKey:@"source"];

  if ([TiUtils isIOSVersionOrGreater:@"9.0"]) {
    annotation = [_launchOptions objectForKey:UIApplicationOpenURLOptionsAnnotationKey];
  }

  // Fix a psossible nullability issue with iOS 13+ (see TIMOB-27354)
  if ([sourceApplication isKindOfClass:[NSNull class]]) {
    sourceApplication = nil;
  }

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
  [[FBSDKAppEvents singleton] activateApp];
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
  TiThreadPerformOnMainThread(
      ^{
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
  return @([FBSDKAccessToken isCurrentAccessTokenActive]);
}

- (void)setCurrentAccessToken:(NSDictionary *_Nonnull)currentAccessToken
{
  FBSDKAccessToken *newToken = [[FBSDKAccessToken alloc] initWithTokenString:[TiUtils stringValue:@"accessToken" properties:currentAccessToken]
                                                                 permissions:[currentAccessToken objectForKey:@"permissions"]
                                                         declinedPermissions:[currentAccessToken objectForKey:@"declinedPermissions"]
                                                          expiredPermissions:[currentAccessToken objectForKey:@"expiredPermissions"]
                                                                       appID:[TiUtils stringValue:@"appID" properties:currentAccessToken]
                                                                      userID:[TiUtils stringValue:@"userID" properties:currentAccessToken]
                                                              expirationDate:[currentAccessToken objectForKey:@"exipirationDate"]
                                                                 refreshDate:[currentAccessToken objectForKey:@"refreshDate"]
                                                    dataAccessExpirationDate:[currentAccessToken objectForKey:@"refreshDate"]];

  [FBSDKAccessToken setCurrentAccessToken:newToken];
}

- (void)setLoginTracking_:(NSNumber *_Nonnull)loginTracking
{
  _loginTracking = loginTracking;
}

- (NSNumber *)loginTracking
{
  return @([TiUtils intValue:_loginTracking def:FBSDKLoginTrackingEnabled]);
}

- (NSDate *_Nullable)expirationDate
{
  __block NSDate *expirationDate = nil;

  TiThreadPerformOnMainThread(
      ^{
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
  NSNumber *amount = [purchase objectAtIndex:0];
  NSString *currency = [TiUtils stringValue:[purchase objectAtIndex:1]];
  ENSURE_TYPE(amount, NSNumber);
  ENSURE_TYPE(currency, NSString);

  if (purchase.count > 2) {
    NSDictionary *parameters = [purchase objectAtIndex:2];
    ENSURE_TYPE(parameters, NSDictionary);

    [FBSDKAppEvents logPurchase:[amount doubleValue] currency:currency parameters:parameters];
  } else {
    [FBSDKAppEvents logPurchase:[amount doubleValue] currency:currency];
  }
}

- (void)logRegistrationCompleted:(NSString *_Nonnull)registrationMethod
{
  NSDictionary *params = @{ FBSDKAppEventParameterNameRegistrationMethod : registrationMethod };

  [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration parameters:params];
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

- (void)authorize:(__unused id)unused
{
  __block FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
  __block FBSDKLoginConfiguration *loginConfiguration = [[FBSDKLoginConfiguration alloc] initWithPermissions:_permissions
                                                                                                    tracking:[TiUtils intValue:_loginTracking
                                                                                                                           def:FBSDKLoginTrackingEnabled]];

  TiThreadPerformOnMainThread(
      ^{
        [loginManager logInFromViewController:nil
                                configuration:loginConfiguration
                                   completion:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                     // Handle error
                                     if (error != nil) {
                                       [self fireLogin:nil authenticationToken:result.authenticationToken cancelled:result.isCancelled withError:error];
                                       return;
                                     }

                                     // Login cancelled
                                     if (result.isCancelled) {
                                       [self fireLogin:nil authenticationToken:FBSDKAuthenticationToken.currentAuthenticationToken cancelled:YES withError:nil];
                                       return;
                                     }

                                     // Logged In
                                   }];
      },
      YES);
}

- (void)initialize:(__unused id)unused
{
  TiThreadPerformOnMainThread(
      ^{
        [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];

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
  TiThreadPerformOnMainThread(
      ^{
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logOut];
      },
      NO);
}

- (void)presentShareDialog:(NSArray<NSDictionary<NSString *, id> *> *_Nonnull)args
{
  NSDictionary *_Nonnull params = [args objectAtIndex:0];

  TiThreadPerformOnMainThread(
      ^{
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

  TiThreadPerformOnMainThread(
      ^{
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

- (void)presentSendRequestDialog:(NSArray<NSDictionary<NSString *, id> *> *)args
{
  NSDictionary *_Nonnull params = [args objectAtIndex:0];

  NSString *message = [params objectForKey:@"message"];
  NSString *title = [params objectForKey:@"title"];
  NSArray *recipients = [params objectForKey:@"recipients"];
  NSArray *recipientSuggestions = [params objectForKey:@"recipientSuggestions"];
  FBSDKGameRequestFilter filters = [TiUtils intValue:[params objectForKey:@"filters"]];
  NSString *objectID = [params objectForKey:@"objectID"];
  id tempData = [params objectForKey:@"data"];
  NSString *data = nil;
  if ([tempData isKindOfClass:[NSDictionary class]]) {
    NSData *dictonaryData = [NSJSONSerialization dataWithJSONObject:tempData options:NSJSONWritingPrettyPrinted error:nil];
    data = [[NSString alloc] initWithData:dictonaryData
                                 encoding:NSUTF8StringEncoding];
  } else {
    data = (NSString *)tempData;
  }

  FBSDKGameRequestActionType actionType = [TiUtils intValue:[params objectForKey:@"actionType"]];

  TiThreadPerformOnMainThread(
      ^{
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
  TiThreadPerformOnMainThread(
      ^{
      [FBSDKAccessToken refreshCurrentAccessTokenWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
          [self fireEvent:@"tokenUpdated" withObject:@{ @"success": @(error == nil), @"error": NULL_IF_NIL(error.localizedDescription) }];
        }];
      },
      NO);
}

- (void)requestNewReadPermissions:(NSArray<id> *_Nonnull)args
{
  DEPRECATED_REPLACED(@"Facebook.requestNewPublishPermissions", @"7.0.0", @"Facebook.authorize");

  NSArray<NSString *> *readPermissions = [args objectAtIndex:0];
  ENSURE_ARRAY(readPermissions);

  KrollCallback *callback = [args objectAtIndex:1];
  ENSURE_TYPE(callback, KrollCallback);

  FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];

  TiThreadPerformOnMainThread(
      ^{
        [loginManager logInWithPermissions:readPermissions
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
  DEPRECATED_REPLACED(@"Facebook.requestNewPublishPermissions", @"7.0.0", @"Facebook.authorize");

  NSArray<NSString *> *publishPermissions = [args objectAtIndex:0];
  ENSURE_ARRAY(publishPermissions);

  NSNumber *_defaultAudience = [args objectAtIndex:1];
  ENSURE_TYPE(_defaultAudience, NSNumber);
  FBSDKDefaultAudience defaultAudience = [TiUtils intValue:_defaultAudience];

  KrollCallback *callback = [args objectAtIndex:2];
  ENSURE_TYPE(callback, KrollCallback);

  FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
  loginManager.defaultAudience = defaultAudience;

  TiThreadPerformOnMainThread(
      ^{
        [loginManager logInWithPermissions:publishPermissions
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
                                                                                            eventObject:propertiesDict
                                                                                             thisObject:self];
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

  TiThreadPerformOnMainThread(
      ^{
        if ([FBSDKAccessToken currentAccessToken]) {
          [[[FBSDKGraphRequest alloc] initWithGraphPath:path parameters:params HTTPMethod:httpMethod]
           startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
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

  TiThreadPerformOnMainThread(
      ^{
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

#pragma mark Event Listeners

- (void)fireLogin:(id _Nullable)result authenticationToken:(FBSDKAuthenticationToken *_Nullable)authenticationToken cancelled:(BOOL)cancelled withError:(NSError *_Nullable)error
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
                                                 NULL_IF_NIL(profile.firstName), @"firstName",
                                                 NULL_IF_NIL(profile.middleName), @"middleName",
                                                 NULL_IF_NIL(profile.lastName), @"lastName",
                                                 NULL_IF_NIL(profile.name), @"name",
                                                 NULL_IF_NIL([profile.linkURL absoluteString]), @"linkURL",
                                                 nil];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
    NSString *resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [event setObject:resultString forKey:@"data"];

    if (_userID != nil) {
      [event setObject:_userID forKey:@"uid"];
    }
  }

  // Inject Open ID authentication token (for limited logins)
  if (authenticationToken != nil) {
    [event setObject:@{
      @"tokenString" : NULL_IF_NIL(authenticationToken.tokenString),
      @"graphDomain" : NULL_IF_NIL(authenticationToken.graphDomain),
      @"nonce" : NULL_IF_NIL(authenticationToken.nonce)
    }
              forKey:@"authenticationToken"];
  }

  [self fireEvent:@"login" withObject:event];
}

- (void)logEvents:(NSNotification *)notification
{
  [[FBSDKAppEvents singleton] activateApp];
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
    [self fireLogin:profile authenticationToken:FBSDKAuthenticationToken.currentAuthenticationToken cancelled:NO withError:nil];
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

#pragma mark Dialog utilities

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

#pragma mark Utilities

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
    return content;
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

    [nativePhotos addObject:nativePhoto];
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

MAKE_SYSTEM_PROP(LOGIN_TRACKING_ENABLED, FBSDKLoginTrackingEnabled);
MAKE_SYSTEM_PROP(LOGIN_TRACKING_LIMITED, FBSDKLoginTrackingLimited);

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

MAKE_SYSTEM_PROP(MESSENGER_BUTTON_MODE_RECTANGULAR, TiFacebookShareButtonModeRectangular);
MAKE_SYSTEM_PROP(MESSENGER_BUTTON_MODE_CIRCULAR, TiFacebookShareButtonModeCircular);

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

MAKE_SYSTEM_STR(EVENT_NAME_COMPLETED_REGISTRATION, FBSDKAppEventNameCompletedRegistration);
MAKE_SYSTEM_STR(EVENT_NAME_VIEWED_CONTENT, FBSDKAppEventNameViewedContent);
MAKE_SYSTEM_STR(EVENT_NAME_ADDED_TO_CART, FBSDKAppEventNameAddedToCart);
MAKE_SYSTEM_STR(EVENT_NAME_INITIATED_CHECKOUT, FBSDKAppEventNameInitiatedCheckout);
MAKE_SYSTEM_STR(EVENT_NAME_ADDED_PAYMENT_INFO, FBSDKAppEventNameAddedPaymentInfo);

MAKE_SYSTEM_STR(EVENT_PARAM_CONTENT, FBSDKAppEventParameterNameContent);
MAKE_SYSTEM_STR(EVENT_PARAM_CONTENT_ID, FBSDKAppEventParameterNameContentID);
MAKE_SYSTEM_STR(EVENT_PARAM_CONTENT_TYPE, FBSDKAppEventParameterNameContentType);
MAKE_SYSTEM_STR(EVENT_PARAM_CURRENCY, FBSDKAppEventParameterNameCurrency);
MAKE_SYSTEM_STR(EVENT_PARAM_NUM_ITEMS, FBSDKAppEventParameterNameNumItems);
MAKE_SYSTEM_STR(EVENT_PARAM_PAYMENT_INFO_AVAILABLE, FBSDKAppEventParameterNamePaymentInfoAvailable);

@end

NS_ASSUME_NONNULL_END
