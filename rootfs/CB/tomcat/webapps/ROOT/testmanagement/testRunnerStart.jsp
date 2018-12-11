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
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<meta name="decorator" content="popup" />
<meta name="module" content="tracker" />

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/roundTripExport.css'/>" type="text/css" media="all" />

<style type="text/css">
	.warning {
		margin-bottom: 10px !important;
	}
	.warning * {
		font-size: 13px;
	}
</style>

<c:set var="testSetRun" value="${engine.testSetRun}" />
<c:set var="canRunAll" value="${testSetRun.canRunNonAcceptedTestCases}"/>
<c:set var="noOfInactiveTestCases" value="${testSetRun.noOfInactiveTestCases}" />
<c:set var="totalNumberOfTestCases" value="${fn:length(testSetRun.testCases)}"/>

<ui:actionMenuBar showRating="false">
	<ui:pageTitle printBody="true" prefixWithIdentifiableName="false">
		<spring:message code="testrunner.page.title.template.ony.test.set"
			arguments="${testSetRun.delegate.name}" htmlEscape="true"/>
	</ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="startCommand" action="${action}">
	<input type="hidden" name="task_id" value="${command.task_id}" />

	<c:set var="warning">
	<c:if test="${noOfInactiveTestCases >0}">
		<div class="warning">
			<tag:joinLines>
				<c:choose>
					<%--
					<c:when test="${totalNumberOfTestCases == 0}">
						<spring:message code="testrunner.no.test.case.is.runnable" />
					</c:when>
					--%>
					<c:when test="${noOfInactiveTestCases == 1}">
						<spring:message code="testrunner.one.test.case.not.accepted" arguments="${noOfInactiveTestCases}" />
						<spring:message var="question" code="testrunner.one.test.case.not.accepted.question" />
					</c:when>
					<c:otherwise>
						<spring:message code="testrunner.some.test.cases.not.accepted" arguments="${noOfInactiveTestCases}" />
						<spring:message var="question" code="testrunner.some.test.cases.not.accepted.question" />
					</c:otherwise>
				</c:choose>
				<c:if test="${! canRunAll}">
					<spring:message var="question" code="testrunner.can.not.run.all.because.missing.run.non.accepted" />
				</c:if>
				<p>${ui:sanitizeHtml(warn)}</p>
				${ui:sanitizeHtml(question)}
				<ui:helpLink target="_blank" helpURL="https://codebeamer.com/cb/wiki/95044#section-Running+only+_22Accepted_22+or+all+TestCases+_3F" />
			</tag:joinLines>
		</div>
	</c:if>
	</c:set>

	<%--
		Because the "Run!" menu opens a popup that must be done from the onclick() of the buttons below,
		if that would happen from javascript that would be blocked by the popup-blockers of the browsers
	 --%>
	<c:set var="url">${executeAction.url}</c:set>
	<c:set var="onclick"><spring:escapeBody javaScriptEscape="true" >${executeAction.onClick}</spring:escapeBody></c:set>
	<script type="text/javascript">
		function runMe(runAll) {
			var url = '${url}';
			var onclick = '${onclick}';

			if (runAll) {
				// set running this testrun as non-accepted using an ajax call
				$.ajax({
					type: "POST",
					url: contextPath + '/testmanagement/forceRunningNonAcceptedTestCases.spr?task_id=${command.task_id}',
					async: false,
					cache: false
				});
			};

			// execute the ActionItem's url or js to run the testrunner in popup here
			var insideOverlay = inlinePopup.findPopup() != null;
			if (insideOverlay && onclick) {
				window.parent.inlinePopup.executeJS(onclick);
			} else {
				window.parent.document.location.href=url;
			}

			// a bit later close the inline-popup
			setTimeout(function(){
				console.log("closing inline popup!");
				inlinePopup.close();
			},1000);

			return false;
		}

		function cancelMe() {
			var insideOverlay = inlinePopup.findPopup() != null;
			if (insideOverlay) {
				inlinePopup.close();
			}
			return true;
		}
	</script>

	<ui:actionBar>
		${warning}

		<c:if test="${totalNumberOfTestCases > 0}">
			<spring:message var="buttonSave" code="testrunner.no.test.case.is.runnable.run.only.accepted" />
			<input type="submit" class="button" name="run" value="${buttonSave}" onclick="return runMe(false);"/>
		</c:if>

		<c:if test="${canRunAll}">
			<spring:message var="buttonSave" code="testrunner.no.test.case.is.runnable.run.all.testcases" />
			<input type="submit" class="button" name="runNotAcceptedTestCases" value="${buttonSave}"
				onclick="return runMe(true);"
			/>
		</c:if>

		<spring:message var="cancelTitle" code="button.cancel" text="Cancel" />
		<input type="submit" name="_cancelled" class="cancelButton" value="${cancelTitle}" onclick="return cancelMe()" />
	</ui:actionBar>

<div class="contentWithMargins">
	<%-- show the list of inactive TestCases --%>
	<h3><spring:message code="testrunner.no.test.case.is.runnable.inactive.testcases" text="Inactive TestCases"/>:</h3>
	<style type="text/css">
		.inactiveTestCases {
			list-style: none;
			padding-left:5px;
		}
		.inactiveTestCases li {
			margin-bottom: 5px;
		}
	</style>
	<ul class="inactiveTestCases">
	<c:forEach var="testCase" items="${engine.testSetRun.inactiveTestCases}">
		  <li>
			<ui:coloredEntityIcon renderAsHTML="true" subject="${testCase}" />
			<ui:trackerItemPath item="${testCase}" target="_blank"/>
		  </li>
	</c:forEach>
	</ul>
</div>

	<form:hidden path="runMode"/>
</form:form>

<script type="text/javascript">
// immediately close the overlay if there are 0 non-accepted TestCases: this can happen if somebody else  has changd the non-accepted-testcases flag already
// when two users working concurrently
<c:if test="${noOfInactiveTestCases == 0}">
	console.log("Closing overlay because there are no non-accepted TestCases left here");
	runMe(false);
</c:if>
</script>