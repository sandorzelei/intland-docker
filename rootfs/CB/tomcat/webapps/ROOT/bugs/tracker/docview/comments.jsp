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
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>

<input type="hidden" name="issueId" value="${item.id}"/>

<c:if test="${empty showAllComment}">
	<c:set var="showAllComment" value="true"></c:set>
</c:if>

<c:choose>
	<c:when test="${empty itemAttachments}">
		<div class="subtext commentGroup">
			<spring:message code="document.commentsAndAttachments.none" text="No comments"/>
		</div>
	</c:when>
	<c:when test="${not showAllComment}">
		<c:set var="attachmentCount" value="${fn:length(itemAttachments)}"/>
		<c:set var="maxVisibleComment" value="10"/>

		<c:forEach begin="0" end="${maxVisibleComment-1}" items="${itemAttachments}" var="comment">
			<c:if test="${comment != null && comment.dto != null }">
				<ct:call object="${comment.dto }" method="getAttribute" param1="commentType" return="commentType"/>
			</c:if>

			<div class="commentGroup ${commentType }">
				<div class="commentMeta">
					<tag:userLink user_id="${comment.dto.owner.id}"/>
					<span class="subtext"><tag:formatDate value="${comment.dto.createdAt}"/></span>
					<span style="float: right"><ui:actionMenu builder="trackerItemAttachmentListContextActionMenuBuilder" subject="${comment}" keys="editDocumentView,deleteAjax"/></span>
				</div>
				<div class="commentContent">
					<tag:transformText owner="${comment.trackerItem}" value="${comment.dto.description}" format="${comment.dto.descriptionFormat}" />
				</div>
				<c:if test="${!empty comment.attachments}">
					<div class="attachments">
						<table cellpadding="0" cellspacing="0">
						<c:forEach var="file" items="${comment.attachments}">
							<tr>
								<td class="commentListFileItem textData" valign="middle">
									<ui:trackerItemAttachmentLink trackerItemAttachment="${file}" revision="${file.baseline.id}" newskin="true"/>
								</td>
								<td class="commentListFileItem subtext" valign="middle">
									<c:set var="attachmentLength" value="${file.dto.fileSize}" />
									<span class="subtext"><tag:formatFileSize value="${attachmentLength}" /></span>
								</td>
								<td class="commentListFileItem" style="position: relative; top: -3px" valign="middle">
									<ui:actionMenu builder="trackerItemAttachmentListContextActionMenuBuilder" subject="${file}"  keys="download, deleteAjax"/>
								</td>
							</tr>
						</c:forEach>
						</table>
					</div>
				</c:if>

				<c:if test="${showItemLink && comment.trackerItem != null }">
					<div class=" replyToContainer">
						<ui:itemLink item="${comment.trackerItem}"></ui:itemLink>
					</div>
				</c:if>
			</div>
		</c:forEach>
		<c:if test="${maxVisibleComment < attachmentCount}">
			<div style="text-align: center">
				<a class="actionLink" href="#" onclick="loadAllComment();">
					<spring:message code="comments.attachments.showAll" text="Show All ({0})" arguments="${fn:length(itemAttachments)}"/>
				</a>
			</div>
		</c:if>
	</c:when>
	<c:otherwise>
		<c:forEach items="${itemAttachments}" var="comment">
			<div class="commentGroup">
				<div class="commentMeta">
					<tag:userLink user_id="${comment.dto.owner.id}"/>
					<span class="subtext"><tag:formatDate value="${comment.dto.createdAt}"/></span>
					<span style="float: right"><ui:actionMenu builder="trackerItemAttachmentListContextActionMenuBuilder" subject="${comment}" keys="editDocumentView,deleteAjax"/></span>
				</div>
				<div class="commentContent">
					<tag:transformText owner="${comment.trackerItem}" value="${comment.dto.description}" format="${comment.dto.descriptionFormat}" />
				</div>
				<c:if test="${!empty comment.attachments}">
					<div class="attachments">
						<c:forEach var="file" items="${comment.attachments}">
							<div><ui:trackerItemAttachmentLink trackerItemAttachment="${file}" newskin="true"/></div>
						</c:forEach>
					</div>
				</c:if>

				<c:if test="${showItemLink && comment.trackerItem != null }">
					<div class=" replyToContainer">
						<ui:itemLink item="${comment.trackerItem}"></ui:itemLink>
					</div>
				</c:if>
			</div>
		</c:forEach>
	</c:otherwise>
</c:choose>
