function fb_query() {
	var fb = require('facebook');
	
	var win = Ti.UI.createWindow({
		title: 'Read Stream',
		backgroundColor:'#fff',
		fullscreen: false
	});

	if (Ti.Platform.osname == 'android') {
		win.fbProxy = fb.createActivityWorker({lifecycleContainer: win});
	}
	
	//
	// Login Button
	//
	var fbButton = fb.createLoginButton({
		bottom:10
	});
	fbButton.style = fb.BUTTON_STYLE_NORMAL;
	win.add(fbButton);
	
	var b1 = Ti.UI.createButton({
		title:'Read User\'s Groups',
		width:260,
		height:80,
		top:10
	});
	win.add(b1);
		
	function runQuery() {
		b1.title = 'Loading...';
	
		fb.requestWithGraphPath('me/groups', {}, 'GET',  function(r)
		{
			var tableView = Ti.UI.createTableView({minRowHeight:30});
			var window = Ti.UI.createWindow({title:'Facebook Query'});
			window.add(tableView);
			
			if (!r.success) {
				if (r.error) {
					alert(r.error);
				} else {
					alert("call was unsuccessful");
				}
				return;
			}
			var resultsNew = JSON.parse(r.result);
			var result = JSON.parse(r.result).data;
			var data = [];
			for (var c=0;c<result.length;c++)
			{

				var row = result[c];
	
				var tvRow = Ti.UI.createTableViewRow({
					height:'auto',
					selectedBackgroundColor:'#fff',
					backgroundColor:'#fff'
				});
	
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

				data[c] = tvRow;			
				
				tvRow.uid = row.id;

			}
			
			tableView.setData(data, { animationStyle : Titanium.UI.iPhone.RowAnimationStyle.DOWN });
			
			window.open({modal:true});
			b1.title = 'Run Query';
		});
	}
	
	b1.addEventListener('click', function() {
		if (!fb.loggedIn)
		{
			Ti.UI.createAlertDialog({title:'Facebook', message:'Login before running query'}).show();
			return;
		}
	
		if(fb.permissions.indexOf('user_groups') < 0) {
			fb.requestNewReadPermissions(['user_groups'],function(e){
				if(!e.success){
					Ti.API.debug('Failed authorization due to: ' + e.error);
				} else {
					runQuery();
				}
			});
		} else {
			runQuery();
		}
	});
	return win;
};

module.exports = fb_query;
