/**
 * Ti.Facebook
 *
 * Copyright (c) 2014 by Mark Mokryn, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 * Copyright (c) 2009-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "FacebookConstants.h"

#import <Foundation/Foundation.h>

NSString * const TiFacebookEventTypeShareCompleted = @"shareCompleted";

NSString * const TiFacebookEventTypeInviteCompleted = @"inviteCompleted";

NSString * const TiFacebookEventTypeRequestDialogCompleted = @"requestDialogCompleted";

NSString * const TiFacebookErrorMessageKeychainAccess = @"Error 308 detected: Please enable keychain-sharing in your project"
                                                        @"by creating an Entitlements file. For more information check the"
                                                        @"\"Migrate to iOS 10\" section in "
                                                        @"https://docs.appcelerator.com/platform/latest/#!/api/Modules.Facebook";
