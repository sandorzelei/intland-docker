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
	JSP fragment renders the progress info for a version

	Expected parameters
	- request.version		- the TrackerItemDto of the version
	- request.stats			- the VersionStatsDto/TrackerItemStatsDto object contains the version statistics
	- param.showFilter		- If the filter should be shown. Optional, defaults to true
--%>
<c:choose>
	<c:when test="${stats.referencedByTrackerItems}">

		<div class="storyPointStats accumulatedStats">
			<span>${!empty stats.totalPoints ? stats.totalPoints : 0}<div class="storyPointsIcon"></div> <spring:message code="cmdb.version.sp.count.committed" /></span>
			<c:set var="greenPercentage" value="${stats.pointPercentage}" />
			<c:set var="grayPercentage" value="${100.0 - greenPercentage}" />
			<ui:progressBar greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}" label="${!empty stats.pointPercentage ?  stats.pointPercentage : 0}%" totalPercentage="100" />
			<span>${!empty stats.closedPoints ? stats.closedPoints : 0}<div class="storyPointsIcon"></div> <spring:message code="cmdb.version.sp.count.done" /></span>
			<span>${!empty stats.openPoints ? stats.openPoints : 0}<div class="storyPointsIcon"></div> <spring:message code="cmdb.version.sp.count.open" /></span>
		</div>

		<spring:message var="progressbarTitle" code="cmdb.version.issues.countBar.tooltip" text="Progress calculated by number of issues open vs closed."/>

		<div class="accumulatedStats">
			<span><spring:message code="cmdb.version.issues.issues.count" arguments="${stats.allItems}"/></span>
			<c:set var="greenPercentage" value="${stats.progressPercentage}" />
			<c:set var="grayPercentage" value="${100.0 - greenPercentage}" />
			<ui:progressBar greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}" label="${greenPercentage}%" totalPercentage="100"
				title="${progressbarTitle}"	/>
			<span><spring:message code="cmdb.version.issues.count.done" arguments="${stats.resolvedAndClosedTrackerItems}"/></span>
			<span><spring:message code="cmdb.version.issues.count.open" arguments="${stats.openItems}" /></span>
		</div>

		<c:set var="progressByHours" value="${stats.progressPercentageByHours}"/>
		<c:if test="${! empty progressByHours}">
			<div class="accumulatedStats">

				<c:set var="plannedHours"   value="${stats.estimatedHours != null ? stats.estimatedHours : 0.0}" />
				<c:set var="spentHours"     value="${stats.spentHours != null ? stats.spentHours : 0.0}" />
				<c:set var="remainingHours" value="${stats.remainingHours != null ? stats.remainingHours : 0.0}" />

				<fmt:formatNumber var="plannedHoursFormatted"   value="${plannedHours}"   maxFractionDigits="1"/>
				<fmt:formatNumber var="spentHoursFormatted"     value="${spentHours}"     maxFractionDigits="1"/>
				<fmt:formatNumber var="remainingHoursFormatted" value="${remainingHours}" maxFractionDigits="1"/>

				<span><spring:message code="cmdb.version.issues.hours.planned" arguments="${plannedHoursFormatted}" argumentSeparator="|"/></span>
				<c:set var="greenPercentage" value="${progressByHours}" />
				<c:set var="grayPercentage" value="${100.0 - progressByHours}" />

				<spring:message var="progressbar2Title" code="cmdb.version.issues.progressHours.tooltip" text="Progress calculated by total spent hours vs total estimated hours."/>
				<c:choose>
					<c:when test="${greenPercentage <= 100}">
						<ui:progressBar greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}" label="${greenPercentage}%" totalPercentage="100"
							title="${progressbar2Title}"
						/>
					</c:when>
					<c:otherwise>
						<%-- if overtime is more than 100%, then the progress bar will show the inverse:
							 a "green" part will show the 100%, and a "red" part will show the overtime, and their length show the ratio between them
						--%>
						<c:set var="pct" value="${(100*100.0)/greenPercentage}" />
						<ui:progressBar greenPercentage="${pct}" redPercentage="${100.0-pct}" label="${greenPercentage}%" totalPercentage="100"
							title="${progressbar2Title}"
						/>
					</c:otherwise>
				</c:choose>
				<span><spring:message code="cmdb.version.issues.hours.spent" arguments="${spentHoursFormatted}" argumentSeparator="|"/></span>

				<c:if test="${stats.estimatedHours > 0}">
					<span><spring:message code="cmdb.version.issues.hours.remaining" arguments="${remainingHoursFormatted}" argumentSeparator="|"/></span>
				</c:if>
			</div>
		</c:if>

		<div class="accumulatedStats">
			<span class="${stats.overTimeItems > 0 ? 'overtimeOrOverdue' : ''}">
				<spring:message code="cmdb.version.issues.count.overtime" arguments="${stats.overTimeItems}"/>
			</span>

			<c:if test="${stats.overTimeHours > 0}">
				<fmt:formatNumber var="overtimeHours" value="${stats.overTimeHours}" maxFractionDigits="1" />
				<span class="overtime"><spring:message code="cmdb.version.issues.hours.overtime" text="{0}h overtime" arguments="${overtimeHours}" argumentSeparator="|"/></span>
			</c:if>

			<span class="${stats.overDueItems  > 0 ? 'overtimeOrOverdue' : ''}">
				<spring:message code="cmdb.version.issues.count.overdue" arguments="${stats.overDueItems}" />
			</span>
		</div>
	</c:when>
	<c:otherwise>
		<div class="accumulatedStats"><span><spring:message code="cmdb.version.issues.none" text="no issues"/></span></div>
	</c:otherwise>
</c:choose>

