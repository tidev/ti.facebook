/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookLikeButton.h"
#import "TiUtils.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FacebookLikeButton

#pragma mark Internal

- (FBSDKLikeControl *)likeButton
{
    if (_likeButton == nil) {
        _likeButton = [[FBSDKLikeControl alloc] init];
        [self addSubview:_likeButton];
    }

    return _likeButton;
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [TiUtils setView:[self likeButton] positionRect:bounds];
}

#pragma mark Public API's

- (void)setObjectType_:(__unused id)unused
{
    DEPRECATED_REMOVED(@"Facebook.likeButton.objectType", @"5.0.0", @"5.0.0");
}

- (void)setObjectId_:(__unused id)unused
{
    DEPRECATED_REPLACED_REMOVED(@"Facebook.likeButton.objectId", @"5.0.0", @"5.0.0", @"Titanium.Facebook.likeButton.objectID");
}

- (void)setObjectID_:(NSString * _Nonnull)objectID
{
    [[self likeButton] setObjectID:objectID];
}

- (void)setForegroundColor_:(NSString * _Nonnull)foregroundColor
{
    [[self likeButton] setForegroundColor:[[TiUtils colorValue:foregroundColor] color]];
}

- (void)setLikeViewStyle_:(NSString * _Nonnull)likeViewStyle
{
    FBSDKLikeControl *btn = [self likeButton];

    if ([likeViewStyle isEqualToString:@"box_count"]) {
        btn.likeControlStyle = FBSDKLikeControlStyleBoxCount;
        return;
    }
    
    if ([likeViewStyle isEqualToString:@"button"]) {
        DEPRECATED_REMOVED(@"Facebook.likeButton.likeViewStyle = \"button\"", @"5.0.0", @"5.0.0");
    }

    btn.likeControlStyle = FBSDKLikeControlStyleStandard;
}

- (void)setAuxiliaryViewPosition_:(NSString * _Nonnull)auxiliaryViewPosition
{
    FBSDKLikeControl *btn = [self likeButton];

    if ([auxiliaryViewPosition isEqualToString:@"bottom"]) {
        btn.likeControlAuxiliaryPosition = FBSDKLikeControlAuxiliaryPositionBottom;
    } else if ([auxiliaryViewPosition isEqualToString:@"inline"]) {
        btn.likeControlAuxiliaryPosition = FBSDKLikeControlAuxiliaryPositionInline;
    } else if ([auxiliaryViewPosition isEqualToString:@"top"]) {
        btn.likeControlAuxiliaryPosition = FBSDKLikeControlAuxiliaryPositionTop;
    } else {
        NSLog(@"[ERROR] Unknown LikeButton value for \"auxiliaryViewPosition\" provided: %@", auxiliaryViewPosition);
    }
}

- (void)setHorizontalAlignment_:(NSString * _Nonnull)horizontalAlignment
{
    FBSDKLikeControl *btn = [self likeButton];

    if ([horizontalAlignment isEqualToString:@"center"]) {
        btn.likeControlHorizontalAlignment = FBSDKLikeControlHorizontalAlignmentCenter;
    } else if ([horizontalAlignment isEqualToString:@"left"]) {
        btn.likeControlHorizontalAlignment = FBSDKLikeControlHorizontalAlignmentLeft;
    } else if ([horizontalAlignment isEqualToString:@"right"]) {
        btn.likeControlHorizontalAlignment = FBSDKLikeControlHorizontalAlignmentRight;
    } else {
        NSLog(@"[ERROR] Unknown LikeButton value for \"horizontalAlignment\" provided: %@", horizontalAlignment);
    }
}

- (void)setSoundEnabled_:(NSNumber * _Nonnull)soundEnabled
{
    [[self likeButton] setSoundEnabled:[TiUtils boolValue:soundEnabled]];
}

@end

NS_ASSUME_NONNULL_END
