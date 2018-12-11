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
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<style type="text/css">
	.miniprogressbar div.progressBarRed {
  		padding-bottom: 0px;
  	}

  	.expandTable.reviewProgress td {
  		vertical-align: middle
  	}

  	.expandTable.reviewProgress td .smallPhoto.photoBox {
  		vertical-align: middle;
  	}
</style>
<c:set var="reviewCompletionStatus" value="${review.reviewCompletionStatus}"/>

<display:table class="expandTable reviewProgress"  excludedParams="page" name="${stastPerUser.entrySet()}" id="entry" cellpadding="0" sort="external">
	<c:set var="userStats" value="${entry.value }"/>

	<spring:message code="issue.review.reviewer.label" text="Reviewer" var="nameLabel"></spring:message>
	<display:column title="${nameLabel }">
		<ui:userPhoto userId="${entry.key.id }"></ui:userPhoto>
		<tag:userLink user_id="${entry.key.id }"></tag:userLink>
	</display:column>

	<spring:message code="baseline.signed.label" text="Signed" var="signedLabel"/>
	<display:column headerClass="dateData column-minwidth fieldColumn columnSeparator" class="dateData column-minwidth fieldColumn columnSeparator" title="${signedLabel}">
		<c:choose>
			<c:when test="${review.isClosed(entry.key)}">
				<c:if test="${not empty reviewCompletionStatus and reviewCompletionStatus.getUserCompletionInfo(entry.key).isPresent()}">
					<c:set var="userInfo" value="${reviewCompletionStatus.getUserCompletionInfo(entry.key).get()}"/>
					<tag:formatDate value="${userInfo.signedAt }"></tag:formatDate>
				</c:if>
			</c:when>
			<c:otherwise>
				--
			</c:otherwise>
		</c:choose>
	</display:column>

	<spring:message code="review.progress.progress.label" text="Progress" var="progressLabel"></spring:message>
	<display:column title="${progressLabel }" headerClass="numberData column-minwidth" class="numberData columnSeparator column-minwidth">
		<fmt:formatNumber var="progressPercentage" value="${100 * userStats.progress }" maxFractionDigits="0"/>

		${progressPercentage }%
	</display:column>

	<display:column>
		<c:set var="greenPercentage" value="${(userStats.accepted * 100.0) / userStats.total}" />
		<c:set var="redPercentage" value="${(100.0 * userStats.rejected) / userStats.total}" />
		<c:set var="grayPercentage" value="${100.0 - greenPercentage - redPercentage}" />
		<fmt:formatNumber var="sprintProgressBarLabel" value="${greenPercentage}" maxFractionDigits="0"/>
		<ui:progressBar redTitle="${userStats.rejected }" greenTitle="${userStats.accepted }" greyTitle="${userStats.total - userStats.rejected - userStats.accepted }"
			redPercentage="${redPercentage }" greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}"
			totalPercentage="100" label="" hideTotal="true"/>

	</display:column>
</display:table>