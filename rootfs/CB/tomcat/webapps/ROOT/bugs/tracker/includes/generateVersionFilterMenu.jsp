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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--

Parameters expected from request scope:
	- version
	- versionsViewModel
	- idPrefix

Parameters set in request:
	- filterMenu

 --%>

 <link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect-filter.less" />" type="text/css" media="all" />
 <script src="<ui:urlversioned value='/js/multiselect-filter.js'/>"></script>
 <script src="<ui:urlversioned value='/bugs/tracker/includes/versionFilterMenu.js'/>"></script>

<c:set var="versionStat" value="${versionsViewModel.versionStats[version.id]}" scope="page" />
<c:set var="info" value="${versionsViewModel.info[version]}" scope="page" />
<c:set var="hasIssues" value="${versionStat.referencedByTrackerItems}" scope="page" />

<c:set var="filterMenu" scope="request">
	<c:if test="${empty param.showFilter || param.showFilter != 'false'}">
		<spring:message code="cmdb.version.issues.filter.button" text="Filter" scope="page" />:
		<spring:message var="issuesFilterTitle" code="cmdb.version.issues.filter.tooltip" text="Show only items ..." scope="page" />
		<spring:message var="allLabel" code="cmdb.version.issues.filter.all" text="All"/>
		<spring:message var="resolvedOrClosedLabel" code="cmdb.version.issues.filter.resolvedOrClosed" text="Resolved/Closed"/>
		<spring:message var="closedLabel" code="cmdb.version.issues.filter.closed" text="Closed"/>
		<spring:message var="resolvedLabel" code="cmdb.version.issues.filter.resolved" text="Resolved"/>
		<spring:message var="overdueLabel" code="cmdb.version.issues.filter.overdue" text="Overdue"/>
		<spring:message var="overtimeLabel" code="cmdb.version.issues.filter.overtime" text="Overtime"/>
		<spring:message var="openLabel" code="cmdb.version.issues.filter.open" text="Open"/>
		<spring:message var="statusLabel" code="cmdb.version.issues.filter.status" text="Status"/>
		<spring:message var="testRunVisibilityLabel" code="cmdb.version.issues.filter.testRunVisibility" text="Test Run Visibility"/>
		<spring:message var="noTestRunsLabel" code="cmdb.version.issues.filter.noTestRuns" text="Do not show Test Runs"/>
		<spring:message var="onlyTestRunsLabel" code="cmdb.version.issues.filter.onlyTestRuns" text="Show only Test Runs"/>
		<spring:message var="allTrackerItems" code="cmdb.version.issues.filter.allTrackerItems" text="Show all Tracker Items"/>

		<div class="filterMenu" title="${issuesFilterTitle}">
			<select multiple="multiple">
				<optgroup label="${statusLabel}">
					<option value="" <c:if test="${empty activeFilters.mainStatusFilter}">selected="selected"</c:if> class="status" title="${allLabel}">${allLabel}</option>
					<option value="resolvedOrClosed" <c:if test="${activeFilters.mainStatusFilter == 'resolvedOrClosed' or activeFilters.mainStatusFilter == 'resolvedorclosed'}">selected="selected"</c:if> class="status" title="${resolvedOrClosedLabel}">${resolvedOrClosedLabel}</option>
					<option value="closed" <c:if test="${activeFilters.mainStatusFilter == 'closed'}">selected="selected"</c:if> class="status" title="${closedLabel}">${closedLabel}</option>
					<option value="resolved" <c:if test="${activeFilters.mainStatusFilter == 'resolved'}">selected="selected"</c:if> class="status" title="${resolvedLabel}">${resolvedLabel}</option>
					<option value="open" <c:if test="${activeFilters.mainStatusFilter == 'open'}">selected="selected"</c:if> class="status" title="${openLabel}">${openLabel}</option>
					<option value="overdue" <c:if test="${activeFilters.mainStatusFilter == 'overdue'}">selected="selected"</c:if> class="status" title="${overdueLabel}">${overdueLabel}</option>
					<option value="overtime" <c:if test="${activeFilters.mainStatusFilter == 'overtime'}">selected="selected"</c:if> class="status" title="${overtimeLabel}">${overtimeLabel}</option>
				</optgroup>
				<optgroup label="${testRunVisibilityLabel}">
					<option value="default" <c:if test="${activeFilters.mainTypeFilter == 'default' || empty activeFilters.mainTypeFilter}">selected="selected"</c:if> class="testRun" title="${noTestRunsLabel}">${noTestRunsLabel}</option>
					<option value="test_runs_only" <c:if test="${activeFilters.mainTypeFilter == 'test_runs_only'}">selected="selected"</c:if> class="testRun" title="${onlyTestRunsLabel}">${onlyTestRunsLabel}</option>
					<option value="all_tracker_items" <c:if test="${activeFilters.mainTypeFilter == 'all_tracker_items'}">selected="selected"</c:if> class="testRun" title="${allTrackerItems}">${allTrackerItems}</option>
				</optgroup>
			</select>
		</div>
	</c:if>
</c:set>
