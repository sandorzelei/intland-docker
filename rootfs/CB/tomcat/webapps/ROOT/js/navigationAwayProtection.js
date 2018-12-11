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
 */

var codebeamer = codebeamer || {};
codebeamer.NavigationAwayProtection = codebeamer.NavigationAwayProtection || (function($) {
	var inspectedElements = {}, // for elements which are dynamically added to the dom
		inited = false;

	var dirtyCheckEditors = function() {
		var isDirty = false;
		if ($.FroalaEditor) {
			$.each($.FroalaEditor.INSTANCES, function(index, editor) {
				// for inline comments the editor doesn't need to be visible to treat it as dirty
				isDirty = !editor.$oel.hasClass('skip-dirty') && editor.$oel.hasClass('dirty') && (editor.$oel.attr('id') == 'editor_new' || editor.$box.is(':visible'));
				return !isDirty;
			});
		}

		return isDirty;
	};

	var dirtyCheckElements = function() {
		var dirty = false;
		$.each(Object.keys(inspectedElements), function(index, id) {
			if (inspectedElements[id].dirty) {
				dirty = true;
			}
		});

		return dirty;
	};

	var getForms = function($context) {
		if (!$context) {
			$context = document;
		}
		return $('form.dirty-form-check', $context);
	};

	/**
	 * Inits the navigation away protection. It uses jquery.areYouSure plugin for forms.
	 */
	var init = function(forceInIframe, $context) {
		if (window.frameElement && !forceInIframe) { // don't run in iframes only if it's forced
			return;
		}

		if (!$context) {
			$context = document;
		}

		getForms($context).areYouSure();

		// fixing issue caused by nested forms for example in document view
		$('form', $context).each(function() {
			var $form = $(this);
			if (!$form.hasClass('dirty-form-check') && !$form.hasClass('field-editor-form')) {
				$form.removeClass('dirty');
			}
		});


		if (!inited) {
			$(window).on('beforeunload', function() {
				if (!codebeamer.skipDirtyCheck && (dirtyCheckEditors() || dirtyCheckElements())) {
					return true;
				}
			});

			inited = true;
		}
	};

	var reset = function() {
		getForms().each(function() {
			$(this).trigger('reinitialize.areYouSure');
		});

		$.each(Object.keys(inspectedElements), function(index, id) {
			inspectedElements[id].dirty = false;
		});

		if ($.FroalaEditor) {
			$.each($.FroalaEditor.INSTANCES, function(index, editor) {
				if (codebeamer.WYSIWYG.getEditorMode(editor.$oel) == 'markup') {
					editor.$oel.removeClass('dirty');
				} else {
					codebeamer.WikiConversion.saveEditor(editor.$oel, true);
				}
			});
		}
	};

	var getElementId = function($element) {
		return $element.attr('data-editor-id') || $element.attr('data-id') || $element.attr('id');
	};

	var addInspectedElement = function($element) {
		var id = getElementId($element);
		if (id) {
			inspectedElements[id] = {
				value: $element.val() || $element.text(),
				dirty: false
			}
		}
	};

	var removeInspectedElement = function($element) {
		var id = getElementId($element);
		if (id) {
			delete inspectedElements[id];
		}
	};

	var checkElement = function($element) {
		var id = getElementId($element);
		if (id) {
			var elementData = inspectedElements[id];
			if (elementData) {
				var value = $element.val() || $element.text();
				elementData.dirty = elementData.value != value;
			} else {
				addInspectedElement($element);
			}
		}
	};

	return {
		init: init,
		reset: reset,
		addInspectedElement: addInspectedElement,
		removeInspectedElement: removeInspectedElement,
		checkElement: checkElement
	};
})(jQuery);
