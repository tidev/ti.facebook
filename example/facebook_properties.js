function fb_properties() {
	var fb = require('facebook');
	
	var win = Ti.UI.createWindow({
		title: 'Properties',
		backgroundColor:'#fff',
		fullscreen: false
	});
	
	win.fbProxy = fb.createActivityWorker({lifecycleContainer: win});
	
	var sv = Ti.UI.createScrollView({
		contentWidth:'auto',
		contentHeight:'auto',
		top:0,
		showVerticalScrollIndicator:true,
		showHorizontalScrollIndicator:true
	});
	win.add(sv);
		
	var plist = []; // list of known FB permissions as of Jan 2011 (see bottom)
	//
	// Login Button
	//
	var fbButton = fb.createLoginButton({
		top: 10
	});
	fbButton.style = fb.BUTTON_STYLE_NORMAL;
	sv.add(fbButton);
	

	var b1 = Ti.UI.createButton({
		title:'Display Properties',
		width:300,
		height:80,
		top:90
	});
	sv.add(b1);
	
	var loggedIn = Ti.UI.createLabel({
		title:'',
		width:300,
		top:200,
		font:{fontSize:13},
		color:'#777'
	});
	sv.add(loggedIn);
	
	var userId = Ti.UI.createLabel({
		title:'',
		height:'auto',
		width:300,
		top:240,
		font:{fontSize:13},
		color:'#777'
	});
	sv.add(userId);
	
	var permissions = Ti.UI.createLabel({
		text:'',
		height:'auto',
		width:300,
		top:280,
		font:{fontSize:13},
		color:'#777'
	});
	sv.add(permissions);
	
	b1.addEventListener('click', function()
	{
		Ti.API.info("click called, logged in = "+fb.loggedIn);
		
		if (!fb.loggedIn)
		{
			Ti.UI.createAlertDialog({title:'Facebook', message:'Login before accessing properties'}).show();
			return;
		}
		loggedIn.text = 'Logged In = ' + fb.getLoggedIn();
		userId.text = 'User Id = ' + fb.getUid();
		permissions.text = "querying for permissions ...";
		
		var query = 'select ' + plist.join(',') + ' from permissions where uid = me()';
		Ti.API.info('Will run query: ' + query);
		
		// https://developers.facebook.com/docs/reference/fql/
		// v2.0 of the Facebook Platform API is the last version where FQL will be available. 
		// v2.0 would expire on August 7th, 2016
		// https://developers.facebook.com/docs/apps/upgrading
		// v1.0 of the Graph API will be deprecated on April 30, 2015
		fb.requestWithGraphPath('v1.0/fql', {q: query}, "GET", function(r) {
			if (!r.success || !r.result) {
				if (r.error) {
					permissions.text = 'error: ' + r.error;
				} else {
					permissions.text = 'failed to query for permissions';
				}
				return;
			}
			permissions.text = '';
			Ti.API.info('Query result from facebook: ' + r.result);
			var list = JSON.parse(r.result).data[0];
		
			var text = '';
			for (var v in list)
			{
				if (v!==null)
				{
					text += v + ' value = ' + list[v] + '\n';
				}
			}
			permissions.text = text;
		});
		
	});
	
	// build list of known FB permissions as of Jan 2011.
	// see http://developers.facebook.com/docs/authentication/permissions
	// friend_* permissions are not included here.
	plist.push('publish_stream');
	plist.push('create_event');
	plist.push('rsvp_event');
	plist.push('sms');
	plist.push('offline_access');
	plist.push('publish_checkins');
	plist.push('user_about_me');
	plist.push('user_activities');
	plist.push('user_birthday');
	plist.push('user_education_history');
	plist.push('user_events');
	plist.push('user_groups');
	plist.push('user_hometown');
	plist.push('user_interests');
	plist.push('user_likes');
	plist.push('user_location');
	plist.push('user_notes');
	plist.push('user_online_presence');
	plist.push('user_photo_video_tags');
	plist.push('user_photos');
	plist.push('user_relationships');
	plist.push('user_relationship_details');
	plist.push('user_religion_politics');
	plist.push('user_status');
	plist.push('user_videos');
	plist.push('user_website');
	plist.push('user_work_history');
	plist.push('email');
	plist.push('read_friendlists');
	plist.push('read_insights');
	plist.push('read_mailbox');
	plist.push('read_requests');
	plist.push('read_stream');
	plist.push('xmpp_login');
	plist.push('ads_management');
	plist.push('user_checkins');
	plist.push('manage_pages');
	
	return win;
};

module.exports = fb_properties;
