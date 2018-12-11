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
<%@ page import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ page import="com.intland.codebeamer.manager.testmanagement.TestSetExpander.TestWithContainerTestSets"%>
<%@ page import="java.util.List"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerTypeDto"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@ page import="com.intland.codebeamer.manager.testmanagement.TestRun"%>
<%@ page import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>
<%@ page import="com.intland.codebeamer.manager.testmanagement.TestRun.TestRunResult"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<tag:catch>

<%
	TrackerSimpleLayoutDecorator decorator = new TrackerSimpleLayoutDecorator();
	request.setAttribute("decorator", decorator);

	// hide the TestSets automatically if sorted by displaytag, because the indentations are wrong/make no sense then
	request.setAttribute("displayTagSorted", ControllerUtils.isDisplayTagSortRequest(request));
%>

<spring:message var="testCaseLabel" code="testset.editor.testcases.or.testsets.label" />
<spring:message var="priorityLabel" code="tracker.field.Priority.label" />
<spring:message var="resultLabel" code="tracker.field.Result.label" />
<spring:message var="bugLabel" code="tracker.type.Bug.plural" />
<spring:message var="runningTimeLabel" code="tracker.field.Running Time.label" />
<spring:message var="runAtLabel" code="testcase.run.at" text="Run at" />
<spring:message var="runByLabel" code="testcase.run.by" text="Run by" />
<spring:message var="statusLabel" code="tracker.field.Status.label" />
<spring:message var="testRunLabel" code="tracker.type.Testrun" />

<script type="text/javascript">
	function hideTestSets(checkbox) {
		var checked = $(checkbox).is(":checked");
		$("#testCasesTable").toggleClass("hideTestSets", checked);
	}
</script>
<style type="text/css">
	.hideTestSets tr.itemType_Testset {
		display: none;
	}
	.hideTestSets tr .indenter {
		display: none;
	}
	#hideTestSets {
		vertical-align: text-bottom;
	}

	/* TODO: should this be in the main css file? */
	.textSummaryData {
		white-space: nowrap;
	}
</style>

<c:set var="testCaseLabel">
	<c:if test="${! displayTagSorted}">
	<label style="float:right;margin-right: 20px;" for='hideTestSets'>
		<input id='hideTestSets' type="checkbox" onclick="hideTestSets(this);" autocomplete="off"/>
		<spring:message code="testrun.details.hide.testsets" text="Hide TestSets"/>
	</label>
	</c:if>
	${testCaseLabel}
</c:set>

<display:table requestURI="" export="false" class="expandTable dragReorder ${displayTagSorted ? 'hideTestSets':'' }" htmlId="testCasesTable" cellpadding="0" name="${testCases}" id="testCase" decorator="decorator" pagesize="${pagesize}" defaultsort="1">
	<display:setProperty name="paging.banner.placement" value="bottom" />
	<%
		TestWithContainerTestSets tc = (TestWithContainerTestSets) pageContext.getAttribute("testCase");

		int depth = 0;
		boolean isTestSet = false;
		if (tc != null) {
			// the "testCase" here can be a TestCase's issue or a TestSet issue (happens if a TestSet contains another TestSet etc..)
			isTestSet = tc.isA(TrackerTypeDto.TESTSET);

			List<?> containers = tc.getContainerTestSets();
			if (containers != null) {
				depth = containers.size();
			}
		}

		pageContext.setAttribute("isTestSet", Boolean.valueOf(isTestSet));
		pageContext.setAttribute("depth", Integer.valueOf(depth));
	%>
	<c:set var="emptyText" value="${isTestSet ? '' : '--'}"/>

	<display:column title="${testCaseLabel}" class="textSummaryData columnSeparator" headerClass="textData" sortable="false" >
		<c:if test="${depth > 0}">
			<span class="indenter" style="margin-left: ${20*depth}px" ></span>	<!-- indent to show the TestSet/TestCase hierarchy -->
		</c:if>

		<c:choose>
			<c:when test="${isTestSet}">
				<img src="<c:url value='/js/jquery/jquery-treetable/images/expand.png'/>" />
			</c:when>
			<c:otherwise>
				<span style="margin-left: 20px;"></span>
			</c:otherwise>
		</c:choose>
		<ui:coloredEntityIcon renderAsHTML="true" subject="${testCase}" />
		<ui:trackerItemPath item="${testCase}"/>

<%--
		<pre>
			testCase: ${testCase}
			testCase.version: ${testCase.version}
		</pre>
--%>
	</display:column>

	<!--  showing the Test Case's status, because only the "Accepted" ones will run  -->
	<display:column title="${statusLabel}" headerClass="textData" class="textData columnSeparator" property="status" sortable="true" sortProperty="sortStatus" comparator="com.intland.codebeamer.persistence.util.DtoComparator"/>

	<display:column title="${priorityLabel}" class="textData columnSeparator" property="priority" sortable="true" />
</display:table>

</tag:catch>
