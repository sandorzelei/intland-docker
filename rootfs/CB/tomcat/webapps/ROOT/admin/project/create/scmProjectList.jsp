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
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="projectModule newskin"/>

<c:if test="${!empty createProjectForm.scmProjectNameFilter}">
	<c:set var="filter" value="${createProjectForm.scmProjectNameFilter}" />
</c:if>

<c:choose>
	<c:when test="${createProjectForm.type == 'pvcs'}">
		<c:set var="scmName" value="scc.name.pvcs" />
		<c:set var="projectNameLabel" value="scc.project.list.projectname.pvcs" />
	</c:when>

	<c:when test="${createProjectForm.type == 'synergy'}">
		<c:set var="scmName" value="scc.name.synergy" />
		<c:set var="projectNameLabel" value="scc.project.list.projectname.ccm" />
	</c:when>

	<c:when test="${createProjectForm.type == 'svn'}">
		<c:set var="navigateOnModules" value="true" />
		<c:set var="scmName" value="scc.name.svn" />
		<c:set var="projectNameLabel" value="scc.project.list.projectname.svn" />
	</c:when>
</c:choose>

<c:forEach items="${createProjectForm.scmCapabilityMap}" var="capability">
	<c:if test="${capability.value && capability.key eq 'supportProjectList'}">
		<c:set var="supportProjectList" value="true"/>
	</c:if>
</c:forEach>

<spring:message var="scmTypeName" code="scc.name.${createProjectForm.type}" />

<ui:actionMenuBar>
	<ui:pageTitle>
			<spring:message code="project.administration.scm.repository.create.title" text="Create new {0} SCM Repository {1}" arguments="${scmTypeName},${createProjectForm.repository}"/>
	</ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="createProjectForm" action="${flowUrl}">

<form:errors cssClass="error"/>

<ui:actionBar>
	<c:if test="${supportProjectList}">
<%-- Since CB-5.7 source files are not parsed/analyzed any more
		<spring:message var="advButton" code="project.administration.scm.managed.repository.advanced.button" text="Advanced Options &gt;"/>
		&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_advanced" value="${advButton}" />
--%>
		<spring:message var="finishButton" code="project.creation.finish.button" text="Finish"/>
		&nbsp;&nbsp;<input id="finishButton" type="submit" class="button" name="_eventId_finish" value="${finishButton}" />
	</c:if>
	
	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<input type="submit" class="linkButton button" name="_eventId_back" value="${backButton}" />

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<input type="submit" class="button cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<form:errors path="scmPackage" cssClass="invalidfield"/>

<c:set var="folder" value="${createProjectForm.scmPackage}" />
<c:if test="${!empty folder}">
	<ui:title style="sub-headline" >
	<c:url context="/" var="link" value="${flowUrl}">
		<c:param name="scmPackage" value="" />
		<c:param name="_eventId_folder" value="Change"/>
	</c:url>
	<a href="${link}"><IMG BORDER="0" SRC="<c:url value='/images/Directory.gif'/>"></a>

	<c:set var="relFolder" value="" />
	<STRONG>
	<c:forTokens items="${folder}" delims="/" var="fld">
		<c:if test="${!empty relFolder}">
			<c:set var="relFolder" value="${relFolder}/" />
		</c:if>
		<c:set var="relFolder" value="${relFolder}${fld}" />

		<c:url context="/" var="link" value="${flowUrl}">
			<c:param name="scmPackage" value="${relFolder}" />
			<c:param name="_eventId_folder" value="Change"/>
		</c:url>
		<a href="${link}">/<c:out value="${fld}"/></a>
	</c:forTokens>
	</STRONG>
	</ui:title>
</c:if>

<spring:message var="filterButton" code="project.administration.scm.repository.project.filter.button" text="Update"/>
<spring:message var="filterTitle" code="project.administration.scm.repository.project.filter.tooltip" text="Filter by name"/>

<form:input path="scmProjectNameFilter" title="${filterTitle}"/>
&nbsp;<input type="submit" class="button" name="_eventId_update" value="${filterButton}" />

<spring:message var="label" code="${projectNameLabel}" />

<display:table requestURI="" name="${createProjectForm.scmProjectList}" id="project" cellpadding="0" defaultsort="2" style="margin-top:4px;">
	<c:set var="folder" value="${createProjectForm.scmPackage}" />
	<c:if test="${!empty folder}">
		<c:set var="folder" value="${folder}/" />
	</c:if>
	<c:set var="folder" value="${folder}${project.name}" />

	<display:column title=" " decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html">
		<form:radiobutton path="scmPackage" value="${folder}"/>
	</display:column>

	<display:column title="${label}" headerClass="textData" class="textData columnSeparator" property="name" sortable="true">
		<c:choose>
			<c:when test="${navigateOnModules}">
				<c:url context="/" var="link" value="${flowUrl}">
					<c:param name="scmPackage" value="${folder}" />
					<c:param name="_eventId_folder" value="Change"/>
				</c:url>

				<a href="${link}">${project.name}</a>
			</c:when>

			<c:otherwise>
				${project.name}
			</c:otherwise>
		</c:choose>
	</display:column>

	<c:if test="${createProjectForm.type == 'synergy'}">
		<display:column title="Status" headerClass="textData" class="textData columnSeparator" property="status" sortable="true" />
		<display:column title="Owner" headerClass="textData" class="textData columnSeparator" property="owner" sortable="true" />
		<display:column title="Release" headerClass="textData" class="textData columnSeparator" property="taskRelease" sortable="true" />
		<display:column title="Date" sortProperty="date" sortable="true" headerClass="dateData" class="dateData columnSeparator">
			<tag:formatDate value="${project.date}" />
		</display:column>
	</c:if>
</display:table>

</form:form>

<spring:message var="dialogMessage" code="project.creation.dialog.content" />
<ui:inProgressDialog message="${dialogMessage}" imageUrl="${pageContext.request.contextPath}/images/newskin/project_create_in_progress.gif" height="250" attachTo="#finishButton" triggerOnClick="true" />

