exports.window = function(value) {
	var fb = require('facebook');
	fb.initialize();

	var win = Ti.UI.createWindow({
		title: 'Facebook Places',
	    backgroundColor: '#fff'
	});

	win.addEventListener('open', function() {
	    
	    function onPermissionsSuccess() {
	        alert('Location permissions granted, you are ready!');
	    }
	    
	    function onPermissionsError() {
	        alert('Location permissions denied, please enable to use Facebook Places!');
	    }
	    
	    if (!Ti.Geolocation.hasLocationPermissions(Ti.Geolocation.AUTHORIZATION_WHEN_IN_USE)) {
	        Ti.Geolocation.requestLocationPermissions(Ti.Geolocation.AUTHORIZATION_WHEN_IN_USE, function(e) {
	            if (!e.success) {
	                onPermissionsError();
	            } else {
	                onPermissionsSuccess();
	            }
	        });
	    } else {
	        onPermissionsSuccess();
	    }
	})

	var btn1 = Ti.UI.createButton({
	    title: 'Find nearby places (GPS)',
	    top: 80
	});

	btn1.addEventListener('click', findPlaces);

	var btn2 = Ti.UI.createButton({
	    title: 'Find nearby places (Text-Input)',
	    top: 160
	});

	btn2.addEventListener('click', function() {
	    var dialog = Ti.UI.createAlertDialog({
	        style: Ti.UI.iOS.AlertDialogStyle.PLAIN_TEXT_INPUT,
	        title: 'Which Location do you want to explore?',
	        hintText: 'Enter Location ...',
	        buttonNames: ['Start Search']
	    });
	    
	    dialog.addEventListener('click', function(e) {
	        findPlacesBySearchTerm(e.value);
	    });
	    
	    dialog.show();
	});

	function findPlaces() {
	    fb.fetchNearbyPlacesForCurrentLocation({
	        confidenceLevel: 0, // optional
	        fields: [], // optional
	        success: function(e) {
	            Ti.API.info(e);
	        },
	        error: function(e) {
	            Ti.API.error(e);
	        }
	    });
	}

	function findPlacesBySearchTerm(value) {
	    fb.fetchNearbyPlacesForSearchTearm({
	        searchTerm: value,
	        categories: [], // categories, optional
	        distance: 5000, // in meters, optional
	        fields: [], // places-fields, optional
	        cursor: null, // paging-cursorm, optional
	        success: function(e) {
	            Ti.API.info(e);
	        },
	        error: function(e) {
	            Ti.API.error(e);
	        }
	    });    
	}

	win.add(btn1);
	win.add(btn2);

	return win;
};
