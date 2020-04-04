exports.window = function(value) {
	if (Ti.Platform.osname == "android") {
		Ti.API.warn("This feature is currently iOS-only.");
		return;
	}
	
	var fb = require('facebook');

	var win = Ti.UI.createWindow({
		title: 'Share on Messanger',
		backgroundColor:'#fff',
		layout: "vertical"
	});

    var shareOnMessengerBtn = Ti.UI.createButton({
        title: 'Share on messanger',
        top: '20%',
        center: true,
    });
    shareOnMessengerBtn.addEventListener("click", shareOnMessenger);
	win.add(shareOnMessengerBtn);
	
	function shareOnMessenger() {
	    if (!Ti.Platform.canOpenURL("fb-messenger-api://")) {
	        alert("No facebook messenger installed");
	        return;
	    }
	    fb.presentMessengerDialog({
	        description: "Sent using Ti.Facebook",
	        link: "https://appcelerator.com",
	        to: []
	    });
	}

	return win;
};
