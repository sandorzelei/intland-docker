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

<script type="text/javascript">
	function confirmSkipParameters() {
		showHiddenConfirmationFormAsDialog("#skipTestParameters");
	};
</script>

<head>
<style type="text/css">
#skipTestParameters {
	display: none;
}

.skipTestParametersForm {
	display: block !important;
}

.skipTestParametersForm .warning {
	margin-bottom: 1em !important;
}

.skipTestParametersForm .optionsTable {
	margin: 5px auto;
	width: 80%;
}

.skipTestParametersForm .optionsTable td {
	margin: 0 auto;
	vertical-align: top;
}

.skipTestParametersForm .optionsTable p {
	margin: 3px 0;
}

.skipTestParametersForm input[type='radio'], .skipTestParametersForm input[type='checkbox'] {
	vertical-align: text-bottom;
}

</style>
</head>

<div id="skipTestParameters">
	<form:form class="skipTestParametersForm" id="skipTestParametersForm">
	<input type="hidden" name="index" value="${engine.index + 1}" />
	<input type="hidden" name="skipParameters" value="true" />

<%--
	<div class="actionMenuBar">
		Skipping parameters
	</div>

	<label for="skipAll"><input id="skipAll" type="radio" name="skip" value="all"/>Skip all parameters?</label><br/>
	<label for="skipCurrent"><input id="skipCurrent" type="radio" name="skip" value="current"/>Skip only current parameters</label><br/>
--%>

	<div class="warning">
		<spring:message code="testrunner.parameters.skip.button.confirm" />
	</div>
	<c:if test="${engine.missingPartlyPassResult}">
		<div class="warning">
			<c:set var="testRunTracker" value="${engine.testRunTracker}" />
			<c:url var="testRunTrackerURL" value="${ui:removeXSSCodeAndHtmlEncode(testRunTracker.urlLink)}" />
			<c:set var="testRunTrackerName"><c:out value="${ui:sanitizeHtml(testRunTracker.name)}" /></c:set>
			<spring:message code="testrunner.parameters.missing.partly.passed" arguments="${ui:removeXSSCodeAndHtmlEncode(testRunTrackerURL)}|${ui:removeXSSCodeAndHtmlEncode(testRunTrackerName)}" argumentSeparator="|" />
		</div>
	</c:if>

	<table class="staticLayout optionsTable">
		<tr>
			<td><b><spring:message code="testrunner.parameters.skip.status.label" /></b></td>
			<td><b><spring:message code="testrunner.end.run.dialog.result.label" text="and will be marked as:"/></b></td>
		</tr>

		<tr>
			<td>
				<p>
					<input type="radio" name="endRunStatus" value="COMPLETED" checked="checked" >
					<label>
						<spring:message code="tracker.choice.Completed.label" text="Completed" />
					</label>
				</p>
				<p>
					<input type="radio" name="endRunStatus" value="SUSPENDED" >
					<label>
						<spring:message code="tracker.choice.Suspended.label" text="Suspended" />
					</label>
				</p>
			</td>
			<td>
				<p>
					<input type="checkbox" name="endRunResult" value="BLOCKED">
					<label>
						<spring:message code="tracker.choice.Blocked.label" text="Blocked" />
					</label>
				</p>
			</td>
		</tr>
	</table>
	</form:form>
</div>
