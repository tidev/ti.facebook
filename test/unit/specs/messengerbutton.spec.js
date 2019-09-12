
const Facebook = require('facebook');
const IOS = (Ti.Platform.osname === 'iphone' || Ti.Platform.osname === 'ipad');

// FIXME: Add this API to Android?
if (IOS) {
	describe('ti.facebook', () => {
		describe('MessengerButton', () => {
			let button;

			beforeEach(() => {
				button = Facebook.createMessengerButton();
			});

			describe('properties', () => {
				it('.apiName', () => {
					expect(button.apiName).toBe('Ti.Facebook.MessengerButton');
				});

				describe('.mode', () => {
					it('defaults to MESSENGER_BUTTON_MODE_RECTANGULAR', () => {
						expect(button.mode).toEqual(Facebook.MESSENGER_BUTTON_MODE_RECTANGULAR);
					});
				});

				describe('.style', () => {
					it('defaults to MESSENGER_BUTTON_STYLE_BLUE', () => {
						expect(button.style).toEqual(Facebook.MESSENGER_BUTTON_STYLE_BLUE);
					});
				});
			});
		});
	});
}