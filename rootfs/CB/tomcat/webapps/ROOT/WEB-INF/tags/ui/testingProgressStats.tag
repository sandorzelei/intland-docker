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
<%@ tag import="com.intland.codebeamer.controller.support.SimpleMessageResolver"%>
<%@ tag language="java" pageEncoding="UTF-8" %>
<%@ tag import="com.intland.codebeamer.manager.testmanagement.TestRun.TestRunResult"%>
<%@ tag import="java.util.Map"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%-- specialized progress bar for Test-management showing the progress of a Test Set Run --%>
<%@ attribute name="engine" type="com.intland.codebeamer.manager.testmanagement.TestRunnerEngine" required="true" %>

<%@ attribute name="showStatsNumbers" required="false" type="java.lang.Boolean" %>

<c:if test="${empty title}">
	<spring:message var="title" code="testrunner.progress.tooltip" text="Progress calculated by the number of test cases completed vs outstanding."/>
</c:if>

<small class="subtext">

<c:if test="${showStatsNumbers || empty showStatsNumbers}">
	<spring:message var="statsNumbersTitle" code="testrunner.progress.stats.title" text="Number of test cases completed."/>
	<c:set var="total" value="${engine.totalNumberOfRunsTillFinished}" />
	<span title="${statsNumbersTitle}"><spring:message code="testrunner.progress.stats" text="{0} of {1} test cases completed" arguments="${engine.numberOfCompletedTestCaseRuns}, ${total}"/></span>
</c:if>

<c:set var="noOfInactiveTestCases" value="${engine.testSetRun.noOfInactiveTestCases}" />
<c:if test="${noOfInactiveTestCases > 0}">
	<span class="wiki-warning" style="margin-left: 5px; padding: 0 5px; font-size: 12px">
		<spring:message code="${noOfInactiveTestCases == 1 ? 'testrunner.there.is.inactive.test.cases.warning' : 'testrunner.there.are.inactive.test.cases.warning'}" arguments="${noOfInactiveTestCases}" />
		<ui:helpLink helpURL="https://codebeamer.com/cb/wiki/95044#section-Running+only+_22Accepted_22+or+all+TestCases+_3F" target="_blank" cssStyle="vertical-align:middle;" />
	</span>
</c:if>
</small>
