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

(function($) {

	/**
	 * Tracker Item Tree Table jQuery plugin
	 *
	 * @param attributes Object representing the attributes:
	 *
	 * 		columnIndex The index of the column where the tree controls should appear
	 * 		expandString String for expand tooltip
	 * 		collapseString String for collapse tooltip
	 * 		loadByAjax If tree elements should load by Ajax
	 * 		ajaxUrl The Ajax URL
	 * 		ajaxMethod Default is GET
	 * 		ajaxItemParamName Parameter name of the request which represents the tracker item ID
	 * 		ajaxMaxDepth The maximum allowed tree depth. Levels deeper than this number won't be loaded.
	 * 		ajaxData Other Ajax request parameters, or function producing an object literal
	 * 		ajaxAsync If Ajax should be async or not
	 * 		ajaxCache If Ajax cache should use or not
	 * 		ajaxFail Callback function for failing the Ajax request
	 * 		onBeforeExpand: Callback function. It is called before Ajax request starts. (loadByAjax must be set to true)
	 * 		onExpand Callback function if a node is expanded (if loadByAjax set to true, onExpand is called by success)
	 * 		onCollapse: Callback function if a node is collapsed
	 * 		autoExpandTrackerItemIds Array of tracker item IDs which should be visible (auto expand node if necessary)
	 *
	 * 	@return
	 */
	$.fn.trackerItemTreeTable = function (attributes) {
		var settings = $.extend({}, $.fn.trackerItemTreeTable.defaults, attributes);

		function init(container) {

			container.addClass("treetable");

			var indenter = $('<span class="indenter"></span>');
			var controlExpand = $('<a href="#" title="' + settings.expandString + '">&nbsp</a>');
			controlExpand.click(function () {
				expand($(this).closest("tr"));
				return false;
			});
			var controlCollapse = $('<a href="#" title="' + settings.collapseString + '">&nbsp</a>');
			controlCollapse.click(function () {
				collapse($(this).closest("tr"));
				return false;
			});

			var loadByAjax = settings.loadByAjax;

			function expand(row) {
				var onExpand = settings.onExpand;

				var switchControls = function () {
					row.removeClass("collapsed");
					row.addClass("expanded");
					row.find(".indenter").empty().append(controlCollapse.clone(true));
				};

				var level = row.data("ttLevel");

				if (loadByAjax) {
					if (settings.hasOwnProperty("onBeforeExpand") &&  settings.onBeforeExpand != null && typeof settings.onBeforeExpand === "function") {
						settings.onBeforeExpand(row);
					}

					var data = {};
					data[settings.ajaxItemParamName] =  row.data("ttId");

					var ajaxData;
					if (settings.ajaxData && typeof settings.ajaxData === "function") {
						ajaxData = $.extend(data, settings.ajaxData(row));
					} else {
						ajaxData = $.extend(data, settings.ajaxData);
					}

					var ajaxMethod = settings.ajaxMethod ? settings.ajaxMethod : 'GET';
					$.ajax(settings.ajaxUrl, {
						type: ajaxMethod,
						async: settings.ajaxAsync,
						cache: settings.ajaxCache,
						data: ajaxData
					})
						.done(function (html) {
							var $infoMessage = $(html).find(".warning");
							var rows = $(html).find("tbody:not(.embeddedTable)>tr");
 							var maxDepth = null;
							if ($.isNumeric(settings.ajaxMaxDepth)) {
								maxDepth = settings.ajaxMaxDepth;
							}
							initControl(rows, level + 1, maxDepth);

							rows.attr('data-tt-parent-id', row.data('tt-id'));

							row.after(rows);
							autoExpand(rows);
							row.data("children", rows);


							if ($infoMessage.length > 0) {
								var $infoMessageRow = $("<tr>", { "class" : "infoMessage"});
								var $indentTd = $("<td>", { colspan: 3, style: "padding: 0" });
								var $messageTd = $("<td>", { colspan: row.find("td").length - 3, style: "padding: 0" });
								$messageTd.append($infoMessage);
								$infoMessageRow.append($indentTd);
								$infoMessageRow.append($messageTd);
								$infoMessageRow.attr('data-tt-parent-id', row.data('tt-id'));
								row.after($infoMessageRow);
							}

							if (onExpand != null && typeof onExpand === "function") {
								onExpand(row);
							}
							switchControls();
						})
						.fail(function () {
							var ajaxFail = settings.ajaxFail;
							if (ajaxFail != null && typeof ajaxFail === "function") {
								ajaxFail(row);
							}
						});
				} else {
					if (onExpand != null && typeof onExpand === "function") {
						onExpand(row);
					}
					switchControls();
				}
			}

			function collapse(row) {
				var onCollapse = settings.onCollapse;

				var switchControls = function () {
					row.removeClass("expanded");
					row.addClass("collapsed");
					row.find(".indenter").empty().append(controlExpand.clone(true));
				};

				var removeChildren = function (childRow) {
					if (childRow.data("children")) {
						container.find("tr").each(function () {
							var children = childRow.data("children");
							var currentRow = $(this);
							children.each(function () {
								var child = $(this);
								if (child[0] == currentRow[0]) {
									child.remove();
								}
								removeChildren(child);
							});
						});
					}
				};

				row.next(".infoMessage").remove();
				removeChildren(row);
				if (onCollapse != null && typeof onCollapse === "function") {
					onCollapse(row);
				}
				switchControls();
			}

			container.addClass("trackerItemTreeTable");

			var initControl = function(rows, level, maxDepth) {
				rows.each(function () {
					var $row = $(this);
					if (!$row.hasClass("skipIdent") && !$row.closest('table.reviews').length) {
						$row.attr("data-tt-level", level);
						var columns = $(this).find("td");
						var treeColumn = $(columns[settings.columnIndex]);
						var indenterClone = indenter.clone();
						indenterClone.css("width", 19 * (level + 1));
						if (settings.isExpandable(this) && (!maxDepth || (level + 1 <= maxDepth))) {
							if (!$row.hasClass("expanded")) {
								// Expand
								$row.addClass("collapsed");
								indenterClone.append(controlExpand.clone(true));
							} else {
								// Collapse
								indenterClone.append(controlCollapse.clone(true));
							}
						}
						if (treeColumn.find("span.indenterPlaceholder")) {
							treeColumn.find("span.indenterPlaceholder").remove();
						}
						treeColumn.prepend(indenterClone);
					}
				});
			};

			var autoExpand = function(rows) {
				var autoExpandTrackerItemIds = settings.autoExpandTrackerItemIds;
				if (autoExpandTrackerItemIds != null) {
					for (var i = 0; i < autoExpandTrackerItemIds.length; i++) {
						var id = autoExpandTrackerItemIds[i];
						rows.each(function() {
							if (settings.isExpandable(this) && id ==  $(this).data("ttId")) {
								expand($(this));
							}
						});
					}
				}
			};

			var tableRows = container.find("tr");
			initControl(tableRows, 0);
			autoExpand(tableRows);
		}

		return this.each(function () {
			init($(this));
		});

	};

	$.fn.trackerItemTreeTable.defaults = {
		columnIndex: 0,
		expandString: "",
		collapseString: "",
		loadByAjax: true,
		ajaxUrl: "",
		ajaxItemParamName : "parent",
		ajaxData: {},
		ajaxAsync: false,
		ajaxCache: false,
		ajaxFail: null,
		onExpand: null,
		onCollapse: null,
		autoExpandTrackerItemIds: null,
		// decide if this row has children, i.e. it is expandable, collapse-able
		isExpandable: function(row) {
			return $(row).data("ttBranch") == true;
		}
	};

})(jQuery);
