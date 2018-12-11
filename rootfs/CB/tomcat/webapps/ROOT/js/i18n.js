/**
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
 *
 * $Revision: 20791:389b48c1e59b $ $Date: 2009-03-27 07:21 +0000 $
 */

/**
 * Internationalization supporting javascript object.
 *
 * An example of usage:
 *
 * alert(i18n.message("cb.welcome.title", "REAL WORLD!"));
 *
 * will show the "Welcome to REAL WORLD!" message, where the message code is resolved
 * from the ApplicationResources_<language>_<country>.properties for your locale.
 */
var i18n = {

	// if the message codes are loaded from the server
	loaded: false,

	// message codes loaded
	messageCodes: {},

	// if the ajax data will be refreshed
	_forceRefresh: false,

	/**
	 * Resolve the given message Code, also resolves any arguments of format {0} to 1st argument, etc...
	 * @param messageCode
	 * @param arg... any number of arguments
	 */
	message:function(messageCode /* any number of arguments */) {
		// lazy init for keys
		if (!i18n.loaded) {
			i18n.load(false);
		}

		var resolved = i18n.messageCodes[messageCode];
		if (!resolved) {
			// resolved = "Unknown message '" + messageCode +"'";
			resolved = messageCode;
			return resolved;
		}

		// replace {0}...etc with the appropriate arguments
		for (var i=1 /* skip 1st arg, that's the messageCode*/ ; i<arguments.length; i++) {
			var arg = arguments[i];
			resolved = resolved.replace("{" + (i-1) +"}", arg);
		}
		return resolved;
	},

	forceRefreshIfServerRestarted: function(serverStartupTime) {
		i18n.serverStartupTime = serverStartupTime;
	},

	/**
	 * Load the cached i18n message codes from the client cache
	 */
	_loadFromClientStorage: function() {
		try {
			// the automatic engine detect does not work properly on Chrome, so using the "local" engine
			// this does not work for IE6 & IE7, but works for FF3, Chrome, IE8
			// Note: the "ie" engine can not be used, because it can not store more than 100k, so it is not usable because i18n messages are bigger
			// It is pointless to use Flash here, because it takes about the same time to download the flash as the data itself
			$.jStore.defaults.engine="local";
			$.jStore.load();
			if ($.jStore.Availability) {
				//var jstore_engine = $.jStore.CurrentEngine;
				//console.log("using engine:" + jstore_engine.type);

				// automatially refresh cache when server has been restarted
				var cachei18nTime = $.jStore.get("CodeBeamer.i18n.messageCodes.cacheTime");
				if (cachei18nTime < i18n.serverStartupTime) {
					i18n._forceRefresh = true;
					console.log("refreshing i18n cache, because the server has been restarted");
					return;
				}

				var cachedi18nData = $.jStore.get("CodeBeamer.i18n.messageCodes");
				if (cachedi18nData != null) {
					try {
						// found in cache
						i18n.messageCodes = cachedi18nData;

						// verify if the cached data is for the same language/country
						if (i18n.isMatchingLanguageLoaded()) {
							i18n.loaded = true;
						} else {
							i18n._forceRefresh = true;
						}

						return;
					} catch (ex) {
						// there was some data in the local-cache, but that's invalid, so force an ajax request without caching
						// so browser will surely get the fresh data from server
						i18n._forceRefresh = true;
					}
				}
			} else {
				// jQuery.jStore is not available
			}
		} catch (ex) {
			// failed to init jQuery storage engine
			console.log("Failed to init jQuery.jStore:" + ex);
		}
		return;
	},

	/**
	 * Check if the i18n object contains the message codes for the expected language/country pair
	 */
	isMatchingLanguageLoaded: function() {
		var resourceLanguage = (i18n.messageCodes == null ? "" : i18n.messageCodes["language"]);
		var matching = (resourceLanguage == language);
		if (matching && country != null && country != "") {
			var resourceCountry = i18n.messageCodes["country"];
			if (resourceCountry != null && resourceCountry != country) {
				console.log("Invalid country code found in cached i18n message code. Country found:" + resourceCountry +", country needed:" + country);
				return false;
			}
		}
		return matching;
	},

	/**
	 * Load the message codes from the server via a json object
	 * @param async If the codes should be loaded asynchronously
	 */
	load :function(loadAsync) {
		// first check if the message-codes are available in the client-side storage
		if (! i18n._forceRefresh) {
			i18n._loadFromClientStorage();
		}
		if (i18n.loaded) {
			return;
		}

		// console.log("loading message-codes using ajax, forceRefresh:" + i18n._forceRefresh);
		// no message-codes, load them using ajax
		$.ajax({ url: contextPath + '/ajax/getMessageCodes.spr?language=' + language +"&country=" + country,
				 async: loadAsync /* not loading asynchronously, because the message-code is needed when returning from this function */,
				 cache: (!i18n._forceRefresh),
				 success: function(data, textStatus, jqXHR) {
				 	// the json "data" contains the keys and message codes for the server
					i18n.messageCodes = data;
					i18n.loaded = true;

					// check if this is correct language
					if (!i18n.isMatchingLanguageLoaded()) {
						// don't refresh again if we are already refreshing
						if (!i18n._forceRefresh) {
							i18n.loaded = false;
							i18n._forceRefresh = true;
							i18n.load(false);
							return;
						}
					}

					// store data in client side storage
					var cachedi18nData = jqXHR.responseText;
					$(function() {
							try {
								$.jStore.remove("CodeBeamer.i18n.messageCodes"); // clean up previous data
							} catch (ex) {
								console.log("Failed to clean i18n in client cache" + ex);
							}
							try {
								$.jStore.store("CodeBeamer.i18n.messageCodes", cachedi18nData);
								$.jStore.store("CodeBeamer.i18n.messageCodes.cacheTime", i18n.serverStartupTime);
							} catch (ex) {
								console.log("Failed to store i18n in client cache" + ex);
							}
						});
				 },
				 failure: function(data) {
					 // don't try to load again
					 i18n.loaded = true;
				 }
			});
	}
}

// refresh if the server is restarted since last cache time
i18n.forceRefreshIfServerRestarted(serverStartupTime);
