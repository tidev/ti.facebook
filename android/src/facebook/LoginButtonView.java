/**
  * Copyright (c) 2015 by Appcelerator, Inc. All Rights Reserved.
  * Licensed under the terms of the Apache Public License 2.0
  * Please see the LICENSE included with this distribution for details.
  *
  */
package facebook;

import android.app.Activity;
import com.facebook.CallbackManager;
import com.facebook.login.DefaultAudience;
import com.facebook.login.widget.LoginButton;
import com.facebook.login.widget.LoginButton.ToolTipMode;
import com.facebook.login.widget.ToolTipPopup;
import java.util.ArrayList;
import java.util.Arrays;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.titanium.view.TiUIView;

public class LoginButtonView extends TiUIView
{

	private static final String TAG = "LoginButtonView";
	private LoginButton loginButton;
	CallbackManager callbackManager;
	private TiFacebookModule module;

	public LoginButtonView(TiViewProxy proxy)
	{
		super(proxy);
		module = TiFacebookModule.getFacebookModule();
		final Activity mActivity = proxy.getActivity();
		Log.d(TAG, "[VIEW LIFECYCLE EVENT] view");
		loginButton = new LoginButton(mActivity);
		// Callback registration
		callbackManager = module.getCallbackManager();
		loginButton.registerCallback(callbackManager, module.getFacebookCallback());
		setNativeView(loginButton);
	}

	@Override
	public void processProperties(KrollDict props)
	{
		super.processProperties(props);

		ArrayList<String> permissionList = new ArrayList<>();
		if (props.containsKey("publishPermissions")) {
			Log.w(TAG, "The 'publishPermissions' property has been deprecated in favor of the 'permissions' property");
			Object value = props.get("publishPermissions");
			if (value instanceof Object[]) {
				permissionList.addAll(Arrays.asList(TiConvert.toStringArray((Object[]) value)));
			}
		}
		if (props.containsKey("readPermissions")) {
			Log.w(TAG, "The 'readPermissions' property has been deprecated in favor of the 'permissions' property");
			Object value = props.get("readPermissions");
			if (value instanceof Object[]) {
				permissionList.addAll(Arrays.asList(TiConvert.toStringArray((Object[]) value)));
			}
		}
		if (props.containsKey("permissions")) {
			Object value = props.get("permissions");
			if (value instanceof Object[]) {
				permissionList.addAll(Arrays.asList(TiConvert.toStringArray((Object[]) value)));
			}
		}
		if (!permissionList.isEmpty()) {
			loginButton.setPermissions(permissionList);
		}

		if (props.containsKey("audience")) {
			Object value = props.get("audience");
			int audience = TiConvert.toInt(value, TiFacebookModule.AUDIENCE_NONE);
			switch (audience) {
				case TiFacebookModule.AUDIENCE_NONE:
					loginButton.setDefaultAudience(DefaultAudience.NONE);
					break;
				case TiFacebookModule.AUDIENCE_ONLY_ME:
					loginButton.setDefaultAudience(DefaultAudience.ONLY_ME);
					break;
				case TiFacebookModule.AUDIENCE_FRIENDS:
					loginButton.setDefaultAudience(DefaultAudience.FRIENDS);
					break;
				case TiFacebookModule.AUDIENCE_EVERYONE:
					loginButton.setDefaultAudience(DefaultAudience.EVERYONE);
					break;
			}
		}
		if (props.containsKey("tooltipBehavior")) {
			Object value = props.get("tooltipBehavior");
			int tooltipBehavior = TiConvert.toInt(value, TiFacebookModule.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC);

			switch (tooltipBehavior) {
				case TiFacebookModule.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_FORCE_DISPLAY:
					loginButton.setToolTipMode(ToolTipMode.DISPLAY_ALWAYS);
					break;
				case TiFacebookModule.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE:
					loginButton.setToolTipMode(ToolTipMode.NEVER_DISPLAY);
					break;
				default:
				case TiFacebookModule.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC:
					loginButton.setToolTipMode(ToolTipMode.AUTOMATIC);
					break;
			}
		}
		if (props.containsKey("tooltipColorStyle")) {
			Object value = props.get("tooltipColorStyle");
			int tooltipColorStyle = TiConvert.toInt(value, TiFacebookModule.LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE);
			switch (tooltipColorStyle) {
				case TiFacebookModule.LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY:
					loginButton.setToolTipStyle(ToolTipPopup.Style.BLACK);
					break;
				default:
				case TiFacebookModule.LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE:
					loginButton.setToolTipStyle(ToolTipPopup.Style.BLUE);
					break;
			}
		}
	}

	@Override
	public void propertyChanged(String key, Object oldValue, Object newValue, KrollProxy proxy)
	{
		if (key.equals("publishPermissions")) {
			Log.w(TAG, "The 'publishPermissions' property has been deprecated in favor of the 'permissions' property");
			if (newValue instanceof Object[]) {
				String[] permissions = TiConvert.toStringArray((Object[]) newValue);
				loginButton.setPermissions(Arrays.asList(permissions));
			}
		} else if (key.equals("readPermissions")) {
			Log.w(TAG, "The 'readPermissions' property has been deprecated in favor of the 'permissions' property");
			if (newValue instanceof Object[]) {
				String[] permissions = TiConvert.toStringArray((Object[]) newValue);
				loginButton.setPermissions(Arrays.asList(permissions));
			}
		} else if (key.equals("permissions")) {
			if (newValue instanceof Object[]) {
				String[] permissions = TiConvert.toStringArray((Object[]) newValue);
				loginButton.setPermissions(Arrays.asList(permissions));
			}
		} else if (key.equals("audience")) {
			int audience = TiConvert.toInt(newValue, TiFacebookModule.AUDIENCE_NONE);
			switch (audience) {
				case TiFacebookModule.AUDIENCE_NONE:
					loginButton.setDefaultAudience(DefaultAudience.NONE);
					break;
				case TiFacebookModule.AUDIENCE_ONLY_ME:
					loginButton.setDefaultAudience(DefaultAudience.ONLY_ME);
					break;
				case TiFacebookModule.AUDIENCE_FRIENDS:
					loginButton.setDefaultAudience(DefaultAudience.FRIENDS);
					break;
				case TiFacebookModule.AUDIENCE_EVERYONE:
					loginButton.setDefaultAudience(DefaultAudience.EVERYONE);
					break;
			}
		} else {
			super.propertyChanged(key, oldValue, newValue, proxy);
		}

		Log.d(TAG, "[VIEW LIFECYCLE EVENT] propertyChanged: " + key + ' ' + oldValue + ' ' + newValue);
	}
}
