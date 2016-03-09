/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookLoginButton.h"
#import "TiUtils.h"

@implementation FacebookLoginButton

-(void)dealloc
{
    RELEASE_TO_NIL(login);
    [super dealloc];
}

-(FBSDKLoginButton*)login
{
    if (login == nil) {
        login = [[FBSDKLoginButton alloc] init];
        [self addSubview:login];
    }
    return login;
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [TiUtils setView:[self login] positionRect:bounds];
}

//Requested permissions when logging in. If set, do not set read permissions.
//audience defaults to AUDIENCE_ONLY_ME if not specifically set
-(void)setPublishPermissions_:(id)publishPermissions
{
    ENSURE_ARRAY(publishPermissions);
    FBSDKLoginButton *loginBtn = [self login];
    loginBtn.publishPermissions = publishPermissions;
}

//Requested permissions when logging in. If set, do not set publish permissions.
-(void)setReadPermissions_:(id)readPermissions
{
    ENSURE_ARRAY(readPermissions);
    FBSDKLoginButton *loginBtn = [self login];
    loginBtn.readPermissions = readPermissions;
}

//default is AUDIENCE_ONLY_ME, only applicable to publish permissions
-(void)setAudience_:(id)audience
{
    ENSURE_SINGLE_ARG(audience, NSNumber);
    FBSDKLoginButton *loginBtn = [self login];
    loginBtn.defaultAudience = [audience intValue];
}
@end
