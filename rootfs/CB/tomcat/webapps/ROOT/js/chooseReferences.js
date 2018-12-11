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

/**
 * Static javascript methods for chooseReferences.tag and userSelector.tag
 */
var chooseReferences = {

	/**
 	 * Javascript function shows the reference-type popup
  	 * @param htmlId The (part of the) identifier for the field contains current value for the label.
 	 * @param urlparams Parameters to pass in the popup url
 	 * @param context is additional context specific information to the request
 	 */
	selectReferences: function(htmlId, urlparams, context, reportMode) {
	 	var referencesFieldId = 'dynamicChoice_references_' + htmlId,
	 		referencesField = document.getElementById(referencesFieldId),
	 		selectedItems = referencesField.value,
	 		url = contextPath + (reportMode ? "/proj/queries/picker.spr?" : "/proj/tracker/selectReference.spr?"),
	 		encodedSelectedItems = encodeURIComponent(selectedItems);
	 	
	 	url += urlparams;
	 	
	 	if (context != null) {
	 		url += "&context=" + encodeURIComponent(context);
	 	}
	 	
	 	if (url.length + encodedSelectedItems.length > 1900) {
	 		url += '&selectedItemsWithJS=' + referencesFieldId;
	 	} else {
	 		url += '&selectedItems=' + encodedSelectedItems;
	 	}

	 	inlinePopup.show(url, { width: reportMode ? 1000 : 900, minHeight: 600 });
	},

	/**
	 * Builds the url and shows the popup for user selection. Passes all parameters...
	 *
  	 * @param htmlId The (part of the) identifier for the field contains current value for the label.
 	 * @param urlparams Parameters to pass in the popup url
 	 * @param context is additional context specific information to the request
 	 */
	showUserSelectorPopup: function(htmlId, urlparams, context) {
		var inputField = document.getElementById("dynamicChoice_references_" + htmlId);
		var selected = inputField.value;
		selected = escape(selected);

		var url = contextPath + "/proj/tracker/selectUser.spr?";
		url += "selectedItems=" + selected;
		// add possible missing "&" to beginning the urlparams
		if (urlparams.indexOf("&") != 0) {
			urlparams = "&" + urlparams;
		}
		url += urlparams;

	 	if (context != null) {
	 		url += "&context=" + context;
	 	}

	 	inlinePopup.show(url, { width: 900, minHeight: 600 });
	}
}
