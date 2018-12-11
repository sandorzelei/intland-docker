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
<%@page import="com.intland.codebeamer.persistence.dto.base.NamedDto" %>
<%@page import="com.intland.codebeamer.ui.view.PriorityRenderer" %>
<%@page import="com.intland.codebeamer.manager.UserManager" %>
<%@page import="com.intland.codebeamer.persistence.dto.TrackerItemDto" %>
<%@page import="com.intland.codebeamer.persistence.dto.ReadOnlyStatusOptionDto" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%--
Parameters:
	- cssClass: optional extra CSS classes to add
	- versionStatsPageEventHandlers: true/false, tells whether version stats event handlers should be added or not
	- hideClosed: true/false, tells whether only open issues column should be shown
	- showTotals: true/false, tells whether to show totals in the bottom of the "Assignee" table or not
	- issueStatsByPriority
	- issueStatsByAssignee
	- issueStatsByType
	- issueStatsByProject
	- showStoryPointsStats
	- showOnlineState
--%>

<c:if test="${(!empty issueStatsByAssignee) and (issueStatsByAssignee.aggregatedTotals.storyPoints eq 0)}">
	<%-- No story points set yet, set showStoryPointsStats to false --%>
	<c:set var="showStoryPointsStats" value="${false}" scope="request" />
</c:if>

<div id="versionStatsBox" class="versionStatsBox versionStatsBoxAccordion accordion ${cssClass}" title="<spring:message code='cmdb.version.stats.filter.tooltip'/>">

	<div class="versionStatsBoxAccordion accordion">
		<c:set var="taskId" scope="request">${version.id}</c:set>

		<%-- Show teams, if there is at least 1 team, except when it is the special unassigned team. --%>
		<c:if test="${!empty issueStatsByTeam && !empty issueStatsByTeam.groups && !(fn:length(issueStatsByTeam.groups) eq 1 && issueStatsByTeam.groups[0].id eq -1)}">
			<h3 class="accordion-header"><spring:message code="cmdb.version.stats.team"/></h3>
			<div class="accordion-content" data-section-id="issueStatsByTeam">

				<table border="0" cellpadding="0" cellspacing="0">
					<tr class="odd">
						<td>
						</td>
						<td class="openIssueCell"><spring:message code="cmdb.version.issues.filter.open"/></td>
						<c:if test="${!hideClosed}">
							<td class="closedIssueCell"><spring:message code="cmdb.version.issues.filter.closed"/></td>
						</c:if>
					</tr>

					<c:set var="totals" scope="request" value="${issueStatsByTeam.totals}"/>
					<bugs:teamStatsRows groups="${issueStatsByTeam.groups}"/>

					<c:if test="${showTotals}">
						<c:set var="notSelectable" value="true" scope="request" />
						<tr class="totals">
							<td class="firstColumn"><spring:message code="versionStatsBox.totals" text="Totals"/></td>
							<%-- Open issues --%>
							<c:set var="script" scope="request" value="" />
							<c:set var="cellCssClass" value="openIssueCell" scope="request" />
							<c:set var="issueCount" value="${issueStatsByTeam.aggregatedTotals.open}" scope="request" />
							<c:set var="storyPoints" value="${issueStatsByTeam.aggregatedTotals.openStoryPoints}" scope="request" />
							<c:set var="storyPointsCssClass" value="open" scope="request" />
							<jsp:include page="versionStatsCellContents.jsp" />
							<c:if test="${!hideClosed}">
								<%-- Closed issues --%>
								<c:set var="script" scope="request" value="" />
								<c:set var="cellCssClass" value="closedIssueCell" scope="request" />
								<c:set var="issueCount" value="${issueStatsByTeam.aggregatedTotals.resolvedOrClosed}" scope="request" />
								<c:set var="storyPoints" value="${issueStatsByTeam.aggregatedTotals.resolvedOrClosedStoryPoints}" scope="request" />
								<c:set var="storyPointsCssClass" value="closed" scope="request" />
								<c:set var="firstColumnClasses" scope="request" value="" />
								<jsp:include page="versionStatsCellContents.jsp" />
							</c:if>
						</tr>
						<c:remove var="notSelectable" scope="request" />
					</c:if>
				</table>

			</div>
		</c:if>

		<h3 class="accordion-header"><spring:message code="cmdb.version.stats.members" text="Members"/></h3>
		<div class="accordion-content" data-section-id="issueStatsByAssignee">
			<c:set var="showOnlineIndicator" scope="request" value="${showOnlineState}"/>
			<jsp:include page="/bugs/tracker/includes/issueStatsByAssignee.jsp"/>
		</div>

		<h3 class="accordion-header"><spring:message code="project.label"/></h3>
		<div class="accordion-content" data-section-id="issueStatsByProject">
			<c:if test="${!empty issueStatsByProject && !empty issueStatsByProject.groups}">
				<table border="0" cellpadding="0" cellspacing="0">
					<tr class="odd">
						<td>
						</td>
						<td class="openIssueCell"><spring:message code="cmdb.version.issues.filter.open"/></td>
						<c:if test="${!hideClosed}">
							<td class="closedIssueCell"><spring:message code="cmdb.version.issues.filter.closed"/></td>
						</c:if>
					</tr>

					<c:set var="groups" scope="request" value="${issueStatsByProject.groups}"/>
					<c:set var="totals" scope="request" value="${issueStatsByProject.totals}"/>
					<c:forEach var="group" items="${groups}">
						<c:set var="group" scope="request" value="${group}"/>
						<c:set var="filterCategoryName" scope="request">project</c:set>
						<c:set var="filterCategoryValue" scope="request">${ui:escapeHtml(group.name)}</c:set>

						<c:set var="groupRendered" scope="request"><div class='state-indicator'></div> ${group.name}</c:set>
						<c:set var="mergeOpenAndClosed" scope="request" value="false" />
						<c:set var="firstColumnClasses" scope="request" value="" />
						<c:set var="dataCollapseParentId" scope="request" value="issueStatsByProject"/>

						<jsp:include page="/bugs/tracker/versionStatsRow.jsp"/>
					</c:forEach>
				</table>
			</c:if>
		</div>

		<h3 class="accordion-header"><spring:message code="tracker.field.Priority.label"/></h3>
		<div class="accordion-content" data-section-id="issueStatsByPriority">
			<c:if test="${!empty issueStatsByPriority && !empty issueStatsByPriority.groups}">
				<table border="0" cellpadding="0" cellspacing="0">
					<tr class="odd">
						<td>
						</td>
						<td class="openIssueCell"><spring:message
								code="cmdb.version.issues.filter.open"/></td>
						<c:if test="${!hideClosed}">
							<td class="closedIssueCell"><spring:message code="cmdb.version.issues.filter.closed"/></td>
						</c:if>
					</tr>

					<c:set var="groups" scope="request" value="${issueStatsByPriority.groups}"/>
					<c:set var="totals" scope="request" value="${issueStatsByPriority.totals}"/>
					<%
						PriorityRenderer priorityRenderer = new PriorityRenderer(request);
					%>

					<c:forEach var="group" items="${groups}">
						<c:set var="group" scope="request" value="${group}"/>
						<c:set var="filterCategoryName" scope="request">priority</c:set>
						<c:set var="filterCategoryValue" scope="request">${ui:escapeJavaScript(group.name)}</c:set>

						<c:set var="groupRendered" scope="request">
						<div class='state-indicator'></div>
						<%
								NamedDto prio = (NamedDto) request.getAttribute("group");
								out.print(priorityRenderer.renderNamedPriority(prio));
							%> <spring:message code="tracker.choice.${group.name}.label" text="${group.name}"/>
						</c:set>
						<c:set var="mergeOpenAndClosed" scope="request" value="false" />
						<c:set var="firstColumnClasses" scope="request" value="" />
						<c:set var="dataCollapseParentId" scope="request" value="issueStatsByPriority"/>
						<jsp:include page="/bugs/tracker/versionStatsRow.jsp?cssClass=rowWithImage priorityRow"/>
					</c:forEach>
				</table>
			</c:if>
		</div>

		<h3 class="accordion-header"><spring:message code="tracker.type.label"/></h3>
		<div class="accordion-content" data-section-id="issueStatsByType">
			<c:if test="${!empty issueStatsByType && !empty issueStatsByType.groups}">
				<table border="0" cellpadding="0" cellspacing="0">
					<tr class="odd">
						<td>
						</td>
						<td class="openIssueCell"><spring:message
								code="cmdb.version.issues.filter.open"/></td>
						<c:if test="${!hideClosed}">
							<td lass="closedIssueCell"><spring:message code="cmdb.version.issues.filter.closed"/></td>
						</c:if>
					</tr>

					<c:set var="groups" scope="request" value="${issueStatsByType.groups}"/>
					<c:set var="totals" scope="request" value="${issueStatsByType.totals}"/>
					<c:forEach var="group" items="${groups}">
						<c:set var="group" scope="request" value="${group}"/>
						<c:set var="filterCategoryName" scope="request">type</c:set>
						<c:set var="filterCategoryValue" scope="request">${ui:escapeJavaScript(group)}</c:set>

						<c:set var="groupRendered" scope="request"><div class='state-indicator'></div> <spring:message code="tracker.type.${group}" text="${group}"/></c:set>
						<c:set var="mergeOpenAndClosed" scope="request" value="false" />
						<c:set var="firstColumnClasses" scope="request" value="" />
						<c:set var="dataCollapseParentId" scope="request" value="issueStatsByType"/>
						<jsp:include page="/bugs/tracker/versionStatsRow.jsp"/>
					</c:forEach>
				</table>
			</c:if>
		</div>

		<h3 class="accordion-header"><spring:message code="tracker.field.Status.label"/></h3>
		<div class="accordion-content" data-section-id="issueStatsByStatus">
			<c:if test="${!hideClosed}">
				<%-- We do not support hiding closed elements yet for this type of statistics! --%>

				<c:if test="${!empty issueStatsByStatus && !empty issueStatsByStatus.groups}">
					<table border="0" cellpadding="0" cellspacing="0">
						<tr class="odd">
							<td>
							</td>
							<td colspan="2"><spring:message code="cmdb.version.issues.filter.open"/>&nbsp;/&nbsp;<spring:message code="cmdb.version.issues.filter.closed"/></td>
						</tr>

						<c:set var="groups" scope="request" value="${issueStatsByStatus.groups}"/>
						<c:set var="totals" scope="request" value="${issueStatsByStatus.totals}"/>

						<c:forEach var="group" items="${groups}">
							<c:set var="group" scope="request" value="${group}"/>
							<c:set var="filterCategoryName" scope="request">status</c:set>
							<c:set var="filterCategoryValue" scope="request">${ui:escapeJavaScript(group.name)}</c:set>

							<c:set var="groupRendered" scope="request">
								<div class='state-indicator'></div>
								<spring:message code="tracker.choice.${group.name}.label" text="${group.name}"/>
							</c:set>
							<c:set var="mergeOpenAndClosed" scope="request" value="true" />
							<c:set var="firstColumnClasses" scope="request" value="" />
							<c:set var="dataCollapseParentId" scope="request" value="issueStatsByStatus"/>
							<jsp:include page="/bugs/tracker/versionStatsRow.jsp?cssClass=rowWithImage statusRow"/>
						</c:forEach>
					</table>
				</c:if>
			</c:if>
		</div>
	</div>

	<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/versionStatsBox.js'/>"></script>

</div>

