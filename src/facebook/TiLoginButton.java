/**
 * Facebook Module
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

package facebook;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiC;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.titanium.view.TiUIView;

import android.R;
import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Color;
import android.util.StateSet;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;


public class TiLoginButton extends TiUIView implements TiFacebookStateListener
{
	private static final String TAG = "TiLoginButton";
	private static final int FB_BLUE = 0xFF6D84B4;
	private TiFacebookModule facebook = null;
	private boolean wide;
	// Resource IDs for the various button images.
	private int resId_login = -1;
	private int resId_loginWide = -1;
	private int resId_LoginPressed = -1;
	private int resId_LoginWidePressed = -1;
	private int resId_logout = -1;
	private int resId_logoutPressed = -1;

	public TiLoginButton(final TiViewProxy proxy) {
		super(proxy);
		initFacebook();
		loadResourceIds(proxy.getActivity());
		ImageButton btn = new ImageButton(proxy.getActivity()) {
			@Override
			protected void drawableStateChanged() {
				super.drawableStateChanged();
				int[] states = getDrawableState();
				if (StateSet.stateSetMatches(
						new int[] { R.attr.state_pressed }, states)
						|| StateSet.stateSetMatches(
								new int[] { R.attr.state_focused }, states)) {
					updateButtonImage(true);
				} else {
					updateButtonImage(false);
				}
			}
		};
		setNativeView(btn);
		btn.setBackgroundColor(Color.TRANSPARENT);
		updateButtonImage(false);
	}

	private void initFacebook()
	{
		this.facebook = ((TiFacebookModuleLoginButtonProxy)this.getProxy()).getFacebookModule();
	}

	protected void updateButtonImage(boolean pressed) {
		if (TiApplication.isUIThread()) {
			handleUpdateButtonImage(pressed);
		} else {
			final boolean fPressed = pressed;
			getProxy().getActivity().runOnUiThread(new Runnable()
			{
				@Override
				public void run()
				{
					handleUpdateButtonImage(fPressed);

				}
			});
		}
	}

	private void handleUpdateButtonImage(boolean pressed)
	{
		boolean loggedIn = facebook.getLoggedIn();
		String stateDescription;
		int resid = 0;
		if (loggedIn) {
			if (pressed) {
				resid = resId_logoutPressed;
				stateDescription = "logged-in and button pressed";
			} else {
				resid = resId_logout;
				stateDescription = "logged-in, button not pressed";
			}
		} else {
			if (wide) {
				if (pressed) {
					resid = resId_LoginWidePressed;
					stateDescription = "not logged-in, using wide button, button is pressed";
				} else {
					resid = resId_loginWide;
					stateDescription = "not logged-in, using wide button, button is not pressed";
				}
			} else {
				if (pressed) {
					resid = resId_LoginPressed;
					stateDescription = "not logged-in, using narrow button, button is pressed";
				} else {
					resid = resId_login;
					stateDescription = "not logged-in, using narrow button, button is not pressed";
				}
			}
		}
		ImageButton btn = (ImageButton) getNativeView();
		if (btn == null) {
			return;
		}
		if (resid > 0) {
			btn.setBackgroundColor(Color.TRANSPARENT);
			btn.setImageResource(resid);
		} else {
			Log.w(TAG, "Facebook resource image could not be located!  State: " + stateDescription);
			// At least give it a "facebook blue" background so it can be seen.
			btn.setBackgroundColor(FB_BLUE);
		}
	}

	@Override
	public void processProperties(KrollDict d) {
		super.processProperties(d);

		facebook.addListener(this);

		if (d.containsKey(TiC.PROPERTY_STYLE)) {
			Object style = d.get(TiC.PROPERTY_STYLE);
			if (style instanceof Number) {
				int styleValue = TiConvert.toInt(style);
				if (styleValue == TiFacebookModule.BUTTON_STYLE_WIDE) {
					wide = true;
					updateButtonImage(false);
				}
			} else {
				String styleName = TiConvert.toString(style);
				if (styleName.equals("wide")) {
					wide = true;
					updateButtonImage(false);
				}
			}
		}
	}

	// TiFacebookStateListener implementation
	@Override
    public void login()
    {
		updateButtonImage(false);
    }
	@Override
    public void logout()
    {
		updateButtonImage(false);
    }

	@Override
	public void release()
	{
		super.release();
		if (facebook != null) {
			facebook.removeListener(this);
		}
	}

	@Override
	protected void setOnClickListener(View view)
	{
		if (view == nativeView) {
			final ImageButton btn = (ImageButton) view;
			btn.setOnClickListener(new OnClickListener() {
				public void onClick(View arg0) {
					if (facebook.getLoggedIn()) {
						facebook.logout();
					} else {
						Activity activity = null;
						if (btn.getContext() instanceof Activity) {
							activity = (Activity) btn.getContext();
						} else {
							activity = getProxy().getActivity();
						}
						if (activity == null) {
							// Fallback on the root activity if possible
							activity = TiApplication.getInstance().getRootActivity();
						}
						facebook.authorize();
					}
				}
			});
		}
	}

	private void loadResourceIds(Context context)
	{
		String packageName = context.getPackageName();
		Resources resources = context.getResources();
		resId_login = resources.getIdentifier("titanium_facebook_login", "drawable", packageName);
		resId_LoginPressed = resources.getIdentifier("titanium_facebook_login_down", "drawable", packageName);
		resId_loginWide = resources.getIdentifier("titanium_facebook_login_wide", "drawable", packageName);
		resId_LoginWidePressed = resources.getIdentifier("titanium_facebook_login_wide_down", "drawable", packageName);
		resId_logout = resources.getIdentifier("titanium_facebook_logout", "drawable", packageName);
		resId_logoutPressed = resources.getIdentifier("titanium_facebook_logout_down", "drawable", packageName);
	}
}