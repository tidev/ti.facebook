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

import org.appcelerator.titanium.view.TiUIView;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.util.TiColorHelper;
import org.appcelerator.titanium.util.TiConvert;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;

import com.facebook.widget.LikeView.*;
import com.facebook.internal.LikeActionController;
import com.facebook.share.widget.LikeView;
import com.facebook.share.widget.LikeView.AuxiliaryViewPosition;
import com.facebook.share.widget.LikeView.HorizontalAlignment;
import com.facebook.share.widget.LikeView.Style;


public class LikeButtonView extends TiUIView 
{
    private static final String TAG = "LikeButtonView";
    
	public static final String ACTION_LIKE_ACTION_CONTROLLER_UPDATED = "com.facebook.sdk.UPDATED";
    public static final String ACTION_LIKE_ACTION_CONTROLLER_DID_ERROR = "com.facebook.sdk.DID_ERROR";
    public static final String ACTION_LIKE_ACTION_CONTROLLER_DID_RESET = "com.facebook.sdk.DID_RESET";
    public static final String ACTION_OBJECT_ID_KEY = "com.facebook.sdk.OBJECT_ID";
    public static final String EVENT_STATUS_CHANGE = "statuschange";

    private LikeView likeView;
    private BroadcastReceiver broadcastReceiver;
    private String objectId;
	
	private class LikeControllerBroadcastReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            String intentAction = intent.getAction();
            Bundle extras = intent.getExtras();
            boolean shouldRespond = true;
            if (extras != null) {
                // See if an Id was set in the broadcast Intent. If it was, treat it as a filter.
                String broadcastObjectId = extras.getString(
                		LikeActionController.ACTION_OBJECT_ID_KEY);
                shouldRespond = broadcastObjectId == null || broadcastObjectId.equals("") ||
                        objectId.equalsIgnoreCase(broadcastObjectId);
            }

            if (!shouldRespond) {
                return;
            }

            if (LikeActionController.ACTION_LIKE_ACTION_CONTROLLER_UPDATED.equals(intentAction)) {
            	updateLikeStatus();
            } else if (LikeActionController.ACTION_LIKE_ACTION_CONTROLLER_DID_ERROR.equals(intentAction)) {
            	updateLikeStatus();
            } else if (LikeActionController.ACTION_LIKE_ACTION_CONTROLLER_DID_RESET.equals(intentAction)) {
                updateLikeStatus();
            }
        }
    }
	
	protected void updateLikeStatus() {
		triggerStatusChangedEvent(); //Call js event 'statuschange'
	}
	
    public void triggerStatusChangedEvent() {
        this.proxy.fireEvent(EVENT_STATUS_CHANGE, new KrollDict());
    }
	
	public LikeButtonView(TiViewProxy proxy) {
		super(proxy);
		likeView = new LikeView(proxy.getActivity());
		// Set the view as the native view. You must set the native view
		// for your view to be rendered correctly.
		setNativeView(likeView);
		
		this.broadcastReceiver = new LikeControllerBroadcastReceiver();
        LocalBroadcastManager localBroadcastManager = LocalBroadcastManager.getInstance(proxy.getActivity());

        // add the broadcast receiver
        IntentFilter filter = new IntentFilter();
        filter.addAction(LikeActionController.ACTION_LIKE_ACTION_CONTROLLER_UPDATED);
        filter.addAction(LikeActionController.ACTION_LIKE_ACTION_CONTROLLER_DID_ERROR);
        filter.addAction(LikeActionController.ACTION_LIKE_ACTION_CONTROLLER_DID_RESET);

        localBroadcastManager.registerReceiver(broadcastReceiver, filter);
	}
		
	// The view is automatically registered as a model listener when the view
	// is realized by the view proxy. That means that the processProperties
	// method will be called during creation and that propertiesChanged and 
	// propertyChanged will be called when properties are changed on the proxy.
	private void setLikeViewStyle(String name) {
		for(Style style : Style.values()) { 
			if (style.name().toString().equalsIgnoreCase(name)) {
				likeView.setLikeViewStyle(style);
				break;
			}
		}		
	}

	private void setAuxiliaryViewPosition(String name) {
		for(AuxiliaryViewPosition avp : AuxiliaryViewPosition.values()) { 
			if (avp.name().toString().equalsIgnoreCase(name)) {
				likeView.setAuxiliaryViewPosition(avp);
				break;
			}
		}		
	}
	
	private void setHorizontalAlignment(String name) {
		for(HorizontalAlignment ha : HorizontalAlignment.values()) { 
			if (ha.name().toString().equalsIgnoreCase(name)) {
				likeView.setHorizontalAlignment(ha);
				break;
			}
		}		
	}
	
	@Override
	public void processProperties(KrollDict props)  {
		super.processProperties(props);
		if (props.containsKey("objectId")) {
			likeView.setObjectIdAndType(props.getString("objectID"),LikeView.ObjectType.PAGE);
		}
		if (props.containsKey("likeViewStyle")) {
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
	public void propertyChanged(String key, Object oldValue, Object newValue, KrollProxy proxy) {
		// This method is called whenever a proxy property value is updated. Note that this 
		// method is only called if the new value is different than the current value.
		if (key.equals("objectID")) {
			likeView.setObjectIdAndType(TiConvert.toString(newValue),LikeView.ObjectType.PAGE);
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
	}
	
}
