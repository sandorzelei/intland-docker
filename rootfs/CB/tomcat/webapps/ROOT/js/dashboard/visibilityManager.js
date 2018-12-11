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
codebeamer.dashboard.visibilityManager = codebeamer.dashboard.visibilityManager || (function($) {

	function init(selectorId, callback) {
		var $element =  $("#" + selectorId);

		$element.data("first", false);
		$element.data("second", false);
		$element.data("callback", callback);
	}

	function updateFirstSwitchState(selectorId, value) {
		var $element =  $("#" + selectorId);

		$element.data("first", value);

		changeVisibility($element);
	};

	function updateSecondSwitchState(selectorId, value) {
		var $element =  $("#" + selectorId);

		$element.data("second", value);

		changeVisibility($element);
	};

	function changeVisibility($element) {
		var callback = null;

		if ($element.data("first") && !$element.data("second")) {
			$element.show();
			callback = $element.data("callback")
			if ($.isFunction(callback)) {
				callback();
			}
		} else {
			$element.hide();
		}
	};

	return {
		"init": init,
		"updateFirstSwitchState": updateFirstSwitchState,
		"updateSecondSwitchState": updateSecondSwitchState
	};

})(jQuery);