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
codebeamer.dashboard.queryField = codebeamer.dashboard.queryField || (function($) {
	function processGroupingData(data, selectorId, currentValue) {
		var groupSelect = $("#" + selectorId);
		if (data) {
			for (key in data) {
				var option = $("<option>", {value: key});
				if (key == currentValue) {
					option.attr("selected", "selected");
				}
				option.html(data[key]);
				groupSelect.append(option);
			}
		}
	}

	function loadGroupingsById(queryId, selectorId, queryOptionsUrl, currentValue, trigger) {
		var groupSelect = $("#" + selectorId);

		groupSelect.empty();

		$.get(contextPath + queryOptionsUrl, {
			queryId: queryId
		}).success(function (data) {
			processGroupingData(data, selectorId, currentValue);
			if (trigger) {
				$("body").trigger("groupings:query:changed", $("#" + selectorId).val());
			}
		});
	}

	function loadGroupingsByQuery(query, selectorId, queryStringOptionsUrl, currentValue, trigger) {
		var groupSelect = $("#" + selectorId);

		groupSelect.empty();

		$.get(contextPath + queryStringOptionsUrl, {
			query: query
		}).success(function (data) {
			processGroupingData(data, selectorId, currentValue);
			if (trigger) {
				$("body").trigger("groupings:query:changed", $("#" + selectorId).val());
			}
		});
	}

	return {
		"loadGroupingsByQuery": loadGroupingsByQuery,
		"loadGroupingsById": loadGroupingsById
	};
})(jQuery);
