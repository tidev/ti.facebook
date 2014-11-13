/**
 * FacebookIOS
 *
 * Created by Mark Mokryn
 * Copyright (c) 2014 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

@protocol TiFacebookStateListener
@required
-(void)login;
-(void)logout;
@end

@interface ComFacebookModule : TiModule
{
    NSString *uid;
    NSArray *permissions;
    NSMutableArray *stateListeners;
}

-(void)addListener:(id<TiFacebookStateListener>)listener;
-(void)removeListener:(id<TiFacebookStateListener>)listener;

-(void)authorize:(id)args;
-(void)logout:(id)args;

@end
