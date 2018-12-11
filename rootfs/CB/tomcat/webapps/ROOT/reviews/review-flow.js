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
codebeamer.review = codebeamer.review || (function($) {
	var config = {};

	var initFlow = function (options) {
		config = $.extend(config, options);
		setUpEventHandlers();

	};

	/**
	 * initializes the necessary event handlers for the flow of creating a new merge request.
	 */
	var initMergeRequestFlow = function (config) {
		$(document).ready(function () {
			// initialize the project selector and set it to emit the codebeamer:projectChanged event
			codebeamer.dashboard.multiSelect.initSingleSelect("project", "codebeamer:projectChanged");
			codebeamer.dashboard.multiSelect.initSingleSelect("targetTrackerId", "codebeamer:trackerChanged");

			var $projectSelector = $("#project");
			$("body").on("codebeamer:projectChanged", function (event, values) {
				if (values == null) {
					return;
				}
				// whenever the project selection changes refresh the tracker list
				updateDependentList([values, "false", "true", config.selected.trackerIds ? config.selected.trackerIds : []],
						"/ajax/review/getAvailableTrackers.spr", "targetTrackerId",
						["projectIds", "onlyWithWritePermission", "includeBranches", "excludedIds"], [config.selected.targetTrackerId]);
			}).trigger("codebeamer:projectChanged", [$projectSelector.val()]);


			$("body").on("codebeamer:trackerChanged", function (event, values) {
				var isBranchSelected = $("#targetTrackerId [value=" + values + "]").is('.branchTracker');
				$("#sendOnlySuspected").prop("disabled", isBranchSelected);
			});
		});
	};

	var setUpEventHandlers = function () {
		$(document).ready(function () {
			codebeamer.dashboard.multiSelect.init("trackerIds", "codebeamer:trackerChanged");
			codebeamer.dashboard.multiSelect.init("releaseIds");
			codebeamer.dashboard.multiSelect.initSingleSelect("baselineId");
			codebeamer.dashboard.multiSelect.init("project", "codebeamer:projectChanged");
			//$("#project").multiselect("uncheckAll");
			codebeamer.dashboard.multiSelect.initSingleSelect("cbqlId");

			$(document).on("click", "[name=reviewType]", function () {
				var $radio = $(this);
				toggleTypeSelectors($radio);
			});

			// if there are selected projet already then trigger the project changed event so that the dependent fields get updated
			var $projectSelector = $("#project");
			if ($projectSelector.multiselect("getChecked").length) {
				// on the first loading reselect the eventually selected items (that come from the request)
				$projectSelector.one("codebeamer:projectChanged", function (event, values) {
					updateDependentList([values, true], "/ajax/review/getAvailableTrackers.spr", "trackerIds", ["projectIds", "includeBranches"], config.selected.trackerIds);
					updateDependentList(values, "/ajax/review/getAvailableReleases.spr", "releaseIds", "projectIds", config.selected.releaseIds);
					updateDependentList(values, "/ajax/review/getAvailableBaselines.spr", "baselineId", "projectIds", config.selected.baselineId, "None");

				});

				var projectIds = [];
				$projectSelector.multiselect("getChecked").each(function () {projectIds.push(this.value);});
				$projectSelector.trigger("codebeamer:projectChanged", [projectIds]);
			}

			// update the tracker and release selectors when a new project is selected
			$(document).on("codebeamer:projectChanged", function (event, values) {
				updateDependentList([values, true], "/ajax/review/getAvailableTrackers.spr", "trackerIds", ["projectIds", "includeBranches"]);
				updateDependentList(values, "/ajax/review/getAvailableReleases.spr", "releaseIds", "projectIds", config.selected.releaseIds);
				updateDependentList(values, "/ajax/review/getAvailableBaselines.spr", "baselineId", "projectIds", config.selected.baselineId, "None");

			});

			// update the tracker and release selectors when a new project is selected
			$(document).on("codebeamer:trackerChanged", function (event, values) {
				var projectIds = [];
				$projectSelector.multiselect("getChecked").each(function () {projectIds.push(this.value);});
				updateDependentList([projectIds, values], "/ajax/review/getAvailableBaselines.spr", "baselineId", ["projectIds", "trackerIds"]);
			});


			var $reviewType = $("[name=reviewType][checked]");
			toggleTypeSelectors($reviewType);
		});
	};

	var toggleTypeSelectors = function ($radio) {
		$("#trackerReview-field,#releaseReview-field,#reportReview-field").hide();

		var checked = $radio.val();
		$("#" + checked + "-field").show();

		var isReportReview = checked === 'reportReview';
		var isTrackerReview = checked === 'trackerReview';
		$(".projectField").toggle(!isReportReview);

		$(".fromBaselineDiffField").toggle(isTrackerReview);
	};


	function updateDependentList(values, listUrl, listId, fieldName, selectedValues, noneLabel) {
		var data = {};
		if (fieldName.constructor == Array) {
			// when passing multiple parameter lists
			for (var i = 0; i < fieldName.length; i++) {
				data[fieldName[i]] = values[i].constructor == Array ? values[i].join(",") : values[i];
			}
		} else {
			var ids = values.constructor == Array ? values.join(",") : values;

			data[fieldName] = ids;
		}

		var $select = $("#" + listId);

		var selectedIds = [];
		if (selectedValues) {
			selectedIds = selectedValues;
		} else {
			$select.multiselect("getChecked").each(function () {selectedIds.push(this.value);});
		}

		$.get(contextPath + listUrl, data).done(function (data) {

			$select.empty();

			if (noneLabel) {
				var $noneOption = $("<option>", {value: 0}).html(i18n.message(noneLabel));
				$select.append($noneOption);
			}

			for (var key in data) {
				var $group = $("<optgroup>").attr('label', $("<div>").html(key).text());

				for (var i = 0; i < data[key].length; i++) {
					var $option = $("<option>", {value: data[key][i].id}).html(data[key][i].name);

					if (data[key][i]["branch"]) {
						$option.addClass("branchTracker");
						$option.addClass("level-" + data[key][i]['level'] );
					}

					$group.append($option);
				}

				$select.append($group);
			}


			// reselect the values
			$select.val(selectedIds);

			$select.multiselect("refresh");

		}).error(function () {
			showOverlayMessage("Error while loading the trackers", 5, true);
		});
	}

	return {
		"initFlow": initFlow,
		"initMergeRequestFlow": initMergeRequestFlow
	};

})(jQuery);