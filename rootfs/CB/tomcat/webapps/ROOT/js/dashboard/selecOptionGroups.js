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
codebeamer.dashboard.selectOptionGroupEditor = codebeamer.dashboard.selectOptionGroupEditor || (function($) {
	var DEFAULT_TRUNCATE_CHARS = 60;

	function truncateText(text, numberOfChars) {
		numberOfChars = numberOfChars || DEFAULT_TRUNCATE_CHARS;
		if (text.length > numberOfChars) {
			return (text.substring(0, numberOfChars) + "...");
		}
		return text;
	};

	function render(result, $selector, checked) {
		var selectionOptionGroup, $selectionOptionGroup, i, j, selectOption, $option;

		$selector.empty();

		for (i = 0; i < result.length; i++) {
			selectionOptionGroup = result[i];
			$selectionOptionGroup = $("<optgroup>", { label: i18n.message("project.label") + ": " + truncateText(selectionOptionGroup.name) });
			selectOptions = selectionOptionGroup.options;

			for (var j=0; j < selectOptions.length; j++) {

				selectOption = selectOptions[j];

				$option = $("<option>", { value : selectOption.id }).text(selectOption.value)

				if (checked.indexOf(selectOption.id) >= 0) {
					$option.attr("selected", "selected");
				}

				$selectionOptionGroup.append($option);
			}

			$selector.append($selectionOptionGroup);
		}
	};

	function getJSON(projectIds, queryUrl, $selector) {
		$.getJSON(queryUrl, { "projectIds[]" : $.isArray(projectIds) ? projectIds.join(",") : projectIds}).done(function(result) {
			var checked = [];

			$selector.multiselect("getChecked").each(function() {
				checked.push(this.value);
			});

			render(result, $selector, checked);

			$selector.multiselect("refresh");
		});
	};

	function getSelectOptionGroups(projectIds, queryUrl, selectorId) {
		getJSON(projectIds, queryUrl, $("#" + selectorId));
	};

	return {
		"getSelectOptionGroups": getSelectOptionGroups
	};

})(jQuery);