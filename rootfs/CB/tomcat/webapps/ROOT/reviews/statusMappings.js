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
(function ($) {
	INVALID_MAPPING_CLASS = "invalid-mapping";

	$("#rejectedStatusIds,#approvedStatusIds").multiselect({
		"header": "Apply",
		"height": "auto",
		"position": {"my": "left top", "at": "left bottom", "collision": "none none"},
		"selectedText": function(numChecked, numTotal, checked) {
			return $.map(checked, function(a) {
				return $(a).attr("title");
			}).join(", ");
		}
	}).multiselectfilter({
		label: "",
		placeholder: i18n.message("Filter")
	});

	var decodeTrackerId = function (encoded) {
		return encoded.split("-")[0];
	};

	var getCheckedTrackerIds = function (listSelector) {
		var approvedIds = $(listSelector).multiselect("getChecked");
		var approvedTrackerIds = $.unique(approvedIds ? approvedIds.map(function () { return decodeTrackerId($(this).val());}).toArray() : []);
		return approvedTrackerIds;
	};

	var setUpSpecialMultiselectEvents = function (selector) {
		$(selector).multiselect("widget").on("change", "input[type=checkbox]", function (event, ui) {
			var $this = $(this);
			if ($this.is(":checked")) {
				var trackerId = decodeTrackerId($this.val());
				// when a status was checked uncheck its siblings. only one item can be selected in an optgroup
				var $li = $(this).closest("li");

				var $siblings = $li.siblings().find("input[type=checkbox]");

				// filter the li elements for which the value starts with the same tracker id
				$siblings = $siblings.filter("input[value^=" + trackerId + "]:checked")
				$siblings.click();
			}

			checkTrackerSelections();
		});
	};

	/**
	 * checks if based on the status selections and the actions selected for the items the status updates
	 * will respect the tracker transitions or not.
	 */
	var validateStatusMappings = function () {
		var $form = $("#completeReviewForm");
		var params = $form.serialize();

		var url = contextPath + "/ajax/review/validateStatuses.spr?" + params;

		$.get(url).done(function (data) {
			// data is a list of ids of the valid status mappings
			var validIdSelectors = data.map(function (id) { return "#" + id;}).join(",");

			var $invalidSelectLists = $("select.mapper:not(.DoNotChange)").not(validIdSelectors);

			// mark the closest tr-s as invalid
			$("." + INVALID_MAPPING_CLASS).removeClass(INVALID_MAPPING_CLASS);
			$invalidSelectLists.closest("tr").addClass(INVALID_MAPPING_CLASS);

			// if there are any invalid mappings then show the warning
			var anyInvalid = $("." + INVALID_MAPPING_CLASS).size() > 0;
			$("#invalid-mappings-warning").toggle(anyInvalid);
		});
	};

	var checkTrackerSelections = function () {
		// check if two statuses are selected for each tracker

		// get all checked approved and rejected ids
		var approvedTrackerIds = getCheckedTrackerIds("#approvedStatusIds");
		var rejectedTrackerIds = getCheckedTrackerIds("#rejectedStatusIds");

		// list of all tracker ids on the page
		var trackerIds = $.unique($("option[data-tracker-id]").map(function () {
			return $(this).data("trackerId");
		}));

		var configuredTrackerCount = 0; // counts the trackers for which both statuses are selected
		for (var i = 0; i < trackerIds.length; i++) {
			// get the approved and rejected ids for this tracker
			var trackerId = trackerIds[i];

			// if there is no rejected or approved status selected for the tracker then disable all status changers
			if (!approvedTrackerIds.contains(trackerId) || !rejectedTrackerIds.contains(trackerId)) {
				$(".action[data-tracker-id=" + trackerId + "]").addClass("disabled");
			} else {
				$(".action[data-tracker-id=" + trackerId + "]").removeClass("disabled");
				configuredTrackerCount += 1;
			}
		}

		// if all trackers are configured properly enable the "Finish Review" button
		var $button = $("button[name=status]");
		if (trackerIds.length == configuredTrackerCount) {
			$button.prop("disabled", false);
		} else {
			$button.prop("disabled", true);
		}
	};

	setUpSpecialMultiselectEvents("#rejectedStatusIds");
	setUpSpecialMultiselectEvents("#approvedStatusIds");

	checkTrackerSelections();

	$(document).on("change", "select.mapper,#approvedStatusIds,#rejectedStatusIds,#executeOnlyValidTransitions", function () {
		var $select = $(this);
		$select.removeClass("DoNotChange SetToApproved SetToRejected");
		$select.addClass($select.val());

		// re-validate the status mappings every time the user changes one action
		validateStatusMappings();
	});

	validateStatusMappings();
}(jQuery));