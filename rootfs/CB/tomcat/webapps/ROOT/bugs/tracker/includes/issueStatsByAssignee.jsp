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
<%@page import="com.intland.codebeamer.persistence.dto.UserDto" %>
<%@page import="com.intland.codebeamer.manager.UserManager" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%--
Parameters:
    - cssClass: optional extra CSS classes to add
    - hideClosed: true/false, tells whether only open issues column should be shown
    - showTotals: true/false, tells whether to show totals in the bottom of the "Assignee" table or not
    - issueStatsByAssignee
    - showOnlineIndicator
--%>

<c:if test="${!empty issueStatsByAssignee && !empty issueStatsByAssignee.groups}">
	<table border="0" cellpadding="0" cellspacing="0">

		<tr class="odd">
			<td>
			</td>
			<td class="openIssueCell"><spring:message code="cmdb.version.issues.filter.open"/></td>
			<c:if test="${!hideClosed}">
				<td class="closedIssueCell"><spring:message code="cmdb.version.issues.filter.closed"/></td>
			</c:if>
		</tr>

		<c:set var="groups" scope="request" value="${issueStatsByAssignee.groups}"/>
		<c:set var="totals" scope="request" value="${issueStatsByAssignee.totals}"/>
		<c:forEach var="group" items="${groups}">
			<c:set var="group" scope="request" value="${group}"/>
			<c:set var="filterCategoryName" scope="request">assignedTo</c:set>
			<c:set var="filterCategoryValue" scope="request">${ui:escapeJavaScript(group.name)}</c:set>

			<c:set var="groupRendered" scope="request">
				<%
					// display an empty userPhoto for roles
					Object group = pageContext.findAttribute("group");
					Integer userId = group instanceof UserDto ? ((UserDto) group).getId() : Integer.valueOf(-1);
					pageContext.setAttribute("userId", userId);
					if (!userId.equals(Integer.valueOf(-1))) {
						pageContext.setAttribute("aliasName", UserManager.getInstance().getAliasName((UserDto) group));
					}

				%>
                   <div class='state-indicator'></div>
				<ui:userPhoto userId="${userId}" userName="" url="#"></ui:userPhoto>
				<div class="nameWithTeamContainer">
					<ui:nameWithTeamIndicators auxiliaryTeamContext="${auxiliaryTeamContext}" userId="${userId}">
						<c:choose><c:when test="${group.id eq -1}">--</c:when><c:when test="${userId > 0}">${aliasName}</c:when><c:otherwise>${group.name}</c:otherwise></c:choose>
					</ui:nameWithTeamIndicators>
				</div>
				<c:if test="${showOnlineIndicator}">
					<tag:userLoginIndicator userId="${userId}"></tag:userLoginIndicator>
				</c:if>
			</c:set>
			<c:set var="mergeOpenAndClosed" scope="request" value="false" />
			<c:set var="firstColumnClasses" scope="request" value="" />
			<c:set var="dataCollapseParentId" scope="request" value="issueStatsByAssignee"/>
			<jsp:include page="/bugs/tracker/versionStatsRow.jsp?cssClass=assigneeTable rowWithImage"/>
		</c:forEach>

		<c:if test="${showTotals}">
			<c:set var="notSelectable" value="true" scope="request" />
			<tr class="totals">
				<td class="firstColumn"><spring:message code="versionStatsBox.totals" text="Totals"/></td>
				<%-- Open issues --%>
				<c:set var="cellCssClass" value="openIssueCell" scope="request" />
				<c:set var="issueCount" value="${issueStatsByAssignee.aggregatedTotals.open}" scope="request" />
				<c:set var="storyPoints" value="${issueStatsByAssignee.aggregatedTotals.openStoryPoints}" scope="request" />
				<c:set var="storyPointsCssClass" value="open" scope="request" />
				<jsp:include page="versionStatsCellContents.jsp" />
				<c:if test="${!hideClosed}">
					<%-- Closed issues --%>
					<c:set var="cellCssClass" value="closedIssueCell" scope="request" />
					<c:set var="issueCount" value="${issueStatsByAssignee.aggregatedTotals.resolvedOrClosed}" scope="request" />
					<c:set var="storyPoints" value="${issueStatsByAssignee.aggregatedTotals.resolvedOrClosedStoryPoints}" scope="request" />
					<c:set var="storyPointsCssClass" value="closed" scope="request" />
					<c:set var="firstColumnClasses" scope="request" value="" />
					<jsp:include page="versionStatsCellContents.jsp" />
				</c:if>
			</tr>
			<c:remove var="notSelectable" scope="request" />
		</c:if>

	</table>

</c:if>