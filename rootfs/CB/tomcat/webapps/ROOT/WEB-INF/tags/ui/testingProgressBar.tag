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
<%@tag import="org.apache.commons.lang.StringUtils"%>
<%@tag import="com.intland.codebeamer.controller.support.SimpleMessageResolver"%>
<%@ tag language="java" pageEncoding="UTF-8" %>
<%@ tag import="com.intland.codebeamer.manager.testmanagement.TestRun.TestRunResult"%>
<%@ tag import="java.util.Map"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%-- specialized progress bar for Test-management showing the progress of a Test Set Run --%>
<%@ attribute name="engine" type="com.intland.codebeamer.manager.testmanagement.TestRunnerEngine" required="true" %>

<%@ attribute name="id" required="false" description="Id for the wrapping DIV element." %>
<%@ attribute name="title" required="false" description="Hover text to display over the bar." %>
<%@ attribute name="hideTotal" required="false" type="java.lang.Boolean" description="If true, then the total percentage is not shown on the bars" %>
<%@ attribute name="showPercentages"  required="false" type="java.lang.Boolean"
			description="If true then each progress piece shows its percentage numbers inside"
%>
<%@ attribute name="showCounts"  required="false" type="java.lang.Boolean"
			description="If true then each progress piece shows the number of tests inside"
%>

<c:if test="${empty title}">
	<spring:message var="title" code="testrunner.progress.tooltip" text="Progress calculated by the number of test cases completed vs outstanding."/>
</c:if>

<%!
	public String printDistribution(Integer count) {
		if (count == null) {
			return "";
		}
		return count.toString();
	}
%>
<%
	SimpleMessageResolver resolver = SimpleMessageResolver.getInstance(request);

	Map<TestRunResult, Integer> progressMapByRunResult = engine.getProgress();
	Integer[] percentages = new Integer[] {
		progressMapByRunResult.get(TestRunResult.PASSED),
		progressMapByRunResult.get(TestRunResult.FAILED),
		progressMapByRunResult.get(TestRunResult.BLOCKED)
	};
	String[] titles = new String[] { "","","" };
	if (showPercentages != null && showPercentages.booleanValue()) {
		titles = new String[] {
				percentages[0] +"%",
				percentages[1] +"%",
				percentages[2] +"%"
		};
//			resolver.getMessage("tracker.coverage.status.passed.label"),
//			resolver.getMessage("tracker.coverage.status.failed.label"),
//			resolver.getMessage("tracker.coverage.status.blocked.label")
	};
	if (showCounts != null && showCounts.booleanValue()) {
		Map<TestRunResult, Integer> distribution = engine.getDistribution();
		titles = new String[] {
				printDistribution(distribution.get(TestRunResult.PASSED)),
				printDistribution(distribution.get(TestRunResult.FAILED)),
				printDistribution(distribution.get(TestRunResult.BLOCKED))
		};
	}
	
	String[] cssClasses = new String[] {"testingProgressBarPassed", "testingProgressBarFailed", "testingProgressBarBlocked" }; // TODO: change css classes for the new colors!
%>

<ui:progressBar
	percentages="<%=percentages%>"
	titles="<%=titles%>"
	cssClasses="<%=cssClasses%>"
	totalPercentage="${engine.totalPercentage}"
	id="${id}"
	title="${title}"
	hideTotal="${hideTotal}"
/>
