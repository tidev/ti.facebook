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

		// TODO: moduleid, guid, name
		// TODO: properties

		describe('constants', () => {
			describe('AUDIENCE_*', () => {
				// FIXME: Android has an AUDIENCE_NONE constant!
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

			if (IOS) { // iOS-specific constants
				describe('PLACE_LOCATION_CONFIDENCE_*', () => {
					it('PLACE_LOCATION_CONFIDENCE_NOT_APPLICABLE', () => {
						expect(Facebook.PLACE_LOCATION_CONFIDENCE_NOT_APPLICABLE).toEqual(jasmine.any(Number));
					});

					it('PLACE_LOCATION_CONFIDENCE_LOW', () => {
						expect(Facebook.PLACE_LOCATION_CONFIDENCE_LOW).toEqual(jasmine.any(Number));
					});

					it('PLACE_LOCATION_CONFIDENCE_MEDIUM', () => {
						expect(Facebook.PLACE_LOCATION_CONFIDENCE_MEDIUM).toEqual(jasmine.any(Number));
					});

					it('PLACE_LOCATION_CONFIDENCE_HIGH', () => {
						expect(Facebook.PLACE_LOCATION_CONFIDENCE_HIGH).toEqual(jasmine.any(Number));
					});
				});
			}

			describe('LOGIN_BEHAVIOR_*', () => {
				// FIXME: On Android these are Strings, but in docs/iOS they're numbers!
				it('LOGIN_BEHAVIOR_BROWSER', () => {
					expect(Facebook.LOGIN_BEHAVIOR_BROWSER).toEqual(jasmine.any(Number));
				});

				it('LOGIN_BEHAVIOR_NATIVE', () => {
					expect(Facebook.LOGIN_BEHAVIOR_NATIVE).toEqual(jasmine.any(Number));
				});

				if (ANDROID) {
					it('LOGIN_BEHAVIOR_NATIVE_WITH_FALLBACK', () => {
						expect(Facebook.LOGIN_BEHAVIOR_NATIVE_WITH_FALLBACK).toEqual(jasmine.any(Number));
					});

					it('LOGIN_BEHAVIOR_DEVICE_AUTH', () => {
						expect(Facebook.LOGIN_BEHAVIOR_DEVICE_AUTH).toEqual(jasmine.any(Number));
					});
				}

				if (IOS) {
					it('LOGIN_BEHAVIOR_SYSTEM_ACCOUNT', () => {
						expect(Facebook.LOGIN_BEHAVIOR_SYSTEM_ACCOUNT).toEqual(jasmine.any(Number));
					});

					it('LOGIN_BEHAVIOR_WEB', () => {
						expect(Facebook.LOGIN_BEHAVIOR_WEB).toEqual(jasmine.any(Number));
					});
				}
			});

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

			if (IOS) {
				describe('MESSENGER_BUTTON_MODE_*', () => {
					it('MESSENGER_BUTTON_MODE_CIRCULAR', () => {
						expect(Facebook.MESSENGER_BUTTON_MODE_CIRCULAR).toEqual(jasmine.any(Number));
					});

					it('MESSENGER_BUTTON_MODE_RECTANGULAR', () => {
						expect(Facebook.MESSENGER_BUTTON_MODE_RECTANGULAR).toEqual(jasmine.any(Number));
					});
				});

				describe('MESSENGER_BUTTON_STYLE_*', () => {
					it('MESSENGER_BUTTON_STYLE_BLUE', () => {
						expect(Facebook.MESSENGER_BUTTON_STYLE_BLUE).toEqual(jasmine.any(Number));
					});

					it('MESSENGER_BUTTON_STYLE_WHITE', () => {
						expect(Facebook.MESSENGER_BUTTON_STYLE_WHITE).toEqual(jasmine.any(Number));
					});

					it('MESSENGER_BUTTON_STYLE_WHITE_BORDERED', () => {
						expect(Facebook.MESSENGER_BUTTON_STYLE_WHITE_BORDERED).toEqual(jasmine.any(Number));
					});
				});
			}

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

			// FIXME: iOS specific APIs, ideally we'd have implementatiosn for Android!
			if (IOS) {
				describe('#createMessengerButton(params)', () => {
					it('is a function', () => {
						expect(Facebook.createMessengerButton).toEqual(jasmine.any(Function));
					});
				});

				describe('#fetchNearbyPlacesForCurrentLocation([confidenceLevel], [fields], success, error)', () => {
					it('is a function', () => {
						expect(Facebook.fetchNearbyPlacesForCurrentLocation).toEqual(jasmine.any(Function));
					});
				});

				describe('#fetchNearbyPlacesForSearchTearm(searchTearm, [categories], [fields], [distance], [cursor], success, error)', () => {
					it('is a function', () => {
						expect(Facebook.fetchNearbyPlacesForSearchTearm).toEqual(jasmine.any(Function));
					});
				});

				describe('#presentMessengerDialog(params)', () => {
					it('is a function', () => {
						expect(Facebook.presentMessengerDialog).toEqual(jasmine.any(Function));
					});
				});

				describe('#setCurrentAccessToken(params)', () => {
					it('is a function', () => {
						expect(Facebook.setCurrentAccessToken).toEqual(jasmine.any(Function));
					});
				});

				describe('#shareMediaToMessenger(params)', () => {
					it('is a function', () => {
						expect(Facebook.shareMediaToMessenger).toEqual(jasmine.any(Function));
					});
				});
			}
		});
	});
});