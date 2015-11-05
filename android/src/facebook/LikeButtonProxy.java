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
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.view.TiUIView;
import org.appcelerator.titanium.proxy.TiViewProxy;


import android.app.Activity;

@Kroll.proxy(creatableInModule = TiFacebookModule.class, propertyAccessors={
	"foregroundColor",
	"likeViewStyle",
	"auxiliaryViewPosition",
	"objectID",
	"horizontalAlignment"
 })
public class LikeButtonProxy extends TiViewProxy 
{
	private static final String TAG = "LikeButtonProxy";
	public LikeButtonProxy() {
		super();
		defaultValues.put("likeViewStyle", "standard");
		defaultValues.put("auxiliaryViewPosition", "bottom");
		defaultValues.put("horizontalAlignment", "center");
		Log.d(TAG, "[VIEWPROXY LIFECYCLE EVENT] init");
	}
	
	@Override
	public TiUIView createView(Activity activity) 
	{	
		LikeButtonView view = new LikeButtonView(this);
		view.getLayoutParams().autoFillsHeight = true;
		view.getLayoutParams().autoFillsWidth = true;
		return view;
	}

	@Override
	public void handleCreationDict(KrollDict options) 
	{
		Log.d(TAG, "VIEWPROXY LIFECYCLE EVENT] handleCreationDict " + options);
		super.handleCreationDict(options);
	}
}
