exports.window = function(value){
	var win = Titanium.UI.createWindow({title:'Read Stream'});
	var fb = require('facebook');
	var b1 = Ti.UI.createButton({
		title:'Run Query',
		width:200,
		height:40,
		top:10
	});
	win.add(b1);
	var tableView = Ti.UI.createTableView({top:60,minRowHeight:100});
	win.add(tableView);
	
	function runQuery()
	{	
		b1.title = 'Loading...';
		
		fb.requestWithGraphPath('me/groups', {}, 'GET',  function(r)
		{
			if (!r.success) {
				if (r.error) {
					alert(r.error);
				} else {
					alert("call was unsuccessful");
				}
				return;
			}
			result = r.result.data;
			
			var data = [];
			for (var c=0;c<result.length;c++)
			{
				var row = result[c];
	
				var tvRow = Ti.UI.createTableViewRow({
					height:'auto',
					selectedBackgroundColor:'#fff',
					backgroundColor:'#fff'
				});
				var imageView;
				imageView = Ti.UI.createImageView({
					image:row.pic_square === null ? '../images/user.png' : row.pic_square,
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
	
/*				var statusLabel = Ti.UI.createLabel({
					font:{fontSize:13},
					left:70,
					top:25,
					right:20,
					height:'auto',
					color:'#222',
					text:(!row.status || !row.status.message ? 'No status message' : row.status.message)
				});
				tvRow.add(statusLabel);*/
	
				tvRow.uid = row.id;
	
				data[c] = tvRow;
			}
			
			tableView.setData(data, { animationStyle : Titanium.UI.iPhone.RowAnimationStyle.DOWN });
			b1.title = 'Run Query';
		});
	}
	
	b1.addEventListener('click', function()
	{
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
