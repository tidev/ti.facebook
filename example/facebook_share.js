exports.window = function (value) {
	var win = Titanium.UI.createWindow({
		title: 'Share Dialog'
	});
	var fb = require('facebook');

	var actionsView = Ti.UI.createScrollView({
		visible: fb.loggedIn,
		width: Ti.UI.FILL,
		height: Ti.UI.FILL,
		layout: 'vertical',
		contentHeight: Ti.UI.SIZE,
		backgroundColor: 'white'
	});

	win.add(Ti.UI.createLabel({
		top: 70,
		height: 40,
		text: 'Please log into Facebook',
		textAlign: 'center'
	}));

	fb.addEventListener('login', function (e) {
		if(e.success) {
			actionsView.show();
		}
		if(e.error) {
			alert(e.error);
		}
	});

	fb.addEventListener('logout', function (e) {
		Ti.API.info('logout event');
		actionsView.hide();
	});

	var shareURL = Ti.UI.createButton({
		title: 'Share URL with share dialog',
		top: '10%',
		center: true,
	});

	shareURL.addEventListener('click', function () {
		fb.presentShareDialog({
			contentURL: 'https://www.appcelerator.com',
			hashtag: '#codestrong'
		});
	});

	actionsView.add(shareURL);

	var shareImage = Ti.UI.createButton({
		title: 'Share Image with share dialog',
		top: '10%',
		center: true,
	});

	shareImage.addEventListener('click', function () {
		Titanium.Media.openPhotoGallery({
			success: function (event) {
				fb.presentPhotoShareDialog({
					image: event.media,
					caption: 'B-e-a-utiful!'
				});
			},
			cancel: function () {},
			error: function (error) {},
			allowEditing: true
		});
	});

	actionsView.add(shareImage);

	fb.addEventListener('shareCompleted', function (e) {
		if(e.success) {
			alert('Share completed');
		} else if(e.cancelled) {
			alert('Share cancelled');
		} else {
			alert('error ' + e.errorDesciption + '. code: ' + e.code);
		}
	});

	var requestDialog = Ti.UI.createButton({
		title: 'Request Dialog',
		top: '10%',
		center: true
	});

	requestDialog.addEventListener('click', function () {
		fb.presentSendRequestDialog({
			message: 'Go to https://appcelerator.com/'
		}, {
			data: '{\'badge_of_awesomeness\':\'1\',' +
				'\'social_karma\':\'5\'}'
		});
	});

	fb.addEventListener('requestDialogCompleted', function (e) {
		if(e.success) {
			alert('Request dialog completed. Returned data is ' + e.data);
		} else if(e.cancelled) {
			alert('Request dialog cancelled');
		} else {
			alert('error ' + e.error);
		}
	});

	actionsView.add(requestDialog);
	win.add(actionsView);

	var likeButton = fb.createLikeButton({
		top: '10%',
		height: '50%', // Note: on iOS setting Ti.UI.SIZE dimensions prevented the button click
		width: '50%',
		center: true,
		objectID: 'https://www.facebook.com/appcelerator', // URL or Facebook ID
		foregroundColor: 'white', // A color in Titanium format - see Facebook docs
		likeViewStyle: 'box_count', // standard, button, box_count - see FB docs
		auxiliaryViewPosition: 'inline', // bottom, inline, top - see FB docs
		horizontalAlignment: 'left', // center, left, right - see FB docs,
		soundEnabled: true // boolean, iOS only
	});

	if(Ti.Platform.osname === 'android') {
		likeButton.height = Ti.UI.SIZE;
		likeButton.width = Ti.UI.SIZE;
	}

	actionsView.add(likeButton);

	return win;
};