
const Facebook = require('facebook');

describe('ti.facebook', () => {
	describe('LoginButton', () => {
		let button;

		beforeEach(() => {
			button = Facebook.createLoginButton();
		});

		function checkValidAudiance(audience) {
			if (audience === Facebook.AUDIENCE_ONLY_ME
				|| audience === Facebook.AUDIENCE_FRIENDS
				|| audience === Facebook.AUDIENCE_EVERYONE) {
			// for valid audiance it will not throw exception and test case will fail
			} else {
				throw new Error('You must provide valid audience');
			}
		}

		function checkValidTooltipBehavior(tooltipBehavior) {
			if (tooltipBehavior === Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC
				|| tooltipBehavior === Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_FORCE_DISPLAY
				|| tooltipBehavior === Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE) {
			// for valid tooltipBehavior it will not throw exception and test case will fail
			} else {
				throw new Error('You must provide valid tooltipBehavior');
			}
		}

		function checkValidTooltipColorStyle(tooltipColorStyle) {
			if (tooltipColorStyle === Facebook.LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY
				|| tooltipColorStyle === Facebook.LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE) {
			// for valid tooltipColorStyle it will not throw exception and test case will fail
			} else {
				throw new Error('You must provide valid tooltipColorStyle');
			}
		}

		it('.apiName', () => {
			expect(button.apiName).toBe('Ti.Facebook.LoginButton');
		});

		describe('properties', () => {

			describe('.audience', () => {
				it('defaults to AUDIENCE_FRIENDS', () => {
					expect(button.audience).toEqual(Facebook.AUDIENCE_FRIENDS);
				});

				it('can be changed to AUDIENCE_EVERYONE', () => {
					button.audience = Facebook.AUDIENCE_EVERYONE;

					expect(button.audience).toEqual(Facebook.AUDIENCE_EVERYONE);
				});

				it('fail with invalid value', () => {
					button.audience = -1; // Assign invalid value
					expect(() => checkValidAudiance(button.audience)).toThrow();
				});
			});

			describe('.permissions', () => {
				it('is a property', () => {
					expect(button.permissions).not.toBeDefined();
				});
				it('change permissions to publish_actions', () => {
					button.permissions = [ 'publish_actions' ];
					expect(button.permissions).toEqual([ 'publish_actions' ]);
				});
			});

			describe('.tooltipBehavior', () => {
				it('defaults to LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC', () => {
					expect(button.tooltipBehavior).toEqual(Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC);
				});

				it('can be changed to LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE', () => {
					button.tooltipBehavior = Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE;

					expect(button.tooltipBehavior).toEqual(Facebook.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE);
				});

				it('fail tooltipBehavior with invalid value', () => {
					button.tooltipBehavior = -1; // Assign invalid value
					expect(() => checkValidTooltipBehavior(button.tooltipBehavior)).toThrow();
				});
			});

			describe('.tooltipColorStyle', () => {
				// should it default to friendly blue or neutral gray?
				// Android Facebook docs say blue is default,
				// I think enum defaults to blue on iOS too
				it('defaults to LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE', () => {
					expect(button.tooltipColorStyle).toEqual(Facebook.LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE);
				});

				it('can be changed to LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY', () => {
					button.tooltipColorStyle = Facebook.LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY;

					expect(button.tooltipColorStyle).toEqual(Facebook.LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY);
				});

				it('fail tooltipColorStyle with invalid value', () => {
					button.tooltipColorStyle = -1; // Assign invalid value
					expect(() => checkValidTooltipColorStyle(button.tooltipColorStyle)).toThrow();
				});
			});
		});
	});
});
