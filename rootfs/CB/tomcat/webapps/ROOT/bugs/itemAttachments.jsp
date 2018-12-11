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
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<spring:message var="addCommentViaOfficeTooltip" code="document.officeEdit.comment.add.tooltip"/>

<style type="text/css">
.separator {
	height: 20px;
	width: 1px;
	display: inline;
	padding-left: 5px;
	border-left: solid 1px #d1d1d1;
}

.show-all-link {
	font-size: 14px;
	color: #0093b8;
	margin-top: 25px;
	padding-top: 10px;
	width: 100%;
}

.commentTableWrapper {
	display: block;
	width: 100%;
	max-width: 1800px;
}

</style>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
function showSelectedCommentTypes(selector) {
	var showComments = true, showAttachments = true;
	switch (selector.value) {
		case "comments":
			showAttachments = false;
			break;
		case "attachments":
			showComments = false;
			break;
		case "all":
			// show all is the default
			break;
	}
	$(".classComment").each(function(index) {
    	$(this).closest("tr").toggle(showComments);
	});
	$(".classAttachment").each(function(index) {
    	$(this).closest("tr").toggle(showAttachments);
	});
}

function reloadWithAllComment(callback){
	var $tab = $("#task-details-attachments");
	var busyDialog = ajaxBusyIndicator.showBusyPage();

	var reInitActionMenus = function($container) {
		$container.find(".yuimenubar").each(function() {
			var actionMenuId = $(this).attr("id");
			initPopupMenu(actionMenuId, {
				context: [actionMenuId, 'tl', 'bl', ['beforeShow', 'windowResize']]
			});
		});
	};

	$.ajax({
		type: "GET",
		url: contextPath + "/ajax/tracker/renderAllComments.spr",
		dataType: "html",
		data: {
			itemId: ${not empty task.id ? task.id : 'undefined'}
		}
	}).done(function(html) {
		var $result = $("<div>").html(html);
		$tab.find(".information").remove();
		$tab.find("#attachment").remove();
		$tab.append($result.find("#attachment"));
		reInitActionMenus($("#attachment"));
		if (callback) {
			callback();
		}
	}).always(function() {
		ajaxBusyIndicator.close(busyDialog);
	});

	return false;
}

$(function() {

	var markAndScrollToComment = function(commentDiv) {
		var selectedRow = commentDiv.closest(".even, .odd");
		if(selectedRow.length > 0){
			var actionMenu = selectedRow.find("td.action-column-minwidth > div.positionWrapper > div.yuimenubar");
			actionMenu = selectedRow.find(".action-column-minwidth").find(".yuimenubar");
			selectedRow.addClass('trackerItemDetailsCommentDirectLink');
			actionMenu.css('background-color', 'transparent');
			$('html, body').animate({
				scrollTop: commentDiv.offset().top
			}, 500, function() {
				flashChanged(selectedRow);
			});
		}

	};

	var hash = getLocationHash();
	if (hash){
		if (hash.indexOf("comment-") > -1){
			// select comments/attachments tab
			org.ditchnet.jsp.TabUtils.switchTab(document.getElementById("task-details-attachments-tab"));

			var commentDiv = $("." + hash).first();
			if (commentDiv.length == 1){
				markAndScrollToComment(commentDiv);
			} else {
				reloadWithAllComment(function() {
					markAndScrollToComment($("." + hash).first());
				});
			}
		}
	}

	var scrollToComment = function(row) {
		$("html, body").animate({
			scrollTop: row.offset().top
		}, 500, function() {
			flashChanged(row);
		});
	};

	$("#task-details-attachments").on( "click", ".replyToLink", function() {
		var parentId = $(this).attr("data-parent-id");
		var row = $("#attachment").find(".comment-" + parentId).closest("tr");
		if (row.length > 0) {
			scrollToComment(row);
		} else {
			reloadWithAllComment(function() {
				scrollToComment($("#attachment").find(".comment-" + parentId).closest("tr"));
			});
		}
		return false;
	});
});

</SCRIPT>

<c:if test="${empty param.showActionBar || param.showActionBar ne false}">
<div class="addCommentBar">
	<jsp:include page="inlineComment.jsp"/>
</div>
</c:if>

<jsp:include page="renderComments.jsp"/>

<c:if test="${showAllButton eq true}">
	<c:set var="attachmentCount" value="${fn:length(itemAttachments)}" />
	<c:if test="${not empty attachmentFullCount}">
		<c:set var="attachmentCount" value="${attachmentFullCount}" />
	</c:if>
	<div class="information">
		<spring:message code="comments.attachments.paged" text="Only the last {0} comment/attachment loaded." arguments="${fn:length(itemAttachments)}"/>
		<a href="#" onclick="reloadWithAllComment(); return false;" class="show-all-link">
			<spring:message code="comments.attachments.showAll" text="Show All ({0})" arguments="${attachmentCount}"/>
		</a>
	</div>
</c:if>
