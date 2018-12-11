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
 * Javascript companion for the ActionComboBoxTag.
 * Used by the ActionComboBoxTag to execute some action when an option is selected from the tag.
 *
 * This works as:
 * - an ActionMenuBuilder adds an ActionItems to an ui:actionComboBox tag
 * - which generates a new option in the select box by ui:actionComboBox
 * - if the ActionItem contains an "onClick" javascript that will be executed when its option is selected
 * - otherwise if the ActionItem contains an URL, then the browser will be forwarded to that URL
 *
 * Also by default the combo-box will do the following processing:
 * - call the onClick function with the (form, action) parameters, where
 * 			- the form is the wrapping <form> html-element of the select-box
 * 			- the action is the "key" of the action as provided by the ActionMenuBuilder
 * - if the onClick returns false the processing is stopped
 * - after this the onBeforeSubmit(form,action) method is called with the same parameters.
 * 		This method can do any preprocessing necessary before the form submit
 * 		(like storing values in hidden-form fields), and can also cancel the form submit if returns "false".
 * - after this the wrapping form is submitted (assuming there is one).
 *
 * @param id
 * @param submitForm
 */
codebeamer.ComboBoxActionHandler = function(id, submitForm) {
	this.id = id;
	this.submitForm = submitForm || true;
	this.registeredActions = new Object();
	// register my id
	var x = codebeamer.ComboBoxActionHandler.instances;
	this.instances[id] = this;
};

// Copied from YUI
codebeamer.augmentObject = function(r, s) {
	if (!s||!r) {
		throw new Error("Absorb failed, verify dependencies.");
	}
	var a=arguments, i, p, overrideList=a[2];
	if (overrideList && overrideList!==true) { // only absorb the specified properties
		for (i=2; i<a.length; i=i+1) {
			r[a[i]] = s[a[i]];
		}
	} else { // take everything, overwriting only if the third parameter is true
		for (p in s) {
			if (overrideList || !(p in r)) {
				r[p] = s[p];
			}
		}

		var _IEEnumFix = function(r, s) {
			var ADD = ["toString", "valueOf"];
			var i, fname, f;
			for (i=0;i<ADD.length;i=i+1) {

				fname = ADD[i];
				f = s[fname];

				if (((typeof f === 'function') || Object.prototype.toString.apply(f) === '[object Function]') && f!=Object.prototype[fname]) {
					r[fname]=f;
				}
			}
		};

		if ($("body").hasClass('IE')) {
			_IEEnumFix(r, s);
		}
	}
};

codebeamer.augmentObject(codebeamer.ComboBoxActionHandler, {

	/**
	 * Get an instance of the ComboBoxActionHandler
	 * @param id The instance id
	 */
	get:function(id) {
		return codebeamer.ComboBoxActionHandler.prototype.instances[id];
	}

});

codebeamer.ComboBoxActionHandler.prototype = {

	// all instances of ComboBoxActionHandler
	instances : new Object(),

	// if the container form will be submitted when an action-handler function returns true
	submitForm: true,

	// action functions registered for this ComboBoxActionHandler
	// contains a hash of "actionname"-> function() {...code to execute when action selected...}
	registeredActions: new Object(),

	// the current form is accessible via this.form
	form: null,
	// the current action is accessible via this.action
	action: null,
	combobox: null,

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

	/**
	 * Execute an action.
	 * @param form The container form to submit when the action is sucessful
	 * @param The action string to execute
	 */
	execute: function(selectbox, action) {
		// save the current form/action
		this.form = selectbox.form;
		this.action = action;
		this.combobox = selectbox;

		var success = false;
		var actionFunction = this.registeredActions[action];
		if (actionFunction != null) {
			try {
				console.log("Executing action-function: " + actionFunction + " with (form:" + selectbox.form +", action:" + action +")");
				success = actionFunction.call(this, selectbox.form, action);
			} catch (e) {
				alert("Failed to execute action " + action +", exception: " + e);
			}
		}
		if (success && this.submitForm && this.form) {
			success = this.onBeforeSubmit(this.form, action);
			if (success) {
				this.form.submit();
			}
		}
		return success;
	},

	/**
	 * Event callback, will be called before submitting the form.
	 * @param form The form will be submitted
	 * @param action The action name which is submitting the form
	 *
	 * @return if returns false the form submit will be cancelled.
	 */
	onBeforeSubmit: function(form, action) {
		return true;
	},

	/**
	 * Register multiple actions in the javascript object-notation syntax
	 * @param actions The actions javascript object
	 */
	registerActions: function(actions) {
		if (this instanceof codebeamer.ComboBoxActionHandler) {
			codebeamer.augmentObject(this.registeredActions, actions, true);
		} else {
			console.log("No id is passed, creating the default ComboBoxActionHandler");
			var handler = new codebeamer.ComboBoxActionHandler(null);
			handler.registerActions(actions);
		}
	}

}
