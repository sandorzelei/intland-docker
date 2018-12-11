/**
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
var codebeamer = codebeamer || {};

codebeamer.MinifiedOverlay = codebeamer.MinifiedOverlay || (function($) {
	var DIALOG_SELECTOR = '.ui-dialog.inlinePopupDialog',
		OVERLAY_SELECTOR = '.ui-widget-overlay',
		CONTAINER_CLOSE = 'container-close',
		MINIFIED_OVERLAY = 'minified-overlay',
		MINIFIED_OVERLAY_SELECTOR = '.' + MINIFIED_OVERLAY;

	var createMinifiedOverlay = function(label) {
		var $minifiedOverlay = $('<div>', { 'class': MINIFIED_OVERLAY }),
			$label = $('<div>', { 'class': 'overlay-label' }).append(label),
			$maximize = $('<a>', { 'class': 'overlay-maximize' }),
			$close = $('<a>', { 'class': CONTAINER_CLOSE });

		$minifiedOverlay.append($label);
		$minifiedOverlay.append($maximize);
		$minifiedOverlay.append($close);

		$minifiedOverlay.on('click', function(e) {
			var $clickedOn = $(e.target);

			maximize();

			if ($clickedOn.hasClass(CONTAINER_CLOSE)) {
				$(DIALOG_SELECTOR).find('.' + CONTAINER_CLOSE).click();
			}
		});

		return $minifiedOverlay;
	};

	var getLabel = function($menubar, selectors) {
		var label = '';

		selectors.some(function(selector) {
			label = $menubar.find(selector).text();
			return label;
		});

		return label;
	};

	var onBeforeUnloadHandler = function() {
		return isMinifiedOverlayPresent();
	};

	var minimize = function() {
		var $openedEditorIframe = $('#inlinedPopupIframe')[0].contentWindow.$('#editor_ifr'),
			$actionMenuBar = $('#inlinedPopupIframe')[0].contentWindow.$('.actionMenuBar'),
			label = getLabel($actionMenuBar, ['.summary', '.breadcrumbs-summary:first', '.page-title']);

		$(DIALOG_SELECTOR).hide();
		$(OVERLAY_SELECTOR).hide();

		var $minifiedOverlay = createMinifiedOverlay(label);
		if (window.parent != window) {
			window.parent.$('body').append($minifiedOverlay);
		} else {
			$('body').append($minifiedOverlay);
		}
		flashChanged($minifiedOverlay, null, null, null, true);

		$(window).on('beforeunload', onBeforeUnloadHandler);
	};

	var maximize = function() {
		var $dialog = $(DIALOG_SELECTOR);

		$dialog.show();
		$(OVERLAY_SELECTOR).show();

		if (window.parent != window) {
			window.parent.$(MINIFIED_OVERLAY_SELECTOR).remove();
		} else {
			$(MINIFIED_OVERLAY_SELECTOR).remove();
		}

		// fix scrollbar rendering issue on chrome
		if ($('body').hasClass('Chrome')) {
			var $contentDiv = $dialog.find('.ui-dialog-content');
			$contentDiv.css('float', 'left');
			setTimeout(function() {
				$contentDiv.css('float', 'none');
			});
		}
		$(window).off('beforeunload', onBeforeUnloadHandler);
	};

	var isMinifiedOverlayPresent = function() {
		return !!$(MINIFIED_OVERLAY_SELECTOR).length;
	};

	var remove = function() {
		$(MINIFIED_OVERLAY_SELECTOR).remove();
		$(window).off('beforeunload', onBeforeUnloadHandler);
	};

	var removeByEditorId = function(editorId) {
		if ($('#originalEditorId').val() == editorId) {
			remove();
		}
	};

	return {
		minimize: minimize,
		maximize: maximize,
		isMinifiedOverlayPresent: isMinifiedOverlayPresent,
		remove: remove,
		removeByEditorId: removeByEditorId
	}
})(jQuery);