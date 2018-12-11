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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<c:set var="hideClosed" scope="request" value="true"/>
<c:set var="showStoryPointsStats" scope="request" value="true"/>
<c:set var="showTotals" scope="request" value="true"/>
<c:set var="showOnlineIndicator" scope="request" value="true"/>

<c:choose>
	<c:when test="${!empty issueStatsByAssignee && !empty issueStatsByAssignee.groups}">
		<div id="versionStatsBox" class="versionStatsBox plannerTeamCommitment" title="<spring:message code='cmdb.version.stats.filter.tooltip'/>">
			<jsp:include page="/bugs/tracker/includes/issueStatsByAssignee.jsp"/>
		</div>
	</c:when>
	<c:otherwise>
		<spring:message code="planner.member.section.empty.hint" text="Please add at least one open tracker item."/>
	</c:otherwise>
</c:choose>
