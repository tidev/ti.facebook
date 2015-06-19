#### 4.0.5
- fixed presentSendRequestDialog with to and title params [MOD-2126]

#### 4.0.4
- fixed photo posting for requestWithGraphPath [TIMOB-18916]
- bumped android version for parity with iOS

#### 4.0.3
- change minsdk to 4.0.0 [MOD-2119]

#### 4.0.2
- Updated Facebook SDK from 3.21.1 to 3.23.1 [TIMOB-18712]
- Exposed data returned on presentSendRequestDialog
- Bumped iOS module version to be same as android
- Fixed `requestNewReadPermissions` and the `LikeButton` in Android [MOD-2105]

#### 4.0.1
- Changing sessionDefaultAudence to audience in Android [MOD-2107]

#### 4.0.0
- Combined and updated the Facebook module from https://github.com/mokesmokes/titanium-android-facebook/ and https://github.com/mokesmokes/titanium-ios-facebook

#### 3.18.02
- Requiring https://github.com/appcelerator/titanium_mobile/pull/6179
- Must pass `lifecycleContainer: windowOrTabGroup` in proxy creation dictionary
- Remove requirement to call proxy during the window's onResume event

#### 3.18.01
- Initial commit based on Facebook SDK 3.18.0
