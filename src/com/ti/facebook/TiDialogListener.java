/**
 * Facebook Module
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

package com.ti.facebook;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.common.Log;

import android.os.Bundle;

import com.facebook.android.DialogError;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;
import com.facebook.android.Util;

public class TiDialogListener implements DialogListener
{
	private KrollFunction callback;
	private String dialogAction;
	private TiFacebookModule module;

	private enum Status {ERROR, CANCEL, SUCCESS}
	
	public TiDialogListener(TiFacebookModule module, KrollFunction callback, String dialogAction)
	{
		this.module = module;
		this.callback = callback;
		this.dialogAction = dialogAction;
	}
	
	private KrollDict buildEventArgs(Status status)
	{
		KrollDict d = new KrollDict();
		boolean success = (status == Status.SUCCESS);
		d.put(TiFacebookModule.PROPERTY_SUCCESS, success);
		d.put(TiFacebookModule.PROPERTY_CANCELLED, status == Status.CANCEL);
		d.put(TiFacebookModule.PROPERTY_CODE, success? 0: -1);
		return d;
	}
	
	private KrollDict buildEventArgs(Throwable t)
	{
		KrollDict d = buildEventArgs(Status.ERROR);
		d.put(TiFacebookModule.PROPERTY_ERROR, t.getLocalizedMessage());
		return d;
	}
	
	private KrollDict buildEventArgs(String result)
	{
		KrollDict d = buildEventArgs(Status.SUCCESS);
		d.put(TiFacebookModule.PROPERTY_RESULT, result);
		return d;
	}
	
	private void complete(Throwable t)
	{
		Log.e("FacebookModule", "Dialog error for '" + dialogAction + "' call: " + t.getLocalizedMessage(), t);
		doCallback(buildEventArgs(t));
	}
	
	private void complete(String result)
	{
		doCallback(buildEventArgs(result));
	}
	
	private void doCallback(KrollDict args)
	{
		if (callback != null) {
			callback.callAsync(module.getKrollObject(), new Object[] { args });
		}
	}
	
	// Facebook.DialogListener implementation
	
	@Override
	public void onComplete(Bundle values)
	{
		String stringVals = "";
		if (values != null) {
			if (values.getString("post_id") == null) {
				// No "post_id" returned means the user canceled posting.
				doCallback(buildEventArgs(Status.CANCEL));
				return;
			} else {
				stringVals = Util.encodeUrl(values);
			}
		}
		complete(stringVals);
	}

	@Override
	public void onFacebookError(FacebookError e)
	{
		complete(e);
	}

	@Override
	public void onError(DialogError e)
	{
		complete(e);
	}

	@Override
	public void onCancel()
	{
		Log.d("FacebookModule-Dialog", "Dialog canceled", Log.DEBUG_MODE);
		doCallback(buildEventArgs(Status.CANCEL));
	}

}
