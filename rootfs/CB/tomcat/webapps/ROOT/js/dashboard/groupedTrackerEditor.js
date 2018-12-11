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
codebeamer.dashboard.groupedTrackerEditor = codebeamer.dashboard.groupedTrackerEditor || (function($) {
	var DEFAULT_TRUNCATE_CHARS = 60;

	function truncateText(text, numberOfChars) {
		numberOfChars = numberOfChars || DEFAULT_TRUNCATE_CHARS;
		if (text.length > numberOfChars) {
			return (text.substring(0, numberOfChars) + "...");
		}
		return text;
	};

	function getTrackersJSON(projectId, groupedTrackerUrl, $selector, selectedIds) {
		var data;

		data = {};

		data['proj_id'] = projectId;
		data['mode'] = "references";

		$.getJSON(groupedTrackerUrl, data).done(function(result) {
			var checked = [];

			if (selectedIds === undefined || selectedIds == null) {

				$selector.multiselect("getChecked").each(function() {
					checked.push(this.value);
				});
			} else {
				checked = selectedIds;
			}

			renderTrackers(result, $selector, checked);

			$selector.multiselect("refresh");
		});
	};

	function renderTrackers(result, $selector, checked) {
		$selector.empty();
		for (var i=0; i < result.length; i++) {
			var reference = false;
			var group = result[i];
			var $trackerGroup = $("<optgroup>", { label: truncateText(group.text) });
			var trackers = group.children;
			for (var j=0; j < trackers.length; j++) {
				var tracker = trackers[j];
				if (tracker.children !== undefined && tracker.children.length && tracker.children.length > 0) {
					reference = true;
					var $referenceGroup = $("<optgroup>", { label: truncateText(tracker.text) });
					for (var k = 0; k < tracker.children.length; ++k) {
						var trackerReference = tracker.children[k];

						var $option = $("<option>", {
							value : trackerReference.id,
						}).text(truncateText(trackerReference.text));

						if (checked.indexOf(trackerReference.id) >= 0) {
							$option.attr("selected", "selected");
						}

						$referenceGroup.append($option);
					}
					$selector.append($referenceGroup);
				} else {
					var $option = $("<option>", {
						value : tracker.id,
					}).text(truncateText(tracker.text));

					if (checked.indexOf(parseInt(tracker.id, 10)) >= 0) {
						$option.attr("selected", "selected");
					}

					$trackerGroup.append($option);
				}

			}
			if (!reference) {
				$selector.append($trackerGroup);
			}
		}
	};

	function getTrackers(projectId, groupedTrackerUrl, selectorId, selectedIds) {
		getTrackersJSON(projectId, groupedTrackerUrl, $("#" + selectorId), selectedIds);
	};

	return {
		"getTrackers": getTrackers
	};

})(jQuery);