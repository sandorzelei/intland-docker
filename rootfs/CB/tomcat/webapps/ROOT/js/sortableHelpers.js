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
var setupCenterAutoScrollOnDnD = function($container, $whatToScroll, tolerance) {
	if (!tolerance) {
		tolerance = 20;
	}

	var scrollUp = function () {
		$whatToScroll.animate({scrollTop: $whatToScroll.scrollTop() + -100}, 50);
	};

	var scrollDown = function () {
		$whatToScroll.animate({scrollTop: $whatToScroll.scrollTop() + 100}, 50);
	};

	$container.mousemove(function(e) {
		// auto-scroll center pane while dragging
		if (codebeamer.is_dragging) {
			e.preventDefault();
			var $helper = $(".ui-sortable-helper");
			var helperOffset = $helper.offset();
			var centerTop = $whatToScroll.offset().top;
			var centerBottom = centerTop + $whatToScroll.height() + tolerance;
			if (helperOffset.top < centerTop) {
				throttle(scrollUp, this, scrollUp, 50);
			} else if (helperOffset.top + $helper.height() > centerBottom) {
				throttle(scrollDown, this, scrollDown, 50);
			}
		}
	});
};