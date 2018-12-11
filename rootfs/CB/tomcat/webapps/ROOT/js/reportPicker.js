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
 */

var codebeamer = codebeamer || {};
codebeamer.ReportPicker = codebeamer.ReportPicker || (function($) {

	var loadingInProgress = false;
	var reportSelectorMode = false;

	var truncateText = function(text) {
		if (text.length > 60) {
			return (text.substring(0, 60) + "...");
		}
		return text;
	};

	var loadQueries = function(page) {
		if (loadingInProgress) {
			return;
		}
		var filter = $("#filter").val();
		var $pickerTab = $('#pickerTab');
		var sort = $pickerTab.data('sort');
		var dir = $pickerTab.data('dir');

		loadingInProgress = true;
		var busy = ajaxBusyIndicator.showBusysign($pickerTab);
		var $checkedOptions = $("#optionSelector").multiselect("getChecked");
		var checkedOptionIds = [];
		$checkedOptions.each(function() {
			checkedOptionIds.push($(this).val());
		});
		if (checkedOptionIds.length == 0) {
			checkedOptionIds.push(-1);
		}
		var data = {
			page: page || 1,
			filter: filter,
			sort: sort || 'name',
			dir: dir || 'asc',
			optionIds: checkedOptionIds.join(",")
		};
		if (reportSelectorMode) {
			data["reportMode"] = true;
		}
		$.ajax({
			method: 'POST',
			url: contextPath + "/proj/queries/pickerTable.spr",
			data: data
		}).done(function(data) {
			ajaxBusyIndicator.close(busy);
			$('#pickerTab').html(data);
			$("#filter").focus();
			checkSelectedItem();
			loadingInProgress = false;
		}).fail(function() {
			ajaxBusyIndicator.close(busy);
			$("#filter").focus();
			loadingInProgress = false;
		});
	};

	var loadQueriesThrottled = throttleWrapper(loadQueries, 500);

	var initOptionSelector = function() {

		var multiselectOptions = {
			classes: "optionSelector",
			minWidth: 200,
			menuWidth: 300,
			checkAllText : "",
			uncheckAllText: "",
			menuHeight: "auto",
			height: 300,
			selectedText: function(numChecked, numTotal, checkedItems) {
				var value = [];
				var $checkedItems = $(checkedItems);
				$checkedItems.each(function(){
					var valueString = $(this).next().html();
					value.push(valueString);
				});
				var joinedText = value.join(", ");
				return truncateText(joinedText);
			},
			create: function() {
				$(".optionSelector .ui-multiselect-all").closest("ul").remove();
			},
			open: function() {
				var $widget = $(this).multiselect("widget");
				var $button = $(this).multiselect("getButton");
				$widget.position({
					my: "left top",
					at: "left bottom",
					of: $button,
					collision: "flipfit",
					using : null,
					within: window
				});
				setTimeout(function() {
					$widget.find(".ui-multiselect-filter input").focus();
				}, 100);
			},
			click: function(event, ui) {
				var $menu = $("#optionSelector").multiselect("widget");
				if (ui.value != "on") {
					if (ui.checked) {
						if (ui.value == 0) {
							$menu.find(":checkbox:checked").each(function () {
								var $that = $(this);
								if ($that.val() != 0 && $that.val() != -1) {
									$that.attr("checked", false);
								}
							});
						} else if (ui.value != -1) {
							$menu.find("[value=0]").attr("checked", false);
						}
					}
				}
				loadQueriesThrottled();
			}
		};

		$("#optionSelector").multiselect(multiselectOptions).multiselectfilter({
			label: "",
			placeholder: i18n.message("Filter")
		});

	};

	var writeBackReport = function(referencesRendered) {
		if (parent.document) {
			var openerDoc = parent.document;
			var openerRefHTML = openerDoc.getElementById("referencesForLabel_" + $("input[name='opener_htmlId']").val());
			if (openerRefHTML && openerRefHTML.reinitAjaxReferenceControl != null) {
				openerRefHTML.reinitAjaxReferenceControl(referencesRendered);
			}
		}
		inlinePopup.close();
	};

	var initReportSelectorButtons = function() {
		$("input[name='setButton']").click(function() {
			var reportId = null;
			$(".reportSelectorRadio").each(function() {
				if ($(this).is(":checked")) {
					reportId = $(this).val();
					return false;
				}
			});
			if (reportId) {
				var $row = $("#pickerTab").find("[data-id='" + reportId + "']");
				writeBackReport([{
					id: "5-" + reportId,
					value: "5-" + reportId,
					shortHTML: $row.attr("data-name"),
					label: $row.attr("data-name")
				}]);
			} else {
				writeBackReport([]);
			}
		});

		$("input[name='clearButton']").click(function() {
			writeBackReport([]);
		});
	};

	var checkSelectedItem = function() {
		if (reportSelectorMode) {
			$(".reportSelectorRadio").each(function() {
				if ($(this).val() == $("input[name='selectedItem']").val()) {
					$(this).prop("checked", true);
				}
			})
		}
	};

	var initLinks = function() {
		$('#pickerTab').on('click', '.pagelinks>a', function(e) {
			e.preventDefault();
			var nextLocation = $(e.target).attr('href');
			var pageParam = codebeamer.ReportSupport.getParamFromUrl(nextLocation, "page");
			loadQueries(pageParam);
		});

		$('#pickerTab').on('click', 'th>a', function(e) {
			e.preventDefault();
			var nextLocation = $(e.target).attr('href');
			var linkSortParam = codebeamer.ReportSupport.getParamFromUrl(nextLocation, "sort");

			var $pickerTab = $('#pickerTab');
			var currentSort = $pickerTab.data('sort');
			var currentDir = $pickerTab.data('dir');
			var dir = currentSort === linkSortParam && currentDir === 'asc' ? 'desc' : 'asc';

			$pickerTab.data('sort', linkSortParam);
			$pickerTab.data('dir', dir);
			loadQueries(1);
		});

		$("#pickerTab").on("click", ".query-link", function(e) {
			e.preventDefault();
			window.parent.location.href = $(this).attr("href");
			inlinePopup.close();
		});
	};

	var initFilter = function() {
		$("#filter").keyup(function(event) {
			var length = $(this).val().length;
			if (event.keyCode == 27) {
				closePopupInline();
			} else if (length == 0 || length > 1) {
				loadQueriesThrottled();
			}
		});
		setTimeout(function() {
			$("#filter").focus();
		}, 200);
	};

	var init = function() {
		reportSelectorMode = $("input[name='reportSelectorMode']").val();
		initOptionSelector();
		if (reportSelectorMode) {
			initReportSelectorButtons();
			checkSelectedItem();
		}
		initFilter();
		initLinks();
	};

	return {
		"init": init
	};

})(jQuery);

