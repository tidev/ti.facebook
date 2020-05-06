let Facebook;

const IOS = (Ti.Platform.osname === 'iphone' || Ti.Platform.osname === 'ipad');
const ANDROID = (Ti.Platform.osname === 'android');

describe('ti.facebook', () => {
	it('can be required', () => {
		Facebook = require('facebook');

		expect(Facebook).toBeDefined();
	});

	describe('module', () => {
		it('.apiName', () => {
			expect(Facebook.apiName).toBe('Ti.Facebook');
		});
		if (IOS) {
			it('.moduleId', () => {
				expect(Facebook.moduleId).toBe('facebook');
			});
		}

		// TODO: moduleid, guid, name
		// TODO: properties

		describe('properties', () => {
			describe('.loginButton', () => {
				it('defaults to undefined', () => {
					expect(Facebook.loginButton).not.toBeDefined();
				});
			});
			describe('.loggedIn', () => {
				it('defaults to false', () => {
					expect(Facebook.loggedIn).toEqual(false);
				});
			});
			describe('.appID', () => {
				it('defaults to undefined', () => {
					expect(Facebook.appID).not.toBeDefined();
				});
			});
			describe('.accessTokenExpired', () => {
				it('defaults to false', () => {
					expect(Facebook.accessTokenExpired).toEqual(false);
				});
			});
			describe('.accessTokenActive', () => {
				it('defaults to false', () => {
					expect(Facebook.accessTokenActive).toEqual(false);
				});
			});
			if (ANDROID) {
				describe('.uid android', () => {
					it('defaults to defined', () => {
						expect(Facebook.uid).toBeDefined();
					});
				});
				describe('.permissions android', () => {
					it('defaults to defined', () => {
						expect(Facebook.permissions).toBeDefined();
					});
				});
				describe('.accessToken android', () => {
					it('defaults to defined', () => {
						expect(Facebook.accessToken).toBeDefined();
					});
				});
				describe('.EVENT_LOGIN', () => {
					it('defaults to undefined', () => {
						expect(Facebook.EVENT_LOGIN).not.toBeDefined();
					});
				});
				describe('.EVENT_LOGOUT', () => {
					it('defaults to undefined', () => {
						expect(Facebook.EVENT_LOGOUT).not.toBeDefined();
					});
				});
				describe('.EVENT_TOKEN_UPDATED', () => {
					it('defaults to undefined', () => {
						expect(Facebook.EVENT_TOKEN_UPDATED).not.toBeDefined();
					});
				});
				describe('.PROPERTY_SUCCESS', () => {
					it('defaults to undefined', () => {
						expect(Facebook.PROPERTY_SUCCESS).not.toBeDefined();
					});
				});
				describe('.PROPERTY_CANCELLED', () => {
					it('defaults to undefined', () => {
						expect(Facebook.PROPERTY_CANCELLED).not.toBeDefined();
					});
				});
				describe('.PROPERTY_ERROR', () => {
					it('defaults to undefined', () => {
						expect(Facebook.PROPERTY_ERROR).not.toBeDefined();
					});
				});
				describe('.PROPERTY_CODE', () => {
					it('defaults to undefined', () => {
						expect(Facebook.PROPERTY_CODE).not.toBeDefined();
					});
				});
				describe('.PROPERTY_DATA', () => {
					it('defaults to undefined', () => {
						expect(Facebook.PROPERTY_DATA).not.toBeDefined();
					});
				});
				describe('.PROPERTY_UID', () => {
					it('defaults to undefined', () => {
						expect(Facebook.PROPERTY_UID).not.toBeDefined();
					});
				});
				describe('.PROPERTY_RESULT', () => {
					it('defaults to undefined', () => {
						expect(Facebook.PROPERTY_RESULT).not.toBeDefined();
					});
				});
				describe('.EVENT_SHARE_COMPLETE', () => {
					it('defaults to undefined', () => {
						expect(Facebook.EVENT_SHARE_COMPLETE).not.toBeDefined();
					});
				});
				describe('.EVENT_REQUEST_DIALOG_COMPLETE', () => {
					it('defaults to undefined', () => {
						expect(Facebook.EVENT_REQUEST_DIALOG_COMPLETE).not.toBeDefined();
					});
				});
				describe('.getFacebookModule', () => {
					it('defaults to undefined', () => {
						expect(Facebook.getFacebookModule).not.toBeDefined();
					});
				});
				describe('.getCallbackManager', () => {
					it('defaults to undefined', () => {
						expect(Facebook.getCallbackManager).not.toBeDefined();
					});
				});
				describe('.getFacebookCallback', () => {
					it('defaults to undefined', () => {
						expect(Facebook.getFacebookCallback).not.toBeDefined();
					});
				});
				describe('.makeMeRequest(accessToken)', () => {
					it('defaults to undefined', () => {
						expect(Facebook.getFacebookCallback).not.toBeDefined();
					});
				});
			}
			if (IOS) {
				describe('.uid ios', () => {
					it('defaults to undefined', () => {
						expect(Facebook.uid).not.toBeDefined();
					});
				});
				describe('.permissions ios', () => {
					it('defaults to undefined', () => {
						expect(Facebook.permissions).not.toBeDefined();
					});
				});
				describe('.accessToken ios', () => {
					it('defaults to undefined', () => {
						expect(Facebook.accessToken).not.toBeDefined();
					});
				});
			}
		});

		describe('constants', () => {
			describe('AUDIENCE_*', () => {
				if (ANDROID) {
					it('AUDIENCE_NONE', () => {
						expect(Facebook.AUDIENCE_NONE).toEqual(jasmine.any(Number));
					});
				}

				it('AUDIENCE_ONLY_ME', () => {
					expect(Facebook.AUDIENCE_ONLY_ME).toEqual(jasmine.any(Number));
				});

				it('AUDIENCE_FRIENDS', () => {
					expect(Facebook.AUDIENCE_FRIENDS).toEqual(jasmine.any(Number));
				});

				it('AUDIENCE_EVERYONE', () => {
					expect(Facebook.AUDIENCE_EVERYONE).toEqual(jasmine.any(Number));
				});
			});

			describe('ACTION_TYPE_*', () => {
				it('ACTION_TYPE_NONE', () => {
					expect(Facebook.ACTION_TYPE_NONE).toEqual(jasmine.any(Number));
				});

				it('ACTION_TYPE_SEND', () => {
					expect(Facebook.ACTION_TYPE_SEND).toEqual(jasmine.any(Number));
				});

				it('ACTION_TYPE_ASK_FOR', () => {
					expect(Facebook.ACTION_TYPE_ASK_FOR).toEqual(jasmine.any(Number));
				});

				it('ACTION_TYPE_TURN', () => {
					expect(Facebook.ACTION_TYPE_TURN).toEqual(jasmine.any(Number));
				});
			});

			describe('FILTER_*', () => {
				it('FILTER_NONE', () => {
					expect(Facebook.FILTER_NONE).toEqual(jasmine.any(Number));
				});

				it('FILTER_APP_USERS', () => {
					expect(Facebook.FILTER_APP_USERS).toEqual(jasmine.any(Number));
				});

				it('FILTER_APP_NON_USERS', () => {
					expect(Facebook.FILTER_APP_NON_USERS).toEqual(jasmine.any(Number));
				});
			});
			if (ANDROID) {
				describe('LOGIN_BEHAVIOR_*', () => {
					it('LOGIN_BEHAVIOR_NATIVE_WITH_FALLBACK', () => {
						expect(Facebook.LOGIN_BEHAVIOR_NATIVE_WITH_FALLBACK).toEqual(jasmine.any(Number));
					});

					it('LOGIN_BEHAVIOR_DEVICE_AUTH', () => {
						expect(Facebook.LOGIN_BEHAVIOR_DEVICE_AUTH).toEqual(jasmine.any(Number));
					});

					it('LOGIN_BEHAVIOR_BROWSER', () => {
						expect(Facebook.LOGIN_BEHAVIOR_BROWSER).toEqual(jasmine.any(Number));
					});

					it('LOGIN_BEHAVIOR_WEB', () => {
						expect(Facebook.LOGIN_BEHAVIOR_WEB).toEqual(jasmine.any(Number));
					});

					it('LOGIN_BEHAVIOR_NATIVE', () => {
						expect(Facebook.LOGIN_BEHAVIOR_NATIVE).toEqual(jasmine.any(Number));
					});
				});
			}

			describe('SHARE_DIALOG_MODE_*', () => {
				it('SHARE_DIALOG_MODE_AUTOMATIC', () => {
					expect(Facebook.SHARE_DIALOG_MODE_AUTOMATIC).toEqual(jasmine.any(Number));
				});

				it('SHARE_DIALOG_MODE_NATIVE', () => {
					expect(Facebook.SHARE_DIALOG_MODE_NATIVE).toEqual(jasmine.any(Number));
				});

				it('SHARE_DIALOG_MODE_WEB', () => {
					expect(Facebook.SHARE_DIALOG_MODE_WEB).toEqual(jasmine.any(Number));
				});

				it('SHARE_DIALOG_MODE_FEED_WEB', () => {
					expect(Facebook.SHARE_DIALOG_MODE_FEED_WEB).toEqual(jasmine.any(Number));
				});

				if (IOS) {
					it('SHARE_DIALOG_MODE_SHARE_SHEET', () => {
						expect(Facebook.SHARE_DIALOG_MODE_SHARE_SHEET).toEqual(jasmine.any(Number));
					});

					it('SHARE_DIALOG_MODE_BROWSER', () => {
						expect(Facebook.SHARE_DIALOG_MODE_BROWSER).toEqual(jasmine.any(Number));
					});

					it('SHARE_DIALOG_MODE_FEED_BROWSER', () => {
						expect(Facebook.SHARE_DIALOG_MODE_FEED_BROWSER).toEqual(jasmine.any(Number));
					});
				}
			});

			describe('LOGIN_BUTTON_TOOLTIP_BEHAVIOR_*', () => {
				it('LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC', () => {
					expect(Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC).toEqual(jasmine.any(Number));
				});

				it('LOGIN_BUTTON_TOOLTIP_BEHAVIOR_FORCE_DISPLAY', () => {
					expect(Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_FORCE_DISPLAY).toEqual(jasmine.any(Number));
				});

				it('LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE', () => {
					expect(Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE).toEqual(jasmine.any(Number));
				});
			});

			describe('LOGIN_BUTTON_TOOLTIP_STYLE_*', () => {
				// FIXME: On Android these are Strings, but in docs/iOS they're numbers!
				it('LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY', () => {
					expect(Facebook.LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY).toEqual(jasmine.any(Number));
				});

				it('LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE', () => {
					expect(Facebook.LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE).toEqual(jasmine.any(Number));
				});
			});

			describe('EVENT_NAME_*', () => {
				it('EVENT_NAME_COMPLETED_REGISTRATION', () => {
					expect(Facebook.EVENT_NAME_COMPLETED_REGISTRATION).toEqual(jasmine.any(String));
				});

				it('EVENT_NAME_VIEWED_CONTENT', () => {
					expect(Facebook.EVENT_NAME_VIEWED_CONTENT).toEqual(jasmine.any(String));
				});

				it('EVENT_NAME_ADDED_TO_CART', () => {
					expect(Facebook.EVENT_NAME_ADDED_TO_CART).toEqual(jasmine.any(String));
				});

				it('EVENT_NAME_INITIATED_CHECKOUT', () => {
					expect(Facebook.EVENT_NAME_INITIATED_CHECKOUT).toEqual(jasmine.any(String));
				});

				it('EVENT_NAME_ADDED_PAYMENT_INFO', () => {
					expect(Facebook.EVENT_NAME_ADDED_PAYMENT_INFO).toEqual(jasmine.any(String));
				});
			});

			describe('EVENT_PARAM_*', () => {
				it('EVENT_PARAM_CONTENT', () => {
					expect(Facebook.EVENT_PARAM_CONTENT).toEqual(jasmine.any(String));
				});

				it('EVENT_PARAM_CONTENT_ID', () => {
					expect(Facebook.EVENT_PARAM_CONTENT_ID).toEqual(jasmine.any(String));
				});

				it('EVENT_PARAM_CONTENT_TYPE', () => {
					expect(Facebook.EVENT_PARAM_CONTENT_TYPE).toEqual(jasmine.any(String));
				});

				it('EVENT_PARAM_CURRENCY', () => {
					expect(Facebook.EVENT_PARAM_CURRENCY).toEqual(jasmine.any(String));
				});

				it('EVENT_PARAM_NUM_ITEMS', () => {
					expect(Facebook.EVENT_PARAM_NUM_ITEMS).toEqual(jasmine.any(String));
				});

				it('EVENT_PARAM_PAYMENT_INFO_AVAILABLE', () => {
					expect(Facebook.EVENT_PARAM_PAYMENT_INFO_AVAILABLE).toEqual(jasmine.any(String));
				});
			});
		});

		describe('methods', () => {
			describe('#authorize()', () => {
				it('is a function', () => {
					expect(Facebook.authorize).toEqual(jasmine.any(Function));
				});
			});

			describe('#createActivityWorker(params)', () => {
				it('is a function', () => {
					expect(Facebook.createActivityWorker).toEqual(jasmine.any(Function));
				});
			});

			describe('#createLoginButton(params)', () => {
				it('is a function', () => {
					expect(Facebook.createLoginButton).toEqual(jasmine.any(Function));
				});
			});

			describe('#fetchDeferredAppLink(callback)', () => {
				it('is a function', () => {
					expect(Facebook.fetchDeferredAppLink).toEqual(jasmine.any(Function));
				});
			});

			describe('#initialize()', () => {
				it('is a function', () => {
					expect(Facebook.initialize).toEqual(jasmine.any(Function));
				});
			});

			describe('#logCustomEvent(event, [valueToSum], [params])', () => {
				it('is a function', () => {
					expect(Facebook.logCustomEvent).toEqual(jasmine.any(Function));
				});
			});

			describe('#logPurchase(amount, currency)', () => {
				it('is a function', () => {
					expect(Facebook.logPurchase).toEqual(jasmine.any(Function));
				});
			});

			describe('#logPushNotificationOpen(payload, [action])', () => {
				it('is a function', () => {
					expect(Facebook.logPushNotificationOpen).toEqual(jasmine.any(Function));
				});
			});

			describe('#logout()', () => {
				it('is a function', () => {
					expect(Facebook.logout).toEqual(jasmine.any(Function));
				});
			});

			describe('#presentPhotoShareDialog(params)', () => {
				it('is a function', () => {
					expect(Facebook.presentPhotoShareDialog).toEqual(jasmine.any(Function));
				});
			});

			describe('#presentSendRequestDialog(params)', () => {
				it('is a function', () => {
					expect(Facebook.presentSendRequestDialog).toEqual(jasmine.any(Function));
				});
			});

			describe('#presentShareDialog(params)', () => {
				it('is a function', () => {
					expect(Facebook.presentShareDialog).toEqual(jasmine.any(Function));
				});
			});

			describe('#refreshPermissionsFromServer()', () => {
				it('is a function', () => {
					expect(Facebook.refreshPermissionsFromServer).toEqual(jasmine.any(Function));
				});
			});

			describe('#requestNewPublishPermissions(permissions, audience, callback)', () => {
				it('is a function', () => {
					expect(Facebook.requestNewPublishPermissions).toEqual(jasmine.any(Function));
				});
			});

			describe('#requestNewReadPermissions(permissions, callback)', () => {
				it('is a function', () => {
					expect(Facebook.requestNewReadPermissions).toEqual(jasmine.any(Function));
				});
			});

			describe('#requestWithGraphPath(path, params, httpMethod, callback)', () => {
				it('is a function', () => {
					expect(Facebook.requestWithGraphPath).toEqual(jasmine.any(Function));
				});
			});

			describe('#setPushNotificationsDeviceToken(deviceToken)', () => {
				it('is a function', () => {
					expect(Facebook.setPushNotificationsDeviceToken).toEqual(jasmine.any(Function));
				});
			});

			describe('#logRegistrationCompleted(registrationMethod)', () => {
				it('is a function', () => {
					expect(Facebook.logRegistrationCompleted).toEqual(jasmine.any(Function));
				});
			});

			if (IOS) {
				describe('#setCurrentAccessToken(params)', () => {
					it('is a function', () => {
						expect(Facebook.setCurrentAccessToken).toEqual(jasmine.any(Function));
					});
				});
				describe('#handleRelaunch(notification)', () => {
					it('is a function', () => {
						expect(Facebook.handleRelaunch).toEqual(jasmine.any(Function));
					});
				});
				describe('#resumed(note)', () => {
					it('is a function', () => {
						expect(Facebook.resumed).toEqual(jasmine.any(Function));
					});
				});
				describe('#activateApp(notification)', () => {
					it('is a function', () => {
						expect(Facebook.activateApp).toEqual(jasmine.any(Function));
					});
				});
				describe('#shutdown(sender)', () => {
					it('is a function', () => {
						expect(Facebook.shutdown).toEqual(jasmine.any(Function));
					});
				});
				describe('#setPermissions(permissions)', () => {
					it('is a function', () => {
						expect(Facebook.setPermissions).toEqual(jasmine.any(Function));
					});
				});
			}
			if (ANDROID) {
				describe('#setLoginBehavior(behaviorConstant)', () => {
					it('is a function', () => {
						expect(Facebook.setLoginBehavior).toEqual(jasmine.any(Function));
					});
				});
				describe('#getLoginBehavior(behaviorConstant)', () => {
					it('is a function', () => {
						expect(Facebook.getLoginBehavior).toEqual(jasmine.any(Function));
					});
				});
			}
		});
	});
});
