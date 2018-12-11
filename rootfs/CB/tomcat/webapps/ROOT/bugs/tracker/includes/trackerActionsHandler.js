/*
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
 * Constructor for TrackerActionsHandler.
 *
 * @param selectionFieldName the field name for selections which is checked by javascript (the checkboxes)
 * @param config is the actions configuration
 * @param context is the current tracker/item context JSON object
 */
function TrackerActionsHandler(selectionFieldName, config, context) {
	if (!selectionFieldName) {
		throw new Exception("Missing 'selectionFieldName' parameter!");
	}

	this.selectionFieldName = selectionFieldName;
	this.context = context;
	this.config  = config;
};

TrackerActionsHandler.prototype = {
	// the field name for selections which is checked by javascript
	selectionFieldName : '',

	// Click handler for context menu
	onClickHandler: function(element) {
		var action = $(element).attr("href");
		var $actionSelector = $("#actionCombo");
		$actionSelector.val(action);
		$actionSelector.change();
	},

	// callback when the selection changes
	// @param selectbox contains the actions
	onSelectionChange:  function (selectbox) {
		var action = selectbox.options[selectbox.selectedIndex].value;
		var success = this.execute(selectbox, action);

		if (!success) {
			// can not submit because no checkbox was checked,
			// reset the selectbox to the 1st selection so "More Actions..." will be selected
			selectbox.selectedIndex = 0;
		}
	},

	// Execute an action
	execute: function(selectbox, action) {
		var options = this.config[action];

		switch (action) {
			case "cut":
			case "copy":
				$(selectbox).cutCopyTrackerItemsToClipboard(this.context.tracker, this.selectedItems(selectbox.form), options);
				break;
			case "paste":
				$(selectbox).pasteTrackerItemsFromClipboard(this.context, options);
				break;
			case "delete":
			case "restore":
				$(selectbox).removeTrackerItems(this.context.tracker, this.selectedItems(selectbox.form), options);
				break;
			case "massEdit":
				$(selectbox).massEditTrackerItems(this.context.tracker, this.selectedItems(selectbox.form), options);
				break;
			case "copyTo" :
			case "moveTo" :
				$(selectbox).showTrackerItemsCopyMoveToDialog(this.context.tracker, this.selectedItems(selectbox.form), options);
				break;
		}
		return false;
	},

	selectedItems : function(form) {
		var items = findAllCheckedCheckboxValues(form, this.selectionFieldName);
		for (var i = 0; i < items.length; ++i) {
			items[i] = parseInt(items[i]);
		}
		return items;
	}


};
