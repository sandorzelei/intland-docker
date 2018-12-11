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
function initInlineRating($element) {
	$element.on("click", ".rating-container", function (event) {
		var $target = $(this);
		var issueId = $target.data("issueid");
		if (!$target.is(".initialized")) {
			$.ajax({
				"url": contextPath + "/ajax/getObjectRatingStats.spr",
				"type": "GET",
				"data": {
					"entityId": issueId,
					"entityTypeId": 9
				},
				"success": function(data) {
					var containerId = "#" + $target.attr("id");
					var rating = new Rating(containerId, data.objectRatingStats, data.userRating, 9, issueId, containerId, "click");
					$target.addClass("initialized");
					var $widget = rating.getWidget()
					var $dialog = $widget.data("ratingDialog")
					var args = $.extend({}, rating.dialogParams);
					args.position.of = $widget;

					$dialog.dialog(args);
				}
			});
		}
	}).on("afterRatingSubmitted", ".rating-container", function (event, stats, rating) {
		var $rating = $(this);
		var rate = Math.floor(rating.objectRatingStats.averageRating);
		$rating.removeClass("rated-0 rated-1 rated-2 rated-3 rated-4 rated-5");
		$rating.addClass("rated-" + rate);
	});
}