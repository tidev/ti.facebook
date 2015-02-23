function fb_photos() {
	var fb = require('facebook');
	
	var win = Ti.UI.createWindow({
		title: 'Share Dialog',
		backgroundColor:'#fff',
		fullscreen: false
	});
	
	if (Ti.Platform.osname == 'android') {
		win.fbProxy = fb.createActivityWorker({lifecycleContainer: win});
	}
	
	var B1_TITLE = 'Share Dialog';
	
	var b1 = Ti.UI.createButton({
		title:B1_TITLE,
		left: 10, right: 10, top: 0, height: 80
	});
	
	var B2_TITLE = 'Web Share Dialog';
	
	var b2 = Ti.UI.createButton({
		title:B2_TITLE,
		left: 10, right: 10, top: 100, height: 80
	});
			
	var login = fb.createLoginButton({
		top: 10
	});

	win.add(login);

	var actionsView = Ti.UI.createView({
		top: 80, left: 0, right: 0, visible: fb.loggedIn, height: 'auto'
	});
	actionsView.add(b1);
	actionsView.add(b2);
	
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
			fb.presentShareDialog({url: 'https://appcelerator.com/' });
		} 
	});

	win.fbProxy.addEventListener('shareCompleted', function(e) {
		if (e.success) {
         alert('share completed');
     }
     else if (e.cancelled) {
           alert('share cancelled');
     }
     else {
           alert('error ' + e.error);           
     }
	});
	
	b2.addEventListener('click', function() {
		fb.presentWebShareDialog(function(e){
		if (e.success) {
			alert("Success");
		}
		if (e.error) {
			alert(e.error);
		}
		});

	});
	
	win.add(actionsView);
	return win;
};

module.exports = fb_photos;
