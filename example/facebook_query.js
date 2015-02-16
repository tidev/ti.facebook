function fb_query() {
	var fb = require('facebook');
	
	var win = Ti.UI.createWindow({
		title:'Query',
		backgroundColor:'#fff',
		fullscreen: false
	});
	
	win.fbProxy = fb.createActivityWorker({lifecycleContainer: win});
	
	//
	// Login Button
	//
	var fbButton = fb.createLoginButton({
		bottom:10
	});
	fbButton.style = fb.BUTTON_STYLE_NORMAL;
	win.add(fbButton);
	
	var b1 = Ti.UI.createButton({
		title:'Run Query',
		width:260,
		height:80,
		top:10
	});
	win.add(b1);
		
	function runQuery() {
		b1.title = 'Loading...';
	
		var tableView = Ti.UI.createTableView({minRowHeight:100});
		var win = Ti.UI.createWindow({title:'Facebook Query'});
		win.add(tableView);
		
		// run query, populate table view and open window
		var query = "SELECT uid, name, pic_square, status FROM user ";
		query +=  "where uid IN (SELECT uid2 FROM friend WHERE uid1 = " + fb.uid + ")";
		query += "order by last_name limit 20";
		Ti.API.info('user id ' + fb.uid);
		// https://developers.facebook.com/docs/apps/upgrading#upgrading_v2_0_user_ids
		// In v2.0, the friends API endpoint returns the list of a person's friends who are also using your app. 
		// In v1.0, the response included all of a person's friends.
		// https://developers.facebook.com/docs/reference/fql/
		// v2.0 of the Facebook Platform API is the last version where FQL will be available. 
		// v2.0 would expire on August 7th, 2016
		// https://developers.facebook.com/docs/apps/upgrading
		// v1.0 of the Graph API will be deprecated on April 30, 2015
		fb.requestWithGraphPath('v1.0/fql', {q: query}, "GET", function(r) {
			if (!r.success) {
				if (r.error) {
					alert(r.error);
				} else {
					alert("call was unsuccessful");
				}
				return;
			}
			var result = JSON.parse(r.result);
			var data = [];
			for (var c=0;c<result.data.length;c++)
			{
				var row = result.data[c];
	
				var tvRow = Ti.UI.createTableViewRow({
					height:'auto',
					backgroundSelectedColor:'#fff',
					backgroundColor:'#fff'
				});
				var imageView;
				imageView = Ti.UI.createImageView({
					image:row.pic_square === null ? '/images/user.png' : row.pic_square,
					left:10,
					width:50,
					height:50
				});
	
				tvRow.add(imageView);
	
				var userLabel = Ti.UI.createLabel({
					font:{fontSize:16, fontWeight:'bold'},
					left:70,
					top:5,
					right:5,
					height:20,
					color:'#576996',
					text:row.name
				});
				tvRow.add(userLabel);
	
				var statusLabel = Ti.UI.createLabel({
					font:{fontSize:13},
					left:70,
					top:25,
					right:20,
					height:'auto',
					color:'#222',
					text:(!row.status || !row.status.message ? 'No status message' : row.status.message)
				});
				tvRow.add(statusLabel);
	
				tvRow.uid = row.uid;
	
				data[c] = tvRow;
			}
			
			tableView.setData(data);
			
			win.open({modal:true});
			b1.title = 'Run Query';
		});
	}
	
	b1.addEventListener('click', function() {
		if (!fb.loggedIn)
		{
			Ti.UI.createAlertDialog({title:'Facebook', message:'Login before running query'}).show();
			return;
		}
	
		runQuery();
	});
	return win;
};

module.exports = fb_query;
