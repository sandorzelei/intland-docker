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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<script type="text/javascript" src="<ui:urlversioned value='/testmanagement/testRunnerAddBug.js'/>"></script>

<%--
	JSP for when the Test-Runner adds an bug to the current test-run
 --%>
<c:choose>
<c:when test="${closeOverlay}">
	<meta name="decorator" content="popup"/>

	<c:url var="url" value="${issueAdded.urlLink}" />
	<c:set var="issueName"><spring:escapeBody htmlEscape="true" javaScriptEscape="true">${issueAdded.name}</spring:escapeBody></c:set>
	<script type="text/javascript">
		closeWithBugAdded(${issueAdded.id}, '${issueName}', '${url}');
	</script>
</c:when>
<c:otherwise>
<c:url var="actionUrl" value="${action}" />

<form:form action="${actionUrl}" enctype="multipart/form-data" commandName="addUpdateTaskForm">
	<div id="testRunnerAddBugContainer" style="display: none">
		<input type="hidden" name="bugTemplateId" value="${param.bugTemplateId}" />
		<ui:actionMenuBar>
			<c:set var="trackerItem" value="${addUpdateTaskForm.trackerItem}" />
			<ui:pageTitle prefixWithIdentifiableName="false">
				<c:set var="testCaseLink"><a href="<c:url value='${testCase.urlLink}'/>" target="_blank" class="titlenormal"><c:out value='${testCase.name}'/></a></c:set>
				<spring:message code="testrunner.bug.report.page.title" text="Adding Bug report for Test Case" arguments="${testCaseLink},${trackerItem.tracker.name},${trackerItem.tracker.project.name}" />
			</ui:pageTitle>
		</ui:actionMenuBar>
		<jsp:include page="/bugs/addUpdateTask.jsp?noActionMenuBar=true&noForm=true&nestedPath=null&noAssociation=true&noTrackerField=true&isPopup=true" />
	</div>
</form:form>

<script type="text/javascript">

	$(function() {
		var increaseDialogSize = function() {
			var dimensions = calculateWindowGeometry("large", window.parent);
			var dialog = window.parent.$(".reportBugDialog").find(".ui-dialog-content");
			dialog.dialog("option", "width", dimensions.width);
			dialog.dialog("option", "height", dimensions.height);
			$("#testRunnerAddBugContainer").show();
		};
		increaseDialogSize();
	});

</script>

</c:otherwise>
</c:choose>