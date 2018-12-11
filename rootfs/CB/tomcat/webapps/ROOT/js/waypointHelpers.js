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
codebeamer.waypointHelpers = codebeamer.waypointHelpers || (function($) {
	var restoreCenterScrollState = function($container, state, itemId, callback) {
		var scrollToSpecificId = false;
		if ($.isEmptyObject(state)) {
			state = { top: 9999999 };
			scrollToSpecificId = true;
		}

		var canLoadMorePages = function() {
			return $container.find(".load-more, .load-more-in-progress").length > 0;
		};
		var scrollMore = function() {
			var item = $container.find("#" + itemId);
			if (scrollToSpecificId) {
				var itemFound = item.length > 0;
				if (itemFound) {
					var itemRelativePosition = item.position().top - item.height() * 2;
					state.top = $container.scrollTop() + itemRelativePosition;
				}
			}
			$container.scrollTop(state.top);
			var currentTop = $container.scrollTop();
			if ((Math.floor(currentTop) < Math.floor(state.top)) && canLoadMorePages()) {
				setTimeout(scrollMore, 200);
			} else {
				if (callback) {
					setTimeout(function() {
						callback(item);
					}, 200);
				}
			}
		};
		scrollMore();
	};

	return {
		"restoreCenterScrollState": restoreCenterScrollState
	};
}(jQuery));