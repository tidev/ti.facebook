var fb = require('facebook');

var tabGroup = Titanium.UI.createTabGroup({
	backgroundColor: '#fff'
});

tabGroup.addTab(Titanium.UI.createTab({
	title: 'Login',
	window: require('facebook_login_logout').window()
}));

tabGroup.addTab(Titanium.UI.createTab({
	title: 'Read',
	window: require('facebook_read_stream').window()
}));

tabGroup.addTab(Titanium.UI.createTab({
	title: 'Share',
	window: require('facebook_share').window()
}));

if (Ti.Platform.osname !== 'android') {
	tabGroup.addTab(Titanium.UI.createTab({
		title: 'Places',
		window: require('facebook_places').window()
	}));
}

fb.initialize(); // after you set up login/logout listeners and permissions

// open tab group
if (Ti.Platform.osname === 'android') {
	tabGroup.fbProxy = fb.createActivityWorker({
		lifecycleContainer: tabGroup
	});
}

tabGroup.open();