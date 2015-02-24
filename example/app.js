var fb = require('facebook');

var win = Ti.UI.createWindow({
	title : 'facebook sample',
	backgroundColor : '#fff',
	fullscreen: false
});

if (Ti.Platform.osname == 'android') {
	win.fbProxy = fb.createActivityWorker({lifecycleContainer: win});
}

//create table view data object
var data = [{
	title : 'Login/Logout',
	hasChild : true,
	test : 'facebook_login_logout'
}, {
	title : 'Read Stream',
	hasChild : true,
	test : 'facebook_read_stream'
}, {
	title : 'Publish Stream',
	hasChild : true,
	test : 'facebook_publish_stream'
}, {
	title : 'Photos',
	hasChild : true,
	test : 'facebook_photos'
}, {
	title : 'Share Dialog',
	hasChild : true,
	test : 'facebook_share_dialog'
}];

// create table view
for (var i = 0; i < data.length; i++) {
	data[i].color = '#000';
	data[i].font = {
		fontWeight : 'bold',
		fontSize : 20
	};
};
var tableview = Titanium.UI.createTableView({
	data : data
});

// create table view event listener
tableview.addEventListener('click', function(e) {
	if (e.rowData.test) {
		var ExampleWindow = require(e.rowData.test), 
			win = new ExampleWindow();
		win.open();
	}
});

// add table view to the window
win.add(tableview); 
fb.initialize(4000);
win.open();

