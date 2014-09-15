/**
 * FacebookIOS
 *
 * Created by Mark Mokryn
 * Copyright (c) 2014 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import <FacebookSDK/FacebookSDK.h>

@protocol TiFacebookStateListener
@required
-(void)login;
-(void)logout;
@end

@interface ComFacebookModule : TiModule
{
    BOOL loggedIn;
    BOOL canShare;
    NSString *uid;
    //NSString *url;
    NSArray *permissions;
    NSMutableArray *stateListeners;
}

-(BOOL)isLoggedIn;
-(BOOL)passedShareDialogCheck;
-(void)addListener:(id<TiFacebookStateListener>)listener;
-(void)removeListener:(id<TiFacebookStateListener>)listener;

-(void)authorize:(id)args;
-(void)logout:(id)args;

@end
