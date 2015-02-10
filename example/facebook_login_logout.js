function fb_login_logout() {
	var fb = require('com.ti.facebook');
	
	var win = Ti.UI.createWindow({
		title: 'Login/Logout',
		backgroundColor:'#fff',
		fullscreen: false
	});
	
	win.fbProxy = fb.createActivityWorker({lifecycleContainer: win});
	
	//
	// Login Status
	//
	var label = Ti.UI.createLabel({
		text:'Logged In = ' + fb.loggedIn,
		color: '#000',
		font:{fontSize:20},
		top:10,
		textAlign:'center'
	});
	win.add(label);
		
	function updateLoginStatus() {
		label.text = 'Logged In = ' + fb.loggedIn;
	}
	
	// capture
	fb.addEventListener('login', updateLoginStatus);
	fb.addEventListener('logout', updateLoginStatus);
	
	//
	// Login Button
	//
	win.add(fb.createLoginButton({
		style : fb.BUTTON_STYLE_WIDE,
		bottom : 30
	})); 
	

	return win;
};

module.exports = fb_login_logout;
