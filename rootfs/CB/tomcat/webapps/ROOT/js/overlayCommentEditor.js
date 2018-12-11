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
codebeamer.commentEditor = codebeamer.commentEditor || (function($) {
	var reloadComments = function () {
		var commentContainer = $("#comments, [data-planner-role=comments]");
		var isPlanner = commentContainer.attr("data-planner-role") == "comments";
		var isDocumentView = commentContainer.attr("data-document-view-role") == "comments";
		var taskId = commentContainer.find("[name=issueId]").val();

		$.ajax({
			"url": contextPath + "/trackers/ajax/getIssueComments.spr",
			"type": "GET",
			"data": {
				"task_id": taskId
			},
			"success": function(data) {
				if (isPlanner || isDocumentView) {
					commentContainer.html(data).closest(".accordion").trigger("refreshCommentCount");
				} else {
					commentContainer.find(".collapsingBorder_content").html(data);
				}

				// update the counts
				var commentGroups = commentContainer.find(".commentGroup");
				flashChanged(commentGroups.first());

				var comments = commentGroups.size();
				var label = i18n.message("planner.comments.label", comments);
				commentContainer.find("legend a").html(label);

			},
			"error": function () {
				showOverlayMessage(i18n.message("planner.add.comment.failed.message"), 3, true);
			},
			"cache": false // no caching because IE cannot handle it correctly
		});
	};

	return {
		"reloadComments": reloadComments
	};
})(jQuery);
