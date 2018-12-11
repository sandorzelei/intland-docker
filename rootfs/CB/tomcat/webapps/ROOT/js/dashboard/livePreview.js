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
 */
var codebeamer = codebeamer || {};
codebeamer.dashboard = codebeamer.dashboard || {};
codebeamer.dashboard.livePreview = codebeamer.dashboard.livePreview || (function($) {

	function init($fieldsContainer, $livePreviewContainer) {
		function changeInputHandler(event) {
			updateLivePreview($livePreviewContainer);
		};

		function updateInputHandler() {
			updateLivePreview($livePreviewContainer);
		};

		if ($fieldsContainer && $fieldsContainer instanceof jQuery) {
			$fieldsContainer.on("change", "input", changeInputHandler);
			$fieldsContainer.on("change", "textarea", changeInputHandler);
			$fieldsContainer.on("change", "select", changeInputHandler);
			codebeamer.dashboard.multiSelect.attachEventListener("widget:chart:updated", updateInputHandler);
		}
	};

	function updateLivePreview($livePreviewContainer) {

		function executeRequest() {
			var formData = $("#editorForm").serialize();

			$.post(contextPath + '/dashboard/preview.spr', formData).done(function (response) {
				$livePreviewContainer.html(response);
				initializeMinimalJSPWikiScripts($livePreviewContainer);
			}).fail(function () {
				var $error = $("<div>", {"class": "error"}).html("Couldn't render the preview");
				$livePreviewContainer.html($error);
			}).always(function () {
				bs.remove();
			});
		};

		if ($livePreviewContainer && $livePreviewContainer instanceof jQuery) {
			$livePreviewContainer.empty();

			var bs = ajaxBusyIndicator.showBusysign($livePreviewContainer);

			// Not exposed API variable, contains the number of active AJAX requests
			// Changes in multiselect editors might trigger other multiselect editors to autoreload!
			// In this case wait for all AJAX request to finish before updating the preview.
			if ($.active > 0) {
				$(document).one("ajaxStop", function() {
					executeRequest();
				});
			} else {
				executeRequest();
			}

		}
	};

	function refreshLivePreview() {
		codebeamer.dashboard.multiSelect.triggerEvent("widget:chart:updated");
	};

	return {
		"init": init,
		"refreshLivePreview": refreshLivePreview
	};
})(jQuery);