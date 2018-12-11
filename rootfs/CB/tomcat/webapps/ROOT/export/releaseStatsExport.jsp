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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="export" prefix="export" %>

<style  type="text/css">

.miniprogressbar .progressBarGreen {
	background-color: #00a85d;
}

.miniprogressbar .progressBarGray {
	background-color: #ababab;
}

.miniprogressbar progressBarRed {
	background-color: #B31317;
}


</style>

<c:if test="${info.descendantsNumber > 0}">

	<table cellspacing="0" border="0" width="400" style="font-size: 11px; color: #5f5f5f; text-align: left; table-layout: fixed;">
		<tr>
			<td width="100" >
				<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;">
					<spring:message code="cmdb.version.issues.sprint.count" arguments="${info.descendantsNumber}" />
				</span>
			</td>
			<c:set var="greenPercentage" value="${(100.0 * info.descendantsResolvedOrClosed) / info.descendantsNumber}" />
			<c:set var="grayPercentage" value="${100.0 - greenPercentage}" />
			<fmt:formatNumber var="sprintProgressBarLabel" value="${greenPercentage}" maxFractionDigits="0"/>

			<td>
				<export:progressBarExport greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}" label="${sprintProgressBarLabel}%" totalPercentage="100" />
			</td>

			<td>
				<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;">
					<spring:message code="cmdb.version.issues.count.closed2" arguments="${info.descendantsResolvedOrClosed}" />
				</span>
			</td>
			<td>
				<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;">
					<spring:message code="cmdb.version.issues.count.open" arguments="${info.descendantsNumber - info.descendantsResolvedOrClosed}" />
				</span>
			</td>
		</tr>

		<c:choose>
			<c:when test="${stats.referencedByTrackerItems}">
				<tr>
					<td width="100" >
						<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;">
							${!empty stats.totalPoints ? stats.totalPoints : 0}<sup style="vertical-align: top; position: relative; top:-0.5em;">SP</sup> <spring:message code="cmdb.version.sp.count.committed" />
						</span>
					</td>
					<c:set var="greenPercentage" value="${stats.pointPercentage}" />
					<c:set var="grayPercentage" value="${100.0 - greenPercentage}" />
					<td>
						<export:progressBarExport greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}" label="${!empty stats.pointPercentage ?  stats.pointPercentage : 0}%" totalPercentage="100" />
					</td>

					<td>
						<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;">${!empty stats.closedPoints ? stats.closedPoints : 0}<sup style="vertical-align: top; position: relative; top:-0.5em;">SP</sup> <spring:message code="cmdb.version.sp.count.done" /></span>
					</td>
					<td>
						<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;">${!empty stats.openPoints ? stats.openPoints : 0}<sup style="vertical-align: top; position: relative; top:-0.5em;">SP</sup> <spring:message code="cmdb.version.sp.count.open" /></span>
					</td>
				</tr>

				<spring:message var="progressbarTitle" code="cmdb.version.issues.countBar.tooltip" text="Progress calculated by number of issues open vs closed."/>

				<tr>
					<td width="100" >
						<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;"><spring:message code="cmdb.version.issues.issues.count" arguments="${stats.allItems}"/></span>
					</td>
					<c:set var="greenPercentage" value="${stats.progressPercentage}" />
					<c:set var="grayPercentage" value="${100.0 - greenPercentage}" />
					<td>
						<export:progressBarExport greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}" label="${greenPercentage}%" totalPercentage="100"
							title="${progressbarTitle}"	/>
					</td>
					<td>
						<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;"><spring:message code="cmdb.version.issues.count.done" arguments="${stats.resolvedAndClosedTrackerItems}"/></span>
					</td>
					<td>
						<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;"><spring:message code="cmdb.version.issues.count.open" arguments="${stats.openItems}" /></span>
					</td>
				</tr>

				<c:set var="progressByHours" value="${stats.progressPercentageByHours}"/>
				<c:if test="${! empty progressByHours}">
					<tr>
						<c:set var="plannedHours"   value="${stats.estimatedHours != null ? stats.estimatedHours : 0.0}" />
						<c:set var="spentHours"     value="${stats.spentHours != null ? stats.spentHours : 0.0}" />
						<c:set var="remainingHours" value="${stats.remainingHours != null ? stats.remainingHours : 0.0}" />

						<fmt:formatNumber var="plannedHoursFormatted"   value="${plannedHours}"   maxFractionDigits="1"/>
						<fmt:formatNumber var="spentHoursFormatted"     value="${spentHours}"     maxFractionDigits="1"/>
						<fmt:formatNumber var="remainingHoursFormatted" value="${remainingHours}" maxFractionDigits="1"/>

						<td width="100" >
							<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;"><spring:message code="cmdb.version.issues.hours.planned" arguments="${plannedHoursFormatted}" argumentSeparator="|"/></span>
						</td>
						<c:set var="greenPercentage" value="${progressByHours}" />
						<c:set var="grayPercentage" value="${100.0 - progressByHours}" />

						<spring:message var="progressbar2Title" code="cmdb.version.issues.progressHours.tooltip" text="Progress calculated by total spent hours vs total estimated hours."/>
						<c:choose>
							<c:when test="${greenPercentage <= 100}">
								<td>
									<export:progressBarExport greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}" label="${greenPercentage}%" totalPercentage="100"
										title="${progressbar2Title}"
									/>
								</td>
							</c:when>
							<c:otherwise>
								<%-- if overtime is more than 100%, then the progress bar will show the inverse:
									 a "green" part will show the 100%, and a "red" part will show the overtime, and their length show the ratio between them
								--%>
								<c:set var="pct" value="${(100*100.0)/greenPercentage}" />
								<td>
									<export:progressBarExport greenPercentage="${pct}" redPercentage="${100.0-pct}" label="${greenPercentage}%" totalPercentage="100"
										title="${progressbar2Title}"
									/>
								</td>
							</c:otherwise>
						</c:choose>
						<td>
							<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;"><spring:message code="cmdb.version.issues.hours.spent" arguments="${spentHoursFormatted}" argumentSeparator="|"/></span>
						<td>

						<c:if test="${stats.estimatedHours > 0}">
							<td>
								<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;"><spring:message code="cmdb.version.issues.hours.remaining" arguments="${remainingHoursFormatted}" argumentSeparator="|"/></span>
							</td>
						</c:if>
					</div>
				</c:if>

				<tr>
					<td>
						<span class="${stats.overTimeItems > 0 ? 'overtimeOrOverdue' : ''}" style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;">
							<spring:message code="cmdb.version.issues.count.overtime" arguments="${stats.overTimeItems}"/>
						</span>
					</td>

					<c:if test="${stats.overTimeHours > 0}">
						<fmt:formatNumber var="overtimeHours" value="${stats.overTimeHours}" maxFractionDigits="1" />
						<td>
							<span class="overtime" style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;">
								<spring:message code="cmdb.version.issues.hours.overtime" text="{0}h overtime" arguments="${overtimeHours}" argumentSeparator="|"/>
							</span>
						</td>
					</c:if>

					<td>
						<span class="${stats.overDueItems  > 0 ? 'overtimeOrOverdue' : ''}" style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left; color: #ae170e;">
							<spring:message code="cmdb.version.issues.count.overdue" arguments="${stats.overDueItems}" />
						</span>
					</td>
				</tr>
			</c:when>
			<c:otherwise>
				<tr>
					<td>
						<span style="width: 8em; white-space: nowrap; font-size: 11px; color: #5f5f5f; text-align: left;"><spring:message code="cmdb.version.issues.none" text="no issues"/></span>
					</td>
				</tr>
			</c:otherwise>
		</c:choose>

	</table>

</c:if>


