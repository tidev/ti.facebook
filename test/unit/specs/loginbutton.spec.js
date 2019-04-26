
const Facebook = require('facebook');

const IOS = (Ti.Platform.osname === 'iphone' || Ti.Platform.osname === 'ipad');
const ANDROID = (Ti.Platform.osname === 'android');

describe('ti.facebook', () => {
	describe('LoginButton', () => {
		let button;

		beforeEach(() => {
			button = Facebook.createLoginButton();
		});

		it('.apiName', () => {
			expect(button.apiName).toBe('Ti.Facebook.LoginButton');
		});

		describe('properties', () => {
			describe('.audience', () => {
				it('defaults to AUDIENCE_ONLY_ME', () => {
					expect(button.audience).toEqual(Facebook.AUDIENCE_ONLY_ME);
				});
				// TODO: change the value, verify it updates? try invalid values
			});

			if (ANDROID) {
				// FIXME: on iOS we get undefined, presumably because of https://jira.appcelerator.org/browse/TIMOB-23504
				describe('.publishPermissions', () => {
					it('is a property', () => {
						expect(Object.getOwnPropertyDescriptor(button, 'publishPermissions')).toBeDefined();
					});
					// TODO: change the value, verify it updates? try invalid values
				});

				describe('.readPermissions', () => {
					it('is a property', () => {
						expect(Object.getOwnPropertyDescriptor(button, 'readPermissions')).toBeDefined();
					});
					// TODO: change the value, verify it updates? try invalid values
				});
			}

			describe('.tooltipBehavior', () => {
				it('defaults to LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC', () => {
					expect(button.tooltipBehavior).toEqual(Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC);
				});
				// TODO: change the value, verify it updates? try invalid values
			});

			describe('.tooltipColorStyle', () => {
				// should it default to friendly blue or neutral gray?
				// Android Facebook docs say blue is default,
				// I think enum defaults to blue on iOS too
				it('defaults to LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE', () => {
					expect(button.tooltipColorStyle).toEqual(Facebook.LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE);
				});
				// TODO: change the value, verify it updates? try invalid values
			});
		});
	});
});