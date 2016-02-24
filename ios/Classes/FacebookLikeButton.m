/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookLikeButton.h"
#import "TiUtils.h"

@implementation FacebookLikeButton

-(void)dealloc
{
    RELEASE_TO_NIL(like);
    [super dealloc];
}

-(FBSDKLikeControl*)like
{
    if (like == nil) {
        like = [[FBSDKLikeControl alloc] init];
        [self addSubview:like];
    }
    return like;
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [TiUtils setView:[self like] positionRect:bounds];
}

-(void)setObjectId_:(id)idString
{
    DEPRECATED_REPLACED_REMOVED(@"Facebook.likeButton.objectId", @"5.0.0", @"5.0.0", @"Titanium.Facebook.likeButton.objectID");
}

-(void)setObjectID_:(id)idString
{
    ENSURE_SINGLE_ARG(idString, NSString);
    FBSDKLikeControl *btn = [self like];
    NSString* objectID = [TiUtils stringValue:idString];
    btn.objectID = objectID;
}

-(void)setForegroundColor_:(id)colorVal
{
    ENSURE_SINGLE_ARG(colorVal, NSObject);
    FBSDKLikeControl *btn = [self like];
    UIColor *c = [[TiUtils colorValue:colorVal] color];
    btn.foregroundColor = c;
}

-(void)setLikeViewStyle_:(id)styleStr
{
    ENSURE_SINGLE_ARG(styleStr, NSString);
    FBSDKLikeControl *btn = [self like];
    NSString* style = [TiUtils stringValue:styleStr];
    if ([style isEqualToString:@"box_count"]) {
        btn.likeControlStyle = FBSDKLikeControlStyleBoxCount;
    } else if ([style isEqualToString:@"button"]) {
        DEPRECATED_REMOVED(@"Facebook.likeButton.likeViewStyle.button", @"5.0.0", @"5.0.0");
        btn.likeControlStyle = FBSDKLikeControlStyleStandard;
    } else {
        btn.likeControlStyle = FBSDKLikeControlStyleStandard;
    }
}

-(void)setAuxiliaryViewPosition_:(id)positionStr
{
    ENSURE_SINGLE_ARG(positionStr, NSString);
    FBSDKLikeControl *btn = [self like];
    NSString* position = [TiUtils stringValue:positionStr];
    if ([position isEqualToString:@"bottom"]) {
        btn.likeControlAuxiliaryPosition = FBSDKLikeControlAuxiliaryPositionBottom;
    } else if ([position isEqualToString:@"inline"]) {
        btn.likeControlAuxiliaryPosition = FBSDKLikeControlAuxiliaryPositionInline;
    } else if ([position isEqualToString:@"top"]) {
        btn.likeControlAuxiliaryPosition = FBSDKLikeControlAuxiliaryPositionTop;
    }
}

-(void)setHorizontalAlignment_:(id)alignStr
{
    ENSURE_SINGLE_ARG(alignStr, NSString);
    FBSDKLikeControl *btn = [self like];
    NSString* align = [TiUtils stringValue:alignStr];
    if ([align isEqualToString:@"center"]) {
        btn.likeControlHorizontalAlignment = FBSDKLikeControlHorizontalAlignmentCenter;
    } else if ([align isEqualToString:@"left"]) {
        btn.likeControlHorizontalAlignment = FBSDKLikeControlHorizontalAlignmentLeft;
    } else if ([align isEqualToString:@"right"]) {
        btn.likeControlHorizontalAlignment = FBSDKLikeControlHorizontalAlignmentRight;
    }
}

-(void)setObjectType_:(id)typeStr
{
    ENSURE_SINGLE_ARG(typeStr, NSString);
    DEPRECATED_REMOVED(@"Facebook.likeButton.objectType", @"5.0.0", @"5.0.0");
}

-(void)setSoundEnabled_:(id)sound
{
    ENSURE_SINGLE_ARG(sound, NSNumber);
    FBSDKLikeControl *btn = [self like];
    btn.soundEnabled = [TiUtils boolValue:sound];
}

@end
