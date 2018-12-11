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
<%@ taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="tag" uri="taglib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<meta name="module" content="tracker"/>

<jsp:useBean id="decorated" beanName="decorated" scope="request" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" />

<c:choose>
	<c:when test="${fn:length(itemAttachments) > 0}">

		<display:table excludedParams="orgDitchnetTabPaneId" class="expandTable trackerItemDetailsComment" requestURI="${requestURI}"
					   name="${itemAttachments}" id="attachment" cellpadding="0"
					   defaultsort="1" defaultorder="descending" export="false">

			<c:if test="${attachment != null && attachment.dto != null }">
				<spring:message var="submittedTitle" code="comment.submittedAt.label" text="Submitted"/>
				<display:column title="${submittedTitle}" sortProperty="dto.createdAt" sortable="true" headerClass="textData" class="textData columnSeparator comment-${attachment.dto.id}"
								style="width:9%; padding-top:2px; padding-bottom:15px;">
					<ui:submission userId="${attachment.dto.owner.id}" userName="${attachment.dto.owner.name}" date="${attachment.dto.createdAt}" lastModifiedAt="${attachment.dto.version gt 1 ? attachment.dto.lastModifiedAt : null}" 
						lastModifiedBy="${attachment.dto.lastModifiedBy.id}" cssStyle="margin-left: -10px;" />
				</display:column>
			</c:if>

			<c:if test="${attachment != null}">
				<spring:message var="commentTitle" code="comment.label" text="Comment"/>
				<display:column title="${commentTitle}" sortProperty="dto.description" sortable="true" headerClass="textData" class="textDataWrap ${empty attachment.attachments ? 'classComment' : 'classAttachment'} ${extraClass } thumbnailImages thumbnailImages800px">
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
										<ui:actionMenu builder="trackerItemAttachmentListContextActionMenuBuilder" subject="${file}" keys="download,delete" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
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

					<c:if test="${not empty attachment.replyTo}">
						<c:set var="replyTo" value="${attachment.replyTo}"/>
						<p class="subtext replyToContainer">
							<spring:message code="comment.this.is.reply.part1"/> <a title="<spring:message code="comment.scroll.to.parent.tooltip"/>" href="#" class="replyToLink" data-parent-id="${replyTo.id}" style="font-size: 11px !important;"><spring:message code="comment.this.is.reply.part2"/></a> <spring:message code="comment.this.is.reply.part3"/>
						</p>
					</c:if>

					<c:set var="subscription" value="${commentSubscriptions[attachment.id]}"/>
					<c:if test="${not empty subscription}">
						<p class="subtext commentSubscriptionContainer">
							<spring:message code="comment.subscription.subscribers.label"/>:
							<c:forEach var="subscriptionUserId" items="${subscription.userIds}" varStatus="loop">
								<tag:userLink user_id="${subscriptionUserId}"/><c:if test="${!loop.last}"> |</c:if>
							</c:forEach><c:if test="${not empty subscription.emailAddresses}">|</c:if><c:forEach var="subscriptionEmail" items="${subscription.emailAddresses}" varStatus="loop">
								<a href="mailto:${subscriptionEmail}"><c:out value="${subscriptionEmail}"/></a><c:if test="${!loop.last}"> |</c:if>
							</c:forEach>
						</p>
					</c:if>

				</display:column>
			</c:if>

			<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html"
							class="action-column-minwidth">
				<ui:actionMenu builder="trackerItemAttachmentListContextActionMenuBuilder" subject="${attachment}" keys="reply,directurl,download,edit,officeedit,delete" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
			</display:column>

		</display:table>
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