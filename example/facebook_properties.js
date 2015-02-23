function fb_properties() {
	var fb = require('facebook');
	
	var win = Ti.UI.createWindow({
		title: 'Properties',
		backgroundColor:'#fff',
		fullscreen: false
	});
	
	if (Ti.Platform.osname == 'android') {
		win.fbProxy = fb.createActivityWorker({lifecycleContainer: win});
	}
	
	var sv = Ti.UI.createScrollView({
		contentWidth:'auto',
		contentHeight:'auto',
		top:0,
		showVerticalScrollIndicator:true,
		showHorizontalScrollIndicator:true
	});
	win.add(sv);
		
	//
	// Login Button
	//
	var fbButton = fb.createLoginButton({
		top: 10
	});
	fbButton.style = fb.BUTTON_STYLE_NORMAL;
	sv.add(fbButton);
	

	var b1 = Ti.UI.createButton({
		title:'Display Properties',
		width:300,
		height:80,
		top:90
	});
	sv.add(b1);
	
	var loggedIn = Ti.UI.createLabel({
		title:'',
		width:300,
		top:200,
		font:{fontSize:13},
		color:'#777'
	});
	sv.add(loggedIn);
	
	var userId = Ti.UI.createLabel({
		title:'',
		height:'auto',
		width:300,
		top:240,
		font:{fontSize:13},
		color:'#777'
	});
	sv.add(userId);
	
	var permissions = Ti.UI.createLabel({
		text:'',
		height:'auto',
		width:300,
		top:280,
		font:{fontSize:13},
		color:'#777'
	});
	sv.add(permissions);
	
	b1.addEventListener('click', function()
	{
		Ti.API.info("click called, logged in = "+fb.loggedIn);
		
		if (!fb.loggedIn)
		{
			Ti.UI.createAlertDialog({title:'Facebook', message:'Login before accessing properties'}).show();
			return;
		}
		loggedIn.text = 'Logged In = ' + fb.getLoggedIn();
		userId.text = 'User Id = ' + fb.getUid();

		Ti.API.info('Permissions granted: ' +fb.getPermissions().toString);
				
		var list = fb.getPermissions();
		
			var text = 'Permissions granted:' + '\n';
			for (var v in list)
			{
				if (v!==null)
				{
					text += list[v] + '\n';
				}
			}
			permissions.text = text;
		
	});
	
	return win;
};

module.exports = fb_properties;
