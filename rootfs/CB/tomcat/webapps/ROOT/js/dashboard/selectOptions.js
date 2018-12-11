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
codebeamer.dashboard.selectOptionEditor = codebeamer.dashboard.selectOptionEditor || (function($) {

	function render(result, $selector, checked) {
		$selector.empty();
		for (var i = 0; i < result.length; i++) {
			var selectOption = result[i];

			var $option = $("<option>", { value : selectOption.id }).text(selectOption.value)

			if (checked.indexOf(selectOption.id) >= 0) {
				$option.attr("selected", "selected");
			}

			$selector.append($option);
		}
	};

	function getJSON(projectIds, teamQueryUrl, $selector) {
		$.getJSON(teamQueryUrl, { "projectIds[]" : projectIds.join(",")}).done(function(result) {
			var checked = [];

			$selector.multiselect("getChecked").each(function() {
				checked.push(this.value);
			});

			render(result, $selector, checked);

			$selector.multiselect("refresh");
		});
	};
	
	function getJSON(projectIds, teamQueryUrl, $selector, extraValue) {
		$.getJSON(teamQueryUrl, { "projectIds[]" : projectIds.join(","), "extraValue" : extraValue}).done(function(result) {
			var checked = [];

			$selector.multiselect("getChecked").each(function() {
				checked.push(this.value);
			});

			render(result, $selector, checked);

			$selector.multiselect("refresh");
		});
	};

	function getSelectOptions(projectIds, queryUrl, selectorId) {
		getJSON(projectIds, queryUrl, $("#" + selectorId));
	};
	
	function getSelectOptions(projectIds, queryUrl, selectorId, extraValue) {
		getJSON(projectIds, queryUrl, $("#" + selectorId), extraValue);
	};

	return {
		"getSelectOptions": getSelectOptions
	};

})(jQuery);