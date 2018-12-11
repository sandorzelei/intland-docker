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
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%-- Display TestRun's progress info on TrackerItem's details page --%>

<%-- test run progress display --%>
<c:if test="${testRunTestCases != null}">
	<style type="text/css">
		#testrun-progress {
			margin: 10px 0;
		}

		#testrun-progress td {
			white-space: nowrap;
			padding-right: 10px;
		}

		#testrun-progress .miniprogressbar {
			width: 100%;
		}
	</style>
	<table id="testrun-progress">
		<tr>
			<td>
				<spring:message code="testrunner.progress.label" text="Progress"/>:
			</td>
			<td style="width:100%;">
				<ui:testingProgressBar engine="${engine}" />
			</td>
			<c:if test="${! engine.needsTestRunGeneration}">
				<td style="padding-right: 5em;">
					<ui:testingProgressStats engine="${engine}" />
				</td>
				<td>
					<spring:message code="tracker.field.Running Time.label" />:
				</td>
				<td>
					${engine.timeSpentHuman}
				</td>
			</c:if>
		</tr>
	</table>
</c:if>
