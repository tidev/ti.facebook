'use strict';
 
exports.id = 'com.appcelerator.facebook';
 
exports.cliVersion = '>=3.2';
 
exports.init = function init(logger, config, cli, appc) {
	cli.on('build.ios.writeEntitlements', {
		pre: function (data, finished) {
			var applicationIdentifier = '$(AppIdentifierPrefix)' + this.tiapp.id;
			var plist = data.args[0];
 
			Array.isArray(plist['keychain-access-groups']) || (plist['keychain-access-groups'] = []);
			if (!plist['keychain-access-groups'].some(function (id) { return id === applicationIdentifier; })) {
				plist['keychain-access-groups'].push(applicationIdentifier);
			}
 
			finished();
		}
	});
};
