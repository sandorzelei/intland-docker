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
codebeamer.dashboard.dateRangeEditor = codebeamer.dashboard.dateRangeEditor || (function($) {

	function initialize(selectorId, hiddenFieldId, existingFromDate, existingToDate) {

		jQuery(function($) {

			var $dateField, $hiddenInputField;

			$dateField = $("#" + selectorId);
			$hiddenInputField = $("#" + hiddenFieldId);

			function updateHiddenInputField() {
				var newRange = {
						from: $dateField.data("fromDate"),
						to: $dateField.data("toDate"),
				};

				$hiddenInputField.val(JSON.stringify(newRange));
				$hiddenInputField.trigger("change");
			}

			function selectCallback($container, $selectedOption, $fromDateInput, $toDateInput) {
				var $rangeSpan = $container.find(".range");
				var $fromDateSpan = $container.find(".fromDate");
				var $toDateSpan = $container.find(".toDate");
				if ($selectedOption.val() == "custom") {
					$rangeSpan.text("");
					if ($fromDateInput.val().length > 0) {
						$fromDateSpan.text(" " + i18n.message("query.condition.widget.from") + " " + $fromDateInput.val());
					} else {
						$fromDateSpan.text("");
					}
					if ($toDateInput.val().length > 0) {
						$toDateSpan.text(" " + i18n.message("query.condition.widget.to") + " " + $toDateInput.val());
					} else {
						$toDateSpan.text();
					}
				} else {
					$rangeSpan.text(" " + $selectedOption.text());
					$fromDateSpan.text("");
					$toDateSpan.text("");
				}

				updateHiddenInputField();
			};

			function dateInputChangeCallback($container, $fromDateInput, $toDateInput) {
				$container.find(".range").text("");
				if ($fromDateInput.val().length > 0) {
					$container.find(".fromDate").text(" " + i18n.message("query.condition.widget.from") + " " + $fromDateInput.val());
				} else {
					$container.find(".fromDate").text("");
				}
				if ($toDateInput.val().length > 0) {
					$container.find(".toDate").text(" " + i18n.message("query.condition.widget.to") + " " + $toDateInput.val());
				} else {
					$container.find(".toDate").text("");
				}

				updateHiddenInputField();
			};

			$dateField.dateRangeSelector({
				id: selectorId,
				existingFromDate: existingFromDate,
				existingToDate: existingToDate,
				selectCallback: selectCallback,
				fromDateInputCallback: dateInputChangeCallback,
				toDateInputCallback: dateInputChangeCallback
			});

		});
	};

	return {
		"initialize": initialize
	};

})(jQuery);