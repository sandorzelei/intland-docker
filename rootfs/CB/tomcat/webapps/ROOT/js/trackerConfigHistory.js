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
 */

var codebeamer = codebeamer || {};
codebeamer.trackerconfig = codebeamer.trackerconfig || {};
codebeamer.trackerconfig.history = codebeamer.trackerconfig.history || (function($) {

	function init() {
		$('.tracker-history-entries').on('click', '.action.revert', function() {
			var $element, version, headVersion, itemId;

			$element = $(this);
			$element.off("click");
			version = $element.data("version");
			headVersion = $element.data("head-version");
			trackerId = $element.data("tracker-id");
			//isEditable = $element.data("editable");
			inlinePopup.show(contextPath + "/trackerdiff/trackerdiff.spr?trackerId=" + trackerId + "&version=" + version +
					"&headVersion=" + headVersion, {
				geometry: "large"
			});
			return false;
		});
	}

	return {
		"init": init
	};
}(jQuery));