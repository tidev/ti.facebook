/**
  * Copyright (c) 2014 by Mark Mokryn All Rights Reserved.
  * Licensed under the terms of the Apache Public License 2.0
  * Please see the LICENSE included with this distribution for details.
  *
  */

package facebook;

import org.appcelerator.titanium.view.TiUIView;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.util.TiColorHelper;
import org.appcelerator.titanium.util.TiConvert;

import com.facebook.widget.LikeView.*;
import com.facebook.widget.LikeView;

public class LikeButtonView extends TiUIView 
{
	// Standard Debugging variables
	private static final String TAG = "LikeButtonView";
	private LikeView likeView;
	
	public LikeButtonView(TiViewProxy proxy) 
	{
		super(proxy);
		
		Log.d(TAG, "[VIEW LIFECYCLE EVENT] view");
		
		likeView = new LikeView(proxy.getActivity());
		// Set the view as the native view. You must set the native view
		// for your view to be rendered correctly.
		setNativeView(likeView);
	}
		
	// The view is automatically registered as a model listener when the view
	// is realized by the view proxy. That means that the processProperties
	// method will be called during creation and that propertiesChanged and 
	// propertyChanged will be called when properties are changed on the proxy.
	
	private void setLikeViewStyle(String name) {
		for(Style style : Style.values()) { 
			if (style.toString().equals(name)) {
				likeView.setLikeViewStyle(style);
				break;
			}
		}		
	}

	private void setAuxiliaryViewPosition(String name) {
		for(AuxiliaryViewPosition avp : AuxiliaryViewPosition.values()) { 
			if (avp.toString().equals(name)) {
				likeView.setAuxiliaryViewPosition(avp);
				break;
			}
		}		
	}
	
	private void setHorizontalAlignment(String name) {
		for(HorizontalAlignment ha : HorizontalAlignment.values()) { 
			if (ha.toString().equals(name)) {
				likeView.setHorizontalAlignment(ha);
				break;
			}
		}		
	}
	
	@Override
	public void processProperties(KrollDict props) 
	{
		super.processProperties(props);
		Log.d(TAG,"[VIEW LIFECYCLE EVENT] processProperties " + props);
		if (props.containsKey("objectId")) {
			likeView.setObjectId(props.getString("objectId"));
		}
		if (props.containsKey("likeViewStyle")) {
			//likeView.setLikeViewStyle(Style.values()[props.getInt("likeViewStyle")]);
			String styleName = props.getString("likeViewStyle");
			setLikeViewStyle(styleName);

		}
		if (props.containsKey("auxiliaryViewPosition")) {
			String positionName = props.getString("auxiliaryViewPosition");
			setAuxiliaryViewPosition(positionName);
		}
		if (props.containsKey("horizontalAlignment")) {
			String haName = props.getString("horizontalAlignment");
			setHorizontalAlignment(haName);
		}
		if (props.containsKey("foregroundColor")) {
			likeView.setForegroundColor(TiColorHelper.parseColor(props.getString("foregroundColor")));
		}		
	}
	
	@Override
	public void propertyChanged(String key, Object oldValue, Object newValue, KrollProxy proxy)
	{
		// This method is called whenever a proxy property value is updated. Note that this 
		// method is only called if the new value is different than the current value.

		if (key.equals("objectId")) {
			likeView.setObjectId(TiConvert.toString(newValue));
		} else if (key.equals("likeViewStyle")) {
			setLikeViewStyle(TiConvert.toString(newValue));
		} else if (key.equals("auxiliaryViewPosition")) {
			setAuxiliaryViewPosition(TiConvert.toString(newValue));
		} else if (key.equals("horizontalAlignment")) {
			setHorizontalAlignment(TiConvert.toString(newValue));
		} else if (key.equals("foregroundColor")) {
			likeView.setForegroundColor(TiColorHelper.parseColor(TiConvert.toString(newValue)));
		} else {
			super.propertyChanged(key, oldValue, newValue, proxy);
		}
		Log.d(TAG,"[VIEW LIFECYCLE EVENT] propertyChanged: " + key + ' ' + oldValue + ' ' + newValue);
	}
}
