function fb_login_logout() {
	var fb = require('facebook');
	
	var win = Ti.UI.createWindow({
		title: 'Login/Logout',
		backgroundColor:'#fff',
		fullscreen: false
	});
	
	if (Ti.Platform.osname == 'android') {
		win.fbProxy = fb.createActivityWorker({lifecycleContainer: win});
	}
	
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
	

	var loginButton = fb.createLoginButton({
		readPermissions: ['read_stream','email'],
		bottom : 30
	});
	loginButton.readPermissions = ['email'];
	win.add(loginButton); 

	return win;
};

module.exports = fb_login_logout;
