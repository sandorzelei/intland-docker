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
codebeamer.dashboard.chartSelector = codebeamer.dashboard.chartSelector || (function($) {

	function init(getEditorUrl, dashboardId) {
		$(".chartSelector img").click(function(event) {
			var isDisabled = $(event.currentTarget).hasClass("disabled");

			if (!isDisabled) {
				var mode = $(event.currentTarget).data("chart-editor-rendering-mode");

				$("input[name*=chartEditorRenderingMode]").val(mode);

				$(".activeChart").removeClass("activeChart");

				$(event.currentTarget).addClass("activeChart");

				loadChartSpecificEditor(getEditorUrl, dashboardId, mode);
			}
		});

		 $("body").one("querySelector:query:changed", function(target, value) {
			initializeChartSelectorAndLoadEditor(value);
			codebeamer.dashboard.multiSelect.attachEventListener("querySelector:query:before:change", handleQueryChangeEvent);
		});

		codebeamer.dashboard.multiSelect.attachEventListener("querySelector:query:cleared", clearEditor);

		codebeamer.dashboard.updateFormAlignment();
	};

	function initializeChartSelectorAndLoadEditor(value) {
		if (value) {
			disableIncompatibleChartTypes(value.groupCount, value.groupedByDate);

			if ($(".activeChart").size() === 0) {
				$(".chartImage:not(.invisible)").first().click();
			}

		}
	}

	function loadChartSpecificEditor(getEditorUrl, dashboardId, mode) {
		$.get(getEditorUrl, {
				"dashboardId" : dashboardId,
				"widgetType": "com.intland.codebeamer.dashboard.component.widgets.chart.UniversalChartWidget",
				"incrementalRender": true,
				"subType": mode
		}).success(function(result) {
			clearEventListeners();

			$(".chartSpecificFields").empty().append(result);

			codebeamer.dashboard.updateFormAlignment();

			setTimeout(function() {
				if (codebeamer.dashboard.chartSelector.newWidget) {
					initializeDefaultNameProvider();
				}

				// This even has to be triggered, many editors depend on the query selector emiting the currently selected query.
				codebeamer.dashboard.storedQueryEditor.triggerStoredQueryEvent();
				codebeamer.dashboard.livePreview.refreshLivePreview();
			}, 100);
		});

	};

	function clearEditor() {
		clearEventListeners();
		$(".chartSpecificFields").empty();
		$(".livePreview").empty();

		$(".activeChart").removeClass("activeChart");
		$(".chartImage").each(function(index, element) {
			$(this).addClass("disabled");
		});

		$("input[name*=chartEditorRenderingMode]").val("");
	}

	function handleQueryChangeEvent(value) {
		clearEventListeners();

		if (value) {

			if (value.groupcount == 0 && value.groupedByDate == false) {
				clearEditor();
			} else {
				disableIncompatibleChartTypes(value.groupCount, value.groupedByDate);

				var $activeChart = $(".activeChart");
				if ($activeChart.size() > 0) {
					if ($activeChart.is(".disabled")) {
						// if the currently selected chart is not available for the current report type then unselect it
						$activeChart.removeClass("activeChart");
						$(".chartImage:not(.invisible)").first().click();
					} else {
						// otherwise reload the chart with the new query
						$activeChart.click();
					}
				} else {
					$(".chartImage:not(.invisible)").first().click();
				}

				// when a new query selected then set the title to the name of the query
				// but only when adding a new widget and until the user specified a custom title
				copyQueryNameToTitle(value);
			}

		}
	};

	/**
	 * when the selected query changes we set the widget name to the query name (but only until the name was changed manually by the user)
	 */
	function initializeDefaultNameProvider() {
		// when a new query selected then set the title to the name of the query
		// but only when adding a new widget and until the user specified a custom title
		$("body").on("querySelector:query:changed", function (target, value) {
			copyQueryNameToTitle(value);
		});
	}

	function copyQueryNameToTitle(value, forceUpdate) {
		if (value && value.hasOwnProperty("id")) {
			userSettings.save("LAST_SELECTED_QUERY_ID", value.id);
		}

		if (value && value.hasOwnProperty("name") && value.name) {
			var $title = $("input[name=title]");
			var currentValue = $title.val().trim();
			var updateTitle = forceUpdate || !$title.data("modified") || currentValue.length == 0;
			if (updateTitle) {
				$title.val(value.name);
				$title.data("currentValue", value.name);
				$title.data("queryId", value.id);

				if (forceUpdate) {
					// no the query name and the title is the same so we can pretend as if no name change happened before
					$title.data("modified", false);
				}
			}
		}
	}

	function getSelectedQueryName() {
		var result = $("#combinedValue").data("name");

		return result ? result : null;
	}

	function copySelectedQueryNameToTitle() {
		var id, name, data;

		id = $("#combinedValue").val();
		name = $("#combinedValue").data("name");

		if (id && name) {
			data = {
				id: id,
				name: name
			}

			copyQueryNameToTitle(data, true);
		}
	}

	function disableIncompatibleChartTypes(groupCount, isGroupyByDateSupported) {
		$(".chartImage").each(function(index, element) {
			var $chartImage, groupSupport, groupByDateSupport, shoulDisable;

			shoulDisable = true;

			$chartImage = $(element);

			// Avoid conversion of the content! (It can be 1 or 1,2 or 2, which convert to either a string or int.)
			groupSupport = $chartImage.attr("data-group-support");
			if (groupSupport) {
				shoulDisable = groupSupport.indexOf(parseInt(groupCount, 10)) < 0;
			}

			groupByDateSupport = $chartImage.data("group-by-date-support");
			if (isGroupyByDateSupported) {
				shoulDisable = shoulDisable && !groupByDateSupport;
			}

			if (shoulDisable) {
				$chartImage.addClass("disabled");
			} else {
				$chartImage.removeClass("disabled");
			}

		});
	};

	function clearEventListeners() {
		codebeamer.dashboard.multiSelect.removeEventListeners("querySelector:query:changed");
		codebeamer.dashboard.multiSelect.removeEventListeners("querySelector:advancedQuery:changed");
		codebeamer.dashboard.multiSelect.removeEventListeners("groupings:query:changed");
	};

	return {
		"init": init,
		"initializeDefaultNameProvider": initializeDefaultNameProvider,
		"initializeChartSelectorAndLoadEditor": initializeChartSelectorAndLoadEditor,
		'copySelectedQueryNameToTitle': copySelectedQueryNameToTitle,
		"getSelectedQueryName": getSelectedQueryName,
		"copyQueryNameToTitle": copyQueryNameToTitle
	};

})(jQuery);