/**
 * Facebook Module
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

package facebook;

import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiContext;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;

import android.app.Activity;

@Kroll.proxy(parentModule=TiFacebookModule.class)
public class TiFacebookModuleLoginButtonProxy extends TiViewProxy
{
	private TiFacebookModule facebookModule = null;

	public TiFacebookModuleLoginButtonProxy()
	{
		super();
	}

	public TiFacebookModuleLoginButtonProxy(TiContext tiContext)
	{
		this();
	}
	
	public TiFacebookModuleLoginButtonProxy(TiFacebookModule facebookModule)
	{
		this();
		Log.d("LoginButtonProxy", "Second constructor called", Log.DEBUG_MODE);
		this.facebookModule = facebookModule;
	}

	public TiFacebookModuleLoginButtonProxy(TiContext tiContext, TiFacebookModule facebookModule)
	{
		this(facebookModule);
	}

	@Override
	public TiUIView createView(Activity activity) {
		return new TiLoginButton(this);
	}
	
	public TiFacebookModule getFacebookModule() {
		return this.facebookModule;
	}
}
