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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="callTag" prefix="ct" %>

<link rel="stylesheet" href="<ui:urlversioned value='/bugs/includes/itemReviewStats.less' />" type="text/css" media="all" />

<c:forEach items="${itemReviewStats }" var="group">
	<div class="reviewStatsBox ${group.key.review.resolvedOrClosed ? 'closed' : 'open' } ${group.key.reviewCast.mergeRequest ? 'merge-request' : ''}">
		<c:if test="${empty reviewItemId}">
			<c:url var="itemUrl" value="${group.key.review.urlLink }"/>
			<strong class="review-item-name"><a href="${itemUrl }"><c:out value="${group.key.review.name }"></c:out></a></strong>
		</c:if>

		<c:set var="userStats" value="${itemReviewStatsCombined[group.key] }"></c:set>


		<div>
			<spring:message code="review.statistics.started.by.label" text="Started by"/>:
			<span class="link-and-date">
				<tag:userLink user_id="${group.key.review.submitter }"></tag:userLink>
				<c:choose>
					<c:when test="${not empty group.key.review.startDate }">
						<span class="subtext date"><tag:formatDate value="${group.key.review.startDate }"></tag:formatDate></span>
					</c:when>
					<c:otherwise>
						<span class="subtext date"><spring:message code="review.statistics.date.not.defined" text="Undefined"/></span>
					</c:otherwise>
				</c:choose>
			</span>,

			<c:set var="currentReview" value="${group.key.reviewCast }"></c:set>
			<spring:message code="review.statistics.signed.by.label" text="Signed by"/>:
			<c:choose>
				<c:when test="${currentReview.signedBy != null }">

					<span class="link-and-date">
						<tag:userLink user_id="${currentReview.signedBy }"></tag:userLink>
						<c:choose>
							<c:when test="${not empty currentReview.signedAt }">
								<span class="subtext date"><tag:formatDate value="${currentReview.signedAt }"></tag:formatDate></span>
							</c:when>
							<c:otherwise>
								<span class="subtext date"><spring:message code="review.statistics.date.not.defined" text="Undefined"/></span>
							</c:otherwise>
						</c:choose>
					</span>
				</c:when>
				<c:otherwise>
					<span class="subtext"><spring:message code="review.statistics.not.signed" text="Not Signed"/></span>
				</c:otherwise>
			</c:choose>
		</div>

		<c:set var="greenPercentage" value="${(userStats.accepted * 100.0) / userStats.total}" />
		<c:set var="redPercentage" value="${(100.0 * userStats.rejected) / userStats.total}" />
		<c:set var="grayPercentage" value="${100.0 - greenPercentage - redPercentage}" />
		<fmt:formatNumber var="sprintProgressBarLabel" value="${greenPercentage}" maxFractionDigits="0"/>

		<span class="referenceSettingBadge versionSettingBadge">v${group.key.reviewItem.version }</span>
		<div class="progressBarContainer">
			<ui:progressBar redTitle="${userStats.rejected }" greenTitle="${userStats.accepted }" greyTitle="${userStats.total - userStats.rejected - userStats.accepted }"
				redPercentage="${redPercentage }" greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}"
				totalPercentage="100" label="" hideTotal="true"/>
		</div>

		<table class="itemReviewStats propertyTable">
			<c:forEach items="${group.value }" var="statEntry">
				<tr>
					<td class="tableItem">
						<ct:call object="${group.key }" method="getLastStatusCommentByUser" param1="${statEntry.key}" return="lastStatusComment"/>
						<tag:userLink user_id="${statEntry.key.id }"></tag:userLink>
						<c:choose>
							<c:when test="${lastStatusComment != null }">
								<span class="subtext"><tag:formatDate value="${lastStatusComment.createdAt}"/></span>
							</c:when>
							<c:when test="${statEntry.value.statusId != 3}">
								<span class="subtext">--</span>
							</c:when>
						</c:choose>
					</td>
					<td class="tableItem">
						<spring:message code="review.${statEntry.value}.label" var="title"/>
						<span class="stat ${statEntry.value }" title="${title }"></span>
					</td>
				</tr>
			</c:forEach>
		</table>
	</div>
</c:forEach>