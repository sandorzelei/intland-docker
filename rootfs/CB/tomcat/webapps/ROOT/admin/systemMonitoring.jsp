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
<meta name="decorator" content="main" />
<meta name="module" content="mystart"/>
<meta name="moduleCSSClass" content="workspaceModule newskin"/>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<style type="text/css">
	.content-container {
		padding-top: 15px;
		padding-bottom: 15px;
	}

	.system-monitoring-chart-synchronizer-control {
		padding-left: 15px;
	}

	body {
		overflow-y: scroll;
	}
</style>

<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="sysadmin.dashboard.monitoring.dashboard" text="System Monitoring Dashboard" />
	</ui:pageTitle>
</ui:actionMenuBar>

<div class="content-container">

	<spring:message code="sysadmin.dashboard.monitoring" text="System Monitoring" var="systemMonitoringDashboardLabel" />
		<ui:systemMonitoringChartSynchronizer>
			<c:forEach var="systemMonitoringChartDto" items="${systemMonitoringChartDtos}" varStatus="loop">
				<ui:systemMonitoringChart containerId="system-monitoring-chart-${loop.index }" title="${systemMonitoringChartDto.title}"
					values="${systemMonitoringChartDto.data}" systemStartupTimestamps="${systemStartupTimestamps}">
				</ui:systemMonitoringChart>
			</c:forEach>
		</ui:systemMonitoringChartSynchronizer>

</div>



