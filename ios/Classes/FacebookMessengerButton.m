/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookMessengerButton.h"
#import "FacebookMessengerButtonProxy.h"
#import "FacebookConstants.h"

@implementation FacebookMessengerButton

-(void)dealloc
{
    [messengerButton removeTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    RELEASE_TO_NIL(messengerButton);
    
    [super dealloc];
}

-(FacebookMessengerButtonProxy*)messengerProxy
{
    return (FacebookMessengerButtonProxy*)[self proxy];
}

-(UIButton*)messengerButton
{
    ENSURE_UI_THREAD_0_ARGS
    
    if (messengerButton == nil) {
        ENSURE_TYPE([[self messengerProxy] valueForKey:@"mode"], NSNumber);
        ENSURE_TYPE([[self messengerProxy] valueForKey:@"style"], NSNumber);

        NSUInteger mode = [TiUtils intValue:[[self messengerProxy] valueForKey:@"mode"] def:TiFacebookShareButtonModeRectangular];
        NSUInteger style = [TiUtils intValue:[[self messengerProxy] valueForKey:@"style"] def:FBSDKMessengerShareButtonStyleBlue];
        
        if (mode == TiFacebookShareButtonModeRectangular) {
            messengerButton = [FBSDKMessengerShareButton rectangularButtonWithStyle:style];
        } else if (mode == TiFacebookShareButtonModeCircular) {
            if ([[self messengerProxy] valueForKey:@"width"]) {
                messengerButton = [FBSDKMessengerShareButton circularButtonWithStyle:style width:[TiUtils floatValue:[[self messengerProxy] valueForKey:@"width"]]];
            } else {
                messengerButton = [FBSDKMessengerShareButton circularButtonWithStyle:style];
            }
        } else {
            [[self messengerProxy] throwException:@"No messenger button mode specified." subreason:@"Please specify the messenger button mode to either MESSENGER_BUTTON_MODE_RECTANGULAR or MESSENGER_BUTTON_MODE_CIRCULAR" location:CODELOCATION];
            return;
        }
        
        [self setFrame:[messengerButton bounds]];
        [self addSubview:messengerButton];
        
        [messengerButton addTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

    }
    return messengerButton;
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [TiUtils setView:[self messengerButton] positionRect:bounds];
}

- (IBAction)didTouchUpInside:(id)sender
{
    if ([[self messengerProxy] _hasListeners:@"click"]) {
        [[self messengerProxy] fireEvent:@"click" withObject:nil];
    }
}

-(BOOL)hasTouchableListener
{
    return YES;
}

-(CGFloat)verifyWidth:(CGFloat)suggestedWidth
{
    return [self sizeThatFits:CGSizeZero].width;
}

-(CGFloat)verifyHeight:(CGFloat)suggestedHeight
{
    return [self sizeThatFits:CGSizeZero].height;
}

@end
