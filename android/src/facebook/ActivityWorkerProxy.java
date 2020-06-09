/**
 * Copyright (c) 2014 by Mark Mokryn All Rights Reserved.
 * Licensed under the terms of the Apache Public License 2.0
 * Please see the LICENSE included with this distribution for details.
 *
 * Appcelerator Titanium Mobile
 * Copyright (c) 2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package facebook;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiBaseActivity;
import org.appcelerator.titanium.TiLifecycle.OnInstanceStateEvent;
import org.appcelerator.titanium.TiLifecycle.OnActivityResultEvent;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;

import com.facebook.*;

@Kroll.proxy(creatableInModule = TiFacebookModule.class)
public class ActivityWorkerProxy extends KrollProxy implements OnActivityResultEvent, OnInstanceStateEvent
{
	private static final String TAG = "ActivityWorkerProxy";
	AccessTokenTracker accessTokenTracker;

	// Constructor
	public ActivityWorkerProxy()
	{
		super();
	}

	// Handle creation options
	@Override
	public void handleCreationDict(KrollDict options)
	{
		super.handleCreationDict(options);

		if (options.containsKey("lifecycleContainer") && accessTokenTracker == null) {
			TiWindowProxy window = (TiWindowProxy)options.get("lifecycleContainer");

			this.onCreate(window.getActivity(), null);
		}
	}

	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState)
	{
		Log.d(TAG, "onCreate called for ActivityWorkerProxy");
		((TiBaseActivity) activity).addOnActivityResultListener(this);
		accessTokenTracker = new AccessTokenTracker() {
			@Override
			protected void onCurrentAccessTokenChanged(AccessToken oldAccessToken, AccessToken currentAccessToken)
			{
				if (currentAccessToken == null) {
					// User logged out
					TiFacebookModule.getFacebookModule().fireEvent(TiFacebookModule.EVENT_LOGOUT, null);
				} else {
					// AccessToken refreshed
					if (TiFacebookModule.getFacebookModule().isAccessTokenRefreshCalled()) {
						TiFacebookModule.getFacebookModule().setAccessTokenRefreshCalled(false);
						TiFacebookModule.getFacebookModule().fireEvent(TiFacebookModule.EVENT_TOKEN_UPDATED, null);
					}
				}
			}
		};
	}

	@Override
	public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data)
	{
		Log.d(TAG, "ActivityWorkerProxy onActivityResult");
		TiFacebookModule.getFacebookModule().getCallbackManager().onActivityResult(requestCode, resultCode, data);
	}

	@Override
	public void onDestroy(Activity activity)
	{
		Log.d(TAG, "ActivityWorkerProxy onDestroy");
		accessTokenTracker.stopTracking();
	}

	@Override
	public void onSaveInstanceState(Bundle outState)
	{
		Log.d(TAG, "ActivityWorkerProxy onSaveInstanceState");
	}

	@Override
	public void onRestoreInstanceState(Bundle inState)
	{
		Log.d(TAG, "ActivityWorkerProxy onRestoreInstanceState");
	}
}