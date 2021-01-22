/**
 * Copyright (c) 2014 by Mark Mokryn All Rights Reserved.
 * Licensed under the terms of the Apache Public License 2.0
 * Please see the LICENSE included with this distribution for details.
 *
 * Appcelerator Titanium Mobile
 * Copyright (c) 2020 by Axway, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package facebook;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import com.facebook.*;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiBaseActivity;
import org.appcelerator.titanium.TiLifecycle.OnActivityResultEvent;

@Kroll.proxy(creatableInModule = TiFacebookModule.class)
public class ActivityWorkerProxy extends KrollProxy implements OnActivityResultEvent
{
	private static final String TAG = "ActivityWorkerProxy";

	private AccessTokenTracker accessTokenTracker = null;

	public ActivityWorkerProxy()
	{
		super();
	}

	@Override
	public void handleCreationDict(KrollDict options)
	{
		super.handleCreationDict(options);

		// If `lifecycleContainer` was set, this will be our proxy activity.
		final Activity activity = getActivity();

		if (activity instanceof TiBaseActivity) {
			final TiBaseActivity baseActivity = (TiBaseActivity) activity;

			// Obtain activity result.
			baseActivity.addOnActivityResultListener(this);
		}

		// Create access token tracker.
		accessTokenTracker = new AccessTokenTracker() {
			@Override
			protected void onCurrentAccessTokenChanged(AccessToken oldAccessToken, AccessToken currentAccessToken)
			{
				if (currentAccessToken == null) {

					// User logged out.
					TiFacebookModule.getFacebookModule().fireEvent(TiFacebookModule.EVENT_LOGOUT, null);
				} else {

					// AccessToken updated.
					if (TiFacebookModule.getFacebookModule().isAccessTokenRefreshCalled()) {
						TiFacebookModule.getFacebookModule().setAccessTokenRefreshCalled(false);
						TiFacebookModule.getFacebookModule().fireEvent(TiFacebookModule.EVENT_TOKEN_UPDATED, null);
					}
				}
			}
		};
	}

	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState)
	{
		Log.d(TAG, "onCreate");

		if (activity instanceof TiBaseActivity) {
			final TiBaseActivity baseActivity = (TiBaseActivity) activity;

			// Obtain activity result.
			baseActivity.addOnActivityResultListener(this);
		}
	}

	@Override
	public void onDestroy(Activity activity)
	{
		Log.d(TAG, "onDestroy");

		accessTokenTracker.stopTracking();
	}

	@Override
	public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data)
	{
		Log.d(TAG, "onActivityResult");

		TiFacebookModule.getFacebookModule().getCallbackManager().onActivityResult(requestCode, resultCode, data);
	}
}
