// this sets the background color of the master UIView (when there are no windows/tab groups on it)
Titanium.UI.setBackgroundColor('#000');

// create tab group
var tabGroup = Titanium.UI.createTabGroup({backgroundColor:'#fff'});
var fb = require('facebook');
//
// create base UI tab and root window
//
tabGroup.addTab(Titanium.UI.createTab({  
    icon:'KS_nav_views.png',
    title:'Login',
    window:require('loginwindow').window()
}));
tabGroup.addTab(Titanium.UI.createTab({  
    icon:'KS_nav_views.png',
    title:'Read',
    window:require('readstream').window()
}));
tabGroup.addTab(Titanium.UI.createTab({  
    icon:'KS_nav_views.png',
    title:'Publish',
    window:require('publishstream').window()
}));

//fb.permissions = ['read_stream','email'];
fb.initialize(); // after you set up login/logout listeners and permissions
// open tab group
tabGroup.open();
