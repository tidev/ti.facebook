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
		if (!e.success) {
			alert(e.error);
			return;
		}

		actionsView.show();
	});

	fb.addEventListener('logout', function (e) {
		Ti.API.info('logout event');
		actionsView.hide();
	});

	var shareURL = Ti.UI.createButton({
		title: 'Share link with share dialog',
		top: '10%',
		center: true,
	});

	shareURL.addEventListener('click', function () {
		fb.presentShareDialog({
			link: 'https://www.appcelerator.com',
			hashtag: '#codestrong'
		});
	});

	actionsView.add(shareURL);

	var shareImage = Ti.UI.createButton({
		title: 'Share image with share dialog',
		top: '10%',
		center: true,
	});

	shareImage.addEventListener('click', function () {
		Titanium.Media.openPhotoGallery({
			success: function (event) {
				fb.presentPhotoShareDialog({
					photos: [
						{
							image: event.media, // Required Ti.Blob or String URL
							caption: 'Great photo!' // Optional caption

						}
					]
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
		title: 'Game Request Dialog',
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

	return win;
};