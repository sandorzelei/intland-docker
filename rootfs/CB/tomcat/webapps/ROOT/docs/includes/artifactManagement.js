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

	// Artifact creation Plugin definition.
	$.fn.createArtifactForm = function(artifact, options) {
		var settings = $.extend( {}, $.fn.createArtifactForm.defaults, options );

		function init(container, artifact) {
			if (settings.displayWarning) {
				var $warning = $("<div>", {"class": "warning"}).text(i18n.message(settings.displayWarning));
				container.append($warning);
				return;
			}

			if (settings.displayHint) {
				var $warning = $("<div>", {"class": "hint"}).text(i18n.message(settings.displayHint));
				container.append($warning);
			}

			var table = $('<table>', { "class" : 'artifactForm propertyTable'}).data('artifact', artifact);
			container.append(table);

			var nameRow   = $('<tr>');
			var nameLabel = $('<td>', { "class" : 'labelCell mandatory' }).text(settings.nameLabel + ':');
			var nameCell  = $('<td>', { "class" : 'dataCell', style : 'width: 5%' });
			var name	  = $('<input>', { type : 'text', name : 'name', value : artifact.name, size: 40, maxlength : 80}).keypress(codebeamer.prefill.ignoreEnterKey);
			name.attr('autocomplete', 'off');

			nameCell.append(name);
			nameRow.append(nameLabel);
			nameRow.append(nameCell);
			table.append(nameRow);

			var descrRow    = $('<tr>',		  { title : settings.descriptionTooltip });
			var descrLabel  = $('<td>', 	  { "class" : 'labelCell optional' }).text(settings.descriptionLabel + ':');
			var descrCell   = $('<td>', 	  { "class" : 'dataCell expandTextArea' });
			var description = $('<textarea>', { name : 'description', rows : 2, cols : 80}).val(artifact.description);
			if (settings.hasOwnProperty('descriptionSizeLimit') && settings.descriptionSizeLimit) {
				description.attr("maxlength", settings.descriptionSizeLimit);
			}

			descrCell.append(description);
			descrRow.append(descrLabel);
			descrRow.append(descrCell);
			table.append(descrRow);

			// If the artifact is a baseline (tag)
			if (artifact.typeId == 12) {
				var signRow   = $('<tr>',	 { title : settings.signatureTitle });
				var signLabel = $('<td>', 	 { "class" : 'labelCell optional' }).text(settings.signatureLabel + ':');
				var signCell  = $('<td>', 	 { "class" : 'dataCell', style : 'width: 5%' });
				var signature = $('<input>', {
					type : 'text',
					name : 'signature',
					size : 60,
					maxlength : 80
				});

				signCell.append(signature);
				signRow.append(signLabel);
				signRow.append(signCell);
				table.append(signRow);

				codebeamer.prefill.prevent(signCell.find("input[name=signature]"), getBrowserType());
			}
		}

		return this.each(function() {
			init($(this), artifact);
		});
	};


	$.fn.createArtifactForm.defaults = {
		nameLabel 		 : 'Name',
		descriptionLabel : 'Description',
		descriptionSizeLimit	: null,
		signatureLabel	 : 'Signature',
		signatureTitle	 : 'You can optionally sign this baseline by entering your password here'
	};


	// Plugin to get the artifact specification from an artifact creation form
	$.fn.getArtifactSpec = function() {
		var form = $('table.artifactForm', this);

		var result = $.extend( {}, form.data('artifact'), {
			name    	: $.trim($('input[name="name"]', form).val()),
			description : $.trim($('textarea[name="description"]', form).val()),
			signature  	: $.trim($('input[name="signature"]', form).val())
		});

		return result;
	};


	// A third plugin to create a new artifact in a dialog
	$.fn.showCreateArtifactDialog = function(artifact, config, dialog, doneCallback, failCallback, beforeSubmitCallback) {
		var settings = $.extend( {}, $.fn.showCreateArtifactDialog.defaults, dialog );

		var popup = $('#createArtifactPopup');
		if (popup.length == 0) {
			popup = $('<div>', { id : 'createArtifactPopup', "class" : 'editorPopup artifactCreationForm', style : 'display: None;'} );
			this.closest('form').append(popup);
		} else {
			popup.empty();
		}

		popup.createArtifactForm(artifact, config);

		settings.position = { my: "center", at: "center", of: window, collision: 'fit' };

		settings.buttons = [];

		if (!config.displayWarning) {
			settings.buttons.push({ text : settings.submitText,
				 click: function(event) {
				 		var buttons = popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button');
				 		buttons.button("disable");

				 		$.isFunction(beforeSubmitCallback) && beforeSubmitCallback.call();

						$.ajax(settings.submitUrl, {
							type: 'POST',
							data : JSON.stringify(popup.getArtifactSpec()),
							contentType : 'application/json',
							dataType : 'json'
						}).done(function(result) {
							$.isFunction(doneCallback) && doneCallback(result);
				  			popup.dialog("close");
				  			popup.remove();
				    	}).fail(function(jqXHR, textStatus, errorThrown) {
							$.isFunction(failCallback) && failCallback(jqXHR);
				    		buttons.button("enable");
				    		try {
					    		var exception = eval('(' + jqXHR.responseText + ')');
					    		showFancyAlertDialog(exception.message);
				    		} catch(err) {
					    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
				    		}
				        });
					}
			});
		}
		settings.buttons.push({ text : settings.cancelText,
		  "class": "cancelButton",
		  click: function() {
		  			popup.dialog("close");
		  			popup.remove();
				 }
		});

		settings['open'] = function (event, ui) {
			var $buttonPane = $(this).parent().find('.ui-dialog-buttonpane');
	        $(this).before($buttonPane);

	        $buttonPane.addClass('actionBar');

	        var $titleBar = $(this).parent().find('.ui-dialog-titlebar');
	        $titleBar.addClass('actionMenuBar');
	    };

		popup.dialog(settings);
	};

	$.fn.showCreateArtifactDialog.defaults = {
		dialogClass		: 'popup',
		width			: 800,
		draggable		: true,
		modal			: true,
		closeOnEscape	: false,
		submitUrl		: null,
		submitText		: 'OK',
		cancelText		: 'Cancel',
		appendTo		: "body"
	};


})( jQuery );
