'use strict';
const path = require('path');
const fs = require('fs-extra');

const appId = process.env.FACEBOOK_APP_ID;
if (!appId) {
	console.error('Please define a FACEBOOK_APP_ID environment variable to use for android testing!');
}

function projectManagerHook(projectManager) {
	projectManager.once('prepared', function () {
		const stringsXML = path.join(this.karmaRunnerProjectPath, '/platform/android/res/values/strings.xml');
		fs.ensureDirSync(path.dirname(stringsXML));
		fs.writeFileSync(stringsXML, `<resources>
	<string name="facebook_app_id">${appId}</string>
</resources>`);

		const tiapp = path.join(this.karmaRunnerProjectPath, 'tiapp.xml');
		const contents = fs.readFileSync(tiapp, 'utf8');

		fs.writeFileSync(tiapp, contents.replace('</manifest>', `<application>
		<activity android:name="com.facebook.FacebookActivity"
				  android:theme="@android:style/Theme.Translucent.NoTitleBar"
				  android:label="YourAppName"
				  android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation" />
		<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>

		<provider android:name="com.facebook.FacebookContentProvider"
				  android:authorities="com.facebook.app.FacebookContentProvider${appId}"
				  android:exported="true" />
	</application>
</manifest>`), 'utf8');
	});
}
projectManagerHook.$inject = [ 'projectManager' ];

module.exports = config => {
	config.set({
		basePath: '../..',
		frameworks: [ 'jasmine', 'projectManagerHook' ],
		files: [
			'test/unit/specs/**/*spec.js'
		],
		reporters: [ 'mocha', 'junit' ],
		plugins: [
			'karma-*',
			{
				'framework:projectManagerHook': [ 'factory', projectManagerHook ]
			}
		],
		titanium: {
			sdkVersion: config.sdkVersion || '9.2.0.GA'
		},
		customLaunchers: {
			android: {
				base: 'Titanium',
				browserName: 'Android AVD',
				displayName: 'android',
				platform: 'android'
			},
			ios: {
				base: 'Titanium',
				browserName: 'iOS Emulator',
				displayName: 'ios',
				platform: 'ios'
			}
		},
		browsers: [ 'android', 'ios' ],
		client: {
			jasmine: {
				random: false
			}
		},
		singleRun: true,
		retryLimit: 0,
		concurrency: 1,
		captureTimeout: 300000,
		logLevel: config.LOG_DEBUG
	});
};
