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
<meta name="decorator" content="main"/>
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="newskin sysadminModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import="com.intland.codebeamer.Config"%>

<%
	pageContext.setAttribute("isDocumentRelocatable", Boolean.valueOf(Config.isDocumentRelocatable()));
%>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="documents.summary.title" text="Document Summary"/></ui:pageTitle>
</ui:actionMenuBar>

<script language="JavaScript" type="text/javascript">
<!-- Hide script from old browsers
function confirmDelete() {
	var form = document.getElementById('documentForm');
	var answer = submitIfSelected(form, 'projectId');
	if (answer) {
		if (!confirm('<spring:message code="empty.trash" />'))
		{
			return false;
		}
	}
	return answer;
}
// -->
</script>

<c:url var="emptyTrashLink" value="/sysadmin/documentsSummary.do" />
<form action="${emptyTrashLink}" id="documentForm" method="POST">

<ui:actionBar>
	<input type="hidden" name="emptyTrash" value="true" />

	<spring:message var="emptyTrashButton" code="documents.emptyTrash.label" text="Empty Trash..."/>
	<spring:message var="emptyTrashTitle" code="documents.emptyTrash.tooltip" text="Empty Trash for selected projects."/>
	<INPUT type="submit" class="button" value="${emptyTrashButton}"	title="${emptyTrashTitle}"	onclick="return confirmDelete();">
	<c:url var="cancelUrl" value="/sysadmin.do"/>
	<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
	<input type="button" class="cancelButton button" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>
</ui:actionBar>

<c:set var="emptyTrash" value="false" />
<c:if test="${!empty param.emptyTrash}">
	<c:set var="emptyTrash" value="${param.emptyTrash}" />
</c:if>

<c:set var="projIds" value="" />
<c:forEach items="${paramValues.projectId}" var="proj_id" varStatus="for_status">
	<c:set var="projIds" value="${projIds}${proj_id}" />
	<c:if test="${!for_status.last}">
		<c:set var="projIds" value="${projIds}," />
	</c:if>
</c:forEach>

<tag:allProjectsDocumentSummary var="data" emptyTrash="${emptyTrash}" projectIds="${projIds}" />

<spring:message var="toggleTitle" code="search.what.toggle" text="Select/Clear All"/>

<c:set var="checkAll">
	<input type="checkbox" title="${toggleTitle}" name="SELECT_ALL" value="on" onclick="setAllStatesFrom(this, 'projectId')" />
</c:set>

<display:table excludedParams="*" requestURI="/sysadmin/documentsSummary.do" name="${data.projects}" id="project" cellpadding="0" pagesize="50" style="width: 90%">
	<display:setProperty name="paging.banner.placement" value="bottom" />

	<display:column title="${checkAll}" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html"
			class="checkbox-column-minwidth" headerClass="checkbox-column-minwidth">
		<input type="checkbox" name="projectId" value="${project.project.id}" />
	</display:column>

	<spring:message var="projectLabel" code="project.label" text="Project"/>
	<display:column title="${projectLabel}" property="project.name" sortProperty="project.name" sortable="true"
		headerClass="textData" class="textData columnSeparator" />

	<%--
	Disabled document relocatable feature
	<c:if test="${isDocumentRelocatable}">
		<spring:message var="mountPointLabel" code="project.mountPoint.label" text="Mount Point"/>
		<display:column title="${mountPointLabel}" sortProperty="mountPoint" headerClass="textData" class="textData columnSeparator" sortable="true">
			<c:url var="editMountPointUrl" value="/sysadmin/editProjectMountPoint.do">
				<c:param name="proj_id" value="${project.project.id}" />
			</c:url>

			<c:choose>
				<c:when test="${empty project.project.mountPoint}">
					<a href="${editMountPointUrl}"><spring:message code="project.mountPoint.default" text="Default repository"/></a>
				</c:when>
				<c:otherwise>
					<a href="${editMountPointUrl}">${project.project.mountPoint}</a>&nbsp;<span class="subtext"><spring:message code="project.mountPoint.custom" text="(Project-specific repository)"/></span>
				</c:otherwise>
			</c:choose>
		</display:column>
	</c:if>
	--%>

	<spring:message var="filesInUseLabel" code="documents.filesInUse.label" text="Documents in Use"/>
	<display:column title="${filesInUseLabel}" sortProperty="filesInUse" sortable="true"
		headerClass="numberData" class="numberData columnSeparator">
			<fmt:formatNumber value="${project.filesInUse}" />
	</display:column>

	<spring:message var="filesInTrashLabel" code="documents.filesInTrash.label" text="Documents in Trash"/>
	<display:column title="${filesInTrashLabel}" sortProperty="filesInTrash" sortable="true"
		headerClass="numberData" class="numberData columnSeparator">
			<fmt:formatNumber value="${project.filesInTrash}" />
	</display:column>

	<spring:message var="dirsInUseLabel" code="documents.dirsInUse.label" text="Directories in Use"/>
	<display:column title="${dirsInUseLabel}" sortProperty="dirsInUse" sortable="true"
		headerClass="numberData" class="numberData columnSeparator">
			<fmt:formatNumber value="${project.dirsInUse}" />
	</display:column>

	<spring:message var="dirsInTrashLabel" code="documents.dirsInTrash.label" text="Directories in Trash"/>
	<display:column title="${dirsInTrashLabel}" sortProperty="dirsInTrash" sortable="true"
		headerClass="numberData" class="numberData columnSeparator">
			<fmt:formatNumber value="${project.dirsInTrash}" />
	</display:column>

	<spring:message var="usedSizeLabel" code="documents.usedSize.label" text="Total Size"/>
	<display:column title="${usedSizeLabel}" sortable="true" sortProperty="usedSize"
		headerClass="numberData" class="numberData columnSeparator">
			<tag:formatFileSize value="${project.usedSize}" />
	</display:column>

	<spring:message var="trashSizeLabel" code="documents.trashSize.label" text="Trash Size"/>
	<display:column title="${trashSizeLabel}" sortable="true" sortProperty="trashSize"
		headerClass="numberData" class="numberData columnSeparator">
			<tag:formatFileSize value="${project.trashSize}" />
	</display:column>

	<display:footer>
		<tr class="head">
			<th nowrap="nowrap" align="left">&nbsp;</th>

			<%--
			Disabled document relocatable feature
			<c:if test="${isDocumentRelocatable}">
				<th nowrap="nowrap" align="left">&nbsp;</th>
			</c:if>
			--%>

			<spring:message var="totalLabel" code="documents.total.label" text="Total"/>

			<th class="numberData">${totalLabel}:</th>

			<th class="numberData"><fmt:formatNumber value="${data.totalFilesInUse}" /></th>

			<th class="numberData"><fmt:formatNumber value="${data.totalFilesInTrash}" /></th>

			<th class="numberData"><fmt:formatNumber value="${data.totalDirsInUse}" /></th>

			<th class="numberData"><fmt:formatNumber value="${data.totalDirsInTrash}" /></th>

			<th class="numberData"><tag:formatFileSize value="${data.totalUsedSize}" /></th>

			<th class="numberData"><tag:formatFileSize value="${data.totalTrashSize}" /></th>
		</tr>
	</display:footer>

</display:table>

</form>