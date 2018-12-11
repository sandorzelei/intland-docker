<%--
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
 * $Revision$ $Date$
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="commentCount" value="${fn:length(itemAttachments)}"/>
<spring:message code="planner.comments.label" arguments="${commentCount}" text="${commentCount} Comments" var="commentsLabel"/>

<c:if test="${canAddCommentsAttachments}">
	<c:url var="addCommentUrl" value="/proj/tracker/docview/showCommentDialog.spr">
		<c:param name="task_id" value="${review == null ? item.id : review.id}"/>
	</c:url>
	<ui:osSpecificHotkeyTooltip code="attachment.add.tooltip.label" var="addCommentTooltip" modifierKey="ALT" />
	<div class="addCommentControl" data-planner-role="add-comment" style="text-align: center">
		<a href="#" title="${addCommentTooltip}" class="actionLink addAttachmentIcon" onclick="addCommentInOverlay(${review == null ? item.id : review.id}); return false;"><spring:message code="attachment.add.label" text="Add Comment/Attachment"/></a>
	</div>
</c:if>

<script type="text/javascript">


	function loadAllComment(){
		var url = window.location.href;
		var taskId = ${review == null ? item.id : review.id};

		var $comments = $("#comments");
		$comments.empty();
		var busySign = ajaxBusyIndicator.showBusysign($comments, i18n.message("ajax.loading"), false);

		$.ajax({
			"url": contextPath + "/trackers/ajax/getIssueComments.spr",
			"type": "GET",
			"data": {
				"task_id": taskId
			},
			"success": function(data) {
				if (busySign) {
					ajaxBusyIndicator.close(busySign);
				}
				$comments.html(data);

				$comments.find(".yuimenubar").each(function() {
					var actionMenuId = $(this).attr("id");
					initPopupMenu(actionMenuId, {
						context: [actionMenuId, 'tl', 'bl', ['beforeShow', 'windowResize']]
					});
				});
			},
			"error": function () {
				if (busySign) {
					ajaxBusyIndicator.close(busySign);
				}
			},
			"cache": false // no caching because IE cannot handle it correctly
		});
	}

</script>

<div id="comments" data-planner-role="comments" data-document-view-role="comments">
	<jsp:include page="comments.jsp"/>
</div>
