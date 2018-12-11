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
<%@page import="java.util.Date"%>
<%@page import="com.intland.codebeamer.persistence.dto.ProjectDto"%>

<meta name="decorator" content="main"/>
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="sysadminModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%!
	public int getDaysSince(Date d) {
		if (d == null) {
			return 0;
		}
		int days = (int)( (new Date().getTime() - d.getTime()) / (1000 * 60 * 60 * 24l) );
		return days;
	}
%>

<style type="text/css">
	p.userDetails {
		margin: 5px 0;
	}

	.idColumnWidth {
		width: 50px;
	}

	.statusColumnWidth {
		width: 50px;
	}

	.createdAtColumnWidth {
		width: 80px;
	}

	.categoryColumnWidth {
		width: 120px;
	}

	.createdByColumnWidth {
		width: 200px;
	}

	.actionColumnWidth {
		width: 140px;
	}

	.fixedTable {
		table-layout: fixed;
		min-width: 980px;
	}

	.wrappedContent {
		word-wrap: break-word;
		white-space: normal;
	}

	a.takeOwnershipAction:hover {
		text-decoration: none;
	}

	#project .checkbox-column-minwidth {
		width: 12px;
	}

	#project .dateData {
		white-space: normal;
	}
</style>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!--
function confirmDelete(button, checkSelection) {
	var answer = checkSelection ? submitIfSelected(button.form, 'projectId') : true;
	if (answer) {
		var msg = '<spring:message javaScriptEscape="true" code="proj.admin.delete.projects.confirm" />';
		answer = showFancyConfirmDialog(button, msg);
	}
	return answer;
}
// -->
</SCRIPT>

<ui:actionMenuBar>
		<ui:pageTitle>
			<spring:message code="sysadmin.projects.label" text="Projects ({0})" arguments="${fn:length(projects)}"/>
		</ui:pageTitle>
</ui:actionMenuBar>

<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
<c:set var="checkAll">
	<input type="checkbox" title="${toggleButton}" name="select_all" VALUE="on"	onclick="setAllStatesFrom(this, 'projectId')">
</c:set>

<c:url var="actionURL" value="/sysadmin/deleteProjects.spr" />
<form:form name="projectListForm" action="${actionURL}">

<ui:actionBar>
	<spring:message var="deleteButton" code="sysadmin.projects.delete.label" text="Delete Projects..."/>
	&nbsp;&nbsp;<input type="submit" class="button" onclick="if($('body').hasClass('IE8')){event.returnValue=confirmDelete(this, true);}else{return confirmDelete(this, true);}" value="${deleteButton}" />
	<spring:message var="deleteButtonFromFile" code="sysadmin.projects.delete.file.label" text="Delete Projects From File"/>
	&nbsp;&nbsp;<input type="submit" name="deleteButtonFromFile" class="button" onclick="if($('body').hasClass('IE8')){event.returnValue=confirmDelete(this, false);}else{return confirmDelete(this, false);}" <c:if test="${not isFileToDelete}">disabled="disabled"</c:if> value="${deleteButtonFromFile}" />
	<c:url var="cancelUrl" value="/sysadmin.do"/>
	<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
	<input type="button" class="cancelButton button" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>
</ui:actionBar>

<div class="contentWithMargins">
	<display:table requestURI="/sysadmin/projectsList.spr" name="${projects}" id="project" class="fixedTable" cellpadding="0" defaultsort="4" defaultorder="descending" export="true" >

		<display:column title="${checkAll}" class="checkbox-column-minwidth" headerClass="checkbox-column-minwidth"	decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html">
			<form:checkbox path="projectId" value="${project.id}" />
		</display:column>

		<spring:message var="projectId" code="project.id.label" text="ID"/>
		<display:column title="${projectId}" property="id" headerClass="numberData idColumnWidth" class="numberData columnSeparator" sortable="true" />

		<spring:message var="projectName" code="project.name.label" text="Name"/>
		<display:column title="${projectName}" property="name" headerClass="textData" class="textData columnSeparator ellipsis" sortable="true" />

		<spring:message var="projectStatus" code="project.status.label" text="Status"/>
		<display:column title="${projectStatus}" headerClass="textData statusColumnWidth" class="textData columnSeparator" sortable="false">
			<c:choose>
				<c:when test="${project.deleted}">
					<spring:message code="project.deleted.label" text="Deleted"/>
				</c:when>
				<c:when test="${project.closed}">
					<spring:message code="project.closed.label" text="Closed"/>
				</c:when>
			</c:choose>
		</display:column>

		<spring:message var="projectCreatedAt" code="project.createdAt.label" text="Created"/>
		<display:column title="${projectCreatedAt}" sortProperty="createdAt" headerClass="dateData createdAtColumnWidth" class="dateData columnSeparator" sortable="true" media="html xml csv pdf rtf">
			<tag:formatDate value="${project.createdAt}" />
			<%
				ProjectDto proj = (ProjectDto) pageContext.findAttribute("project");
				int days = getDaysSince(proj.getCreatedAt());
				pageContext.setAttribute("days", Integer.valueOf(days));
			%>
			<br/>
			( ${days} days ago )
		</display:column>

		<display:column title="${projectCreatedAt}" property="createdAt" headerClass="dateData" class="dateData columnSeparator" sortable="true" media="excel" />

		<spring:message var="projectCreatedBy" code="project.createdBy.label" text="Created by"/>
		<display:column media="html" title="${projectCreatedBy}" headerClass="textData createdByColumnWidth" class="textData columnSeparator" sortable="true" sortProperty="createdBy.name">
			<c:set var="createdBy" value="${project.createdBy}" />
			<tag:userLink user_id="${createdBy}" />

			<p class="userDetails"><c:out value="${createdBy.firstName}"/> <c:out value="${createdBy.lastName}"/>
				, <c:out value="${createdBy.company}" default="--"/></p>
		</display:column>

		<display:column media="excel xml csv pdf rtf" title="${projectCreatedBy}" headerClass="textData" class="textData columnSeparator">
			<c:set var="user" value="${applicationScope.userData[project.createdBy.id]}" />
			<c:out value="${user.name}, (${user.lastName}, ${user.firstName})" />
		</display:column>

		<spring:message var="projectCategory" code="project.category.label" text="Category"/>
		<display:column title="${projectCategory}" property="category" headerClass="textData categoryColumnWidth" class="textData columnSeparator ellipsis" sortable="true" />

		<spring:message var="projectAdminsTitle" code="project.admins.label" text="Administrators"/>
		<display:column media="html" title="${projectAdminsTitle}" headerClass="textData" class="textData columnSeparator wrappedContent">
			<c:set var="separator" value="" />

			<tag:joinLines newLinePrefix="">
				<c:forEach items="${projectAdmins[project.id]}" var="projectAdmin">
					<c:out value="${separator}" escapeXml="false" /><tag:userLink user_id="${projectAdmin}" />
					<c:set var="separator" value=", " />
				</c:forEach>
			</tag:joinLines>
		</display:column>

		<display:column media="excel xml csv pdf rtf" title="${projectAdminsTitle}" headerClass="textData columnSeparator" class="textData">
			<c:set var="separator" value="" />

			<tag:joinLines newLinePrefix="">
				<c:forEach items="${projectAdmins[project.id]}" var="projectAdmin">
					<c:out value="${separator}" escapeXml="false" /><c:out value="${projectAdmin.name}" />
					<c:set var="separator" value=", " />
				</c:forEach>
			</tag:joinLines>
		</display:column>

		<c:if test="${showActions}">
			<spring:message var="projectAction" code="project.admin.action" text="Action"/>
			<spring:message var="actionLink" code="project.ownership.action" text="Take ownership"/>
			<display:column title="${projectAction}" headerClass="textData actionColumnWidth" class="textData columnSeparator" sortable="false">
				<c:if test="${not project.deleted}">
					<a href="takeOwnership.spr?project_id=${project.id}" class="button takeOwnershipAction">${actionLink}</a>
				</c:if>
			</display:column>
		</c:if>

	</display:table>
</div>

</form:form>
