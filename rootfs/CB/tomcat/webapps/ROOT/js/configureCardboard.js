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
codebeamer.cardboardConfiguration = codebeamer.cardboardConfiguration || (function($) {
	var _config = {};

	var toggleInsertButtons = function () {
		if ($("tr.header td").size() >= _config.maximumColumns) {
			$(".insert-column-icon").hide();
			$("#reached-column-maximum").show();
		} else {
			$(".insert-column-icon").show();
			$("#reached-column-maximum").hide();
		}
	};

	var addNewColumnAfter = function ($td) {
		var $headerRow = $("tr.header");
		var $bodyRow = $("tr.body");
		var index = $headerRow.find("td").index($td);

		var header = $($("#column-header-template").html());
		var body = $($("#column-body-template").html());
		var $prevCell = $headerRow.find("td:nth(" + index + ")");

		var isLast = $td.hasClass('last');

		if (isLast) {
			$td.removeClass('last').addClass('notLast');
			$bodyRow.find('td.last').removeClass('last').addClass('notLast');
		}

		var cssClass = isLast ? 'last' : 'notLast';

		$prevCell.after($("<td>", { 'class': cssClass, "style": "width: 20%;"}).append(header));
		$bodyRow.find("td:nth(" + index + ")").after($("<td>", { 'class': 'lane ' + cssClass }).append(body));

		var $new = $prevCell.next("td");
		$new.find("[name=names]").focus();

		toggleInsertButtons();
	};

	var removeColumn = function ($target) {
		var $td = $target.closest("td");
		var index = $("tr.header td").index($td);

		$td.remove();
		$("tr.body td:nth(" + index + ")").remove();
		toggleInsertButtons();
	};

	var computeStatusList = function () {
		$("tr.body td").each(function () {
			var $td = $(this);
			var statuses = $td.find(".moved-group .status:not(.ui-sortable-helper)").map(function () {return $(this).data("id");}).toArray().join(", ");
			$td.find("[name=statuses]").val(statuses);
		});
	};

	var makeSortable = function ($statusLists) {
		$statusLists.sortable({
			"helper": "clone",
			"zIndex": 200,
			"start": function (event, ui) {
				var $moved = $(event.target);
				var $td = $moved.closest("td");
				var $targets = $("tr.body td");
				var index = $targets.index($td);

				var tableBody = $("#userStories").find("tr.body");
				var firstTarget = $($targets.get(0));
				var otherTargetsButMe = $("tr.body td:not(:nth(" + index + "))");

				(function addPlaceholders() {
					$("<div>").addClass("floatingPlaceholder acceptsDrop")
						.height(tableBody.height() - 5)
						.width(firstTarget.width())
						.css("top", tableBody.offset().top)
						.prependTo(otherTargetsButMe);
				})();

				(function alignPlaceholders() {
					$targets.each(function () {
						var $td = $(this);
						var $placeholder = $td.find(".floatingPlaceholder");
						$placeholder.css("left", $td.offset().left + 5);
					});
				})();

				$(".floatingPlaceholder").droppable({
					"accept": ".status",
					"drop": function (event, ui) {
						var $draggable = $(ui.draggable);
						var $target = $(event.target).closest("td");

						var $movedGroup = $target.find(".moved-group");
						$movedGroup.show();

						var $original = $("li[data-id=" +  $draggable.data("id") + "]:not(.ui-sortable-helper)");
						var $tracker = $($original.get(0)).closest(".tracker");
						var $trackerNode = $movedGroup.find(".tracker[data-id=" + $tracker.data("id") + "]");

						if ($trackerNode.size() == 0) {
							$trackerNode = $tracker.clone();
							var $statusList = $trackerNode.find("ul.status-list");
							$statusList.empty();
							makeSortable($statusList);
							$movedGroup.find("ul.tracker-list").prepend($trackerNode);
						}

						$trackerNode.find(".status-list").prepend($($original.get(0)).clone().show());
						$original.remove();

						computeStatusList();
					}
				});
			},
			"stop": function (event, ui) {
				$(".floatingPlaceholder").remove();
			}
		});
	};

	var init = function(config) {
		if (config) _config = config;
		makeSortable($(".status-list"));

		$("tr.header").click(function (event) {
			var $target = $(event.target);

			if ($target.is(".remove-column-icon")) {
				removeColumn($target);
			} else if ($target.is(".insert-column-icon")) {
				var $td = $target.closest("td");
				addNewColumnAfter($td);
			}
		});

		computeStatusList();
		toggleInsertButtons();
	};

	return {
		"init": init
	};
})(jQuery);
