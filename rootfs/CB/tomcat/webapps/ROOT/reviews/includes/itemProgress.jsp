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
--%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemRevisionDto"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@ page import="com.intland.codebeamer.persistence.dto.ReviewItemDto"%>

<style type="text/css">
	.reviewMergedBadge {
		position: relative;
    	top: 2px;
	}
</style>

<%-- this bean is used for finding out if a summary is visible or not --%>
<jsp:useBean id="decorated" beanName="decorated" scope="request" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" />

<c:if test="${not empty statsPerItem}">
	<display:table  excludedParams="page" name="${statsPerItem.entrySet()}" id="entry" cellpadding="0" sort="external" class="item-progress" >
		<c:set var="item" value="${entry.key }"></c:set>
		<jsp:useBean id="item" beanName="item" type="com.intland.codebeamer.persistence.dto.TrackerItemDto" />

		<%
			decorated.initRow(new TrackerItemRevisionDto(new ReviewItemDto(item).getReviewItem(), null, null), 0, 0);
		%>
		<c:set var="itemStats" value="${entry.value }"></c:set>
		<c:set var="nameVisible" value="${decorated.nameVisible }"/>
		<c:set var="statusEditable" value="${decorated.editableByUser}"/>

		<c:if test="${nameVisible && empty item.name }">
			<spring:message code="tracker.view.layout.document.no.summary" text="[No Summary]" var="itemName"/>
		</c:if>

		<spring:message code="tracker.field.Name.label" var="nameLabel" text="Name"></spring:message>
		<display:column title="${nameLabel }">

			<c:if test="${not empty item.reviewItem }">
				<ui:wikiLink item="${item.reviewItem}" showSuspectedBadge="${false}"/>

				<c:if test="${not itemStats.ambiguous and review.mergeRequest and review.resolvedOrClosed }">
					<span class="generalBadge reviewMergedBadge">
						<spring:message code="review.statistics.merged.label" text="Merged"></spring:message>
					</span>
				</c:if>
			</c:if>
			<c:if test="${empty item.reviewItem }">
				<spring:message code="tracker.view.layout.document.summary.not.readable" text="[Summary not readable]"></spring:message>
			</c:if>
		</display:column>

		<spring:message code="review.needMoreWork.label" text="Needs More Work" var="rejectedLabel"></spring:message>
		<display:column title="${rejectedLabel }" headerClass="numberData column-minwidth" class="numberData column-minwidth">
			<span class="stat rejected">${itemStats.rejected }</span>
		</display:column>

		<spring:message code="review.approved.label" text="Approved" var="approvedLabel"></spring:message>
		<display:column title="${approvedLabel }" headerClass="numberData column-minwidth" class="numberData column-minwidth">
			<span class="stat accepted">${itemStats.accepted }</span>
		</display:column>

		<spring:message code="review.notReviewed.label" text="Not Reviewed" var="notReviewedLabel"></spring:message>
		<display:column title="${notReviewedLabel }" headerClass="numberData column-minwidth" class="numberData column-minwidth">
			${itemStats.notReviewed }
		</display:column>

		<spring:message code="comments.label" text="Comments" var="commentsLabel"></spring:message>
		<display:column title="${commentsLabel}" headerClass="numberData column-minwidth" class="numberData column-minwidth">
			${itemStats.comments }
		</display:column>

		<c:if test="${showActions }">
			<spring:message code="review.action.label" var="actionLabel" text="Action"/>
			<display:column title="${actionLabel}" headerClass="column-minwidth" class="column-minwidth">
				<c:choose>
					<c:when test="${nameVisible and statusEditable}">
						<div class="action disabled" data-tracker-id="${item.reviewItem.tracker.id }">
							<div class="smallWarning permission">
								<spring:message code="review.done.mapping.not.selected.warning" text="Please select the status mappings for the tracker of this item"/>
							</div>
							<c:if test="${updatedItems[item.reviewItem.id] != null }">
								<div class="smallWarning updated">
									<spring:message code="review.done.mapping.item.updated.warning"
									text="This item has been updated since the review started"/>
								</div>
							</c:if>
							<form:select path="statusChanges[${item.reviewItem.id}]" cssClass="mapper ${itemStats.combinedStatus }" id="${item.reviewItem.id }">
								<c:set var="ambiguous" value="${itemStats.ambiguous}"/>
								<option value="DoNotChange" ${ambiguous ? "selected='selected'" : '' } title='<spring:message code="review.done.dont.change.status.title"/>'>
									<spring:message code="review.done.dont.change.status.label" text="Do not change the status"/>
								</option>
								<option value="SetToApproved" ${not ambiguous and itemStats.accepted > 0 ? "selected='selected'" : '' } title='<spring:message code="review.done.set.approved.status.title"/>'>
									<spring:message code="review.done.set.approved.status.label" text="Set to Approved status"/>
								</option>
								<option value="SetToRejected" ${not ambiguous and itemStats.rejected > 0 ? "selected='selected'" : '' } title='<spring:message code="review.done.set.approved.status.title"/>'>
									<spring:message code="review.done.set.rejected.status.label" text="Set to Rejected status"/>
								</option>
							</form:select>
						</div>
					</c:when>
					<c:otherwise>
						<div class="smallWarning">
							<spring:message code="review.complete.item.not.editable.warning" text="Item not editable"></spring:message>
						</div>
					</c:otherwise>
				</c:choose>

			</display:column>
		</c:if>
	</display:table>
</c:if>