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

	// Show a user info link
	$.fn.userInfoLink = function(user, date) {

		function init(container, user, date) {
			container.append( $('<label>', { "class" : 'userInfo', title : '[USER:' + user.id + ']: ' + user.realName } ).text(user.name));
			if (date) {
				container.append(', ' + date);
			}
		}

		return this.each(function() {
			init($(this), user, date);
		});
	};

	// Show a help link. The passed options must contain the help 'URL' plus optionally a link 'title'
	$.fn.helpLink = function(options) {
		return this.each(function() {
			if (options && options.URL) {
				$(this).append($('<a>', { href: options.URL, title : options.title, style : 'float: Right;' }).append(
					$('<img>', { "class" : 'labelHintImg', src : contextPath + "/images/newskin/action/information-s.png", style: 'margin-top: 1px;' })
				).click(function() {
					window.open(options.URL, "_blank");
					return false;
				}));
			}
		});
	};

	// A plugin to show additional/administrative information about an object in an infobox popup.
	$.fn.objectInfoBox = function(object, options) {
		var settings = $.extend( {}, $.fn.objectInfoBox.defaults, options );

		function showInfo() {
			var infoLink = $(this);
			var object = infoLink.data('object');
			var infobox = $('<div>');

			var table = $('<table>', { "class" : 'formTable' });
			infobox.append(table);

			var idRow = $('<tr>');
			idRow.append($('<td>', { "class" : 'labelCell optional' }).text(settings.idLabel + ':'));
			idRow.append($('<td>', { "class" : 'dataCell'  }).text(object.id));
			table.append(idRow);

			var createdBy = $('<tr>');
			createdBy.append($('<td>', { "class" : 'labelCell optional' }).text(settings.createdByLabel + ':'));
			createdBy.append($('<td>', { "class" : 'dataCell'  }).userInfoLink(object.owner, object.createdAt));
			table.append(createdBy);

			if (object.version > 1) {
				var lastModification = $('<tr>');
				lastModification.append($('<td>', { "class" : 'labelCell optional' }).text(settings.lastModifiedLabel + ':'));
				lastModification.append($('<td>', { "class" : 'dataCell'  }).userInfoLink(object.lastModifiedBy, object.lastModifiedAt).append(' (' + settings.versionLabel + ': ' + object.version + ')'));
				table.append(lastModification);

				if (object.comment && object.comment.length > 0) {
					var comment = $('<tr>');
					comment.append($('<td>', { "class" : 'labelCell optional' }).text(settings.commentLabel + ':'));
					comment.append($('<td>', { "class" : 'dataCell'  }).text(object.comment));
					table.append(comment);
				}
			}

			infobox.dialog({
				dialogClass	    : 'popup',
				title			: settings.infoLabel,
				position		: { my: "right top", at: "right top", of: infoLink, collision: 'fit' },
				modal			: true,
				draggable	    : false,
				minWidth		: 400,
				height		  	: 128,
				closeOnEscape	: true,
				close			: function(event, ui) {
									  infobox.remove();
								  }
			});
		}

		if (object && object.id) {
			$(this).append($('<span>', { "class" : 'ui-icon ui-icon-info', title : settings.infoTitle, style : 'float: Right; margin-top: 0px;' }).data('object', object).click(showInfo));
		}
	};

	$.fn.objectInfoBox.defaults = {
		infoLabel			: 'Administrative Information',
		infoTitle			: 'Additional/administrative information about this choice option',
		idLabel				: 'Id',
		versionLabel		: 'Version',
		createdByLabel		: 'Created by',
		lastModifiedLabel	: 'Last modified by',
		commentLabel		: 'Comment'
	};


})( jQuery );

