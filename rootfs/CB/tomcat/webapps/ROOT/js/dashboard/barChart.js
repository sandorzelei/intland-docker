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
codebeamer.dashboard.barChart = codebeamer.dashboard.barChart || (function($) {
	function updateDependentFields(type) {
		var simple = type == "SIMPLE"; // if changed to simple bar chart
		var $groupingField = $("#groupingField");
		var $refreshButton = $(".refreshButton");

		var isProgrammaticUpdatesAllowed = $refreshButton.data("programmatic-update-allowed");

		if (isProgrammaticUpdatesAllowed) {
			if (simple) {
				$groupingField.show();
				$refreshButton.attr("data-filter-type", "GROUPED");
			} else {
				$groupingField.hide();
				$refreshButton.attr("data-filter-type", "GROUPED_BY_TWO_ATTRIBUTE");
			}

			try {
				$("#chartOrdering select").multiselect("refresh");
			} catch (e) {}

			$refreshButton.click();
		}
	}

	var init = function () {
		$("body").on("fixedChoice:showAs:changed", null, function (event, value) { // a new bar chart type was selected
			updateDependentFields(value);
		});

		$(document).ready(function () {
			var $showAs = $("#showAs select");
			if ($("#globalMessages").hasClass("invisible")) {
				updateDependentFields($showAs.val());
			}
		});
	};

	/**
	 * highchart label formatter that hides zero labels.
	 */
	var zeroIgnoringFormatter = function () {
		if(this.y > 0) {
			return this.y;
		}
	}

	return {
		init: init,
		zeroIgnoringFormatter: zeroIgnoringFormatter
	};
})(jQuery);