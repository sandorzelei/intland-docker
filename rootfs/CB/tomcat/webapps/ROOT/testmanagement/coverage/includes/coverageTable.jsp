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

<%--
	The table containing the coverage rows. This is a dynamic expandable table, the child rows are loaded via ajax
	when a row is expanded.
--%>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui"%>

<ui:UserSetting var="coverageBrowserTreeWidth" setting="COVERAGE_BROWSER_TREE_WIDTH" defaultValue="300"/>

<table id="coverageTree" class="treetable">
	<thead>
		<tr>
			<td class="firstHeader" style="width: ${coverageBrowserTreeWidth}px;">
				<spring:message code="tracker.${coverageType == 'testrun' ? 'testrun' : 'coverage'}.browser.items.label"></spring:message>
			</td>
			<c:if test="${command.showColors}">
				<td>
					<spring:message code="tracker.field.Color.label"/>
				</td>
			</c:if>
			<td>
				<spring:message code="${coverageType == 'testrun' ? 'tracker.coverage.browser.result.label' : 'tracker.coverage.browser.coverage.label'}"/>
			</td>
			<c:if test="${command.recentRuns != 0}">
				<td>
					<spring:message code="testcase.run.by"/>
				</td>
			</c:if>
			<td>
				<spring:message code="tracker.Test Cases.label"/>
			</td>
			<td>
				<spring:message code="tracker.coverage.browser.analysis.label"/>
			</td>
			<c:if test="${command.recentRuns != 0}">
				<td>
					<spring:message code="testcase.run.at"/>
				</td>
			</c:if>
		</tr>
	</thead>
	<tbody>
		<jsp:include page="coverageRows.jsp"></jsp:include>
	</tbody>
</table>