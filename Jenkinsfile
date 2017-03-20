@NonCPS
def jsonParse(def json) {
	new groovy.json.JsonSlurperClassic().parseText(json)
}

def nodeVersion = '4.7.3'
// We need 6.0.3+ for module build fixes
// FIXME Use 6.0.3.GA when available!
def tiSDKVersion = '6.0.3.v20170317093820'
def androidAPILevel = '23'

/*
 * Allows us to pass in a "block" of code to execute while we are logged into
 * the appc cli production environment. We acquire an exclusive lock for the login
 * (blocking other logins until we're done), log into the cli/env, do whatever it is we
 * want in our block, then log out and release the lock.
 */
def loggedIntoProduction(Closure body) {
	// acquire exclusing lock to the login for these credentials
	lock('appc-login:895d8db1-87c2-4d96-a786-349c2ed2c04a') { // only let one login at a time for this user!
		sh 'rm -rf ~/.appcelerator/appc-cli.json' // Forcibly wipe the config because we often get into a bad state here
		sh 'appc config set defaultEnvironment prod'
		withCredentials([usernamePassword(credentialsId: '895d8db1-87c2-4d96-a786-349c2ed2c04a', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
			sh 'appc login --username "$USER" --password "$PASS"'
		}

		// Now do whatever it is we want to actually do!
		body()

		// then log out
		sh 'appc logout'
	}
}

def sdkSetup(sdkVersion) {
	sh 'npm install -g appcelerator'
	sh 'appc logout' // it may have already been installed and logged into another user/env
	def sdkListOutput = ''
	loggedIntoProduction {
		sh 'appc use latest'
		sh "appc ti sdk install ${sdkVersion} -d"
		sh "appc ti sdk select ${sdkVersion}" // Forcibly select it, because install may not have if already installed
		sdkListOutput = sh(returnStdout: true, script: 'appc ti sdk list -o json')
	}
	def sdkListJSON = jsonParse(sdkListOutput)
	def activeSDKVersion = sdkListJSON['activeSDK']
	return sdkListJSON['installed'][activeSDKVersion]
}

def buildAndroid(nodeVersion, tiSDKVersion, androidAPILevel) {
	return {
		node('android-sdk && android-ndk && (osx || linux)') {
			unstash 'sources'
			nodejs(nodeJSInstallationName: "node ${nodeVersion}") {
				def activeSDKPath = sdkSetup(tiSDKVersion)

				// We have to hack to make sure we pick up correct ANDROID_SDK/NDK values from the node that's currently running this section of the build.
				def androidSDK = env.ANDROID_SDK // default to what's in env (may have come from jenkins env vars set on initial node)
				def androidNDK = env.ANDROID_NDK
				withEnv(['ANDROID_SDK=', 'ANDROID_NDK=']) {
					try {
						androidSDK = sh(returnStdout: true, script: 'printenv ANDROID_SDK')
					} catch (e) {
						// squash, env var not set at OS-level
					}
					try {
						androidNDK = sh(returnStdout: true, script: 'printenv ANDROID_NDK')
					} catch (e) {
						// squash, env var not set at OS-level
					}

					dir('android') {
						writeFile file: 'build.properties', text: """
titanium.platform=${activeSDKPath}/android
android.platform=${androidSDK}/platforms/android-${androidAPILevel}
google.apis=${androidSDK}/add-ons/addon-google_apis-google-${androidAPILevel}
"""
						// TODO Use 'appc ti build --build-only'!
						// if lib folder doesn't exist, create it
						sh 'mkdir -p lib'
						// if build folder doesn't exist, create it
						sh 'mkdir -p build'
						// if build/docs folder doesn't exist, create it
						sh 'mkdir -p build/docs'
						loggedIntoProduction {
							// Even setting config needs login, ugh
							sh "appc ti config android.sdkPath ${androidSDK}"
							sh "appc ti config android.ndkPath ${androidNDK}"
							sh 'appc ti build -p android --build-only'
						}
						dir('dist') {
							archiveArtifacts '*.zip'
						}
					} // dir
				} // withEnv
			} // nodeJs
		} // node
	}
}

def buildIOS(nodeVersion, tiSDKVersion) {
	return {
		node('osx && xcode') {
			unstash 'sources'
			nodejs(nodeJSInstallationName: "node ${nodeVersion}") {
				def activeSDKPath = sdkSetup(tiSDKVersion)

				dir('ios') {
					writeFile file: 'titanium.xcconfig', text: """
TITANIUM_SDK = ${activeSDKPath}
TITANIUM_BASE_SDK = \"\$(TITANIUM_SDK)/iphone/include\"
TITANIUM_BASE_SDK2 = \"\$(TITANIUM_SDK)/iphone/include/TiCore\"
TITANIUM_BASE_SDK3 = \"\$(TITANIUM_SDK)/iphone/include/ASI\"
TITANIUM_BASE_SDK4 = \"\$(TITANIUM_SDK)/iphone/include/APSHTTPClient\"
HEADER_SEARCH_PATHS= \$(TITANIUM_BASE_SDK) \$(TITANIUM_BASE_SDK2) \$(TITANIUM_BASE_SDK3) \$(TITANIUM_BASE_SDK4) \${PROJECT_DIR}/**
"""
					loggedIntoProduction {
						sh 'appc ti build -p ios --build-only'
					}
					// TODO Test module in app! See https://raw.githubusercontent.com/sgtcoolguy/ci/v8/travis/script.sh
					archiveArtifacts '*.zip'
				} // dir
			} // nodeJs
		} // node
	}
}

timestamps {
	def branches = [failFast: true]
	node {
		stage('Checkout') {
			// checkout scm
			// Hack for JENKINS-37658 - see https://support.cloudbees.com/hc/en-us/articles/226122247-How-to-Customize-Checkout-for-Pipeline-Multibranch
			checkout([
				$class: 'GitSCM',
				branches: scm.branches,
				extensions: scm.extensions + [[$class: 'CleanBeforeCheckout']],
				userRemoteConfigs: scm.userRemoteConfigs
			])
			stash 'sources'
			// Determine if we need to run android/ios branches!
			if (fileExists('android')) {
				branches['android'] = buildAndroid(nodeVersion, tiSDKVersion, androidAPILevel)
			}
			if (fileExists('ios')) { // TODO Check for 'iphone' folder
				branches['iOS'] = buildIOS(nodeVersion, tiSDKVersion)
			}
		}
	}

	stage('Build') {
		parallel(branches)
	}
} // timestamps
