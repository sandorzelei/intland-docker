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

/**
 * Javascript for coverage.jsp
 */
function updatePermanentLink() {
	var url = getFilteredUrl();

	// update the permanent link
	var $link = $("#permalink");
	$link.attr("href", url);

	var $exportToWord = $("#exportToWord");
	var exportToWordUrl = contextPath + "/trackers/coverage/" + codebeamer.coverage.exportUrl + getUrlParams();
	$exportToWord.attr("onclick", "showPopupInline('" + exportToWordUrl + "')");

	// update the browser's url bar so refresh will work (at least in FF/Chrome)
	History.pushState({"url": url}, document.title, url);
}

function getSelectedIds(selectId) {
	var $select = $(selectId);
	if (!isMultiselectInitialized($select)) {
		return [];
	}
	return $(selectId).multiselect("getChecked").map(function() {
		return $(this).val();
	}).toArray().join();
}

function isMultiselectInitialized($select) {
	return !!$select.data('ech-multiselect');
}

function getUrlParams() {
	var requirementStatusIds = getSelectedIds("#filterByStatus");
	var testCaseTypes = getSelectedIds("#filterByTestCaseType");
	var configurationIds = getSelectedIds("#configurationSelector");
	var requirementReleases = getSelectedIds("#requirementReleaseSelector");
	var assigneeIds = [];
	var selectedAssignees = $("#dynamicChoice_references_assigneeIds").val();
	if (selectedAssignees) {
		assigneeIds = selectedAssignees.split(",").map(function (a, b) {return a.split("-")[1];})
	}
	var filterTrackerIds = getSelectedIds("#filterTrackerIds");

	var serialized = $("#advancedFilterForm  :input[value!=''],#build,#lastRunTo,#lastRunFrom")
		.not("[name=_assigneeIds],[name=_configurationIds],[name=_requirementStatuses],[name=_requirementReleases],[name=_filterTrackerIds],[name=_testCaseType]").serialize(); // excluding empty fields and some others
	var params = "?" + serialized
		+ (requirementStatusIds.length == 0 ? "" : "&requirementStatuses=" + requirementStatusIds)
		+ (configurationIds.length == 0 ? "" : "&configurationIds=" + configurationIds)
		+ (requirementReleases.length == 0 ? "" : "&requirementReleases=" + requirementReleases)
		+ (assigneeIds.length == 0 ? "" : "&assigneeIds=" + assigneeIds)
		+ (filterTrackerIds.length == 0 ? "" : "&filterTrackerIds=" + filterTrackerIds)
		+ (testCaseTypes.length == 0 ? "" : "&testCaseTypes=" + testCaseTypes);
	var $trackerSelector = $("[name=trackerSelector]");
	if ($trackerSelector.size() > 0 && isMultiselectInitialized($trackerSelector)) {
		var $selected = $trackerSelector.multiselect("getChecked");
		var $option = $trackerSelector.find("option[value=" + $selected.val() + "]");
		var isBranch = $option.is('.branchTracker');

		params += "&tracker_id=" + (isBranch ? $option.data('trackerId') : $selected.val());
		var view = $("#viewSelector").val();
		if (view) {
			params += "&testRunViewId=" + view;
		}

		if (isBranch) {
			params += "&branchId=" + $selected.val();
		}
	} else {
		params += "&task_id=" + $("#releaseSelector").val();
	}

	var $referringTrackerSelector = $("[name=referringTracker]");
	if ($referringTrackerSelector.size() > 0) {
		var referringTrackerIds = getSelectedIds("[name=referringTracker]");
		params += "&referringTrackerIds=" + referringTrackerIds;
	}

	var $referringTestCaseTrackerSelector = $("[name=referringTestCaseTracker]");
	if ($referringTestCaseTrackerSelector.size() > 0 && isMultiselectInitialized($referringTestCaseTrackerSelector)) {
		var $selected = $referringTestCaseTrackerSelector.multiselect("getChecked");

		if ($selected && $selected.val()) {
			params += "&referringTestCaseTrackerId=" + $selected.val();
		}
	}

	params += "&showColors=" + $("#showColors").is(":checked");
	params += "&combineWithOr=" + $("#combineWithOr").is(":checked");
	params += "&hideIncomplete=" + $("#hideIncomplete").is(":checked");

	return params;
}

function getFilteredUrl() {
	var url = location.pathname + getUrlParams();
	return url;
}

function loadCoverageBrowser() {
	location.href = getFilteredUrl();
}

// initialize the tooltips on page load for the project subtotals
$(document).ready(function () {
	$(document).tooltip({
	    show: 300,
	    items: ".project-subtotal-label.tooltip-trigger",
		tooltipClass: 'trackerItemUrl-ui-tooltip',
		position: {my: "right top", at: "left-5 top", collision: "flipfit flipfit"},
	    content: function() {
	    	return $(this).next(".project-description-container").html();
	    }
	});
});

var codebeamer = codebeamer || {};
codebeamer.coverage = codebeamer.coverage || (function($) {
	var config = {};
	var exportUrl;

	var init = function(options) {
		config = options;
		codebeamer.coverage.exportUrl = config.exportUrl;
		setUpEventHandlers();
		setUpAccordion();
		setUpMultiselect();
		initContextHelps();

		initFieldHighlighters();
	};

	/*
	 * initializes the highlighter buttons that on click open the filter box and highlight the selected field.
	 */
	var initFieldHighlighters = function () {
		$(document).on('click', '.highlight-editor', function () {
			var accordion = getAccordion();
			var $selectorRow = $('#testRunReleaseSelector').closest('tr');

			$('#centerDiv').animate({
		        scrollTop: $selectorRow.offset().top
		    }, 500);
			flashChanged($selectorRow);

			accordion.cbMultiAccordion("open", 0);
		});
	};

	var setUpEventHandlers = function () {
		var $coverageTable = $("#coverageTree");
		// set up the table openen/closer event handlers
		$(document).on('click', '.indenter', function () {
			var $row = $(this).closest('tr');

			if ($row.is('.initialized')) {
				// if the row is already initialized just expand or collapse it
				toggleRow($row);
			} else {
				// otherwise load the child rows and add them to the table
				var parameters = getParameters($row);

				var bs = ajaxBusyIndicator.showBusyPage();
				$.get(contextPath + "/trackers/coverage/ajax/" + config.treeUrl, parameters)
				.done(function(html) {
					var children = $(html);

					addRows($row, children);
					refreshFiltering();
				}).fail(function(jqXHR, textStatus, errorThrown) {
					try {
			    		var exception = $.parseJSON(jqXHR.responseText);
			    		alert(exception.message);
					} catch(err) {
						console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
					}
			    }).always(function () {
			    	if (bs) {
			    		bs.remove();
			    	}
			    });
			}
		});

		// make the first column resizable
		$("#coverageTree .firstHeader").resizable({
			handles: 'e, w',
			maxWidth: window.outerWidth ? 0.5 * window.outerWidth : 600,
			minWidth: 150,
			alsoResize: '.firstColumn',
			stop: function(event, data) {
				// store the width at the end of the resizing
				try {
					var width = $(".firstHeader").width();

					console.log("Saving resized to:" + width);
					$.post(contextPath + "/userSetting.spr?name=COVERAGE_BROWSER_TREE_WIDTH&value=" + width);
				} catch (e) {
					console.log("Failed to save column width:" + data +", ex:" + e);
				}
			}
		});

		// refresh the filtering when the target item type changes
		$("#searchTestCases,#searchRequirements").change(function () {
			refreshFiltering();
		});

		$("#searchBox_coverageTree").keyup(function(e, d) {
			if (e.keyCode == 27) {	//esc should clear search
				$(this).val('');
			}
			if (e.charcode !== 0) {
				filterKeyup.call(this);
			}
		});

		$('#filters select').change(function() {
			var accordion = getAccordion();
			accordion.cbMultiAccordion("close", 0);
		});

		$("#coverageTree").on("mouseover", "li", function (event) {
			var $row = $(this);

			// using this method instead of stopPropagation() for preventin the bubbling up of the events to the parent li elements
			// because stopPropagation() disables the .resultBox tooltips
			if ($row.find(".hovered").size() == 0) {
				$row.addClass("hovered");
			}
		}).on("mouseout", "li", function (event) {
			$(this).removeClass("hovered");
		});


		if (config.coverageType == "requirement") {
			// reload the coverage when a new item was selected in the tracker/branch selector
			$('.trackerSelectorTag').on('multiselectclick codeBeamer:update', function (event, data) {
				var $target = $(event.currentTarget);
				var name = $target.attr('name');

				var selected = getSelectedIds('#' + $target.attr('id'));
				updateReferringList(name, selected);
			});
		}
	};

	var setUpAccordion = function () {
		var accordion = getAccordion();
		accordion.cbMultiAccordion({
			active: config.coverageType == 'requirement' ? 2 : 1
		});
	};

	var getAccordion = function () {
		var accordion = $('.accordion');
		return accordion;
	}

	var setUpMultiselect = function () {
		var selectId = config.coverageType == "release" ? "#releaseSelector" : "#trackerSelector";
		$(selectId).multiselect({
			"multiple": false,
			"selectedText": function(numChecked, numTotal, checked) {
				return $.map(checked, function(a) {
					return $(a).attr("title");
				}).join(", ");
			},
			"create": function (e) {
				var $widget = $("[name=multiselect_" + $(this).attr("id") + "]").closest(".ui-multiselect-menu");
				$widget.hide();

				var li = $("<div>").addClass("filter").addClass("option-filter").append($("<input>").attr("type", "text"));
				li.append($("<div>").addClass("ui-icon ui-icon-circle-close"));
				$widget.prepend(li);

				li.find("input").keyup(function () {
					var searchText = $(this).val().toLowerCase();
					filterList($widget.find('.ui-multiselect-checkboxes > li:not(.ui-multiselect-optgroup,.filter)'), searchText);
				});

				li.find(".ui-icon").click(function () {
					var $allListElements = $widget.find('.ui-multiselect-checkboxes > li:not(.ui-multiselect-optgroup,.filter)');
					$allListElements.show();
					$(this).prev("input").val("");
				});

				$("li.ui-multiselect-optgroup").each(function() {
					var $groupHeader = $(this);
					var $clearer = $("<div>").addClass("optgroup-clearer ui-icon ui-icon-circle-close").attr("title", "Clear selection in this group");
					$groupHeader.append($clearer);
				});

				$(".optgroup-clearer").click(function() {
					var $header = $(this).parent();
					var $items = $header.nextUntil("li.ui-multiselect-optgroup").not(".ui-multiselect-disabled");
					$items.find(":checkbox:checked").closest("label").click();
					$(this).hide();
				});
			}
		});
	};

	var getParameters = function ($row) {
		var data = {
			"startingLevel": $row.data("level")
		};

		$.extend(data, config);

		data["nodeId"] = $row.data("ttId");

		var $trackerSelector = $(".trackerSelectorTag").first();
		if ($trackerSelector.size() > 0) {
			data["tracker_id"] = $trackerSelector.val()[0];
			data["branchId"] = $("#branchSelector").val();
			var view = $("#viewSelector").val();
			if (view) {
				data["viewId"] = view;
			}
		} else {
			data["task_id"] = $("#releaseSelector").val();
		}

		return data;
	};

	/**
	* appends children (a list of trs) after $parent in the table
	*/
	var addRows = function ($parent, children) {
		$parent.after(children);

		// set the parent expanded, and also set it as initialized
		$parent.addClass('expanded').removeClass('collapsed').addClass('initialized');
	};

	/**
	* toggles a row (expands or collapses it) and shows its children.
	*/
	var toggleRow = function ($row) {
		if ($row.is('.expanded')) {
			// if the row is expanded then collapse it: hide its children and set them as collapsed
			var children = [];
			findChildren($row, children);

			var $children = $(children);
			$children.filter('.expanded').removeClass('expanded').addClass('collapsed');

			$children.hide();

			$row.removeClass('expanded').addClass('collapsed');
		} else {
			// show the direct children
			var directChildren = $('tr[data-tt-parent-id=' + $row.data("ttId") + ']');
			$(directChildren).show();

			$row.removeClass('collapsed').addClass('expanded');
		}
	};

	var filterKeyup = throttleWrapper(function () {
		var filterText = $("#searchBox_coverageTree").val();

		console.log("Tree is seaching for:" +filterText);

		if (filterText.length < 3) {
			clearFiltering();
		} else {
			filterTreeTable(filterText);
		}
	}, 500);

	var findChildren = function ($row, children) {
		var id = $row.data('ttId');
		var directChildren = $('tr[data-tt-parent-id=' + id + ']');
		if (directChildren.size()) {
			children.addAll(directChildren);

			for (var i = 0; i < directChildren.size(); i++) {
				findChildren($(directChildren.get(i)), children);
			}
		}
	};

	var findParents = function ($row, parents) {
		var parentId = $row.data('ttParentId');
		if (!parentId) {
			return;
		}

		var parent = $('tr[data-tt-id=' + parentId + ']');
		if (parent.size()) {
			parents.push(parent);

			findParents($(parent), parents);
		}
	};

	var filterTreeTable = function (filterText) {

		var selectors = [];
		if ($("#searchRequirements:checked").size()) {
			selectors.push('.requirement');
		}

		if ($("#searchTestCases:checked").size()) {
			selectors.push('.testcase,.testRun');
		}

		var selector = selectors.join(",");
		var $rows = $(selector);
		var lower = filterText.toLowerCase();
		var $matching = $.grep($rows, function (row){
			// match for name or id
			var $row = $(row);
			var matchesName = $row.find('.itemUrl').text().toLowerCase().indexOf(lower) >= 0;
			var matchesId = $row.data("id") == filterText;

			return matchesName || matchesId;
		});

		// find the parents and children of the matching rows because they also need to be shown
		var children = [];
		var parents = [];

		// show the empty tree message when there are no matching rows
		$("#emptyTreeMessage").toggle($matching.length == 0);

		for (var i = 0; i < $matching.length; i++) {
			var $row = $($matching[i]);
			findParents($row, parents);
			findChildren($row, children);
		}

		// hide all rows
		$("#coverageTree tbody tr").removeClass("matching-node").hide();

		// show the matching nodes and their children
		for (var i = 0; i < $matching.length; i++) {
			$($matching[i]).addClass("matching-node").show();
		}
		for (var i = 0; i < children.length; i++) {
			$(children[i]).show();
		}
		for (var i = 0; i < parents.length; i++) {
			$(parents[i]).removeClass('collapsed').addClass('expanded').show();
		}
	};

	var clearFiltering = function () {
		var $allRows = $("#coverageTree tbody tr");
		$allRows.removeClass("matching-node");

		// show all rows except the children of collapsed nodes
		var $collapsed = $.grep($allRows, function (el) {return $(el).is('.collapsed')});
		var children = [];
		for (var i = 0; i < $collapsed.length; i++) {
			findChildren($($collapsed[i]), children);
		}

		$allRows.show();
		$(children).hide();

		var hasMathingRow = $("#coverageTree tbody tr").size();
		$("#emptyTreeMessage").toggle(!hasMathingRow);
	};

	var refreshFiltering = function () {
		var $searchBox = $("#searchBox_coverageTree");

		if ($searchBox.val()) {
			$searchBox.trigger("keyup");
		}
	};

	return {
		"init": init,
		"exportUrl": exportUrl
	};
}(jQuery));
