/**
  * Copyright (c) 2014 by Mark Mokryn, Inc. All Rights Reserved.
  * Licensed under the terms of the Apache Public License 2.0
  * Please see the LICENSE included with this distribution for details.
  *
  */

package facebook;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.view.TiUIView;
import org.appcelerator.titanium.proxy.TiViewProxy;

import com.facebook.widget.LikeView.*;

import android.app.Activity;

@Kroll.proxy(creatableInModule = TiFacebookModule.class, propertyAccessors={
	"foregroundColor",
	"likeViewStyle",
	"auxiliaryViewPosition",
	"objectId",
	"horizontalAlignment"
 })
public class LikeButtonProxy extends TiViewProxy 
{
	// Standard Debugging variables
	private static final String TAG = "LikeButtonProxy";

	public LikeButtonProxy() {
		super();
		defaultValues.put("likeViewStyle", Style.STANDARD);
		defaultValues.put("auxiliaryViewPosition", AuxiliaryViewPosition.BOTTOM);
		defaultValues.put("horizontalAlignment", HorizontalAlignment.CENTER);
		Log.d(TAG, "[VIEWPROXY LIFECYCLE EVENT] init");
	}
	
	@Override
	public TiUIView createView(Activity activity) 
	{
		// This method is called when the view needs to be created. This is
		// a required method for a TiViewProxy subclass.
		
		LikeButtonView view = new LikeButtonView(this);
		view.getLayoutParams().autoFillsHeight = true;
		view.getLayoutParams().autoFillsWidth = true;
		
		return view;
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
