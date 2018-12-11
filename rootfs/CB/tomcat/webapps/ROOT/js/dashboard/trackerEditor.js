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
codebeamer.dashboard.trackerEditor = codebeamer.dashboard.trackerEditor || (function($) {
	var DEFAULT_TRUNCATE_CHARS = 60;

	function truncateText(text, numberOfChars) {
		numberOfChars = numberOfChars || DEFAULT_TRUNCATE_CHARS;
		if (text.length > numberOfChars) {
			return (text.substring(0, numberOfChars) + "...");
		}
		return text;
	};

	function getTrackersJSON(projectIds, trackerTypeIds, trackerQueryUrl, $selector) {
		var data;

		data = {};

		data['project_id_list'] = $.isArray(projectIds) ?  projectIds.join(",") : projectIds;

		if (trackerTypeIds) {
			data['tracker_type'] = $.isArray(trackerTypeIds) ?  trackerTypeIds.join(",") : null;
		}

		$.getJSON(trackerQueryUrl, data).done(function(result) {
			var checked = [];

			$selector.multiselect("getChecked").each(function() {
				checked.push(this.value);
			});

			renderTrackers(result, trackerTypeIds, $selector, checked);

			$selector.multiselect("refresh");
		});
	};

	function renderTrackers(result, trackerTypeIds, $selector, checked) {
		$selector.empty();
		for (var i=0; i < result.length; i++) {
			var project = result[i];
			var $projectGroup = $("<optgroup>", { label: i18n.message("project.label") + ": " + truncateText(project.name) });
			var trackers = project.trackers;
			for (var j=0; j < trackers.length; j++) {
				var tracker = trackers[j];
				if (!tracker.hidden ) {

					var $option = $("<option>", {
						value : tracker.id,
						"data-hidden":  tracker.hidden,
					}).text(truncateText(tracker.name));

					if (checked.indexOf(tracker.id) >= 0) {
						$option.attr("selected", "selected");
					}

					$projectGroup.append($option);

				}
			}
			$selector.append($projectGroup);
		}
	};

	function getTrackers(projectIds, trackerTypeIds, trackerQueryUrl, selectorId) {
		getTrackersJSON(projectIds, trackerTypeIds, trackerQueryUrl, $("#" + selectorId));
	};

	return {
		"getTrackers": getTrackers
	};

})(jQuery);