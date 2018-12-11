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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<c:choose>
	<c:when test="${completedByCurrentUser}">
		<spring:message code="review.statistics.completed.by.user.title" text="You have reviewed all items in this review"
						var="reviewTickTitle"/>
		<span class="review-completed-icon" title="${pageScope.reviewTickTitle}"></span>
	</c:when>
	<c:otherwise>
		<span class="review-completed-placeholder"></span>
	</c:otherwise>
</c:choose>


<c:set var="greenPercentage" value="${(stats.accepted * 100.0) / stats.total}" />
<c:set var="redPercentage" value="${(100.0 * stats.rejected) / stats.total}" />
<c:set var="grayPercentage" value="${100.0 - greenPercentage - redPercentage}" />
<fmt:formatNumber var="sprintProgressBarLabel" value="${greenPercentage}" maxFractionDigits="0"/>
<ui:progressBar redTitle="${stats.rejected }" greenTitle="${stats.accepted }" greyTitle="${stats.total - stats.rejected - stats.accepted }"
	redPercentage="${redPercentage }" greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}"
	totalPercentage="100" label="" hideTotal="true"/>