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

<%@ page import="com.intland.codebeamer.persistence.dto.ScmRepositoryDto"%>

<meta name="decorator" content="main"/>

<c:choose>
<c:when test="${flowDef == 'createProject'}">
	<meta name="module" content="project_browser"/>
	<meta name="moduleCSSClass" content="newskin projectModule"/>
	<spring:message var="titleContext" code="project.creation.title" text="Creating New Project"/>
</c:when>
<c:otherwise>
	<meta name="module" content="sources"/>
	<meta name="moduleCSSClass" content="newskin sourceCodeModule"/>
	<meta name="useModuleDefaults" content="true" />
	<spring:message var="titleContext" code="scm.repository.creation.title" />
</c:otherwise>
</c:choose>

<c:set var="managedRepositoryHint">
	<div class="explanation"><spring:message code="project.administration.scm.hint" text="Should be enabled with managed repository or Scmloop."/></div>
</c:set>

<spring:message var="scmTypeName" code="scc.name.${scmForm.type}" />

<ui:actionMenuBar>
	<c:choose>
		<c:when test="${flowDef != 'createProject'}">
			<ui:breadcrumbs showProjects="false" projectAware="${scmForm.repositoryDto}"/>
			<ui:breadcrumbs showProjects="false">
				<ui:pageTitle>
					<span class='breadcrumbs-separator'>&raquo;</span>
					${titleContext}<span class='breadcrumbs-separator'>&raquo;</span>
					<spring:message code="project.administration.scm.repository.settings.title" text="{0} Repository Settings" arguments="${scmTypeName}"/>
				</ui:pageTitle>
			</ui:breadcrumbs>
		</c:when>
		<c:otherwise>
			<ui:pageTitle>
				<span class='breadcrumbs-separator'>&raquo;</span>
				${titleContext}<span class='breadcrumbs-separator'>&raquo;</span>
				<spring:message code="project.administration.scm.repository.settings.title" text="{0} Repository Settings" arguments="${scmTypeName}"/>
			</ui:pageTitle>
		</c:otherwise>
	</c:choose>
</ui:actionMenuBar>

<form:form commandName="scmForm" action="${flowUrl}" autocomplete="off">

<form:hidden path="projectId"/>

<ui:actionBar>
	<input type="submit" name="_eventId_submit" value="Save" style="display:none;"/>

	<spring:message var="saveButton" code="button.save" text="Save"/>
	&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_submit" value="${saveButton}" />

	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<input type="submit" class="linkButton button" name="_eventId_back" value="${backButton}" />

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<input type="submit" class="cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<div class="information">
	<spring:message code="project.administration.scm.external.info.message" text="For more information about external repositories see the knowledge base"/>
</div>
<div class="contentWithMargins" style="margin-top:20px;">
<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="0">

<jsp:include page="/scm/includes/scmAttributesEditor.jsp" />

<c:if test="${scmForm.localManagedRepository}">
<%--
	<TR>
		<TD class="optional">Access URL:</TD>
		<TD CLASS="expandText">
			<form:input path="accessUrl" size="60"/>
			<BR/>
			<form:errors path="accessUrl" cssClass="invalidfield"/>
		</TD>
	</TR>
--%>
	<c:if test="${supportPublicRead}">
		<TR VALIGN="top">
			<TD class="optional"><spring:message code="scm.repository.publicRead.label" text="Public access"/>:</TD>
			<TD><form:checkbox path="publicRead" id="publicRead"/>
				<label for="publicRead">
					<spring:message code="scm.repository.publicRead.tooltip" text="Allow public (anonymous) read access"/>
				</label>
			</TD>
		</TR>
	</c:if>
</c:if>

</TABLE>
</div>
</form:form>
