/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
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

-(FBLikeControl*)like
{
    if (like == nil)
    {
        like = [[FBLikeControl alloc] init];
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
    ENSURE_SINGLE_ARG(idString, NSString);
    FBLikeControl *btn = [self like];
    NSString* objectID = [TiUtils stringValue:idString];
    btn.objectID = objectID;
}

-(void)setForegroundColor_:(id)colorVal
{
    ENSURE_SINGLE_ARG(colorVal, NSObject);
    FBLikeControl *btn = [self like];
    UIColor *c = [[TiUtils colorValue:colorVal] color];
    btn.foregroundColor = c;
}

-(void)setLikeViewStyle_:(id)styleStr
{
    ENSURE_SINGLE_ARG(styleStr, NSString);
    FBLikeControl *btn = [self like];
    NSString* style = [TiUtils stringValue:styleStr];
    if ([style isEqualToString:@"box_count"]) {
        btn.likeControlStyle = FBLikeControlStyleBoxCount;
    } else if ([style isEqualToString:@"button"]) {
        btn.likeControlStyle = FBLikeControlStyleButton;
    } else {
        btn.likeControlStyle = FBLikeControlStyleStandard;
    }
}

-(void)setAuxiliaryViewPosition_:(id)positionStr
{
    ENSURE_SINGLE_ARG(positionStr, NSString);
    FBLikeControl *btn = [self like];
    NSString* position = [TiUtils stringValue:positionStr];
    if ([position isEqualToString:@"bottom"]) {
        btn.likeControlAuxiliaryPosition = FBLikeControlAuxiliaryPositionBottom;
    } else if ([position isEqualToString:@"inline"]) {
        btn.likeControlAuxiliaryPosition = FBLikeControlAuxiliaryPositionInline;
    } else if ([position isEqualToString:@"top"]) {
        btn.likeControlAuxiliaryPosition = FBLikeControlAuxiliaryPositionTop;
    }
}

-(void)setHorizontalAlignment_:(id)alignStr
{
    ENSURE_SINGLE_ARG(alignStr, NSString);
    FBLikeControl *btn = [self like];
    NSString* align = [TiUtils stringValue:alignStr];
    if ([align isEqualToString:@"center"]) {
        btn.likeControlHorizontalAlignment = FBLikeControlHorizontalAlignmentCenter;
    } else if ([align isEqualToString:@"left"]) {
        btn.likeControlHorizontalAlignment = FBLikeControlHorizontalAlignmentLeft;
    } else if ([align isEqualToString:@"right"]) {
        btn.likeControlHorizontalAlignment = FBLikeControlHorizontalAlignmentRight;
    }
}

-(void)setObjectType_:(id)typeStr
{
    ENSURE_SINGLE_ARG(typeStr, NSString);
    FBLikeControl *btn = [self like];
    NSString* oType = [TiUtils stringValue:typeStr];
    if ([oType isEqualToString:@"page"]) {
        btn.objectType = FBLikeControlObjectTypePage;
    } else if ([oType isEqualToString:@"openGraphObject"]) {
        btn.objectType = FBLikeControlObjectTypeOpenGraphObject;
    } else {
        btn.objectType = FBLikeControlObjectTypeUnknown;
    }
}

-(void)setSoundEnabled_:(id)sound
{
    ENSURE_SINGLE_ARG(sound, NSNumber);
    FBLikeControl *btn = [self like];
    btn.soundEnabled = [TiUtils boolValue:sound];
}

@end
