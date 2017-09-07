/**
 * Ti.Facebook
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookMessengerButton.h"
#import "FacebookMessengerButtonProxy.h"
#import "FacebookConstants.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FacebookMessengerButton

- (FacebookMessengerButtonProxy *)messengerProxy
{
    return (FacebookMessengerButtonProxy *)[self proxy];
}

- (UIButton *)messengerButton
{
    if (_messengerButton == nil) {
        NSUInteger mode = [TiUtils intValue:[[self messengerProxy] valueForKey:@"mode"] def:TiFacebookShareButtonModeRectangular];
        NSUInteger style = [TiUtils intValue:[[self messengerProxy] valueForKey:@"style"] def:FBSDKMessengerShareButtonStyleBlue];
        
        if (mode == TiFacebookShareButtonModeRectangular) {
            _messengerButton = [FBSDKMessengerShareButton rectangularButtonWithStyle:style];
        } else if (mode == TiFacebookShareButtonModeCircular) {
            if ([[self messengerProxy] valueForKey:@"width"]) {
                _messengerButton = [FBSDKMessengerShareButton circularButtonWithStyle:style width:[TiUtils floatValue:[[self messengerProxy] valueForKey:@"width"]]];
            } else {
                _messengerButton = [FBSDKMessengerShareButton circularButtonWithStyle:style];
            }
        } else {
            [[self messengerProxy] throwException:@"No messenger button mode specified." subreason:@"Please specify the messenger button mode to either MESSENGER_BUTTON_MODE_RECTANGULAR or MESSENGER_BUTTON_MODE_CIRCULAR" location:CODELOCATION];
        }
        
        [self setFrame:[_messengerButton bounds]];
        [self addSubview:_messengerButton];
        
        [_messengerButton addTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _messengerButton;
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [TiUtils setView:[self messengerButton] positionRect:bounds];
}

- (void)didTouchUpInside:(id)sender
{
    if ([[self messengerProxy] _hasListeners:@"click"]) {
        [[self messengerProxy] fireEvent:@"click" withObject:nil];
    }
}

- (BOOL)hasTouchableListener
{
    return YES;
}

- (CGFloat)verifyWidth:(CGFloat)suggestedWidth
{
    return [self sizeThatFits:CGSizeZero].width;
}

- (CGFloat)verifyHeight:(CGFloat)suggestedHeight
{
    return [self sizeThatFits:CGSizeZero].height;
}

@end

NS_ASSUME_NONNULL_END
