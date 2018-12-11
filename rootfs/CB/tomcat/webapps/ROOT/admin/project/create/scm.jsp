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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="com.intland.codebeamer.persistence.dto.ScmRepositoryDto"%>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="projectModule newskin"/>

<style type="text/css">
<!--
input[type="text"], input[type="password"] {
	width: 50em;
}

-->
</style>

<spring:message var="titleContext" code="project.creation.title" text="Create New Project"/>

<wysiwyg:froalaConfig />

<spring:message var="scmTypeName" code="scc.name.${createProjectForm.type}" />

<ui:actionMenuBar>
	<ui:pageTitle>
			${titleContext} <span class='breadcrumbs-separator'>&raquo;</span>
			<spring:message code="project.administration.scm.repository.settings.title" text="{0} Repository Settings" arguments="${scmTypeName}"/>
	</ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="createProjectForm" action="${flowUrl}" autocomplete="off">

<form:hidden path="projectId"/>

<form:errors cssClass="error"/>

<ui:actionBar>
	<input type="submit" name="_eventId_finish" value="Finish" style="display:none;"/>

	<c:choose>
		<c:when test="${supportProjectList}">
			<spring:message var="nextButton" code="button.goOn" text="Next &gt;"/>
			&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_scm_project_list" value="${nextButton}" />
		</c:when>
		<c:otherwise>
<%-- Since CB-5.7 source files are not parsed/analyzed any more
			<spring:message var="advButton" code="project.administration.scm.managed.repository.advanced.button" text="Advanced Options &gt;"/>
			&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_advanced" value="${advButton}" />
--%>
			<spring:message var="finishButton" code="project.creation.finish.button" text="Finish"/>
			&nbsp;&nbsp;<input id="finishButton" type="submit" class="button" name="_eventId_finish" value="${finishButton}" />
		</c:otherwise>
	</c:choose>

	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<input type="submit" class="linkButton button" name="_eventId_back" value="${backButton}" />

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<input type="submit" class="cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<div class="contentWithMargins" style="margin-top: 20px";>
<TABLE BORDER="0" CELLPADDING="0" class="formTableWithSpacing">
	<c:set var="scmPackageRequirement" value="mandatory" scope="request" />

	<c:set var="scmForm" scope="request" value="${createProjectForm}" />
	<jsp:include page="/scm/includes/scmAttributesEditor.jsp?projCreation=true" />
</TABLE>
</div>
</form:form>

<spring:message var="dialogMessage" code="project.creation.dialog.content" />
<ui:inProgressDialog message="${dialogMessage}" imageUrl="${pageContext.request.contextPath}/images/newskin/project_create_in_progress.gif" height="250" attachTo="#finishButton" triggerOnClick="true" />

