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
<%@ page import="com.intland.codebeamer.persistence.util.TrackerItemAttachmentRevision" %>
<%@ page import="com.intland.codebeamer.persistence.dto.ReviewItemDto" %>
<%@ taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="tag" uri="taglib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="callTag" prefix="ct" %>

<jsp:useBean id="decorated" beanName="decorated" scope="request" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" />

<c:choose>
	<c:when test="${fn:length(itemAttachments.list) > 0}">

		<c:url value="/review/${review.id }/feedback" var="requestURI"></c:url>
		<display:table excludedParams="orgDitchnetTabPaneId reviewId" class="expandTable" requestURI="${requestURI}"
					   name="${itemAttachments}" id="commentNode" cellpadding="0" export="false" pagesize="${pageSize }">

			<c:set var="attachment" value="${commentNode.attachment }" scope="request"></c:set>

			<c:if test="${attachment != null && attachment.dto != null }">
				<ct:call object="${attachment.dto }" method="getAttribute" param1="commentType" return="commentType"/>
			</c:if>
			<jsp:useBean id="attachment" beanName="attachment" scope="request" type="com.intland.codebeamer.persistence.util.TrackerItemAttachmentRevision" />

			<c:if test="${attachment != null && attachment.dto != null }">
				<spring:message var="submittedTitle" code="comment.submittedAt.label" text="Submitted"/>
				<display:column title="${submittedTitle}"  sortable="false" headerClass="textData"
					class="textData columnSeparator assocSubmitterCol comment-${attachment.dto.id} ${attachment.replyTo != null ? 'reply' : '' } ${commentType } ${commentNode.addedBeforeReview ? 'added-before-review' : '' }"
								style="width:10%; padding-top:2px; padding-bottom:15px;">
					<ui:submission userId="${attachment.dto.owner.id}" userName="${attachment.dto.owner.name}" date="${attachment.dto.createdAt}"/>
				</display:column>
			</c:if>

			<c:if test="${attachment != null}">
				<spring:message var="commentTitle" code="comment.label" text="Comment"/>
				<display:column title="${commentTitle}"  sortable="false" headerClass="textData"
					class="textDataWrap ${empty attachment.attachments ? 'classComment' : 'classAttachment'} ${commentNode.addedBeforeReview ? 'added-before-review' : '' } thumbnailImages thumbnailImages800px
						level-${commentNode.level } ${attachment.replyTo != null ? 'reply' : '' }  ${commentType }">

					<c:if test="${commentNode.addedBeforeReview}">
						<div style="display:block;">
							<div class="smallWarning">
								<spring:message code="review.comments.added.before.review" text="This comment was added before this review started"/>
							</div>
						</div>
					</c:if>
					<c:if test="${canAddComment }">
						<div class="reply-to-box">
							<a class="actionLink reply-to" data-comment-id="${attachment.dto.id }" data-task-id="${attachment.trackerItem.id }">
								<spring:message code="action.reply.label" text="Reply"/>
							</a>
							<c:if test="${not empty commentType }">
								<span class="subtext commentType"><spring:message code="review.comment.type.${commentType }.label"/></span>
							</c:if>
						</div>
					</c:if>

					<span class="replied"></span>
					<tag:transformText owner="${attachment.trackerItem}" value="${attachment.dto.description}" format="${attachment.dto.descriptionFormat}" />
					<c:if test="${!empty attachment.attachments}">
						<table cellspacing="0" cellpadding="0">
							<c:forEach var="file" items="${attachment.attachments}">
								<tr>
									<td class="commentListFileItem textData" valign="middle">
										<ui:trackerItemAttachmentLink trackerItemAttachment="${file}" revision="${file.baseline.id}" newskin="true"/>
									</td>
									<td class="commentListFileItem subtext" valign="middle">
										<c:set var="attachmentLength" value="${file.dto.fileSize}" />
										<span class="subtext" title="${titleLengthValue}"><tag:formatFileSize value="${attachmentLength}" /></span>
									</td>
									<td class="commentListFileItem" valign="middle">
										<%-- <ui:actionMenu builder="trackerItemAttachmentListContextActionMenuBuilder" subject="${file}"/>--%>
									</td>
								</tr>
							</c:forEach>
						</table>
					</c:if>

					<c:set var="visibility" value="<%=decorated.getVisibility((TrackerItemAttachmentRevision)attachment)%>"/>
					<c:if test="${!empty visibility}">
						<p class="subtext" style="margin-bottom:0;" title="<spring:message code='issue.attachment.limited.visibility.tooltip'/>">
							<img src='<c:url value="/images/shield.png"/>' style="vertical-align: bottom;" />
							<spring:message code="issue.attachment.limited.visibility.info" arguments="${visibility}" argumentSeparator="|"/>
						</p>
					</c:if>

					<c:if test="${attachment.trackerItem != null }">
						<div class=" replyToContainer">
							<c:set var="isReviewItem" value="<%= attachment.getTrackerItem() instanceof ReviewItemDto %>"/>
							<c:choose>
								<c:when test="${attachment.trackerItem.tracker.review and isReviewItem and attachment.trackerItem.reviewItem != null}">
									<ui:itemLink item="${attachment.trackerItem.reviewItem}" showVersionBadge="true"></ui:itemLink>
								</c:when>
								<c:otherwise>
									<ui:itemLink item="${attachment.trackerItem}" showVersionBadge="true"></ui:itemLink>
								</c:otherwise>
							</c:choose>

						</div>
					</c:if>

				</display:column>
			</c:if>

		</display:table>
		<ui:displaytagPaging defaultPageSize="${pageSize }" items="${itemAttachments}" excludedParams="page reviewId"/>


	</c:when>
	<c:otherwise>
		<table id="emptyAttachment" class="expandTable displaytag">
			<thead>
				<tr>
					<th>&nbsp;</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td><spring:message code="table.nothing.found"/></td>
				</tr>
			</tbody>
		</table>
	</c:otherwise>
</c:choose>

<script type="text/javascript">
	$(function () {
		$(document).on('click', '.reply-to', function () {
			var $link = $(this);
			var taskId = $link.data("taskId");
			var artifactId = $link.data("commentId");

			var url = contextPath + '/proj/tracker/docview/showCommentDialog.spr?task_id=' + taskId + '&artifact_id=' + artifactId + '&reply=true&showCommentTypes=true';
			showPopupInline(url, {'geometry': 'large'});
		});
	});

	function refreshAfterComment() {
		location.reload();
	}
</script>