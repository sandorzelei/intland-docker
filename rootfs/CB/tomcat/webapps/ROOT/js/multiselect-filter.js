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
codebeamer.multiselect = codebeamer.multiselect || (function($) {
	var showHideClearers = function () {
		$(".plannerTrackerSelector li.ui-multiselect-optgroup").each(function() {
			var $this = $(this);
			var $items = $this.nextUntil("li.ui-multiselect-optgroup").not(".ui-multiselect-disabled");
			var hasChecked = $items.find(":checkbox:checked").size() > 0;
			if (hasChecked) {
				$this.find(".optgroup-clearer").show();
			} else {
				$this.find(".optgroup-clearer").hide();
			}
		});
	};

	var showApplyButton = function () {
		$(".plannerTrackerSelector .ui-multiselect-header").show();
	};

	var init = function ($list, config) {
		var $list = $('#tracker-select');
		var multiselectConfig = {
			"header": i18n.message("button.apply"),
			"position": {"my": "left top", "at": "left bottom", "collision": "none none"},
			"classes": "plannerTrackerSelector",
			"create": function() {
				$list.multiselect("close");

				var $header = $(".plannerTrackerSelector .ui-multiselect-header");
				$(".plannerTrackerSelector.ui-multiselect-menu").append($header);
				$header.find("ul").addClass("button");
				$header.click(function() {
					if (config.filter) {
						config.filter();
					}
					$list.multiselect("close");
					$(".plannerTrackerSelector .ui-multiselect-header").hide();
				});

				$(".plannerTrackerSelector .ui-multiselect-checkboxes li label").each(function() {
					var $this = $(this);
					var $input = $this.find("input");

					$input.hide();

					var $checker = $("<div class='checker'>");
					$this.prepend($checker);

					$this.click(function(e) {
						var $this = $(this);
						var checker = $this.find(".checker");
						var input = $this.find("input");
						var wasChecked = input.is(":checked");

						input.prop("checked", !wasChecked);
						if (wasChecked) {
							input.removeAttr("checked");
						}
						checker.toggleClass("checked", !wasChecked);

						$list.multiselect("update");

						var $item = $(this).closest("li");

						showApplyButton();
						showHideClearers();

						return false;
					});
				});

				// prevent the select all/none operation on clicking the optgroup headers
				$(".plannerTrackerSelector  li.ui-multiselect-optgroup a").bind("click.multiselect", function (e) {
					e.stopPropagation();
				});
				$(".plannerTrackerSelector  li.ui-multiselect-optgroup").each(function() {
					var $groupHeader = $(this);
					var $clearer = $("<div>").addClass("optgroup-clearer ui-icon ui-icon-circle-close").attr("title", "Clear selection in this group");
					$groupHeader.append($clearer);
				});

				$(".plannerTrackerSelector  .optgroup-clearer").click(function() {
					var $header = $(this).parent();
					var $items = $header.nextUntil("li.ui-multiselect-optgroup").not(".ui-multiselect-disabled");
					$items.find(":checkbox:checked").parents("label").each(function () {
						$(this).click();
					});
					showApplyButton();
					$(this).hide();
				});

				// restore the selection status
				$list.find(":selected").each(function() {
					var val = $(this).val();
					$("input[value=" + val + "]").siblings(".checker").addClass("checked");
				});

				showHideClearers();
			},
			"selectedText": function(numChecked, numTotal, checked) {
				return $.map(checked, function(a) {
					return $(a).attr("title");
				}).join(", ");
			}
		};

		$.extend(multiselectConfig, config);

		$list.multiselect(multiselectConfig);
	};

	return {
		"init": init
	};
}(jQuery));