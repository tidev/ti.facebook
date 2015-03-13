/**
  * Copyright (c) 2015 by Appcelerator, Inc. All Rights Reserved.
  * Licensed under the terms of the Apache Public License 2.0
  * Please see the LICENSE included with this distribution for details.
  *
  */
package facebook;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;

import android.app.Activity;

@Kroll.proxy(creatableInModule = TiFacebookModule.class, propertyAccessors={
	"audience",
	"publishPermissions",
	"readPermissions",
	"sessionLoginBehavior"
 })
public class LoginButtonProxy extends TiViewProxy {
	// Standard Debugging variables
	private static final String TAG = "LoginButtonProxy";

	public LoginButtonProxy() {
		super();
		Log.d(TAG, "[VIEWPROXY LIFECYCLE EVENT] init");
	}
			
	@Override
	public TiUIView createView(Activity activity) 
	{
		return new LoginButtonView(this);
	}

	// Handle creation options
	@Override
	public void handleCreationDict(KrollDict options) 
	{
		// This method is called from handleCreationArgs if there is at least
		// argument specified for the proxy creation call and the first argument
		// is a KrollDict object.

		Log.d(TAG, "VIEWPROXY LIFECYCLE EVENT] handleCreationDict " + options);

		// Calling the superclass method ensures that the properties specified
		// in the dictionary are properly set on the proxy object.
		super.handleCreationDict(options);
	}
}
