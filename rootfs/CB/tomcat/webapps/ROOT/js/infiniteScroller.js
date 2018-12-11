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
 */

/*
* infinite scrolling for document view.
*/

/**
 * small module for handling bidirectional infinite scrolling on document view.
 * how this works: when you scroll down or up we check if you reached a special point (a trigger point). if yes then
 * the code removes the previous/next 50 (or other number configured as pagesize) rows from the dom and loads 50 new rows
 * (if possible). for checking the  trigger points we use the waypoint plugin. waypoint is always initialized for the first and last row of the
 * table.
 *
 * about the scrolling behaviour: to make the scrolling experience smooth the code manipulates the scrollTop property of the container. Whenever
 * some rows are removed or added the scrolltop property is updated to prevent "jumping". also, when there is only 50 elements on the page and the user
 * scrolls down we cannot just remove the previous 50 rows and load 50 new ones because it would make the experience very bad. so in this case
 * only 25 rows are removed and 50 rows are added. on the subsequent paging event we remove and add 50 rows, so the dom contains at each moment
 * at most 50 rows.
 */
var codebeamer = codebeamer || {};
codebeamer.infiniteScroller = codebeamer.infiniteScroller || (function($) {
	var PLACEHOLDER_ID = "#scroll-placeholder";
	var CONTAINER_SELECTOR = "#rightPane";
	var config = {
			pageSize: 50,
			idAttr: "id"
	};

	/**
	 * initializes waypoint using $loadMoreLink element as the trigger element. if $loadMoreLink is falsy it tries
	 * to find an element with class LOAD_MORE_LINK_CLASS and will use that.
	 */
	var init = function (options) {
		updateWaypointTriggerLinks();
		config = $.extend(config, options);

		var $container = $(CONTAINER_SELECTOR);
		if (!$container.data('heightChangeHandlerAdded')) {
			$container.on('cbRightPaneHeightChanged', updateWaypointTriggerLinks);
			$container.data('heightChangeHandlerAdded', true);
		}
	};

	var waypointHandler = function (direction) {
		if (codebeamer.infiniteScroller.disabled) {
			// prevent the infinite scroller handler from triggering immediately after a new page fragment was loaded
			console.log("infinite scrolling is currently disabled");
			return;
		}

		var $row = $(this);

		console.log("waypoint", direction, $row.attr("id"));

		// these variables are exclusive. they show (accordingly) if wee need to load the previous or the next page
		var loadNextPage = direction == "down" && $row.attr("id") == findLastRow().attr("id");
		var loadPreviousPage = direction == "up" && $row.attr("id") == findFirstRow().attr("id");


		if (!loadNextPage && !loadPreviousPage) {
			return;
		}

		if (loadNextPage && !$row.data("hasmoreAfter") || loadPreviousPage && !$row.data("hasmoreBefore")) {
			return;
		}

		// if waypoint was already triggered on this row return
		if ($row.data("triggered")) {
			console.log('returning because this waypoint link has already been triggered', $row);

			return;
		}
//
//		if (codebeamer.infiniteScroller.loadingInProgress) {
//			console.log('returning because the loading was already started by an other trigger link');
//
//			return;
//		}

		// trigger an event at this point because it is certain that the current page will be unloaded
		$(document).trigger('codebeamer.beforePageUnload');

		var $loader = createLoader($row);

		// the common request parameters for both directions
		var params = {
			"pageSize": config.pageSize
		};

		$.extend(params, config.defaultParams);

		$.extend(params, getFilterParameters());

		var idAttr = config.idAttr ? config.idAttr : "id";
		if (loadNextPage) {
			$.extend(params, {
				"showFrom": $row.attr(idAttr)
			});
			$row.find("td:nth(1)").append($loader);

		} else if (loadPreviousPage) {
			$.extend(params, {
				"showTo": $row.attr(idAttr)
			});

			$row.find("td:nth(1)").prepend($loader);

		}

		codebeamer.infiniteScroller.loadingInProgress = true;

		var ajaxMethod = config.ajaxMethod || "GET";
		if (loadNextPage) {
			$row.data("triggered", true);
			$.ajax(contextPath + config.url, {
				"data": params,
				"method" : ajaxMethod,
				"success": function (data) {
					var $table = $("#requirements > tbody");

					$table.append(data);

					var viewTop = $(CONTAINER_SELECTOR).scrollTop();

					// the last / first visible element of the new table (depending on the direction
					var $referenceRow = $("#requirements tr.requirementTr:" + (loadNextPage ? "last" : "first"));

					// deload the first 50 rows keeping at most 100 rows visible at a time
					var $requirementRows = $(".requirementTr").not("[id='#new-item-id']");

					var slice = computeSliceSize($requirementRows);
					var $rowToRemove = $requirementRows.slice(0, slice);

					if ($rowToRemove.index($referenceRow) < 0) {
						$loader.remove();

						var removedHeight = computeTotalHeight($rowToRemove);
						cancelOpenEditors($rowToRemove);
						$rowToRemove.remove();

						$(CONTAINER_SELECTOR).scrollTop(viewTop - removedHeight);
					}

					// update the trigger points with settimeout to make sure that the new trigger points are not triggered immediately
					setTimeout(updateWaypointTriggerLinks, 400);
//					updateWaypointTriggerLinks();

					$loader.remove();

					$(document).trigger('codebeamer.afterPageLoad', [$table]);
				}
			});
		} else if (loadPreviousPage) {
			// store the info that waypoint was triggered on this row
			$row.data("triggered", true);
			$.ajax(contextPath + config.url, {
				"data": params,
				"method" : ajaxMethod,
				"success": function (data) {
					var $table = $("#requirements > tbody");
					var $referenceRow = $("#requirements tr.requirementTr:first");

					var viewTop = $(CONTAINER_SELECTOR).scrollTop();

					// insert the newly fetched rows before the reference row
					$referenceRow.before(data);

					// after inserting the rows we have to prevent the browser from scolling up
					var $requirementRows = $(".requirementTr").not("[id='#new-item-id']");

					var slice = computeSliceSize($requirementRows);
					var $rowToRemove = $requirementRows.slice($requirementRows.size() - slice, $requirementRows.size());

					var $insertedRows = $requirementRows.slice(0, $requirementRows.index($referenceRow));
					var insertedHeight = computeTotalHeight($insertedRows);
					var removedHeight = computeTotalHeight($rowToRemove);

					$(CONTAINER_SELECTOR).scrollTop(viewTop + insertedHeight);

					if ($rowToRemove.index($referenceRow) < 0) {
						cancelOpenEditors($rowToRemove);
						$rowToRemove.remove();
					}

					// update the trigger points with settimeout to make sure that the new trigger points are not triggered immediately
					setTimeout(updateWaypointTriggerLinks, 400);

//					updateWaypointTriggerLinks();

					$loader.remove();

					$(document).trigger('codebeamer.afterPageLoad', [$table]);
				}
			});
		}
	};

	var cancelOpenEditors = function($rowToRemove) {
		$rowToRemove.find('.editor-wrapper textarea').trigger('cancelEditing');
	};

	var updateWaypointTriggerLinks = function () {
		var $rightPane = $(CONTAINER_SELECTOR);

		var waypointOptions = {
			"offset": function() {
				return $rightPane.height() + 300;
			},
			"context": '#rightPane',
			"handler": waypointHandler,
			"triggerOnce": true // this option is set to false because all links are removed after an event was handled for them
		};

		// destroy the previous waypoint bindings. this is necessary because otherwise the previously triggered waypoint triggers
		// would fire again
		$.waypoints("destroy");

		// move the BEFORE link to the first row in the table
		var $firstRow = findFirstRow();

		// move the AFTER link to the last row in the table
		var $lastRow = findLastRow();

		var lastRowHeight = $lastRow.height();

		if ($lastRow.data("hasmoreAfter")) {
			$lastRow.waypoint($.extend(waypointOptions, {
				"offset": function() {
					return $rightPane.height() + 100;
				}
			}));
		}

		if ($firstRow.data("hasmoreBefore")) {
			var firstRowHeight = $firstRow.height();
			$firstRow.waypoint($.extend(waypointOptions, {
				triggerOnce: false,
				"offset": function() {
					return - firstRowHeight - 400;
				}
			}));
		}

		// make sure the triggered state of the trigger rows is false
		$firstRow.data("triggered", false);
		$lastRow.data("triggered", false);

		codebeamer.infiniteScroller.loadingInProgress = false;
	};

	var findFirstRow = function () {
		return $("#requirements .requirementTr:first");
	};

	var findLastRow = function () {
		return $("#requirements .requirementTr:last");
	};

	var createLoader = function ($row) {
		var $loader = $("<div class='load-more-in-progress' style='text-align: center; padding: 1em; margin-top: -20px; position: relative;'></div>");
		$loader.html('<img src="' + contextPath + '/images/ajax-loading_10.gif">');

		return $loader;
	};

	/**
	 * computes the combined height of a list of rows
	 */
	var computeTotalHeight = function ($rows) {
		var heights = $rows.map(function () {return $(this).height();});

		// compute the total height of the inserted rows
		var totalHeight = 0;
		for (var i = 0; i< heights.length; i++) totalHeight += heights[i];

		return totalHeight;
	};

	/**
	 * compute the ptimal number of rows to remove on paging based on the number of items in the table.
	 */
	var computeSliceSize = function ($requirementRows) {
		// when there are less then 150 rows remove only the first 25 because othwerwise the window will jump (due to the large scrollbarsize change)
		return $requirementRows.size() >= 3*config.pageSize ? config.pageSize : config.pageSize / 2;
	};

	return {
		"init": init
	};
}(jQuery));