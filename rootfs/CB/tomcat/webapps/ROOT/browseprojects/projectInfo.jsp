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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="taglib" prefix="tag" %>

<c:set var="markup">
	<spring:message code="tracker.view.chart.issueCountTrend.tooltip"
		text="Displays the number of items created vs the number of items resolved for a period of a time" var="countTrendsTooltip"/>
	<spring:message code="tracker.view.chart.issueCountTrend.working.item.label" text="Working Item Trends" var="countTrendsTitle"/>

	<%-- initialized in BrowserProjectsController.getProjectInfo --%>
	<c:if test="${! empty statusDescription}">
		<c:out value="${statusDescription}"></c:out>
	</c:if>

	[{IssueCountTrends tooltip='${countTrendsTooltip}' title='${countTrendsTitle}' projectId='${projectId}' width='533' height='266' cssClass='countrends-plugin-center'}]

    [{ReleaseActivityTrends projectId='${projectId}' showDropdownFilters='false'}]

	[{ActivityStream projectId='${projectId}'}]
</c:set>

<tag:transformText value="${markup}" format="W" />

