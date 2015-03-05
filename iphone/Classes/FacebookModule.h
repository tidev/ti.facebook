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

#import "TiModule.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

@protocol TiFacebookStateListener
@required
-(void)login;
-(void)logout;
@end

@interface FacebookModule : TiModule
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
