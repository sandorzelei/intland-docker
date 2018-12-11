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
 *
 * $Revision$ $Date$
 */

(function($) {

	var $multiselect;

	function clearFilter() {
		var $allListElements = $('.versionFilterMenu .ui-multiselect-checkboxes > li:not(.versionFilterMenu .ui-multiselect-optgroup,.filter)');
		$allListElements.show();
		$("#optionFilter").val("");
	};

	function showApplyButton() {
		$(".versionFilterMenu .ui-multiselect-header").show();
	};

	function showHideClearers() {
		$("versionFilterMenu .li.ui-multiselect-optgroup").each(function() {
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

	function selectOne(value, cssClass) {
		$multiselect.multiselect("widget").find("." + cssClass + " :checkbox:checked").each(function() {
			var $this = $(this);
			if ($this.val() != value && $this.is(":checked")) {
				$this.attr("checked", false);
				$this.siblings(".checker").removeClass("checked");
			}
		});
	};

	function getSelectedValues() {
		var selectedClasses;

		selectedClasses = [];

		$multiselect.multiselect("getChecked").each(function() {
			if (this.value) {
				selectedClasses.push(this.value);
			}
		});

		return selectedClasses;
	}

	function publishFilterState() {
		var selectedValues, i, newState;

		selectedValues = getSelectedValues();
		newState = {};

		if (selectedValues.length > 0) {
			for(i = 0; i < selectedValues.length; i++) {
				switch(selectedValues[i]) {
					case "resolvedOrClosed": newState.status = "resolvedOrClosed";
						break;
					case "closed": newState.status = "closed";
						break;
					case "resolved": newState.status = "resolved";
						break;
					case "open": newState.status = "open";
		             	break;
					case "overdue": newState.status = "overdue";
						break;
					case "overtime": newState.status = "overtime";
						 break;
					case "default": newState.testRunVisibility = "default";
	                    break;
					case "test_runs_only": newState.testRunVisibility = "test_runs_only";
						break;
					case "all_tracker_items": newState.testRunVisibility = "all_tracker_items";
						break;
                    default: break;
				}

			}

			$(document).trigger("release:filter:update", [newState]);
		}
	}

	function applyFilters() {
		var selectedClasses, $rows;

		selectedClasses = getSelectedValues();

		// show/hide the rows matching with the filter
		$rows = $("#versionsPlaceholder").find("table.issuelist tr");
		$rows.each(function(i, el) {
			var show, i;

			show = true;

			for (i = 0; i < selectedClasses.length; i++) {
				show = show && $(this).hasClass(selectedClasses[i]);
			}

			$(this).toggle(show);
		});
	};

	$(document).ready(function() {

		$multiselect = $(".filterMenu>select");

		$multiselect.multiselect({
			"classes" : "versionFilterMenu",
			"header": i18n.message("button.apply"),
			"position": {"my": "left top", "at": "left bottom", "collision": "none none"},
			"height": 245,
			"close": function () {
				clearFilter();
			},
			"open": function () {
				$("#optionFilter").focus();
			},
			"create": function() {
				// move the header to the bottom
				var $header = $(".versionFilterMenu .ui-multiselect-header");
				$(".versionFilterMenu.ui-multiselect-menu").append($header);
				$header.find("ul").addClass("button");
				$header.click(function() {
					$multiselect.multiselect("close");
					$(".versionFilterMenu .ui-multiselect-header").hide();
					publishFilterState();
				});
				$multiselect.multiselect("close");

				$(".versionFilterMenu .ui-multiselect-checkboxes li label").each(function() {
					var $this = $(this);
					$this.find("input").hide().click(function() {
						return false;
					});

					var $checker;
					if ($this.find("input:checked").length > 0) {
						$checker = $("<div class='checker checked'>");
					} else {
						$checker = $("<div class='checker'>");
					}

					$this.prepend($checker);

					$this.click(function(e) {
						var $this = $(this);
						var checker = $this.find(".checker");
						var input = $this.find("input");
						var wasChecked = input.is(":checked");
						input.attr("checked", !wasChecked);
						checker.toggleClass("checked", !wasChecked);

						showApplyButton();
						var uniqueSelectClasses = ["testRun", "status"];
						var $item = $this.closest("li");
						$.each(uniqueSelectClasses, function () {
							var cl = this;
							if ($item.hasClass(cl)) {
								selectOne(input.val(), cl);
							}
						});

						showHideClearers();

						$multiselect.multiselect("update");

						return false;
					});
				});

				// prevent the select all/none operation on clicking the optgroup headers
				$(".versionFilterMenu li.ui-multiselect-optgroup a").bind("click.multiselect", function (e) {
					e.stopPropagation();
				});
				$(".versionFilterMenu li.ui-multiselect-optgroup").each(function() {
					var $groupHeader = $(this);
					var $clearer = $("<div>").addClass("optgroup-clearer ui-icon ui-icon-circle-close").attr("title", "Clear selection in this group");
					$groupHeader.append($clearer);
				});

				$(".versionFilterMenu .optgroup-clearer").click(function() {
					var $header = $(this).parent();
					var $items = $header.nextUntil("li.ui-multiselect-optgroup").not(".ui-multiselect-disabled");
					$items.find(":checkbox:checked").closest("label").click();
					showApplyButton();
					$(this).hide();
				});

				showHideClearers();

				// add the filter box for options
				var li = $("<div>").addClass("filter").append($("<input>").attr("type", "text").attr("id", "optionFilter"));
				li.append($("<div>").addClass("ui-icon ui-icon-circle-close"));
				$(".versionFilterMenu.ui-multiselect-menu").prepend(li);

				$("#optionFilter").keyup(function () {
					var searchText = $(this).val().toLowerCase();
					filterList('.ui-multiselect-checkboxes > li:not(.ui-multiselect-optgroup,.filter)', searchText);
				});

				$("div.filter .ui-icon").click(clearFilter);

			},
			"selectedText": function(numChecked, numTotal, checked) {
				return $.map(checked, function(input) {
					return $(input).attr("title");
				}).join(", ");
			}
		});
	});

})(jQuery);
