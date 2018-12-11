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
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%-- JSP fragment for showing the table of Document or Wiki comments
	Parameters:
	param.requestURI		The uri called by displaytag to reorder table
	request.comments		The list of comments to show
--%>
<c:set var="requestURI" value="${param.requestURI}" />

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
function confirmDeleteComment(docId,commentId) {
	var message = i18n.message('tracker.delete.comment.confirm');
	if (docId && commentId) {
		if (confirm(message)) {
			url = '<c:url value="/proj/doc/deleteComment.do?&action=DELETE&delsingle=true"/>';
			url += '&docId=' + docId;
			url += '&commentId=' + commentId;
			document.location.href = url;
		}
		return false;
	} else {
		return confirm(message);
	}
}

var commentsFilter = {

	updateMenu: function(commentsTableSelector) {
		var rowsByType = commentsFilter._filterRowsByType(commentsTableSelector);

		var $filterMenu= $(".commentsFilter").find(".yuimenuitem");
		var $showCommentsMenu = $filterMenu.eq(0).find('a');
		var $showAttachmentsMenu = $filterMenu.eq(1).find('a');
		var $showCommentsAndAttachmentsMenu = $filterMenu.eq(2).find('a');

		var noOfComments = rowsByType.commentRows.length;
		var noOfAttachments = rowsByType.attachmentRows.length;

		// update menu texts
		$showCommentsMenu.text($showCommentsMenu.text().replace("0", noOfComments));
		$showAttachmentsMenu.text($showAttachmentsMenu.text().replace("0", noOfAttachments));
		$showCommentsAndAttachmentsMenu.text($showCommentsAndAttachmentsMenu.text().replace("0", noOfComments + noOfAttachments));
	},

	showSelectedCommentTypes: function(element, commentsTableSelector, typestring) {
		var rowsByType = commentsFilter._filterRowsByType(commentsTableSelector);
		switch (typestring) {
			case "showcomments":
				commentsFilter._toggle(rowsByType.commentRows, true);
				commentsFilter._toggle(rowsByType.attachmentRows, false);
				break;
			case "showattachments":
				commentsFilter._toggle(rowsByType.commentRows, false);
				commentsFilter._toggle(rowsByType.attachmentRows, true);
				break;
			default:
				commentsFilter._toggle(rowsByType.commentRows, true);
				commentsFilter._toggle(rowsByType.attachmentRows, true);
		}
		// move the check-mark to the current item
		$(element).closest("ul").find(".yuimenuitem-checked").removeClass("yuimenuitem-checked");
		$(element).addClass("yuimenuitem-checked");
	},

	_toggle: function(rows, show) {
		$.each(rows, function(index, value) {$(value).toggle(show);});
	},

	/**
	 * @param The jquery selector for the html table contains attachments and comments
	 * @return the comment only rows and the attachment rows from the table
	 */
	_filterRowsByType: function(commentsTableSelector) {
		var commentRows = [];
		var attachmentRows = [];
		$(commentsTableSelector + " > tbody > tr").each(function() {
			var $attachmentsTable = $(this).find(".commentFileTable");
			var isAttachment = $attachmentsTable.length > 0;
			if (isAttachment) {
				// $(this).css("border", "solid 1px red");
				attachmentRows.push(this);
			} else {
				// $(this).css("border", "solid 1px blue");
				commentRows.push(this);
			};
		});
		return {commentRows: commentRows, attachmentRows: attachmentRows};
	}

};

function showSelectedCommentTypes(element, typestring) {
	commentsFilter.showSelectedCommentTypes(element, "#comment", typestring);
}

$(document).ready(function() {
	commentsFilter.updateMenu("#comment");
});
</SCRIPT>

<display:table name="${docComments}" id="comment" requestURI="" excludedParams="orgDitchnetTabPaneId"
		defaultsort="1" defaultorder="descending" export="false" class="expandTable thumbnailImages" cellpadding="0"
		decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator">

  <ui:actionGenerator builder="artifactCommentActionMenuBuilder" actionListName="actions" subject="${comment}">

	<spring:message var="commentSubmitted" code="comment.submittedAt.label" text="Submitted"/>:
	<display:column title="${commentSubmitted}" sortProperty="sortCreatedAt" headerClass="textData" class="textData columnSeparator assocSubmitterCol"
		style="width:5%; padding-top:2px; padding-bottom:15px;">
		<ui:submission userId="${comment.dto.owner.id}" userName="${comment.dto.owner.name}" date="${comment.dto.createdAt}"/>
		<c:if test="${comment.dto.lastModifiedAt != comment.dto.createdAt}">
			<br/>
			<span class="subtext"><spring:message code="document.lastModifiedBy.label" text="Last modified"/>:</span>&nbsp;
			<tag:userLink user_id="${comment.dto.lastModifiedBy.id}"/>
			<br/>
			<span class="subtext"><tag:formatDate value="${comment.dto.lastModifiedAt}"/></span>
		</c:if>
	</display:column>

	<spring:message var="commentDescription" code="comment.description.label" text="Comment"/>:
	<display:column title="${commentDescription}" property="description" headerClass="textData" class="textDataWrap" />

	<display:column headerClass="textData" media="html" class="action-column-minwidth columnSeparator" style="width:20px">
		<ui:actionMenu actions="${actions}" keys="editComment, deleteComment" />
	</display:column>

  </ui:actionGenerator>

</display:table>
