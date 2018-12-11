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
 * $Revision$ $Date$
 */

// Ajax utility classes
// $Id$

/**
 * Static helper class for reporting Ajax errors.
 *
 */
var AjaxErrorReport = {

	// if the page is being unloaded, so ajax-communication errors are supressed
	pageunloading : false,

	init: function() {
		$(window).on("unload", function() {AjaxErrorReport.pageunloading = true});
	},

	/**
	 * Common method to report an ajax call failure to the user, and also logs it.
	 *
	 * It takes care about that it won't report "communication errors" when navigating away from a page,
	 * and because of this navigation the pending ajax calls are aborted by the browser.
	 *
	 * Use it for handleFailure() method of your ajax callback.
	 *
	 * @param o
	 * @param msg Optional message shown to the user if the error is reported
	 */
    reportAjaxFailure:function(o, msg){
		try {
			console.log("Ajax call Failure:" + o.statusText +"\n" + o.responseText +"\nstatus:" + o.status);
			if (o.status >0 || !AjaxErrorReport.pageunloading) {
				if (typeof msg == "undefined") {
					msg = "";
				}
				alert(msg + "\nAjax call failure:" + o.statusText +"\nstatus:" + o.status);
			}
		} catch (e) {
			console.log("Error in reportAjaxFailure:" + e);
		}
    }

};

AjaxErrorReport.init();
