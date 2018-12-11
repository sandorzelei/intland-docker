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
codebeamer.dashboard.storedQuery = codebeamer.dashboard.storedQuery || (function($) {

	function getQueriesJSON(reloadQueriesUrl, queryFilterType, $selector) {
		$.getJSON(reloadQueriesUrl, { "queryFilterType" : queryFilterType}).done(function(result) {

			var checked = [];

			$selector.multiselect("getChecked").each(function() {
				checked.push(this.value);
			});

			renderQueries(result, $selector, checked);

			$selector.multiselect("refresh");

			// update the titles
			$(".ui-multiselect-disabled ").each(function () { var t = $(this).find("label"); $(this).attr("title", t.attr("title"));})

			// show the appropriate hint
			var hint = i18n.message("widget.editor.disabled.value." + queryFilterType + ".title");
			var $hintBox = $("#query-id-hint .hint");
			$hintBox.html(hint);
			$hintBox.show();
		});
	}

	function renderQueries(result, $selector, checked) {
		$selector.empty();
		for (var i=0; i < result.length; i++) {
			var optgr = result[i];
			var $htmlGroup = $("<optgroup>", { label: i18n.message(optgr.name) });
			var queries = optgr.options;
			for (var j=0; j < queries.length; j++) {
				var query = queries[j];
				var text = i18n.message(query.value);
				var $option = $("<option>", {
					value : query.id
				}).text(text);

				if (query.disabled) {
					$option.attr("disabled", "disabled");
				}

				if (query.title) {
					$option.attr("title", i18n.message(query.title));
				}

				if (checked.indexOf(query.id) >= 0 && !query.disabled) {
					$option.attr("selected", "selected");
				}

				if (query.hasOwnProperty("groupCount")) {
					$option.attr("data-group-count", query.groupCount);
				} else {
					$option.attr("data-group-count", -1);
				}

				if (query.hasOwnProperty("groupedByDate")) {
					$option.attr("data-group-by-date", query.groupedByDate);
				} else {
					$option.attr("data-group-by-date", false);
				}

				$htmlGroup.append($option);
			}
			$selector.append($htmlGroup);

		}

		// trigger the change event on the query selector to keep the combined value actual
		$selector.trigger("change");
	}

	function reloadQueries(reloadQueriesUrl, queryFilterType, selectorId) {
		getQueriesJSON(reloadQueriesUrl, queryFilterType, $("#" + selectorId));
	}

	function clickOnCheckedOption(selectorId) {
		$($("#" + selectorId).multiselect("getChecked")).click();
	}

	return {
		"reloadQueries": reloadQueries,
		"clickOnCheckedOption": clickOnCheckedOption
	};
})(jQuery);
