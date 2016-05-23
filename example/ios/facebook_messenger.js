exports.window = function(value){
	var fb = require('facebook');

	var win = Ti.UI.createWindow({
		title: 'Login/Logout',
		backgroundColor:'#fff',
		layout: "vertical"
	});

	addButtonWithModeAndStyle(fb.MESSENGER_BUTTON_MODE_CIRCULAR,fb.MESSENGER_BUTTON_STYLE_BLUE);
	addButtonWithModeAndStyle(fb.MESSENGER_BUTTON_MODE_CIRCULAR,fb.MESSENGER_BUTTON_STYLE_WHITE);
	addButtonWithModeAndStyle(fb.MESSENGER_BUTTON_MODE_CIRCULAR,fb.MESSENGER_BUTTON_STYLE_WHITE_BORDERED);

	addButtonWithModeAndStyle(fb.MESSENGER_BUTTON_MODE_RECTANGULAR,fb.MESSENGER_BUTTON_STYLE_BLUE);
	addButtonWithModeAndStyle(fb.MESSENGER_BUTTON_MODE_RECTANGULAR,fb.MESSENGER_BUTTON_STYLE_WHITE);
	addButtonWithModeAndStyle(fb.MESSENGER_BUTTON_MODE_RECTANGULAR,fb.MESSENGER_BUTTON_STYLE_WHITE_BORDERED);

	function addButtonWithModeAndStyle(mode, style) {
	    var btn = fb.createMessengerButton({
	      top: 20,
	      mode: mode,
	      style: style
	    });

	    btn.addEventListener("click", shareOnMessenger);
	    win.add(btn);
	}

	function shareOnMessenger() {
	    if (!Ti.Platform.canOpenURL("fb-messenger-api://")) {
	        alert("No facebook messenger installed");
	        return;
	    }
	    fb.presentMessengerDialog({
	        title: "Appcelerator Titanium rocks!",
	        description: "Sent using Ti.Facebook",
	        link: "https://appcelerator.com",
	        to: []
	    });
	}

	return win;
};
