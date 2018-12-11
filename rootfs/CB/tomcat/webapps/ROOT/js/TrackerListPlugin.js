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

/**
 Javascript used by TrackerListPlugin wiki plugin.
 */
function initTrackerListPluginContextMenu(availableKeys) {
	if(availableKeys == "") {
		console.log("No menus to show");
		return;
	}

	// without refresh we should bind new elements, for ex.: new widget is added to the dashboard without page refresh
	$(document).off("click", ".trackerListPlugin td.tracker-context-menu .menuArrowDown");

	$(document).on("click", ".trackerListPlugin td.tracker-context-menu .menuArrowDown", function(event) {
		var target = $(event.target);
		var td = target.closest("td.tracker-context-menu").first();
		var trigger = td.find(".menu-container").first();
		if (!trigger.hasClass("menu-downloaded")) {
			target.remove();
		}
		buildInlineMenu(trigger, '/trackers/ajax/trackerMenu.spr', {
			'tracker_id': td.data("trackerId"),
			'availableKeys': availableKeys,
			'cssClass': 'inlineActionMenu',
			'builder': 'trackerListContextActionMenuBuilder'
		});
	});
}

var filterbyTrackerType = {
	init: function() {
		$(".trackerListPlugin .filterbyTrackerType").each(function() {
			var $this = $(this);
			// if the "select" is hidden then it is already a multiselect-box
			if ($this.css("display") == "none") {
				return; // avoid multiple init if there are multiple tracker-list plugins on the page
			}

			// initialize the options: the tracker-types
			filterbyTrackerType.initOptions($this);

			// initialize multiselect
			var filterLabel = i18n.message("tracker.list.filter.label");
			$this.multiselect({
				"noneSelectedText": filterLabel,
				// "header": "Filter by type",
				"selectedText": function(numChecked, numTotal, checked) {
					if (numChecked == numTotal) {
						return filterLabel;	// All is selected
					}
					var text = $.map(checked, function(a) {
						return $(a).attr("title");
					}).join(", ");
					// shorten to avoid getting too wide
					if (text.length > 20) {
						text = i18n.message("subset.x.of.y", numChecked, numTotal);
					}
					return text;
				},
				classes: "ui-multiselect-menu-newskin"
			});

			// init event handler
			$this.change(filterbyTrackerType.applyFilter);
		});
	},

	getTrackerType:function(tr) {
		var trackerType = $(tr).data("trackertype");
		return trackerType;
	},

	initOptions: function(filter) {
		var $table = $(filter).closest(".trackerListPlugin");
		var options = {};
		$table.find("tr:not(.hiddenTrackerType)").each(function() {
			var trackerType = filterbyTrackerType.getTrackerType(this);

			if (trackerType) {
				// group all Test related trackers to one filter option
				if (trackerType.indexOf("Test") == 0 /* starts with Test */) {
					trackerType = "TestRelated";
				}

				var count = options[trackerType];
				if (count == null) {
					count = 0;
				}
				options[trackerType] = count + 1;
			}
		});

		// translate and sort tracker-types by name
		var optionsTranslated = {};
		var labels = [];
		for (trackerType in options) {
			var count = options[trackerType];

			var label = i18n.message('tracker.type.' + trackerType +".plural");
			if (trackerType == "TestRelated") {
				label = i18n.message('tracker.list.type.filter.TestRelated');
			}
			var title = label;
			label += " (" + count +")";

			var opt = "<option value='" + trackerType +"' title='" + title +"' selected='selected' >" + label +"</option>"

			optionsTranslated[label] = opt;
			labels.push(label);
		}

		// sort by keys
		labels.sort();

		// put the sorted to select box
		for (var i=0; i< labels.length; i++) {
			var label = labels[i];
			var opt = optionsTranslated[label];
			$(filter).append(opt);
		}
	},

	// apply the filter
	applyFilter: function() {
		var $filter = $(this);
		var selectedTrackerTypes = filterbyTrackerType.getFilterByTrackerType($filter);

		var $plugin = $filter.closest(".trackerListPlugin");
		var $table = $plugin.find("table");
		$table.find("tbody tr").each(function() {
			var $tr = $(this);

			// only hide/show a row with a tracker-type
			var trackerType = filterbyTrackerType.getTrackerType($tr);
			if (trackerType) {
				var visible = false;
				visible = ($.inArray(trackerType, selectedTrackerTypes) != -1);
				$tr.toggleClass("hiddenTrackerType", ! visible);
			}
		});

		// update summary-statistics
		$table.trigger("updateSummary");
	},

	// get the selected tracker-types in the filter
	getFilterByTrackerType: function(filter) {
		var $filter = $(filter);
		var selected = $filter.multiselect("getChecked").map(function() {
			return $(this).val();
		}).toArray();

		// expand the "TestRelated" pseudo type to real types
		if ($.inArray("TestRelated", selected) != -1) {
			selected.push("Test");
			selected.push("Testconf");
			selected.push("Testrun");
			selected.push("Testcase");
			selected.push("Testset");
		}

		console.log("filterByTrackerType:" + selected);
		return selected;
	}
}

function saveTrackerList(plugin, trackerIdsInOrder) {
	var configURL = $(plugin).find("a.configURL").attr("href");
	if (configURL) {
		console.log("Saving tracker's order to " + configURL +", ids:" + trackerIdsInOrder);

		$.post(configURL,
			{
				"trackerOrder": trackerIdsInOrder.join(",")
			}
		);	// TODO: success/error handling ?
	}
}

var trackerListSorting = {

	// get the tracker id from rows
	getTrackerId: function(tr) {
		var $td = $(tr).find("td.tracker-context-menu").first();
		var trackerId = $td.data("trackerId");
		return trackerId;
	},

	/**
	 * collect all trackers' order in a table
	 * @return the tracker ids in order in a table
	 */
	getTrackersOrder: function(table) {
		var trackerIds = [];
		$(table).find("tr").each(function() {
			var trackerId = trackerListSorting.getTrackerId($(this));
			if (trackerId != null) {
				if ($.inArray(trackerId, trackerIds) == -1) {	// avoid duplicates
					trackerIds.push(trackerId);
				}
			}
		});
		return trackerIds;
	},

	initSorting: function() {
		$(".trackerListPlugin table.sortable").sortable(
			{
				"items" : "tbody tr",
				"placeholder": "ui-state-highlight",
				"update": function(event, ui) {
					var dropped = ui.item;
					var trackerId = trackerListSorting.getTrackerId(dropped);
					console.log("dropped tracker:" + trackerId);
					var $plugin = $(dropped).closest(".trackerListPlugin");
					var trackerIdsInOrder = trackerListSorting.getTrackersOrder($plugin);
					console.log("Order of trakkers is:" + trackerIdsInOrder);

					$plugin.trigger("orderChanged", [ trackerIdsInOrder ]);

					// saveTrackerList($plugin, trackerIdsInOrder);	// TODO: remove this and the save method?
				}
			}
		);
	}

}

function showEmptyMessage(table, empty) {
	// handle when the table goes completely empty
	var $emptyMessage = $(table).find("tfoot tr.emptyMessage");
	// table is empty then show/hide the head and footer
	$(table).toggleClass("emptyTable", empty);

	if (empty) {
		// table is empty show message
		if ($emptyMessage.length == 0) {
			$(table).find("tfoot")
				.append("<tr class='emptyMessage' title='" + i18n.message('tracker.list.empty.tooltip') +"' ><th colspan='999'>" +
						i18n.message('tracker.list.empty')
						+ "</th></tr>");
		} else {
			$emptyMessage.show();
		}
	} else {
		// table is not empty hide message
		$emptyMessage.remove();
	}
}

/**
 * JS for tracker-list-plugin-new-layout.vm
 */
var trackerListPluginNew = {

	/**
	 * @param menuItemsAvailable
	 * @param canEdit If the user has permission to configure the plugin (like drag-drop sorting)
	 */
	init: function(menuItemsAvailable) {
		initTrackerListPluginContextMenu(menuItemsAvailable);
		filterbyTrackerType.init();

		function initDetailedLayoutSwitcher() {
			$(".trackerList_toDetailedLayout").click(function() {
				var url = window.location.href;
				var separatorChar = "?";
				if (url.indexOf("?") > -1) {
					separatorChar = "&";
				}
				window.location.href = url + separatorChar + "detailed_layout=true";
			});
		}
		$(document).ready(function() {
			initDetailedLayoutSwitcher();
		});

        function updateSummary(table){
        	var sum = 0;
        	var all = 0;
        	var $visibleRows = $(table).find("tbody tr:not(.hidden)");
        	$visibleRows.each( function( index, element ){
				if (!$(this).hasClass("summary-row")){
					sum += trackerListPlugin.getIntCell($(element).find(".tracker-open-count"));
					all += trackerListPlugin.getIntCell($(element).find(".tracker-all-items-count"));
                }
			});
			$(table).find(".summary-row .number").text(sum + " / " + all);

			// handle when the table goes completely empty
			var empty = ($visibleRows.length == 0);
			showEmptyMessage(table, empty);
        };

    	// use a flag to avoid double event calls when two or more plugins appear on the page
        if (! trackerListPluginNew.eventsInitialized) {
        	trackerListPluginNew.eventsInitialized = true;

        	$(".trackerListPlugin").on("updateSummary", function(event, arg1, arg2) {
        		var target = event.target;
        		var $table = $(target).closest("table");
        		updateSummary($table);
        	});

	        $(".trackerListPlugin .showAllCheckbox").click(function() {
	        	var $table = $(this).closest("table");
	        	$table.toggleClass("trackerListPluginShowHidden", this.checked);
	        	// this will update the summary calculations
	        	$table.trigger("updateSummary");
	        });


	        var triggerUpdateSummary = function() {
				$(".trackerListPlugin .displaytag").each( function() {
					// this will update the summary calculations
					$(this).trigger("updateSummary");
	    		});
	        };

	        $(document).ready(triggerUpdateSummary);

        	trackerListSorting.initSorting();
        }
	}
}

/**
 * JS for tracker-list-plugin.vm
 */
var trackerListPlugin = {

	//  Get/parse an integer cell's content
	getIntCell: function($element) {
		var $el = $($element).first();
		var stringValue = $el.text().trim();

		// if the value contains two numbers use only the first one
		if (stringValue.indexOf("/") >= 0) {
			stringValue = stringValue.substring(0, stringValue.indexOf("/")).trim();
		}

    	// Delete thousand separator
    	stringValue = stringValue.replace(/[^\d]/g, "");
    	return parseInt(stringValue);
	},

	init: function(menuItemsAvailable) {
        initTrackerListPluginContextMenu(menuItemsAvailable);

		function initNewLayoutSwitcher() {
			$(".trackerList_toNewLayout").click(function() {
				var url = window.location.href;
				url = url.replace("?detailed_layout=true", "");
				url = url.replace("&detailed_layout=true", "");
				window.location.href = url;
			});
		}
		$(document).ready(function() {
			initNewLayoutSwitcher();
		});

        function updateSummary(table){
        	var open = 0;
        	var total = 0;
        	var assignedToMe = 0;
        	var submittedByMe = 0;

        	$(table).find("tbody tr:not(.hiddenTrackerType)").each( function( index, element ){
				if (!$(this).hasClass("summary-row")){
					open += trackerListPlugin.getIntCell($(element).find(".tracker-open-count"));
                	total += trackerListPlugin.getIntCell($(element).find(".tracker-all-count"));
                	assignedToMe += trackerListPlugin.getIntCell($(element).find(".tracker-assigned-count"));
                	submittedByMe += trackerListPlugin.getIntCell($(element).find(".tracker-submitted-count"));
                }
			});

			$(table).find(".summary-open").text(open);
			$(table).find(".summary-total").text(total);
			$(table).find(".summary-assigned-to-me").text(assignedToMe);
			$(table).find(".summary-submitted-by-me").text(submittedByMe);
        };

    	// use a flag to avoid double event calls when two or more plugins appear on the page
        if (! trackerListPlugin.eventsInitialized) {
        	trackerListPlugin.eventsInitialized = true;

	        $(".trackerListPlugin .showAllCheckbox").click(function() {
	        	var $table = $(this).closest("table");
	            $table.find("tr.hidden").toggle(this.checked);
	            updateSummary($table);
	        });

	        $(document).ready(function() {
				$(".trackerListPlugin .displaytag").each( function(){
	    			updateSummary(this);
	    		});
			});
        }
	}
}

