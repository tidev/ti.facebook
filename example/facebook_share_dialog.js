function fb_photos() {
	var fb = require('com.ti.facebook');
	
	var win = Ti.UI.createWindow({
		title: 'Share Dialog',
		backgroundColor:'#fff',
		fullscreen: false
	});
	
	win.fbProxy = fb.createActivityWorker({lifecycleContainer: win});
	
	var B1_TITLE = 'Share Dialog';
	
	var b1 = Ti.UI.createButton({
		title:B1_TITLE,
		left: 10, right: 10, top: 0, height: 80
	});
			
	var login = fb.createLoginButton({
		top: 10
	});
	login.style = fb.BUTTON_STYLE_WIDE;
	win.add(login);

	var actionsView = Ti.UI.createView({
		top: 80, left: 0, right: 0, visible: fb.loggedIn, height: 'auto'
	});
	actionsView.add(b1);
	
	fb.addEventListener('login', function(e) {
		if (e.success) {
			actionsView.show();
		}
		if (e.error) {
			alert(e.error);
		}
	});
	
	fb.addEventListener('logout', function(e){
		Ti.API.info('logout event');
		actionsView.hide();
	});
	
	b1.addEventListener('click', function() {
		if(fb.canPresentShareDialog) {
			fb.share({url: 'https://appcelerator.com/' });
		}
	});
	
	win.add(actionsView);
	return win;
};

module.exports = fb_photos;
