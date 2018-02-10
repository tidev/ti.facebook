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
import org.appcelerator.titanium.view.TiUIView;

import android.app.Activity;

import com.facebook.CallbackManager;
import com.facebook.login.DefaultAudience;
import com.facebook.login.widget.LoginButton;
import com.facebook.login.widget.ToolTipPopup;
import com.facebook.login.widget.LoginButton.ToolTipMode;

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
		Log.d(TAG, "[VIEW LIFECYCLE EVENT] processProperties " + props);
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
				case TiFacebookModule.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC:
					loginButton.setToolTipMode(ToolTipMode.AUTOMATIC);
					break;
				case TiFacebookModule.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_FORCE_DISPLAY:
					loginButton.setToolTipMode(ToolTipMode.DISPLAY_ALWAYS);
					break;
				case TiFacebookModule.LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE:
					loginButton.setToolTipMode(ToolTipMode.NEVER_DISPLAY);
					break;
			}
		}
		if (props.containsKey("tooltipColorStyle")) {
			Object value = props.get("tooltipColorStyle");
			String tooltipColorStyle =
				TiConvert.toString(value, TiFacebookModule.LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY);

			if (tooltipColorStyle.equals(TiFacebookModule.LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY)) {
				loginButton.setToolTipStyle(ToolTipPopup.Style.BLACK);
			} else if (tooltipColorStyle.equals(TiFacebookModule.LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE)) {
				loginButton.setToolTipStyle(ToolTipPopup.Style.BLUE);
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
