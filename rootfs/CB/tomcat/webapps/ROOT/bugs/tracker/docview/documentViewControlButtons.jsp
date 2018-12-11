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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<jsp:useBean id="decorated" beanName="decorated" scope="request" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" />

<%--
	renders the document view control buttons (status/transition change, new comment, new referring item etc) for a row on the document view.
 --%>

<c:set var="isGroupingItem" value="${item.groupingItem}"/>
<spring:message code="tracker.view.layout.document.add.comment.tooltip" text="Click to view comments or add one ..." var="addCommentTitle"/>

<span class="compact-mode-button"></span>
<div class="controls">
	<ui:coloredEntityIcon subject="${item}" iconUrlVar="imgUrl" iconBgColorVar="iconBgColor"/>
	<spring:message code="tracker.view.layout.document.referring.item.tooltip" text="Click here to create new referring items" var="referringTooltip"/>
	<spring:message code="tracker.view.layout.document.transition.tooltip" var="transitionTooltip" text="Click to view the available transitions"/>
	<c:choose>
		<c:when test="${!isGroupingItem}">
			<c:if test="${decorated.statusVisible}">
				<div style="margin-top: 11px;">
					<c:choose>
						<c:when test="${empty baseline and hasDocViewLicense}">
							<img style="background-color:${iconBgColor}" src="<c:url value="${imgUrl}"/>" class="item-icon" title="${transitionTooltip }"/>
						</c:when>
						<c:otherwise>
							<img style="background-color:${iconBgColor}" src="<c:url value="${imgUrl}"/>"/>
						</c:otherwise>
					</c:choose>
				</div>
			</c:if>
			<c:if test="${enableRating && empty baseline}">
				<c:set var="ratingClass" value=""/>
				<c:if test="${ratings[item.id] != null }">
					<c:set var="ratingClass" value="rated-${ratings[item.id] }"/>
				</c:if>

				<div class="rating-container ${ratingClass}" data-issueid="${item.id }" id="rating_${item.id }" title="${ratingHoverTitle}">
				</div>
			</c:if>
			<c:if test="${issueIsEditable and (thisSummaryEditable or descriptionEditable[item])}">
				<div class="edit-overlay-container">
					<div class="edit-overlay">
						<spring:message code="tracker.view.layout.document.edit.description.tooltip"
							text="Click here to edit the description" var="editDescriptionTooltip"/>
						<div class="edit-button edit-description" title="${editDescriptionTooltip}"></div>
						<c:if test="${officeEditEnabled && thisDescriptionEditable }">
							<spring:message code="tracker.view.layout.document.edit.in.word.tooltip"
								text="Click here to edit the item in Microsoft Word" var="editInWordTooltip"/>
							<div class="edit-button edit-in-word" title="${editInWordTooltip}"></div>
						</c:if>
					</div>
				</div>
			</c:if>
			<c:if test="${empty baseline}">
				<div class="comments">
					<span class="comment-bubble" data-id="${item.id }" data-canview="${canViewCommentsAttachments}" title="${addCommentTitle}">
						${fn:length(decorated.attachments)}
					</span>
					<span class="comment-bubble-arrow"></span>
				</div>
				<c:if test="${showReferingItems}">
					<div class="referring-items" title="${referringTooltip}"></div>
				</c:if>
			</c:if>
		</c:when>
		<c:otherwise>
			<img style="background-color:${iconBgColor}; margin-top: 12px;" src="<c:url value="${imgUrl}"/>"/>
			<span style="display: none" class="comment-bubble" data-id="${item.id }" data-canview="${canViewCommentsAttachments}" title="${addCommentTitle}">
				${fn:length(decorated.attachments)}
			</span>
			<c:if test="${isRequirementOrStoryTracker && empty baseline}">
				<div class="referring-items folder-menu" title="${referringTooltip}"></div>
			</c:if>
		</c:otherwise>
	</c:choose>
</div>