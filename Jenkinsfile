library 'pipeline-library'

def isMaster = env.BRANCH_NAME.equals('master')

buildModule {
	sdkVersion = '9.0.0.v20200127103011'
	npmPublish = isMaster // By default it'll do github release on master anyways too
	iosLabels = 'osx && xcode-11'
}
