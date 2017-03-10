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

-(FBSDKLoginButton*)loginButton
{
    if (login == nil) {
        login = [FBSDKLoginButton new];
        [self addSubview:login];
    }
    return login;
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [TiUtils setView:[self loginButton] positionRect:bounds];
}

// Requested permissions when logging in. If set, do not set read permissions
// The audience defaults to AUDIENCE_ONLY_ME if not specifically set.
-(void)setPublishPermissions_:(id)args
{
    ENSURE_ARRAY(args);
    [[self loginButton] setPublishPermissions:args];
}

-(NSArray*)publishPermissions
{
    return [[self loginButton] publishPermissions];
}

// Requested permissions when logging in. If set, do not set publish permissions
-(void)setReadPermissions_:(id)args
{
    ENSURE_ARRAY(args);
    [[self loginButton] setReadPermissions:args];
}

-(NSArray*)readPermissions
{
    return [[self loginButton] readPermissions];
}

// The default is AUDIENCE_ONLY_ME, only applicable to publish permissions
-(void)setAudience_:(id)value
{
    ENSURE_SINGLE_ARG(value, NSNumber);
    [[self loginButton] setDefaultAudience:[TiUtils intValue:value]];
}

// The default audience to use, if publish permissions are requested at login time.
-(NSNumber*)audience
{
    return NUMUINTEGER([[self loginButton] defaultAudience]);
}

// Sets the desired tooltip behavior
-(void)setTooltipBehavior_:(id)value
{
    ENSURE_SINGLE_ARG(value, NSNumber);
    [[self loginButton] setTooltipBehavior:[TiUtils intValue:value]];
}

// Gets the desired tooltip behavior
-(NSNumber*)tooltipBehavior
{
    return NUMUINTEGER([[self loginButton] tooltipBehavior]);
}

// Sets the desired tooltip color style
-(void)setTooltipColorStyle_:(id)value
{
    ENSURE_SINGLE_ARG(value, NSNumber);
    [[self loginButton] setTooltipColorStyle:[TiUtils intValue:value]];
}

// Gets the desired tooltip color style
-(NSNumber*)tooltipColorStyle
{
    return NUMUINTEGER([[self loginButton] tooltipColorStyle]);
}

@end
