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

(function($) {

	// Tracker Field Mandatory Plugin definition.
	$.fn.fieldMandatoryControl = function(required, options) {
		var settings = $.extend( {}, $.fn.fieldMandatoryControl.defaults, options );

		if (!$.isArray(required)) {
			required = [];
		}

		var states = [{ id : null, name : '--'}];

		var statusOptions = settings.statusOptions;
		if (typeof(statusOptions) == 'function') {
			statusOptions = settings.statusOptions();
		}

		if ($.isArray(statusOptions) && statusOptions.length > 0) {
			states.push.apply(states, statusOptions);
		}

		var selector = $('<select>', { "class" : 'statusSelector', multiple : true, disabled : !settings.editable, title : settings.mandatoryTitle });
		for (var i = 0; i < states.length; ++i) {
			selector.append($('<option>', { "class" : 'status', value : states[i].id, selected : ($.inArray(states[i].id, required) >= 0) }).text(states[i].name));
	    }

		this.append(selector);

		if (options.disabled) {
			selector.prop("disabled", true);
		}

		selector.multiselect({
    		checkAllText	 : settings.checkAllText,
    	 	uncheckAllText	 : settings.uncheckAllText,
    	 	noneSelectedText : settings.noneText,
    	 	autoOpen		 : false,
    	 	multiple         : true,
    	 	selectedList	 : states.length,
    	 	minWidth		 : settings.minWidth,
    	 	height			 : states.length * 32
		});

		return this;
	};

	$.fn.fieldMandatoryControl.defaults = {
		editable			: false,
	 	minWidth		 	: 720, //'auto',
		statusOptions		: [],
		mandatoryLabel		: 'Mandatory',
		mandatoryTitle		: 'Please click here, to define in which states this field must have a value.',
		inStatusLabel		: 'in Status',
		allText  			: 'All',
		noneText  			: 'None',
		exceptLabel			: 'except',
		exceptTitle			: 'Basically the field is mandatory in all states, except for the specified ones (if any)',
		checkAllText		: 'Check all',
		uncheckAllText		: 'Uncheck all',
		submitText			: 'OK',
		cancelText			: 'Cancel'
	};


	// Complementary Plugin to fieldMandatoryControl, to get the list of states where the field is required in
	$.fn.getFieldRequiredIn = function() {
		var required = [];

		var selected = $('select.statusSelector', this).multiselect('getChecked');
		if (selected) {
			for (var i = 0; i < selected.length; ++i) {
				var statusId = parseInt(selected[i].value);
				required.push(isNaN(statusId) ? null : statusId);
			}
		}
		return required;
	};


	// A third plugin to show a field mandatory control in a dialog
	$.fn.showFieldMandatoryDialog = function(required, inStatus, options, dialog, callback) {
		var settings = $.extend( {}, $.fn.showFieldMandatoryDialog.defaults, dialog );

		var popup = this;
		popup.empty();

		var header = $('<div>', { title : options.allExceptTitle, style : 'vertical-align: middle; margin-bottom: 6px;' });

		var allExcept = $('<input>', { type: 'checkbox', name: 'required', checked: required, disabled : !options.editable });
		allExcept.uniqueId();

		if (options.disabled) {
			allExcept.prop("disabled", true);
		}

		var label = $('<label>', { "for" : allExcept.attr('id'), style : 'margin-left: 4px; color: ' + (required ? 'black' : 'lightGray') });
		label.append('<b>' + options.allText + '</b>, ' + options.exceptLabel + ':');

		if (options.editable) {
			allExcept.click(function() {
				label.css('color', $(this).is(':checked') ? 'black' : 'lightGray');
			});
		}

		header.append(allExcept);
		header.append(label);
		popup.append(header);

		popup.fieldMandatoryControl(inStatus, options);

		if (options.editable && typeof(callback) == 'function') {
			settings.buttons = [
			   { text : options.submitText,
				 click: function() {
							var statusList = popup.getFieldRequiredIn();

							callback(allExcept.is(':checked'), statusList);

							popup.dialog("close");
						}
				},
				{ text : options.cancelText,
				  "class": "cancelButton",
				  click: function() {
					  		popup.dialog("close");
					  		popup.remove();
						 }
				}
			];
		} else {
			settings.buttons = [];
		}

		popup.dialog(settings);
	};

	$.fn.showFieldMandatoryDialog.defaults = {
		dialogClass		: 'popup',
		width			: 800,
		draggable		: true
	};


})( jQuery );
