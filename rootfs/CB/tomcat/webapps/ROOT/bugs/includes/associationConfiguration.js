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

	// Plugin shows a form to define the kind of association (if any) to establish between original items and copied items
	$.fn.associationBetweenCopiedItems = function(association, config) {
		var settings = $.extend( {}, $.fn.associationBetweenCopiedItems.defaults, config );

		function init(container, association) {
			if (!$.isPlainObject(association)) {
				association = {
					type 				: null,
					description			: null,
					propagatingSuspects : false
				};
			}

			if ($.isArray(settings.assocTypes) && settings.assocTypes.length > 0) {
				var assocCell   = container;
				var supectCell  = container;
				var commentLine = null;
				var commentCell = null;

				if (!settings.compactLayout) {
					var fieldSet = $('<fieldset>', { style : 'margin-top: 1em; margin-bottom: 1em;' }).append($('<legend>').text(settings.assocTypeTitle));
					container.append(fieldSet);

					var table = $('<table>', { "class" : 'formTableWithSpacing', style : 'width: 100%;' });
					fieldSet.append(table);

					var assocLine = $('<tr>', { style: "vertical-align: middle; "});
					assocLine.append($('<td>', { "class" : 'optional', style : 'width: 5%;' }).text(settings.assocTypeLabel + ':'));

					assocCell = $('<td>', { "class" : 'column-minwidth' });
					assocLine.append(assocCell);

					supectCell = $('<td>', { style: 'white-space: nowrap; vertical-align: middle; text-align: left;' });
					assocLine.append(supectCell);

					table.append(assocLine);

					commentLine = $('<tr>', { style: "vertical-align: middle; display: None;" });
					commentLine.append($('<td>', { "class" : 'optional', style : 'width: 5%;' }).text(settings.commentLabel + ':'));

					commentCell = $('<td>', { "class" : 'expandtextarea', colspan : 2 });
					commentLine.append(commentCell);
					table.append(commentLine);
				}

				var assocTypeSelector = $('<select>', { name : 'assocType' });
				if (settings.assocTypes.length == 0 || settings.assocTypes[0].id != 0) {
					assocTypeSelector.append($('<option>', { "class" : 'assocType', value : 0 }).text(settings.assocTypeNone));
				}

				for (var i = 0; i < settings.assocTypes.length; ++i) {
					var $option =$('<option>',
							{ "class" : 'assocType', value : settings.assocTypes[i].id, selected : association.type ? settings.assocTypes[i].id == association.type.id : false }).text(settings.assocTypes[i].name);

					if (settings.assocTypes[i].selected) {
						$option.prop("selected", true);
					}
					assocTypeSelector.append($option);
				}

				assocCell.append(assocTypeSelector);

				var suspectLabel = $('<label>', { id : 'suspectedLink', title : settings.suspectedTitle, style : "display:none; margin-left: 1em;" });
				var suspectCheck = $('<input>', { type : 'checkbox', name : 'propagatingSuspects', value : 'true', checked : association.propagatingSuspects });

				if (settings.propagateSuspectedByDefault) {
					suspectCheck.prop("checked", "checked");
				}

				suspectLabel.append(suspectCheck);
				suspectLabel.append(settings.suspectedLabel);
			 	supectCell.append(suspectLabel);

			 	var commentField = $('<textarea>', { name : 'comment', rows : 2, cols : 60 }).val(association.description);

			 	if (settings.compactLayout) {
			 		commentField.attr('placeholder', settings.commentLabel);

					commentLine = $('<div>', { title : settings.commentLabel, style: "margin-top: 4px; display: None;" });
					container.append(commentLine);

					commentLine.append(commentField);
			 	} else {
				 	commentCell.append(commentField);
			 	}

				assocTypeSelector.change(function() {
					if (this.value == '0') {
						suspectLabel.hide();
						commentLine.hide();
					} else {
						suspectLabel.show();
						commentLine.show();
					}
				});

				assocTypeSelector.change();
			}
		}

		return this.each(function() {
			init($(this), association);
		});
	};

	$.fn.associationBetweenCopiedItems.defaults = {
		assocTypes      : [],
		assocTypeTitle	: 'What kind of association should be established between the copied items and their originals ?',
		assocTypeLabel	: 'Association Type',
		assocTypeNone	: 'None',
		suspectedTitle	: 'Should this association be marked \'Suspected\' whenever the association target is modified?',
		suspectedLabel	: 'Propagate suspects',
		commentLabel	: 'Comment',
		compactLayout	: false
	};


	// Plugin to get the type of association to setup between copied item and original
	$.fn.getAssociationBetweenCopiedItems = function() {
		var assocType = $('select[name="assocType"] > option.assocType:selected', this);
		return assocType.length == 0 || assocType.attr('value') == '0' ? null : {
			type : {
				id 	 : parseInt(assocType.attr('value')),
				name : assocType.text()
			},
			description			: $.trim($('textarea[name="comment"]', this).val()),
			propagatingSuspects : $('input[type="checkbox"][name="propagatingSuspects"]', this).is(':checked')
		};
	};

})( jQuery );

