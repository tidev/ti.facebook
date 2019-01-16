/**
 * Copyright (c) 2014 by Mark Mokryn All Rights Reserved.
 * Licensed under the terms of the Apache Public License 2.0
 * Please see the LICENSE included with this distribution for details.
 *
 * Appcelerator Titanium Mobile
 * Copyright (c) 2015-Present by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package facebook;

import java.util.Arrays;
import java.util.Currency;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.math.BigDecimal;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiBlob;
import org.appcelerator.titanium.TiFileProxy;
import org.appcelerator.titanium.TiLifecycle.OnActivityResultEvent;
import org.appcelerator.titanium.util.TiConvert;
import org.json.JSONArray;
import org.json.JSONObject;

import com.facebook.AccessToken;
import com.facebook.applinks.AppLinkData;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookRequestError;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphRequest.Callback;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.DefaultAudience;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginBehavior;
import com.facebook.login.LoginResult;
import com.facebook.share.Sharer;
import com.facebook.share.model.GameRequestContent;
import com.facebook.share.model.GameRequestContent.ActionType;
import com.facebook.share.model.GameRequestContent.Filters;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.AppInviteContent;
import com.facebook.share.widget.GameRequestDialog;
import com.facebook.share.widget.ShareDialog;
import com.facebook.share.widget.ShareDialog.Mode;
import com.facebook.share.widget.AppInviteDialog;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

@Kroll.module(name = "Facebook", id = "facebook")
public class TiFacebookModule extends KrollModule implements OnActivityResultEvent
{
	private static final String TAG = "TiFacebookModule";
	public static final String EVENT_LOGIN = "login";
	public static final String EVENT_LOGOUT = "logout";
	public static final String EVENT_TOKEN_UPDATED = "tokenUpdated";
	public static final String PROPERTY_SUCCESS = "success";
	public static final String PROPERTY_CANCELLED = "cancelled";
	public static final String PROPERTY_ERROR = "error";
	public static final String PROPERTY_CODE = "code";
	public static final String PROPERTY_DATA = "data";
	public static final String PROPERTY_UID = "uid";
	public static final String PROPERTY_RESULT = "result";
	public static final String PROPERTY_PATH = "path";
	public static final String PROPERTY_METHOD = "method";
	public static final String EVENT_SHARE_COMPLETE = "shareCompleted";
	public static final String EVENT_INVITE_COMPLETE = "inviteCompleted";
	public static final String EVENT_REQUEST_DIALOG_COMPLETE = "requestDialogCompleted";

	@Kroll.constant
	public static final int AUDIENCE_NONE = 0;
	@Kroll.constant
	public static final int AUDIENCE_ONLY_ME = 1;
	@Kroll.constant
	public static final int AUDIENCE_FRIENDS = 2;
	@Kroll.constant
	public static final int AUDIENCE_EVERYONE = 3;

	@Kroll.constant
	public static final int ACTION_TYPE_NONE = 0;
	@Kroll.constant
	public static final int ACTION_TYPE_SEND = 1;
	@Kroll.constant
	public static final int ACTION_TYPE_ASK_FOR = 2;
	@Kroll.constant
	public static final int ACTION_TYPE_TURN = 3;

	@Kroll.constant
	public static final int FILTER_NONE = 0;
	@Kroll.constant
	public static final int FILTER_APP_USERS = 1;
	@Kroll.constant
	public static final int FILTER_APP_NON_USERS = 2;

	@Kroll.constant
	public static final String LOGIN_BEHAVIOR_BROWSER = "WEB_ONLY";
	@Kroll.constant
	public static final String LOGIN_BEHAVIOR_NATIVE = "NATIVE_ONLY";
	@Kroll.constant
	public static final String LOGIN_BEHAVIOR_NATIVE_WITH_FALLBACK = "NATIVE_WITH_FALLBACK";
	@Kroll.constant
	public static final String LOGIN_BEHAVIOR_DEVICE_AUTH = "DEVICE_AUTH";

	@Kroll.constant
	public static final int LOGIN_BUTTON_TOOLTIP_BEHAVIOR_AUTOMATIC = 0;
	@Kroll.constant
	public static final int LOGIN_BUTTON_TOOLTIP_BEHAVIOR_FORCE_DISPLAY = 1;
	@Kroll.constant
	public static final int LOGIN_BUTTON_TOOLTIP_BEHAVIOR_DISABLE = 2;

	@Kroll.constant
	public static final String LOGIN_BUTTON_TOOLTIP_STYLE_NEUTRAL_GRAY = "NEUTRAL_GRAY";
	@Kroll.constant
	public static final String LOGIN_BUTTON_TOOLTIP_STYLE_FRIENDLY_BLUE = "FRIENDLY_BLUE";

	@Kroll.constant
	public static final int SHARE_DIALOG_MODE_AUTOMATIC = 0;
	@Kroll.constant
	public static final int SHARE_DIALOG_MODE_NATIVE = 1;
	@Kroll.constant
	public static final int SHARE_DIALOG_MODE_WEB = 2;
	@Kroll.constant
	public static final int SHARE_DIALOG_MODE_FEED_WEB = 6; // For iOS-parity

	private static TiFacebookModule module;
	private static String[] permissions = new String[] {};
	private String loginBehavior;

	private KrollFunction permissionCallback = null;

	private CallbackManager callbackManager;
	private FacebookCallback<LoginResult> facebookCallback;
	private boolean accessTokenRefreshCalled = false;

	public TiFacebookModule()
	{
		super();
		module = this;
	}

	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app)
	{
		FacebookSdk.sdkInitialize(app.getApplicationContext());
	}

	public static TiFacebookModule getFacebookModule()
	{
		return module;
	}

	public CallbackManager getCallbackManager()
	{
		return callbackManager;
	}

	public FacebookCallback<LoginResult> getFacebookCallback()
	{
		return facebookCallback;
	}

	public void makeMeRequest(final AccessToken accessToken)
	{
		new Handler(Looper.getMainLooper()).post(new Runnable() {
			@Override
			public void run()
			{
				GraphRequest request =
					GraphRequest.newMeRequest(accessToken, new GraphRequest.GraphJSONObjectCallback() {
						@Override
						public void onCompleted(JSONObject user, GraphResponse response)
						{
							FacebookRequestError err = response.getError();
							KrollDict data = new KrollDict();

							if (user != null) {
								data.put(TiFacebookModule.PROPERTY_CANCELLED, false);
								data.put(TiFacebookModule.PROPERTY_SUCCESS, true);
								data.put(TiFacebookModule.PROPERTY_UID, user.optString("id"));
								data.put(TiFacebookModule.PROPERTY_DATA, user.toString());
								data.put(TiFacebookModule.PROPERTY_CODE, 0);
								fireEvent(TiFacebookModule.EVENT_LOGIN, data);
							}

							if (err != null) {
								String errorString = TiFacebookModule.handleError(err);
								data.put(TiFacebookModule.PROPERTY_ERROR, errorString);
								fireEvent(TiFacebookModule.EVENT_LOGIN, data);
							}
						}
					});
				request.executeAsync();
			}
		});
	}

	public static String handleError(FacebookRequestError error)
	{
		String errorMessage = null;
		if (error == null) {
			errorMessage = "An error occurred. Please try again.";
		} else {
			switch (error.getCategory()) {
				case LOGIN_RECOVERABLE:
				case TRANSIENT:
					errorMessage = error.getErrorMessage();
					break;
				case OTHER:
				default:
					// an unknown issue occurred, this could be a code error, or
					// a server side issue
					errorMessage = "An error code " + error.getErrorCode() + " has occured. " + error.getErrorMessage();
					break;
			}
		}
		return errorMessage;
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public boolean getCanPresentShareDialog()
	// clang-format on
	{
		Log.w(TAG, "The getCanPresentShareDialog property is deprecated. This always returns true.");
		return true;
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public boolean getCanPresentOpenGraphActionDialog()
	// clang-format on
	{
		Log.w(TAG, "The getCanPresentOpenGraphActionDialog property is deprecated. This always returns true.");
		return true;
	}

	@Kroll.method
	public void requestWithGraphPath(String path, KrollDict params, String httpMethod, final KrollFunction callback)
	{
		HttpMethod method = null;
		if (httpMethod == null || httpMethod.length() == 0 || httpMethod.equalsIgnoreCase("get")) {
			method = HttpMethod.GET;
		} else if (httpMethod.equalsIgnoreCase("post")) {
			method = HttpMethod.POST;
		} else if (httpMethod.equalsIgnoreCase("delete")) {
			method = HttpMethod.DELETE;
		}
		Bundle paramBundle = Utils.mapToBundle(params);
		AccessToken accessToken = AccessToken.getCurrentAccessToken();
		GraphRequest request = GraphRequest.newGraphPathRequest(accessToken, path, new Callback() {
			@Override
			public void onCompleted(GraphResponse response)
			{
				FacebookRequestError err = response.getError();
				KrollDict data = new KrollDict();
				if (err != null) {
					String errorString = handleError(err);
					Log.e(TAG, "requestWithGraphPath callback error: " + err.getErrorMessage());
					data.put(PROPERTY_ERROR, errorString);
					callback.callAsync(getKrollObject(), data);
					return;
				}

				data.put(PROPERTY_SUCCESS, true);
				data.put(PROPERTY_RESULT, response.getRawResponse().toString());
				callback.callAsync(getKrollObject(), data);
			}
		});

		request.setParameters(paramBundle);
		request.setHttpMethod(method);
		request.executeAsync();
	}

	@Kroll.method
	public void setPushNotificationsDeviceToken(String token)
	{
		AppEventsLogger.setPushNotificationsRegistrationId(token);
	}

	@Kroll.method
	public void logPushNotificationOpen(KrollDict parameters, @Kroll.argument(optional = true) String action)
	{
		AppEventsLogger logger = AppEventsLogger.newLogger(TiApplication.getInstance().getCurrentActivity());
		Bundle paramBundle = Utils.mapToBundle(parameters);

		if (action == null) {
			logger.logPushNotificationOpen(paramBundle);
		} else {
			logger.logPushNotificationOpen(paramBundle, action);
		}
	}

	@Kroll.method
	public void logCustomEvent(String event, @Kroll.argument(optional = true) Double valueToSum,
							   @Kroll.argument(optional = true) KrollDict parameters)
	{
		Activity activity = TiApplication.getInstance().getCurrentActivity();
		AppEventsLogger logger = AppEventsLogger.newLogger(activity);
		Bundle paramBundle = parameters != null ? Utils.mapToBundle(parameters) : null;
		if (logger != null) {
			if (valueToSum == null) {
				logger.logEvent(event, paramBundle);
			} else {
				logger.logEvent(event, valueToSum, paramBundle);
			}
		}
	}

	@Kroll.method
	public void logPurchase(double amount, String currency)
	{
		Activity activity = TiApplication.getInstance().getCurrentActivity();
		AppEventsLogger logger = AppEventsLogger.newLogger(activity);
		if (logger != null) {
			logger.logPurchase(BigDecimal.valueOf(amount), Currency.getInstance(currency));
		}
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public String getUid()
	// clang-format on
	{
		if (AccessToken.getCurrentAccessToken() != null) {
			return AccessToken.getCurrentAccessToken().getUserId();
		}
		return "";
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public String getAccessToken()
	// clang-format on
	{
		if (AccessToken.getCurrentAccessToken() != null) {
			return AccessToken.getCurrentAccessToken().getToken();
		}
		return "";
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public boolean getAccessTokenExpired()
	// clang-format on
	{
		if (AccessToken.getCurrentAccessToken() != null) {
			return AccessToken.getCurrentAccessToken().isExpired();
		}
		return false;
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public boolean getAccessTokenActive()
	// clang-format on
	{
		if (AccessToken.getCurrentAccessToken() != null) {
			return AccessToken.isCurrentAccessTokenActive();
		}
		return false;
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public Date getExpirationDate()
	// clang-format on
	{
		if (AccessToken.getCurrentAccessToken() != null) {
			return AccessToken.getCurrentAccessToken().getExpires();
		}
		return null;
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public boolean getLoggedIn()
	// clang-format on
	{
		return (AccessToken.getCurrentAccessToken() != null);
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public String[] getPermissions()
	// clang-format on
	{
		AccessToken currentAccessToken = AccessToken.getCurrentAccessToken();
		if (currentAccessToken != null) {
			Set<String> permissionsList = currentAccessToken.getPermissions();
			String[] permissionsArray = permissionsList.toArray(new String[permissionsList.size()]);
			return permissionsArray;
		}
		return null;
	}

	// clang-format off
	@Kroll.setProperty
	@Kroll.method
	public void setLoginBehavior(String behaviorConstant)
	// clang-format on
	{
		loginBehavior = behaviorConstant;
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public String getLoginBehavior()
	// clang-format on
	{

		return loginBehavior;
	}

	@Kroll.method
	public void requestNewReadPermissions(String[] permissions, final KrollFunction callback)
	{
		permissionCallback = callback;
		Activity activity = TiApplication.getInstance().getCurrentActivity();
		LoginManager.getInstance().logInWithReadPermissions(activity, Arrays.asList(permissions));
	}

	@Kroll.method
	public void requestNewPublishPermissions(String[] permissions, int audienceChoice, final KrollFunction callback)
	{
		DefaultAudience audience;

		switch (audienceChoice) {
			case TiFacebookModule.AUDIENCE_NONE:
				audience = DefaultAudience.NONE;
				break;
			case TiFacebookModule.AUDIENCE_ONLY_ME:
				audience = DefaultAudience.ONLY_ME;
				break;
			case TiFacebookModule.AUDIENCE_FRIENDS:
				audience = DefaultAudience.FRIENDS;
				break;
			default:
			case TiFacebookModule.AUDIENCE_EVERYONE:
				audience = DefaultAudience.EVERYONE;
				break;
		}

		permissionCallback = callback;
		Activity activity = TiApplication.getInstance().getCurrentActivity();
		LoginManager.getInstance().setDefaultAudience(audience);
		LoginManager.getInstance().logInWithPublishPermissions(activity, Arrays.asList(permissions));
	}

	// clang-format off
	@Kroll.setProperty
	@Kroll.method
	public void setPermissions(Object[] permissions)
	// clang-format on
	{
		TiFacebookModule.permissions = Arrays.copyOf(permissions, permissions.length, String[].class);
	}

	@Kroll.method
	public void initialize(@Kroll.argument(optional = true) int timeout)
	{
		// Variable `timeout` is not used
		// When not set, timeout is -1
		if (timeout >= 0) {
			Log.w(TAG, "Property `timeout` is deprecated. It is not used.");
		}
		callbackManager = CallbackManager.Factory.create();
		facebookCallback = new FacebookCallback<LoginResult>() {
			KrollDict data = new KrollDict();
			@Override
			public void onSuccess(LoginResult loginResult)
			{
				if (permissionCallback != null) {
					data.put(PROPERTY_SUCCESS, true);
					permissionCallback.callAsync(getKrollObject(), data);
					permissionCallback = null;
					return;
				}
				data.put(PROPERTY_SUCCESS, true);
				data.put(PROPERTY_CANCELLED, false);
				AccessToken accessToken = AccessToken.getCurrentAccessToken();
				makeMeRequest(accessToken);
			}

			@Override
			public void onCancel()
			{
				data.put(PROPERTY_CANCELLED, true);
				data.put(PROPERTY_SUCCESS, false);
				fireEvent(TiFacebookModule.EVENT_LOGIN, data);
				if (permissionCallback != null) {
					permissionCallback.callAsync(getKrollObject(), data);
					permissionCallback = null;
				}
			}

			@Override
			public void onError(FacebookException exception)
			{
				Log.e(TAG, "FacebookCallback error: " + exception.getMessage());
				data.put(PROPERTY_ERROR, exception.getMessage());
				data.put(PROPERTY_SUCCESS, false);
				data.put(PROPERTY_CANCELLED, false);
				fireEvent(TiFacebookModule.EVENT_LOGIN, data);
				if (permissionCallback != null) {
					permissionCallback.callAsync(getKrollObject(), data);
					permissionCallback = null;
				}
			}
		};
		LoginManager.getInstance().registerCallback(getCallbackManager(), getFacebookCallback());
	}

	@Kroll.method
	public void authorize()
	{
		Activity activity = TiApplication.getInstance().getCurrentActivity();
		if (loginBehavior != null) {
			setLoginManagerLoginBehavior();
		}
		LoginManager.getInstance().logInWithReadPermissions(activity, Arrays.asList(TiFacebookModule.permissions));
	}

	@Kroll.method
	public void refreshPermissionsFromServer()
	{
		setAccessTokenRefreshCalled(true);
		AccessToken.refreshCurrentAccessTokenAsync();
	}

	public boolean isAccessTokenRefreshCalled()
	{
		return accessTokenRefreshCalled;
	}

	public boolean setAccessTokenRefreshCalled(boolean bool)
	{
		return (accessTokenRefreshCalled = bool);
	}

	@Kroll.method
	public void logout()
	{
		LoginManager.getInstance().logOut();
	}

	@Kroll.method
	public void presentPhotoShareDialog(@Kroll.argument final KrollDict args)
	{
		ShareDialog shareDialog = new ShareDialog(TiApplication.getInstance().getCurrentActivity());

		shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
			KrollDict data = new KrollDict();
			@Override
			public void onCancel()
			{
				data.put(PROPERTY_SUCCESS, false);
				data.put(PROPERTY_CANCELLED, true);
				fireEvent(EVENT_SHARE_COMPLETE, data);
			}

			@Override
			public void onError(FacebookException error)
			{
				data.put(PROPERTY_SUCCESS, false);
				data.put(PROPERTY_CANCELLED, false);
				data.put(PROPERTY_ERROR, "Error posting story");
				fireEvent(EVENT_SHARE_COMPLETE, data);
			}

			@Override
			public void onSuccess(Sharer.Result results)
			{
				final String postId = results.getPostId();
				data.put(PROPERTY_SUCCESS, true);
				data.put(PROPERTY_CANCELLED, false);
				data.put(PROPERTY_RESULT, postId);
				fireEvent(EVENT_SHARE_COMPLETE, data);
			}
		});

		Mode mode = Mode.AUTOMATIC;
		Object[] proxyPhotos = (Object[]) args.get("photos");
		KrollDict[] photos = new KrollDict[proxyPhotos.length];
		SharePhotoContent shareContent = null;

		for (int i = 0; i < proxyPhotos.length; i++) {
			HashMap obj = (HashMap) proxyPhotos[i];
			KrollDict dict = new KrollDict();

			dict.put("photo", obj.get("photo"));

			if (obj.containsKey("caption")) {
				dict.put("caption", (String) obj.get("caption"));
			}

			if (obj.containsKey("userGenerated")) {
				dict.put("userGenerated", (boolean) obj.get("userGenerated"));
			}

			photos[i] = dict;
		}

		switch (TiConvert.toInt(args.get("mode"), TiFacebookModule.SHARE_DIALOG_MODE_AUTOMATIC)) {
			case TiFacebookModule.SHARE_DIALOG_MODE_NATIVE:
				mode = Mode.NATIVE;
				break;
			case TiFacebookModule.SHARE_DIALOG_MODE_WEB:
				mode = Mode.WEB;
				break;
			case TiFacebookModule.SHARE_DIALOG_MODE_FEED_WEB:
				mode = Mode.FEED;
				break;
			default:
			case TiFacebookModule.SHARE_DIALOG_MODE_AUTOMATIC:
				mode = Mode.AUTOMATIC;
				break;
		}

		SharePhotoContent.Builder shareContentBuilder = new SharePhotoContent.Builder();

		for (KrollDict proxyPhoto : photos) {
			SharePhoto.Builder photoBuilder = new SharePhoto.Builder();

			Object photo = proxyPhoto.get("photo");
			String caption = (String) proxyPhoto.get("caption");
			boolean userGenerated = proxyPhoto.optBoolean("userGenerated", false);

			// A photo can either be a Blob or String
			if ((photo instanceof TiBlob) || (photo instanceof TiFileProxy)) {
				if (photo instanceof TiFileProxy) {
					photo = TiBlob.blobFromFile(((TiFileProxy) photo).getBaseFile());
				}
				photoBuilder = photoBuilder.setBitmap(((TiBlob) photo).getImage());
			} else if (photo instanceof String) {
				photoBuilder = photoBuilder.setImageUrl(Uri.parse((String) photo));
			} else {
				Log.e(TAG, "Required \"photo\" not found or of unknown type: " + photo.getClass().getName());
			}

			// An optional caption
			if (caption != null) {
				photoBuilder = photoBuilder.setCaption(caption);
			}

			// An optional flag indicating if the photo was user generated
			photoBuilder = photoBuilder.setUserGenerated(userGenerated);

			shareContentBuilder = shareContentBuilder.addPhoto(photoBuilder.build());
		}

		if (photos != null) {
			shareContent = shareContentBuilder.build();
		} else {
			Log.e(TAG, "The \"photos\" property is required when showing a photo share dialog.");
		}

		if (shareDialog != null && shareDialog.canShow(SharePhotoContent.class)) {
			shareDialog.show(shareContent);
		} else {
			Log.e(TAG, "Cannot show image share dialog due to unsupported device or configuration!");
		}
	}

	@Kroll.method
	public void presentShareDialog(@Kroll.argument final KrollDict args)
	{
		ShareDialog shareDialog = new ShareDialog(TiApplication.getInstance().getCurrentActivity());

		shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
			KrollDict data = new KrollDict();
			@Override
			public void onCancel()
			{
				data.put(PROPERTY_SUCCESS, false);
				data.put(PROPERTY_CANCELLED, true);
				fireEvent(EVENT_SHARE_COMPLETE, data);
			}

			@Override
			public void onError(FacebookException error)
			{
				data.put(PROPERTY_SUCCESS, false);
				data.put(PROPERTY_CANCELLED, false);
				data.put(PROPERTY_ERROR, "Error posting story");
				fireEvent(EVENT_SHARE_COMPLETE, data);
			}

			@Override
			public void onSuccess(Sharer.Result results)
			{
				final String postId = results.getPostId();
				data.put(PROPERTY_SUCCESS, true);
				data.put(PROPERTY_CANCELLED, false);
				data.put(PROPERTY_RESULT, postId);
				fireEvent(EVENT_SHARE_COMPLETE, data);
			}
		});

		ShareLinkContent shareContent = null;
		Mode mode = Mode.AUTOMATIC;

		String link = (String) args.get("link");
		String title = (String) args.get("title");
		String description = (String) args.get("description");
		String picture = (String) args.get("picture");
		String placeId = (String) args.get("placeId");
		String ref = (String) args.get("ref");

		if (title != null) {
			Log.w(TAG, "Ti.Facebook.presentShareDialog.title has been deprecated as of the Graph v2.9 changes.");
		}

		if (description != null) {
			Log.w(TAG, "Ti.Facebook.presentShareDialog.description has been deprecated as of the Graph v2.9 changes.");
		}

		if (picture != null) {
			Log.w(TAG, "Ti.Facebook.presentShareDialog.picture has been deprecated as of the Graph v2.9 changes.");
		}

		switch (TiConvert.toInt(args.get("mode"), TiFacebookModule.SHARE_DIALOG_MODE_AUTOMATIC)) {
			case TiFacebookModule.SHARE_DIALOG_MODE_NATIVE:
				mode = Mode.NATIVE;
				break;
			case TiFacebookModule.SHARE_DIALOG_MODE_WEB:
				mode = Mode.WEB;
				break;
			case TiFacebookModule.SHARE_DIALOG_MODE_FEED_WEB:
				mode = Mode.FEED;
				break;
			default:
			case TiFacebookModule.SHARE_DIALOG_MODE_AUTOMATIC:
				mode = Mode.AUTOMATIC;
				break;
		}

		if (link != null) {
			shareContent =
				new ShareLinkContent.Builder().setContentUrl(Uri.parse(link)).setPlaceId(placeId).setRef(ref).build();
		} else {
			Log.e(TAG, "The \"link\" property is required when showing a share dialog.");
		}

		if (shareDialog != null && shareDialog.canShow(shareContent, mode)) {
			shareDialog.show(shareContent, mode);
		}
	}

	@Kroll.method
	public void presentInviteDialog(@Kroll.argument(optional = true) final KrollDict args)
	{
		Log.w(
			TAG,
			"The method presentInviteDialog has been deprecated by the Facebook SDK 4.29.0 and will be removed in the future.");

		AppInviteDialog appInviteDialog = new AppInviteDialog(TiApplication.getInstance().getCurrentActivity());

		appInviteDialog.registerCallback(callbackManager, new FacebookCallback<AppInviteDialog.Result>() {
			KrollDict event = new KrollDict();
			@Override
			public void onCancel()
			{
				event.put(PROPERTY_SUCCESS, false);
				event.put(PROPERTY_CANCELLED, true);
				fireEvent(EVENT_INVITE_COMPLETE, event);
			}

			@Override
			public void onError(FacebookException error)
			{
				event.put(PROPERTY_SUCCESS, false);
				event.put(PROPERTY_CANCELLED, false);
				event.put(PROPERTY_ERROR, "Error inviting people");
				fireEvent(EVENT_INVITE_COMPLETE, event);
			}

			@Override
			public void onSuccess(AppInviteDialog.Result results)
			{
				event.put(PROPERTY_SUCCESS, true);
				event.put(PROPERTY_CANCELLED, false);
				fireEvent(EVENT_INVITE_COMPLETE, event);
			}
		});

		if (!appInviteDialog.canShow()) {
			KrollDict errorEvent = new KrollDict();

			errorEvent.put(PROPERTY_SUCCESS, false);
			errorEvent.put(PROPERTY_CANCELLED, false);
			errorEvent.put(PROPERTY_ERROR, "Could not show invite dialog");
			fireEvent(EVENT_INVITE_COMPLETE, errorEvent);
		} else {
			String appLink = (String) args.get("appLink");
			String appPreviewImageLink = (String) args.get("appPreviewImageLink");

			AppInviteContent content =
				new AppInviteContent.Builder().setApplinkUrl(appLink).setPreviewImageUrl(appPreviewImageLink).build();

			appInviteDialog.show(content);
		}
	}

	@Kroll.method
	public void presentWebShareDialog(@Kroll.argument(optional = true) final KrollDict args)
	{
		Log.w(TAG, "The method presentWebShareDialog is deprecated.");
		presentShareDialog(args);
	}

	@Kroll.method
	public void presentSendRequestDialog(@Kroll.argument(optional = true) final KrollDict args)
	{
		GameRequestDialog requestDialog = new GameRequestDialog(TiApplication.getInstance().getCurrentActivity());
		requestDialog.registerCallback(callbackManager, new FacebookCallback<GameRequestDialog.Result>() {
			KrollDict data = new KrollDict();
			public void onSuccess(GameRequestDialog.Result result)
			{
				final String postId = result.getRequestId();
				if (postId != null) {
					data.put(PROPERTY_RESULT, postId);
				}
				data.put(PROPERTY_SUCCESS, true);
				data.put(PROPERTY_CANCELLED, false);
				fireEvent(EVENT_REQUEST_DIALOG_COMPLETE, data);
			}

			public void onCancel()
			{
				data.put(PROPERTY_SUCCESS, false);
				data.put(PROPERTY_CANCELLED, true);
				fireEvent(EVENT_REQUEST_DIALOG_COMPLETE, data);
			}

			public void onError(FacebookException error)
			{
				data.put(PROPERTY_SUCCESS, false);
				data.put(PROPERTY_CANCELLED, false);
				data.put(PROPERTY_ERROR, "Error sending Game Request");
				fireEvent(EVENT_REQUEST_DIALOG_COMPLETE, data);
			}
		});

		String title = (String) args.get("title");
		String message = (String) args.get("message");
		Map<String, String> data = (HashMap<String, String>) args.get("data");
		String recipients = (String) args.get("recipients");
		String suggestions = (String) args.get("recipientSuggestions");
		String objectID = (String) args.get("objectID");

		String to = (String) args.get("to");
		if (to != null) {
			Log.w(TAG, "Property `to` is deprecated. Please use `recipients`.");
		}

		int actionTypeChoice = args.optInt("actionType", TiFacebookModule.ACTION_TYPE_NONE);
		ActionType actionType;
		switch (actionTypeChoice) {
			case TiFacebookModule.ACTION_TYPE_SEND:
				actionType = ActionType.SEND;
				break;
			case TiFacebookModule.ACTION_TYPE_TURN:
				actionType = ActionType.TURN;
				break;
			case TiFacebookModule.ACTION_TYPE_ASK_FOR:
				actionType = ActionType.ASKFOR;
				break;
			default:
			case TiFacebookModule.ACTION_TYPE_NONE:
				actionType = null;
				break;
		}

		int filtersChoice = args.optInt("filters", TiFacebookModule.FILTER_NONE);
		Filters filters;
		switch (filtersChoice) {
			case TiFacebookModule.FILTER_APP_NON_USERS:
				filters = Filters.APP_NON_USERS;
				break;
			case TiFacebookModule.FILTER_APP_USERS:
				filters = Filters.APP_USERS;
				break;
			default:
			case TiFacebookModule.FILTER_NONE:
				filters = null;
				break;
		}

		String dataString = null;
		if (data != null) {
			dataString = data.toString();
		}

		List<String> recipientsList = null;
		if (recipients != null) {
			String[] recipientsArray = recipients.split(",");
			recipientsList = Arrays.asList(recipientsArray);
		}

		List<String> suggestionsList = null;
		if (suggestions != null) {
			String[] suggestionsArray = suggestions.split(",");
			suggestionsList = Arrays.asList(suggestionsArray);
		}

		GameRequestContent content = new GameRequestContent.Builder()
										 .setTitle(title)
										 .setMessage(message)
										 .setData(dataString)
										 .setRecipients(recipientsList)
										 .setActionType(actionType)
										 .setObjectId(objectID)
										 .setFilters(filters)
										 .setSuggestions(suggestionsList)
										 .build();
		requestDialog.show(content);
	}

	@Override
	public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data)
	{
		callbackManager.onActivityResult(requestCode, resultCode, data);
	}

	@Kroll.method
	public void fetchDeferredAppLink(final KrollFunction callback)
	{
		AppLinkData.fetchDeferredAppLinkData(TiApplication.getInstance().getCurrentActivity(),
											 new AppLinkData.CompletionHandler() {
												 @Override
												 public void onDeferredAppLinkDataFetched(AppLinkData appLinkData)
												 {
													 KrollDict data = new KrollDict();

													 if (appLinkData == null) {
														 data.put("success", false);
														 data.put("error", "An error occurred. Please try again.");
													 } else {
														 data.put("success", true);
														 data.put("url", appLinkData.getTargetUri().toString());
													 }

													 callback.callAsync(getKrollObject(), data);
												 }
											 });
	}

	private void setLoginManagerLoginBehavior()
	{
		LoginManager.getInstance().setLoginBehavior(LoginBehavior.valueOf(loginBehavior));
	}
}
