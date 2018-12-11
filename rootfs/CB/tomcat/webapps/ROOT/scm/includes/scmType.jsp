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

<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="com.intland.codebeamer.utils.Common" %>

<meta name="decorator" content="main"/>
<meta name="module" content="sources"/>
<meta name="useModuleDefaults" content="true" />
<meta name="moduleCSSClass" content="newskin sourceCodeModule"/>

<spring:message var="titleContext" code="scm.repository.creation.title"/>

<%
	pageContext.setAttribute("isLocalHost",
		Boolean.toString(Common.isLocalHost(request.getRemoteAddr())));
%>

<ui:actionMenuBar>
	<c:choose>
		<c:when test="${flowDef != 'createProject'}">
			<ui:breadcrumbs showProjects="false" projectAware="${scmForm.repositoryDto}"/>
			<ui:breadcrumbs showProjects="false">
				<ui:pageTitle>
					<span class='breadcrumbs-separator'>&raquo;</span>
					${titleContext}<span class='breadcrumbs-separator'>&raquo;</span>
					<spring:message code="project.administration.scm.repository.provider.title" text="Select SCM repository type"/>
				</ui:pageTitle>
			</ui:breadcrumbs>
		</c:when>
		<c:otherwise>
			<ui:pageTitle>
				<span class='breadcrumbs-separator'>&raquo;</span>
				${titleContext}<span class='breadcrumbs-separator'>&raquo;</span>
				<spring:message code="project.administration.scm.repository.provider.title" text="Select SCM repository type"/>
			</ui:pageTitle>
		</c:otherwise>
	</c:choose>
</ui:actionMenuBar>

<style type="text/css">
<!--
	#scmForm label {
		font-weight: bold;
	}
-->
</style>

<form:form commandName="scmForm" action="${flowUrl}" id="scmForm">

<form:hidden path="projectId"/>

<ui:actionBar>
	<spring:message var="configButton" code="project.administration.scm.repository.config.button" text="Configure &gt;"/>
	<c:choose>
		<c:when test="${flowBlocked}">
			&nbsp;&nbsp;<input type="submit" class="disabledButton" name="_eventId_submit" value="${configButton}" disabled="disabled" />
		</c:when>
		<c:otherwise>
			&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_submit" value="${configButton}" />
		</c:otherwise>
	</c:choose>
	<%-- &nbsp;&nbsp;<input type="submit" class="button" name="_eventId_cancel" value="Cancel" />--%>
</ui:actionBar>

<spring:hasBindErrors name="scmForm">
	<ui:showSpringErrors errors="${errors}" />
</spring:hasBindErrors>

<jsp:include page="scmTypeList.jsp"/>
</form:form>
