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

	// Plugin shows a form to enter an issue reminder specification
	$.fn.issueReminderForm = function(issue, options) {
		var settings = $.extend( {}, $.fn.issueReminderForm.defaults, options );

		function init(container, issue) {
			container.append(settings.inLabel);
			container.append($('<input>', { type : 'number', name : 'offset', size : 3, maxlength : 10, title : settings.inTooltip, style : 'margin-left: 2px; margin-right: 2px;' }));

			var unit = $('<select>', { name : 'unit', style : 'margin-right: 6px;' });
			for (var i = 0; i < settings.units.length; ++i) {
				unit.append($('<option>', { value : settings.units[i].id }).text(settings.units[i].name));
			}
			container.append(unit);
			container.append($('<br>'));
			container.append(settings.atLabel);

			var date = $('<input>', { type : 'text', name : 'date', size : 12, maxlength : 14, style : 'margin-left: 2px; margin-right: 4px;'  });
			date.datepicker(settings.datepicker);

			container.append(date);
			container.append(settings.timeLabel);

			var time = $('<input>', { type : 'text', name : 'time', size : 5, maxlength : 5, style : 'margin-left: 2px; margin-right: 2px;'  });
			container.append(time);
			container.append(settings.hoursLabel);
		}

		return this.each(function() {
			init($(this), issue);
		});
	};


	$.fn.issueReminderForm.defaults = {
		inLabel     : 'in',
		inTooltip	: 'Remind me in this number of seconds/minutes/hours/days (working time) from now',
		units 		: [{ id : 6, name : 'days' }, { id : 5, name : 'hours' }, { id : 4, name : 'minutes' }],
		atLabel		: 'or on',
		atTooltip	: 'Remind me at this date',
		timeLabel	: 'at',
		timeTooltip	: 'Remind me at this time on the specified date',
		hoursLabel  : 'hrs'
	};


	// Plugin to get the reminder specification from an issue reminder form
	$.fn.getIssueReminder = function() {
		return {
			"in" : parseFloat($('input[name="offset"]', this).val()),
			unit : parseInt($('select[name="unit"]', this).val()),
			"at" : $.trim($('input[name="date"]', this).val() + ' ' + $('input[name="time"]', this).val())
		};
	};


	// A third plugin to create a new artifact in a dialog
	$.fn.showReminderDialog = function(issue, config, dialog, callback) {
		var settings = $.extend( {}, $.fn.showReminderDialog.defaults, dialog );

		var popup = $('#issueReminderPopup');
		if (popup.length == 0) {
			popup = $('<div>', { id : 'issueReminderPopup', "class" : 'editorPopup', style : 'display: None;'} );
			this.closest('form').append(popup);
		} else {
			popup.empty();
		}

		popup.issueReminderForm(issue, config);

		settings.position = { my: "center", at: "center", of: window, collision: 'fit' };

		settings.buttons = [
		   { text : settings.submitText,
			 click: function(event) {
				 		var buttons = popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button');
				 		buttons.button("disable");

						$.ajax(settings.submitUrl, {type: 'POST', data : JSON.stringify(popup.getIssueReminder()), contentType : 'application/json', dataType : 'json' }).done(function(result) {
						 	callback(result);
				  			popup.dialog("close");
				  			popup.remove();
				    	}).fail(function(jqXHR, textStatus, errorThrown) {
				    		buttons.button("enable");

				    		try {
					    		var exception = eval('(' + jqXHR.responseText + ')');
					    		alert(exception.message);
				    		} catch(err) {
					    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
				    		}
				        });
					}
			},
			{ text : settings.cancelText,
			  "class": "cancelButton",
			  click: function() {
			  			popup.dialog("close");
			  			popup.remove();
					 }
			}
		];

		popup.dialog(settings);
	};

	$.fn.showReminderDialog.defaults = {
		dialogClass		: 'popup',
		width			: 500,
		draggable		: true,
		modal			: true,
		closeOnEscape	: false,
		submitUrl		: null,
		submitText		: 'OK',
		cancelText		: 'Cancel',
		appendTo		: "body"
	};


})( jQuery );
