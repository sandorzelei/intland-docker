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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="projectModule newskin"/>
<spring:message var="titleContext" code="project.creation.title" text="Create New Project"/>

<ui:actionMenuBar>
		<ui:pageTitle>
			${titleContext} <span class='breadcrumbs-separator'>&raquo;</span>
			<spring:message code="project.advanced.title" text="Advanced Options"/>
		</ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="createProjectForm" action="${flowUrl}">

<form:errors cssClass="error"/>

<ui:actionBar>
	<spring:message var="finishButton" code="project.creation.finish.button" text="Finish"/>
	&nbsp;&nbsp;<input id="finishButton" type="submit" class="button" name="_eventId_finish" value="${finishButton}" />
	
	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<input type="submit" class="linkButton button" name="_eventId_back" value="${backButton}" />

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<input type="submit" class="button cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<spring:hasBindErrors name="createProjectForm">
	<ui:showSpringErrors errors="${errors}" />
	<BR/>
</spring:hasBindErrors>

<TABLE BORDER="0" CELLPADDING="2" class="formTableWithSpacing">

<TR>
	<TD CLASS="optional"><spring:message code="project.advanced.ignoredDirs.label" text="Directories to ignore"/>:</TD>
	<TD>
		<form:input size="70" path="ignoredDirs"/>
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="project.advanced.vcpp.label" text="This is a Visual C++ Project"/>:</TD>
	<TD>
		<form:checkbox path="vcpp"/>
	</TD>
</TR>

<c:forEach var="filegroup" items="${createProjectForm.fileGroups}">
	<TR>
		<TD CLASS="optional">
			<c:out value="${filegroup.description}" />
			<spring:message code="project.advanced.filegroup.label" text="file extensions"/>:
		</TD>

		<c:set var="type" value="${filegroup.type}" />

		<TD NOWRAP>
			<form:input size="70" path="extension[${type}]"/>
		</TD>
	</TR>
</c:forEach>

<TR>
	<TD class="optional"><spring:message code="project.advanced.classPath.label" text="CLASSPATH (Java)"/> :</TD>
	<TD>
		<form:input size="70" path="classPath"/>
	</TD>
</TR>

<TR>
	<TD VALIGN="top" CLASS="optional"><spring:message code="project.advanced.c_macro.label" text="C/C++ pre-processor commands"/>:</TD>
	<TD CLASS="expandTextArea" >
		<form:textarea cssClass="expandTextArea" rows="4" cols="70" path="c_macro"/>
	</TD>
</TR>

<TR>
	<TD CLASS="optional"><spring:message code="project.advanced.sourceCodeSymbols.label" text="Source Code Symbols"/>:</TD>
	<TD><form:checkbox path="sourceCodeSymbols"/><spring:message code="project.advanced.sourceCodeSymbols.tooltip" text="Enabled"/></TD>
</TR>

<TR>
	<TD CLASS="optional"><spring:message code="project.advanced.xref.label" text="Cross Reference"/>:</TD>
	<TD><form:checkbox path="xref"/><spring:message code="project.advanced.xref.tooltip" text="Enabled"/></TD>
</TR>

</TABLE>

</form:form>

<spring:message var="dialogMessage" code="project.creation.dialog.content" />
<ui:inProgressDialog message="${dialogMessage}" imageUrl="${pageContext.request.contextPath}/images/newskin/project_create_in_progress.gif" height="250" attachTo="#finishButton" triggerOnClick="true" />

