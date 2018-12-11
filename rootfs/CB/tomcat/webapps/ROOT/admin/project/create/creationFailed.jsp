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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="uitaglib" prefix="ui"%>

<meta name="decorator" content="main" />
<meta name="module" content="project_browser" />
<meta name="moduleCSSClass" content="projectModule newskin" />

<ui:actionMenuBar>
	<ui:pageTitle>
			<spring:message code="project.creation.failed.title" text="Creating project failed ..." />
	</ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="createProjectForm" action="${flowUrl}">

	<form:errors cssClass="error" />

	<ui:actionBar>
		<spring:message var="continueButton" code="button.continue"	text="Continue" />
		&nbsp;&nbsp;<input type="submit" class="button"	name="_eventId_continue" value="${continueButton}" />
	</ui:actionBar>

<div class="contentWithMargins">
	<div class="warning">
		<spring:message code="project.creation.failed.message"	text="Failed to create CodeBeamer Project {0}, because {1}"	arguments="${ui:removeXSSCodeAndHtmlEncode(createProjectForm.name)},${ui:sanitizeHtml(flowExecutionException.cause.message)}" />
	</div>
</div>

</form:form>
