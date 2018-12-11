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

	// Tracker Escalation Rules configuration Plugin definition.
	$.fn.ajaxSubmitButton = function(options) {
		var settings = $.extend( {}, $.fn.ajaxSubmitButton.defaults, options );

		var elemAttributes = { type : 'submit', "class" : 'button', name : 'SAVE', value : settings.submitText };
		if (settings['id']) {
			elemAttributes.id = settings.id;
		}
		this.prepend($('<input>', elemAttributes).click(function(event, eventData) {
		    event.preventDefault();
		    eventData = eventData || {};

		    var data = settings.submitData;
		    if ($.isFunction(data)) {
		    	data = data();
		    }

		    var body = $('body');
		    var button = this;
		    button.disabled = true;
		    body.css('cursor', 'progress');

			var busy = ajaxBusyIndicator.showBusyPage();

			$.ajax(settings.submitUrl, {
				type		: 'POST',
				data 		: JSON.stringify(data),
				contentType : 'application/json',
				dataType 	: 'json'
			}).done(function(result) {
				settings.onSuccess(result, eventData);
			}).fail(function(jqXHR, textStatus, errorThrown) {
				// prevent error handling if the user is unauthorized, this error handled by codebeamer-main.js - ajaxErrorHandler()
				if (jqXHR.status != 401){
					settings.onFailure(jqXHR, textStatus, errorThrown);
				}
	        }).always(function() {
				button.disabled = false;
				body.css('cursor', 'auto');
				ajaxBusyIndicator.close(busy);
			});

			return false;
		}));
	};

	$.fn.ajaxSubmitButton.defaults = {
		submitText	: 'Save',
		submitUrl	: '',
		submitData	: {},

		onSuccess	: function(result) {
						showOverlayMessage(i18n.message("ajax.changes.successfully.saved"));
					  },

		onFailure	: function(jqXHR, textStatus, errorThrown) {
			    		try {
				    		var exception = eval('(' + jqXHR.responseText + ')');
				    		showFancyAlertDialog(exception.message);
			    		} catch(err) {
				    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
			    		}
			          }
	};


})( jQuery );
