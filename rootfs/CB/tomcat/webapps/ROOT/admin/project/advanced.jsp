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
 *
 * $Revision$ $Date$
--%>
<meta name="decorator" content="main"/>
<meta name="module" content="admin"/>
<meta name="moduleCSSClass" content="adminModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@page import="com.intland.codebeamer.persistence.dto.ProjectDto"%>
<%@page import="com.intland.codebeamer.persistence.dto.ProjectPreferencesDto"%>
<%@page import="com.intland.codebeamer.controller.ControllerUtils"%>

<ui:showErrors />

<%
	ProjectDto project = ControllerUtils.getCurrentProject(request);
    ProjectPreferencesDto preferences = new ProjectPreferencesDto();
    preferences.setProject(project);

	pageContext.setAttribute("preferences", preferences);
	pageContext.setAttribute("TAB", "\t");
	pageContext.setAttribute("NEWLINE", "\n");
%>

<html:form action="/proj/admin/configAdvanced">

<c:set target="${advancedProjectSettingsForm.map}" property="xref" value="${preferences.xref}" />
<c:set target="${advancedProjectSettingsForm.map}" property="sourceCodeSymbols" value="${preferences.sourceCodeSymbols}" />

<html:hidden property="proj_id" value="<%=String.valueOf(project.getId())%>"/>

<div class="actionBar">
	<spring:message var="saveButton" code="button.save" text="Save"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

	&nbsp;&nbsp;<html:submit styleClass="button" property="SAVE" value="${saveButton}" />
	&nbsp;&nbsp;<html:cancel styleClass="button cancelButton" value="${cancelButton}" />
</div>

<TABLE BORDER="0" CELLPADDING="1" class="formTableWithSpacing">

<TR>
	<TH NOWRAP ALIGN="left">&nbsp;<spring:message code="project.advanced.package_name.label" text="External Java Packages"/>&nbsp;</TH>
	<TH NOWRAP ALIGN="left">&nbsp;<spring:message code="project.advanced.package_url.label" text="JavaDoc URL"/>&nbsp;</TH>
</TR>

<c:forTokens var="packageWithUrl" items="${preferences.packageURL}" delims="${NEWLINE}">
	<c:set var="nameAndURL" value='${fn:split(packageWithUrl, TAB)}' />

	<TR>
		<TD>
			<html:text size="25" property="package_name" value="${nameAndURL[0]}" />
		</TD>

		<TD CLASS="expandText">
			<html:text size="70" property="package_url" styleClass="expandText" value="${nameAndURL[1]}" />
		</TD>
	</TR>
</c:forTokens>

<TR VALIGN="top">
	<TD class="optional"><spring:message code="project.advanced.c_macro.label" text="C/C++ pre-processor commands"/>:</TD>
	<TD CLASS="expandTextArea">
		<html:textarea rows="4" cols="60" property="c_macro" styleClass="expandText" value="${preferences.macros}" />
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="project.advanced.sourceCodeSymbols.label" text="Source Code Symbols"/>:</TD>
	<TD><html:checkbox property="sourceCodeSymbols" /><spring:message code="project.advanced.sourceCodeSymbols.tooltip" text="Enabled"/></TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="project.advanced.xref.label" text="Cross Reference"/>:</TD>
	<TD><html:checkbox property="xref" /><spring:message code="project.advanced.xref.tooltip" text="Enabled"/></TD>
</TR>

</TABLE>

</html:form>