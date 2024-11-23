/**
  * Copyright (c) 2015 by Appcelerator, Inc. All Rights Reserved.
  * Licensed under the terms of the Apache Public License 2.0
  * Please see the LICENSE included with this distribution for details.
  *
  */
package facebook;

import android.app.Activity;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;

@Kroll.proxy(
	creatableInModule = TiFacebookModule.class,
	propertyAccessors = { "audience", "publishPermissions", "readPermissions", "tooltipBehavior", "tooltipColorStyle" })
public class LoginButtonProxy extends TiViewProxy
{
	// Standard Debugging variables
	private static final String TAG = "LoginButtonProxy";

	public LoginButtonProxy()
	{
		super();
		defaultValues.put("audience", TiFacebookModule.AUDIENCE_FRIENDS);
		defaultValues.put("tooltipBehavior", TiFacebookModule.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC);
		defaultValues.put("tooltipColorStyle", TiFacebookModule.LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE);
	}

	@Override
	public String getApiName()
	{
		return "Ti.Facebook.LoginButton";
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

		// Calling the superclass method ensures that the properties specified
		// in the dictionary are properly set on the proxy object.
		super.handleCreationDict(options);
	}
}
