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

	// Tracker item comment/attachment visibility control Plugin definition.
	$.fn.commentVisibilityControl = function(trackerId, visibility, options) {
		var settings = $.extend( {}, $.fn.commentVisibilityControl.defaults, options );

		if (typeof visibility === 'string') {
			visibility = visibility.split(',');
		} else if (!$.isArray(visibility)) {
			visibility = [];
		}

		var selector = $('<select>', { name : 'visibleTo', title : settings.visibilityTitle, multiple : true });
		$(this).append(selector);

		if ($.isArray(settings.memberFields) && settings.memberFields.length > 0) {
			var prefix = '3-' + trackerId + '/';
			var group = $('<optgroup>', { label : settings.memberFieldsLabel });
			selector.append(group);

			for (var i = 0; i < settings.memberFields.length; ++i) {
				var value = prefix + settings.memberFields[i].id;

				group.append($('<option>', { "class" : 'field', value: value, selected : ($.inArray(value, visibility) >= 0) }).text(settings.memberFields[i].name));
		    }
		}

		if ($.isArray(settings.roles) && settings.roles.length > 0) {
			var prefix = '13-';
			var group = $('<optgroup>', { label : settings.rolesLabel });
			selector.append(group);

			for (var i = 0; i < settings.roles.length; ++i) {
				var value = prefix + settings.roles[i].id;
				group.append($('<option>', { "class" : 'role', value: value, selected : ($.inArray(value, visibility) >= 0) }).text(settings.roles[i].name));
		    }
		}

		selector.multiselect({
    		checkAllText	 : settings.checkAllText,
    	 	uncheckAllText	 : settings.everybodyLabel,
    	 	noneSelectedText : settings.everybodyLabel,
    	 	autoOpen		 : false,
    	 	multiple         : true,
    	 	selectedList	 : 99,
    	 	height			 : 320,
			classes			 : "commentVisibilityControl",
			create			 : function() {
				$(this).next('.ui-multiselect').css("min-width", 220);
			},
			position: {
				my: 'right bottom', at: 'right top'
			}
		});

		_moveToEditorToolbar($(this));
		return this;
	};

	$.fn.commentVisibilityControl.defaults = {
		memberFields		: [],
		roles				: [],
		visibilityTitle		: 'Limit visibility of this comment',
		everybodyLabel		: 'Everybody',
		everybodyTitle		: 'Everybody who normally can see the issue, will see this comment too',
		memberFieldsLabel	: 'Participants',
		rolesLabel		 	: 'Roles',
		checkAllText		: 'Check all',
		uncheckAllText		: 'Uncheck all'
	};


	// A second plugin to get the comment/attachment visibility from the control Plugin
	$.fn.getCommentVisibility = function() {
		var selected = $('select[name="visibleTo"]', this).multiselect("getChecked").map(function() { return this.value; }).get();
		return selected.join(',');
	};

	// A third plugin to set the comment/attachment visibility
	$.fn.setCommentVisibility = function(visibility) {
		var values = visibility.split(',');
		$('select[name="visibleTo"]', this).multiselect('widget').find(':checkbox').each(function() {
			var $checkbox = $(this);
			if (values.indexOf($checkbox.val()) > -1 && !$checkbox.is(':checked')) {
				$checkbox.click();
			}
		});
	};

	// moves the visibility control inside the wysiwyg editor's toolbar if the editor is found
	function _moveToEditorToolbar($element) {
		var $container = $element.closest('.issueCommentVisibilityControl'),
			$editorWrapper = $container.siblings('.editor-wrapper');

		if ($editorWrapper.length) {
			$container.css('position', 'static');
			var $tmp = $container.detach();
			$editorWrapper.find('.fr-toolbar').append($tmp);
		}
	}

})( jQuery );
