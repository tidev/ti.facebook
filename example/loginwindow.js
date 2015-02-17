exports.window = function(value){
	var win = Titanium.UI.createWindow({title:'Login'});
	var fb = require('facebook');
	//
	// Login Status
	//
	var label = Ti.UI.createLabel({
		text:'Logged In = ' + fb.loggedIn,
		font:{fontSize:14},
		height:'auto',
		top:10,
		textAlign:'center'
	});
	win.add(label);
	
	var loginButton = Ti.UI.createButton({
		title:'Log in',
		top:50,
		width:160,
		height:40
	});
	win.add(loginButton);
		
	loginButton.addEventListener('click', function() {
  		if (!fb.loggedIn) {
  		// then you want to show a login UI
  			fb.authorize();
  		}
	});

	var logoutButton = Ti.UI.createButton({
		title:'Logout',
		top:100,
		width:160,
		height:40
	});
	win.add(logoutButton);
		
	logoutButton.addEventListener('click', function() {
		if(fb.loggedIn) {
			fb.logout();
		}
	});	
	
	fb.addEventListener('login',function(e) {
		// You *will* get this event if loggedIn == false below
     	// Make sure to handle all possible cases of this event
     	if (e.success) {
 			alert('login from uid: '+e.uid+', name: '+e.data.name);
 			label.text = 'Logged In = ' + fb.loggedIn;
     	}
     	else if (e.cancelled) {
       		// user cancelled logout
       		alert('login cancelled');
     	}
     	else {
       		alert(e.error);   		
     	}
  	});
 
 	fb.addEventListener('logout',function(e) {
		alert('logged out');
		label.text = 'Logged In = ' + fb.loggedIn;
  	});
  	
  	var permissionsButton = Ti.UI.createButton({
		title:'current Permissions',
		top:200,
		width:160,
		height:40
	});
	win.add(permissionsButton);
		
	permissionsButton.addEventListener('click', function() {
		fb.refreshPermissionsFromServer();
	});	
	
	fb.addEventListener('tokenUpdated', function() {
		alert(fb.permissions);
	});
/* 
 	function updateReadPerms(){
		if (doRead.value) {
			fb.requestNewReadPermissions(['read_stream'], function(e) {
				if(e.success) {
					alert('request read permission success');
				} else if (e.cancelled) {
					alert('user cancelled');
				} else {
					Ti.API.debug('Failed authorization due to: ' + e.error);
				}
			});
		}
	}

	function readToggle(title,viewTop){
		win.add(Ti.UI.createLabel({
			top:viewTop, left:10, width:200, text:title, height:40
		}));
		var result = Ti.UI.createSwitch({
			value:false, left:220, top:viewTop
		});
		win.add(result);
		result.addEventListener('change',updateReadPerms);
		return result;
	}

	var doRead = readToggle('Read stream',200);
	*/
	 	function updatePublishPerms(){
		if (doPublish.value) {
			fb.requestNewPublishPermissions(['publish_actions'],fb.AUDIENCE_FRIENDS, function(e) {
				if(e.success) {
					alert('request publish permission success');
				} else if (e.cancelled) {
					alert('user cancelled');
				} else {
					Ti.API.debug('Failed authorization due to: ' + e.error);
				}
			});
		}
	}

	function publishToggle(title,viewTop){
		win.add(Ti.UI.createLabel({
			top:viewTop, left:10, width:200, text:title, height:40
		}));
		var result = Ti.UI.createSwitch({
			value:false, left:220, top:viewTop
		});
		win.add(result);
		result.addEventListener('change',updatePublishPerms);
		return result;
	}

	var doPublish = publishToggle('Publish stream',150);

	//
	// Login Button
	//
	var logInButton = fb.createLogInButton({
    	top: 260,
    	height: 40, // Note: on iOS setting Ti.UI.SIZE dimensions prevented the button click
    	width: 200,
    	readPermissions: ['read_stream','email']
//publishPermissions: ['publish_actions'],
//    	audience: fb.AUDIENCE_EVERYONE
	});
	win.add(logInButton);
	
	return win;
};
