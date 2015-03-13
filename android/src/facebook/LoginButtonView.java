/**
  * Copyright (c) 2015 by Appcelerator, Inc. All Rights Reserved.
  * Licensed under the terms of the Apache Public License 2.0
  * Please see the LICENSE included with this distribution for details.
  *
  */
package facebook;

import java.util.Arrays;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.titanium.util.TiRHelper;
import org.appcelerator.titanium.util.TiRHelper.ResourceNotFoundException;
import org.appcelerator.titanium.view.TiUIView;

import com.facebook.SessionDefaultAudience;
import com.facebook.SessionLoginBehavior;
import com.facebook.widget.LoginButton;

public class LoginButtonView extends TiUIView {

	private static final String TAG = "LoginButtonView";
	private LoginButton loginButton;
	
	public LoginButtonView(TiViewProxy proxy) {
		super(proxy);

		Log.d(TAG, "[VIEW LIFECYCLE EVENT] view");
		
		int fbLoginButtonId;
		try {
			fbLoginButtonId = TiRHelper.getResource("layout.ti_fb_login_button");
		} catch (ResourceNotFoundException e) {
			Log.e(TAG, "XML resources could not be found!!!");
			return;
		}
		loginButton = (LoginButton) proxy.getActivity().getLayoutInflater().inflate(fbLoginButtonId, null);

		// Set the view as the native view. You must set the native view
		// for your view to be rendered correctly.
		setNativeView(loginButton);
	}
		
	@Override
	public void processProperties(KrollDict props) 
	{
		super.processProperties(props);
		Log.d(TAG,"[VIEW LIFECYCLE EVENT] processProperties " + props);
		if (props.containsKey("publishPermissions")) {
			Object value = props.get("publishPermissions");
			if (value instanceof Object[]) {
				String[] publishPermissions = TiConvert.toStringArray((Object[]) value);
				loginButton.setPublishPermissions(Arrays.asList(publishPermissions));
			}
		}
		if (props.containsKey("readPermissions")) {
			Object value = props.get("readPermissions");
			if (value instanceof Object[]) {
				String[] readPermissions = TiConvert.toStringArray((Object[]) value);
				loginButton.setReadPermissions(Arrays.asList(readPermissions));
			}
		}
		if (props.containsKey("audience")) {
			Object value = props.get("audience");
			int audience = TiConvert.toInt(value, TiFacebookModule.AUDIENCE_NONE);
			switch(audience){
				case TiFacebookModule.AUDIENCE_NONE:
					loginButton.setDefaultAudience(SessionDefaultAudience.NONE);
					break;
				case TiFacebookModule.AUDIENCE_ONLY_ME:
					loginButton.setDefaultAudience(SessionDefaultAudience.ONLY_ME);
					break;
				case TiFacebookModule.AUDIENCE_FRIENDS:
					loginButton.setDefaultAudience(SessionDefaultAudience.FRIENDS);
					break;
				case TiFacebookModule.AUDIENCE_EVERYONE:
					loginButton.setDefaultAudience(SessionDefaultAudience.EVERYONE);
					break;
			}
		}
		if (props.containsKey("sessionLoginBehavior")) {
			Object value = props.get("sessionLoginBehavior");
			int loginBehavior = TiConvert.toInt(value, TiFacebookModule.SSO_WITH_FALLBACK);
			switch(loginBehavior){
				case TiFacebookModule.SSO_WITH_FALLBACK:
					loginButton.setLoginBehavior(SessionLoginBehavior.SSO_WITH_FALLBACK);
					break;
				case TiFacebookModule.SSO_ONLY:
					loginButton.setLoginBehavior(SessionLoginBehavior.SSO_ONLY);
					break;
				case TiFacebookModule.SUPPRESS_SSO:
					loginButton.setLoginBehavior(SessionLoginBehavior.SUPPRESS_SSO);
					break;
			}
		}

	}
	
	@Override
	public void propertyChanged(String key, Object oldValue, Object newValue, KrollProxy proxy)
	{
		// This method is called whenever a proxy property value is updated. Note that this 
		// method is only called if the new value is different than the current value.
		if (key.equals("publishPermissions")) {
			if (newValue instanceof Object[]) {
				String[] publishPermissions = TiConvert.toStringArray((Object[]) newValue);
				loginButton.setPublishPermissions(Arrays.asList(publishPermissions));
			}
		} else if (key.equals("readPermissions")) {
			if (newValue instanceof Object[]) {
				String[] readPermissions = TiConvert.toStringArray((Object[]) newValue);				
				loginButton.setReadPermissions(Arrays.asList(readPermissions));
			}
		} else if (key.equals("audience")) {
			int audience = TiConvert.toInt(newValue, TiFacebookModule.AUDIENCE_NONE);
			switch(audience){
				case TiFacebookModule.AUDIENCE_NONE:
					loginButton.setDefaultAudience(SessionDefaultAudience.NONE);
					break;
				case TiFacebookModule.AUDIENCE_ONLY_ME:
					loginButton.setDefaultAudience(SessionDefaultAudience.ONLY_ME);
					break;
				case TiFacebookModule.AUDIENCE_FRIENDS:
					loginButton.setDefaultAudience(SessionDefaultAudience.FRIENDS);
					break;
				case TiFacebookModule.AUDIENCE_EVERYONE:
					loginButton.setDefaultAudience(SessionDefaultAudience.EVERYONE);
					break;
			}
		} else if (key.equals("sessionLoginBehavior")) {
			int loginBehavior = TiConvert.toInt(newValue, TiFacebookModule.SSO_WITH_FALLBACK);
			switch(loginBehavior){
				case TiFacebookModule.SSO_WITH_FALLBACK:
					loginButton.setLoginBehavior(SessionLoginBehavior.SSO_WITH_FALLBACK);
					break;
				case TiFacebookModule.SSO_ONLY:
					loginButton.setLoginBehavior(SessionLoginBehavior.SSO_ONLY);
					break;
				case TiFacebookModule.SUPPRESS_SSO:
					loginButton.setLoginBehavior(SessionLoginBehavior.SUPPRESS_SSO);
					break;
			}
		} else {
			super.propertyChanged(key, oldValue, newValue, proxy);
		}
		
		Log.d(TAG,"[VIEW LIFECYCLE EVENT] propertyChanged: " + key + ' ' + oldValue + ' ' + newValue);
	}
}
