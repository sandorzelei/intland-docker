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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="taglib" prefix="tag" %>

<spring:message code="tracker.coverage.status.passed.label" text="Passed" var="passedLabel"/>
<spring:message code="tracker.coverage.status.partlypassed.label" text="Partly Passed" var="partlyPassedLabel"/>
<spring:message code="tracker.coverage.status.failed.label" text="Failed" var="failedLabel"/>
<spring:message code="tracker.coverage.status.blocked.label" text="Blocked" var="blockedLabel"/>
<spring:message code="tracker.coverage.status.incomplete.label" text="Incomplete" var="incompleteLabel"/>
<spring:message code="tracker.coverage.status.notcovered.label" text="Not Covered" var="notCoveredLabel"/>
<spring:message code="tracker.coverage.browser.filter.by.coverage.opt.covered" text="Covered" var="coveredLabel"/>
<spring:message code="Total" text="Total" var="totalLabel"/>

<div class="hint block-hint"><spring:message code="tracker.coverage.browser.statistics.hint"/></div>

<table class="stats-table">
	<thead>
		<tr>
			<td></td>
			<td class="testRunPassed">${passedLabel }</td>
			<td class="testRunPartlypassed">${partlyPassedLabel }</td>
			<td class="testRunFailed">${failedLabel }</td>
			<td class="testRunBlocked">${blockedLabel }</td>
			<td class="testRunIncomplete">${incompleteLabel }</td>
			<c:if test="${coverageType != 'testrun' }">
				<td class="testRunNotCovered">${notCoveredLabel }</td>
				<td class="total">${coveredLabel }</td>
			</c:if>
			<td class="total">${totalLabel }</td>
		</tr>
	</thead>
	<tbody>
		<c:forEach items="${coveredTrackersByProject }" var="entry">
			<c:forEach items="${entry.value }" var="tracker">
				<ct:call object="${coverage }" method="getTestCoverageForTrackerWithoutTestCases" param1="${tracker }" param2="${command.combineWithOr }" return="trackerCoverage"/>
				<c:if test="${not empty trackerCoverage}">
					<c:set var="total" value="${trackerCoverage.total + trackerCoverage.notCovered}"></c:set>
					<tr>
						<td class="row-label">
							<c:url var="trackerUrl" value="${tracker.urlLink}"/>
							<spring:message code="tracker.${tracker.name }.label" text="${tracker.name }" var="trackerName" htmlEscape="true"></spring:message>
							<c:set var="trackerName" value="${tracker.project.name } - ${trackerName }"/>
							<c:if test="${tracker.branch }">
								<tag:branchName var="trackerName" trackerId="${tracker.id }" prependProjectName="true"></tag:branchName>
							</c:if>
							<a href="${trackerUrl }" title="${trackerName}">${trackerName}</a>

							<c:if test="${tracker.branch }">
								<bugs:trackerBranchBadge branch="${tracker}"/>
							</c:if>
						</td>
						<td title="${trackerName}, ${passedLabel}">
							${trackerCoverage.passed }
							<c:if test="${trackerCoverage.passed != 0 }">
								(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${trackerCoverage.passed / total}" />)
							</c:if>
						</td>
						<td title="${trackerName}, ${partlyPassedLabel}">
							${trackerCoverage.partlyPassed }
							<c:if test="${trackerCoverage.partlyPassed != 0 }">
								(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${trackerCoverage.partlyPassed / total}" />)
							</c:if>
						</td>
						<td title="${trackerName}, ${failedLabel}">
							${trackerCoverage.failed }
							<c:if test="${trackerCoverage.failed != 0 }">
								(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${trackerCoverage.failed / total}" />)
							</c:if>
						</td>
						<td title="${trackerName}, ${blockedLabel}">
							${trackerCoverage.blocked } <c:if test="${trackerCoverage.blocked != 0 }">
								(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${trackerCoverage.blocked / total}" />)
							</c:if>
						</td>
						<td title="${trackerName}, ${incompleteLabel}">
							${trackerCoverage.incomplete }  <c:if test="${trackerCoverage.incomplete != 0 }">
								(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${trackerCoverage.incomplete / total}" />)
							</c:if>
						</td>
						<c:if test="${coverageType != 'testrun' }">
							<td title="${trackerName}, ${notCoveredLabel}">
								${trackerCoverage.notCovered }  <c:if test="${trackerCoverage.notCovered != 0 }">
									(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${trackerCoverage.notCovered / total}" />)
								</c:if>
							</td>

							<td title="${trackerName}, ${coveredlabel}">
								${trackerCoverage.total }  <c:if test="${trackerCoverage.total != 0 }">
									(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${trackerCoverage.total / total}" />)
								</c:if>
							</td>
						</c:if>
						<td title="${trackerName}, ${totalLabel}">
							${total }
						</td>
					</tr>
				</c:if>

			</c:forEach>

			<c:if test="${fn:length(trackersByProject) > 1 }">
				<%-- display the subtotal for this project --%>
				<c:set var="subtotalCoverage" value="${projectSubtotals[entry.key] }"/>
				<c:set var="total" value="${subtotalCoverage.total + subtotalCoverage.notCovered}"></c:set>
				<spring:message var="projectSubtotalLabel" text="${entry.key.name }" htmlEscape="true"></spring:message>
				<tr class="subtotal">
					<td class="row-label">
						<c:url var="projectUrl" value="${entry.key.urlLink }"/>
						<a href="${projectUrl}" class="project-subtotal-label ${not empty entry.key.status ? 'tooltip-trigger' : '' }">${projectSubtotalLabel}</a>
						<div class="project-description-container" style="display: none;">
							<c:out value="${entry.key.status }"/>
						</div>
					</td>
					<td title="${projectSubtotalLabel}, ${passedLabel}">
						${subtotalCoverage.passed }
						<c:if test="${subtotalCoverage.passed != 0 }">
							(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${subtotalCoverage.passed / total}" />)
						</c:if>
					</td>
					<td title="${projectSubtotalLabel}, ${partlyPassedLabel}">
						${subtotalCoverage.partlyPassed }
						<c:if test="${subtotalCoverage.partlyPassed != 0 }">
							(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${subtotalCoverage.partlyPassed / total}" />)
						</c:if>
					</td>
					<td title="${projectSubtotalLabel}, ${failedLabel}">
						${subtotalCoverage.failed }
						<c:if test="${subtotalCoverage.failed != 0 }">
							(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${subtotalCoverage.failed / total}" />)
						</c:if>
					</td>
					<td title="${projectSubtotalLabel}, ${blockedLabel}">
						${subtotalCoverage.blocked }
						<c:if test="${subtotalCoverage.blocked != 0 }">
							(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${subtotalCoverage.blocked / total}" />)
						</c:if>
					</td>
					<td title="${projectSubtotalLabel}, ${incompleteLabel}">
						${subtotalCoverage.incomplete }
						<c:if test="${subtotalCoverage.incomplete != 0 }">
							(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${subtotalCoverage.incomplete / total}" />)
						</c:if>
					</td>
					<c:if test="${coverageType != 'testrun' }">
						<td title="${projectSubtotalLabel}, ${notCoveredLabel}">
							${subtotalCoverage.notCovered}
							<c:if test="${subtotalCoverage.notCovered != 0 }">
								(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${subtotalCoverage.notCovered / total}" />)
							</c:if>
						</td>

						<td title="${projectSubtotalLabel}, ${coveredLabel}">
							${subtotalCoverage.total}
							<c:if test="${subtotalCoverage.total != 0 }">
								(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${subtotalCoverage.total / total}" />)
							</c:if>
						</td>
					</c:if>
					<td title="${projectSubtotalLabel}, ${totalLabel}">
						${subtotalCoverage.total + subtotalCoverage.notCovered}
					</td>
				</tr>
			</c:if>
		</c:forEach>
		<ct:call object="${coverage }" method="getTestCoverageWithoutTestCases" param1="${command.combineWithOr }" return="totalCoverage"/>
		<c:set var="total" value="${totalCoverage.total + totalCoverage.notCovered}"></c:set>
		<spring:message code="versionStatsBox.totals" text="Totals" var="totalsLabel"/>
		<tr class="subtotal">
			<td class="row-label">
				${totalsLabel}
			</td>
			<td title="${totalsLabel}, ${passedLabel}">
				${totalCoverage.passed }
				<c:if test="${totalCoverage.passed != 0 }">
					(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${totalCoverage.passed / total}" />)
				</c:if>
			</td>
			<td title="${totalsLabel}, ${partlyPassedLabel}">
				${totalCoverage.partlyPassed }
				<c:if test="${totalCoverage.partlyPassed != 0 }">
					(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${totalCoverage.partlyPassed / total}" />)
				</c:if>
			</td>
			<td title="${totalsLabel}, ${failedLabel}">
				${totalCoverage.failed }
				<c:if test="${totalCoverage.failed != 0 }">
					(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${totalCoverage.failed / total}" />)
				</c:if>
			</td>
			<td title="${totalsLabel}, ${blockedLabel}">
				${totalCoverage.blocked }
				<c:if test="${totalCoverage.blocked != 0 }">
					(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${totalCoverage.blocked / total}" />)
				</c:if>
			</td>
			<td title="${totalsLabel}, ${incompleteLabel}">
				${totalCoverage.incomplete }
				<c:if test="${totalCoverage.incomplete != 0 }">
					(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${totalCoverage.incomplete / total}" />)
				</c:if>
			</td>
			<c:if test="${coverageType != 'testrun' }">
				<td title="${totalsLabel}, ${notCoveredLabel}">
					${totalCoverage.notCovered}
					<c:if test="${totalCoverage.notCovered != 0 }">
						(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${totalCoverage.notCovered / total}" />)
					</c:if>
				</td>

				<td title="${totalsLabel}, ${coveredLabel}">
					${totalCoverage.total}
					<c:if test="${totalCoverage.total != 0 }">
						(<fmt:formatNumber type="percent" maxIntegerDigits="3" value="${totalCoverage.total / total}" />)
					</c:if>
				</td>
			</c:if>
			<td title="${totalsLabel}, ${totalLabel}">
				${totalCoverage.total + totalCoverage.notCovered}
			</td>
		</tr>
	</tbody>
</table>