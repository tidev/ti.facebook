let Facebook;

const IOS = (Ti.Platform.osname === 'iphone' || Ti.Platform.osname === 'ipad');
const ANDROID = (Ti.Platform.osname === 'android');

describe('ti.facebook', function () {

	it('can be required', () => {
		Facebook = require('ti.facebook');
		expect(Facebook).toBeDefined();
	});

	it('.apiName', () => {
		expect(Facebook.apiName).toBe('Ti.Facebook');
	});

	// describe('constants', () => {

	// 	describe('AUDIENCE_*', () => {
	// 		it('AUDIENCE_ONLY_ME', () => {
	// 			expect(Facebook.AUDIENCE_ONLY_ME).toEqual(jasmine.any(Number));
	// 		});

	// 		it('AUDIENCE_FRIENDS', () => {
	// 			expect(Facebook.AUDIENCE_FRIENDS).toEqual(jasmine.any(Number));
	// 		});

	// 		it('AUDIENCE_EVERYONE', () => {
	// 			expect(Facebook.AUDIENCE_EVERYONE).toEqual(jasmine.any(Number));
	// 		});
	// 	});

	// 	describe('ACTION_TYPE_*', () => {
	// 		it('ACTION_TYPE_NONE', () => {
	// 			expect(Facebook.ACTION_TYPE_NONE).toEqual(jasmine.any(Number));
	// 		});

	// 		it('ACTION_TYPE_SEND', () => {
	// 			expect(Facebook.ACTION_TYPE_SEND).toEqual(jasmine.any(Number));
	// 		});

	// 		it('ACTION_TYPE_ASK_FOR', () => {
	// 			expect(Facebook.ACTION_TYPE_ASK_FOR).toEqual(jasmine.any(Number));
	// 		});

	// 		it('ACTION_TYPE_TURN', () => {
	// 			expect(Facebook.ACTION_TYPE_TURN).toEqual(jasmine.any(Number));
	// 		});
	// 	});

	// 	describe('FILTER_*', () => {
	// 		it('FILTER_NONE', () => {
	// 			expect(Facebook.FILTER_NONE).toEqual(jasmine.any(Number));
	// 		});

	// 		it('FILTER_APP_USERS', () => {
	// 			expect(Facebook.FILTER_APP_USERS).toEqual(jasmine.any(Number));
	// 		});

	// 		it('FILTER_APP_NON_USERS', () => {
	// 			expect(Facebook.FILTER_APP_NON_USERS).toEqual(jasmine.any(Number));
	// 		});
	// 	});

	// 	describe('BUTTON_STYLE_*', () => {
	// 		it('BUTTON_STYLE_NORMAL', () => {
	// 			expect(Facebook.BUTTON_STYLE_NORMAL).toEqual(jasmine.any(Number));
	// 		});

	// 		it('BUTTON_STYLE_WIDE', () => {
	// 			expect(Facebook.BUTTON_STYLE_WIDE).toEqual(jasmine.any(Number));
	// 		});
	// 	});

	// 	describe('PLACE_LOCATION_CONFIDENCE_*', () => {
	// 		it('PLACE_LOCATION_CONFIDENCE_NOT_APPLICABLE', () => {
	// 			expect(Facebook.PLACE_LOCATION_CONFIDENCE_NOT_APPLICABLE).toEqual(jasmine.any(Number));
	// 		});

	// 		it('PLACE_LOCATION_CONFIDENCE_LOW', () => {
	// 			expect(Facebook.PLACE_LOCATION_CONFIDENCE_LOW).toEqual(jasmine.any(Number));
	// 		});

	// 		it('PLACE_LOCATION_CONFIDENCE_MEDIUM', () => {
	// 			expect(Facebook.PLACE_LOCATION_CONFIDENCE_MEDIUM).toEqual(jasmine.any(Number));
	// 		});

	// 		it('PLACE_LOCATION_CONFIDENCE_HIGH', () => {
	// 			expect(Facebook.PLACE_LOCATION_CONFIDENCE_HIGH).toEqual(jasmine.any(Number));
	// 		});
	// 	});

	// 	describe('LOGIN_BEHAVIOR_*', () => {
	// 		it('LOGIN_BEHAVIOR_BROWSER', () => {
	// 			expect(Facebook.LOGIN_BEHAVIOR_BROWSER).toEqual(jasmine.any(Number));
	// 		});

	// 		it('LOGIN_BEHAVIOR_NATIVE', () => {
	// 			expect(Facebook.LOGIN_BEHAVIOR_NATIVE).toEqual(jasmine.any(Number));
	// 		});

	// 		it('LOGIN_BEHAVIOR_SYSTEM_ACCOUNT', () => {
	// 			expect(Facebook.LOGIN_BEHAVIOR_SYSTEM_ACCOUNT).toEqual(jasmine.any(Number));
	// 		});

	// 		it('LOGIN_BEHAVIOR_WEB', () => {
	// 			expect(Facebook.LOGIN_BEHAVIOR_WEB).toEqual(jasmine.any(Number));
	// 		});

	// 		it('LOGIN_BEHAVIOR_NATIVE_WITH_FALLBACK', () => {
	// 			expect(Facebook.LOGIN_BEHAVIOR_NATIVE_WITH_FALLBACK).toEqual(jasmine.any(Number));
	// 		});

	// 		it('LOGIN_BEHAVIOR_DEVICE_AUTH', () => {
	// 			expect(Facebook.LOGIN_BEHAVIOR_DEVICE_AUTH).toEqual(jasmine.any(Number));
	// 		});
	// 	});

	// 	// FIXME: How does this interact with LOGIN_BEHAVIOR_* constants?
	// 	// FIXME: This points to a LoginButton.sessionLoginBehavior property not documented!
	// 	describe('SSO_*', () => {
	// 		it('SSO_WITH_FALLBACK', () => {
	// 			expect(Facebook.SSO_WITH_FALLBACK).toEqual(jasmine.any(Number));
	// 		});

	// 		it('SUPPRESS_SSO', () => {
	// 			expect(Facebook.SUPPRESS_SSO).toEqual(jasmine.any(Number));
	// 		});

	// 		it('SSO_ONLY', () => {
	// 			expect(Facebook.SSO_ONLY).toEqual(jasmine.any(Number));
	// 		});
	// 	});

	// 	describe('SHARE_DIALOG_MODE_*', () => {
	// 		it('SHARE_DIALOG_MODE_AUTOMATIC', () => {
	// 			expect(Facebook.SHARE_DIALOG_MODE_AUTOMATIC).toEqual(jasmine.any(Number));
	// 		});

	// 		it('SHARE_DIALOG_MODE_NATIVE', () => {
	// 			expect(Facebook.SHARE_DIALOG_MODE_NATIVE).toEqual(jasmine.any(Number));
	// 		});

	// 		it('SHARE_DIALOG_MODE_SHARE_SHEET', () => {
	// 			expect(Facebook.SHARE_DIALOG_MODE_SHARE_SHEET).toEqual(jasmine.any(Number));
	// 		});

	// 		it('SHARE_DIALOG_MODE_BROWSER', () => {
	// 			expect(Facebook.SHARE_DIALOG_MODE_BROWSER).toEqual(jasmine.any(Number));
	// 		});

	// 		it('SHARE_DIALOG_MODE_WEB', () => {
	// 			expect(Facebook.SHARE_DIALOG_MODE_WEB).toEqual(jasmine.any(Number));
	// 		});

	// 		it('SHARE_DIALOG_MODE_FEED_BROWSER', () => {
	// 			expect(Facebook.SHARE_DIALOG_MODE_FEED_BROWSER).toEqual(jasmine.any(Number));
	// 		});

	// 		it('SHARE_DIALOG_MODE_FEED_WEB', () => {
	// 			expect(Facebook.SHARE_DIALOG_MODE_FEED_WEB).toEqual(jasmine.any(Number));
	// 		});
	// 	});

	// 	describe('MESSENGER_BUTTON_MODE_*', () => {
	// 		it('MESSENGER_BUTTON_MODE_CIRCULAR', () => {
	// 			expect(Facebook.MESSENGER_BUTTON_MODE_CIRCULAR).toEqual(jasmine.any(Number));
	// 		});

	// 		it('MESSENGER_BUTTON_MODE_RECTANGULAR', () => {
	// 			expect(Facebook.MESSENGER_BUTTON_MODE_RECTANGULAR).toEqual(jasmine.any(Number));
	// 		});
	// 	});

	// 	describe('MESSENGER_BUTTON_STYLE_*', () => {
	// 		it('MESSENGER_BUTTON_STYLE_BLUE', () => {
	// 			expect(Facebook.MESSENGER_BUTTON_STYLE_BLUE).toEqual(jasmine.any(Number));
	// 		});

	// 		it('MESSENGER_BUTTON_STYLE_WHITE', () => {
	// 			expect(Facebook.MESSENGER_BUTTON_STYLE_WHITE).toEqual(jasmine.any(Number));
	// 		});

	// 		it('MESSENGER_BUTTON_STYLE_WHITE_BORDERED', () => {
	// 			expect(Facebook.MESSENGER_BUTTON_STYLE_WHITE_BORDERED).toEqual(jasmine.any(Number));
	// 		});
	// 	});

	// 	describe('LOGIN_BUTTON_TOOLTIP_BEHAVIOR_*', () => {
	// 		it('LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC', () => {
	// 			expect(Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC).toEqual(jasmine.any(Number));
	// 		});

	// 		it('LOGIN_BUTTON_TOOLTIP_BEHAVIOR_FORCE_DISPLAY', () => {
	// 			expect(Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_FORCE_DISPLAY).toEqual(jasmine.any(Number));
	// 		});

	// 		it('LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE', () => {
	// 			expect(Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE).toEqual(jasmine.any(Number));
	// 		});
	// 	});

	// 	describe('LOGIN_BUTTON_TOOLTIP_STYLE_*', () => {
	// 		it('MESSENGER_BUTTON_STYLE_LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAYBLUE', () => {
	// 			expect(Facebook.LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY).toEqual(jasmine.any(Number));
	// 		});

	// 		it('LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE', () => {
	// 			expect(Facebook.LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE).toEqual(jasmine.any(Number));
	// 		});
	// 	});
	// });

});