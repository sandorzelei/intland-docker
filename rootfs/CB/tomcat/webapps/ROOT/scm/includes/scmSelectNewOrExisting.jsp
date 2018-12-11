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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>

<c:choose>
<c:when test="${flowDef == 'createProject'}">
	<meta name="module" content="project_browser"/>
	<meta name="moduleCSSClass" content="projectModule newskin"/>
	<spring:message var="titleContext" code="project.creation.title" text="Create New Project"/>
</c:when>
<c:otherwise>
	<meta name="module" content="sources"/>
	<meta name="useModuleDefaults" content="true" />
	<meta name="moduleCSSClass" content="newskin"/>
	<spring:message var="titleContext" code="scm.repository.creation.title"/>
</c:otherwise>
</c:choose>

<style type="text/css">
label {
	display: block;
	margin-bottom: 5px;
}
.newskin input[type="radio"] {
	vertical-align: text-bottom;
} 
</style>

<spring:message var="scmTypeName" code="scc.name.${scmType}" />

<ui:actionMenuBar>
	<c:choose>
		<c:when test="${flowDef != 'createProject'}">
			<ui:breadcrumbs showProjects="false" projectAware="${scmForm.repositoryDto}"/>
			<ui:breadcrumbs showProjects="false">
				<ui:pageTitle>
					<span class='breadcrumbs-separator'>&raquo;</span>
					${titleContext} <span class='breadcrumbs-separator'>&raquo;</span>
					<spring:message code="project.administration.scm.repository.title" text="{0} Repository Management" arguments="${scmTypeName}"/>
				</ui:pageTitle>
			</ui:breadcrumbs>
		</c:when>
		<c:otherwise>
			<ui:pageTitle>
				${titleContext} <span class='breadcrumbs-separator'>&raquo;</span>
				<spring:message code="project.administration.scm.repository.title" text="{0} Repository Management" arguments="${scmTypeName}"/>
			</ui:pageTitle>
		</c:otherwise>
	</c:choose>
</ui:actionMenuBar>

<form:form commandName="${flowForm}" action="${flowUrl}">

<form:hidden path="projectId"/>

<ui:actionBar>
	<input type="submit" name="_eventId_submit" value="Next &gt;" style="display:none;"/>

	<spring:message var="nextButton" code="button.goOn" text="Next &gt;"/>
	&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_submit" value="${nextButton}" />
	
	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<input type="submit" class="linkButton button" name="_eventId_back" value="${backButton}" />

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<input type="submit" class="cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<div class="contentWithMargins" style="margin-top:20px;">
<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="2">

<TR VALIGN="top">
	<TD class="mandatory" style="vertical-align:top;"><spring:message code="project.administration.scm.repository.choose.label" text="Repository"/>:</TD>

	<TD NOWRAP>
		<label for="createNew">
			<form:radiobutton path="createNewRepository" value="true" id="createNew" />
			<spring:message code="project.administration.scm.repository.createNew.label" text="Create New Managed Repository"/>
		</label>		
		<label for="useExternal">
			<form:radiobutton path="createNewRepository" value="false" id="useExternal" />
			<spring:message code="project.administration.scm.repository.useExternal.label" text="Use Existing External Repository"/>
		</label>
	</TD>
</TR>

</TABLE>
</div>
</form:form>

<c:if test="${projectCreation}">
	<spring:message var="dialogMessage" code="project.creation.dialog.content" />
	<ui:inProgressDialog message="${dialogMessage}" imageUrl="${pageContext.request.contextPath}/images/newskin/project_create_in_progress.gif" height="250" attachTo="#finishButton" triggerOnClick="true" />
</c:if>