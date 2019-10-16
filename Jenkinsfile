library 'pipeline-library'

def isMaster = env.BRANCH_NAME.equals('master')

buildModule {
	sdkVersion = '8.1.0.GA'
	npmPublish = true // By default it'll do github release on master anyways too
	iosLabels = 'osx && xcode-11'
	npmPublishArgs = '--access public --dry-run'
}
