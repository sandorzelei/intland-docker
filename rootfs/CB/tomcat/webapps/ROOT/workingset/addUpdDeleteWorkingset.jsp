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
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="workspaceModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<wysiwyg:froalaConfig />

<head>
<style type="text/css">
	#filter {
		margin-top: 15px;
		margin-bottom: 15px;
	}
	#name {
		margin-top: 10px;
		margin-bottom: 5px;
	}
</style>
</head>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers
function confirmDelete(form) {
	return confirm('<spring:message code="workingset.delete.confirm" />');
}

function onProjectSelected(item) {
	// change project selection on both tabs
	var form = document.getElementById('workingSetForm');
	var checked = item.checked;
	var length = form.elements.length;
	for (var i=0; i < length; i++) {
		var e = form.elements[i];
		if(e.name.indexOf('selectedItemId') != -1 && e.value == item.value) {
			e.checked = checked;
		}
	}
}

function selectWorkingSetDetailsTab(event) {
	org.ditchnet.jsp.TabUtils.tabLinkClicked(event,'user-working-set-details');
}

function nextButtonClicked(event) {
	var nextButton = document.getElementById("nextButton");
	var saveButton = document.getElementById("saveButton");
	// hide next and show save button
	nextButton.style.display = "none";
	saveButton.style.display = "inline";

	// show the tabs
	// the parent div is put there by ditchnet to allow the skining
	var tabContainer = document.getElementById("user-working-set-editor");
	var parent_with_skin = tabContainer.parentNode;
	$(parent_with_skin).removeClass("ditch-tab-skin-invisible-project");
	// click on next
	org.ditchnet.jsp.TabUtils.tabLinkClicked(event,'user-working-set-projects');
}

function showProjectDetails(event) {
	// switch to next tab using ditchnet's function
	org.ditchnet.jsp.TabUtils.nextTabButtonClicked(event,'user-working-set-projects-container');

	updateProjectDetailsLinkText();
}

function updateProjectDetailsLinkText() {
	var showProjectDetailsLink = document.getElementById("showProjectDetailsLink");

	var projectsDiv = document.getElementById("user-working-sets-projects-simple");
	var text;
	if (projectsDiv.style.display == "none") {
		text = "Less details...";
	} else {
		text = "More details...";
	}
	showProjectDetailsLink.innerHTML = text;
}

// when page loaded update more/less details text
$(function() {
	updateProjectDetailsLinkText();
	$("#name").focus();
});

// -->
</SCRIPT>

<c:if var="editWorkingSet" test="${!empty workingSetId}" />

<c:choose>
	<c:when test="${editWorkingSet}">
		<spring:message var="title" code="workingset.edit.label" text="Edit Working Set"/>
	</c:when>

	<c:otherwise>
		<spring:message var="title" code="workingset.create.label" text="Create Working Set"/>
	</c:otherwise>
</c:choose>

<ui:actionMenuBar>
	<ui:pageTitle>${title}</ui:pageTitle>
</ui:actionMenuBar>

<c:set var="tabSkin" value="" />
<c:set var="controlButtons">
	<c:choose>
		<c:when test="${editWorkingSet}">

			<spring:message var="saveButton" code="button.save" text="Save"/>
			<spring:message var="deleteButton" code="button.delete" text="Delete"/>

			&nbsp;&nbsp;<input type="submit" class="button" value="${saveButton}" />
			&nbsp;&nbsp;<input type="submit" class="button" name="DELETE" value="${deleteButton}" onclick="return confirmDelete(this.form);" />
		</c:when>
		<c:otherwise>
			<!-- adding a new workingset -->
			<spring:message var="addButton" code="button.add" text="Add"/>
			<spring:message var="nextButton" code="button.continue" text="Continue"/>
			&nbsp;&nbsp;
			<input type="submit" class="button" id="nextButton" onclick="nextButtonClicked(event);" value="${nextButton}" />
			<input type="submit" class="button" id="saveButton" value="${addButton}" style="display:none;" />

			<SCRIPT type="text/javascript">
				$(selectWorkingSetDetailsTab);
			</SCRIPT>
		</c:otherwise>
	</c:choose>

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

	&nbsp;&nbsp;<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" />
</c:set>

<form:form commandName="workingSetForm">

<ui:actionBar>
	<c:out value="${controlButtons}" escapeXml="false" />
</ui:actionBar>

<spring:hasBindErrors name="workingSetForm">
	<c:if test="${errors.errorCount > 0}">
		<div class="warning">Please correct the errors below!</div>
	</c:if>
</spring:hasBindErrors>

<div style="margin:10px;">
<tab:tabContainer id="user-working-set-editor" skin="cb-box ${tabSkin}">
	<spring:message var="workingSetDetails" code="workingset.details.label" text="Details"/>
	<tab:tabPane id="user-working-set-details" tabTitle="${workingSetDetails}">

	<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="2">

	<TR>
		<TD class="mandatory" ><spring:message code="workingset.name.label" text="Name" />:</TD>
		<TD CLASS="expandText">
			<form:input path="name" size="60" maxlength="50" cssClass="expandText"/><br/><form:errors path="name" cssClass="invalidfield"/>
		</TD>
	</TR>

	<TR>
		<TD VALIGN="top" class="mandatory">
			<spring:message code="workingset.description.label" text="Description" />:
		</TD>

		<TD CLASS="expandTextArea">
			<wysiwyg:editor editorId="editor" formatSelectorSpringPath="descriptionFormat" useAutoResize="true" heightMin="200">
			    <form:textarea path="description" id="editor" rows="10" cols="60" />
			</wysiwyg:editor>
			<br/>
			<form:errors path="description" cssClass="invalidfield"/>
		</TD>
	</TR>
	</TABLE>

</tab:tabPane>

<spring:message var="workingSetProjects" code="workingset.projects.label" text="Projects"/>
<tab:tabPane id="user-working-set-projects" tabTitle="${workingSetProjects}">

	<strong><spring:message code="workingset.projects.available" text="Available Projects"/>:&nbsp;</strong>

	<span class="optional"><spring:message code="project.filter.label" text="Filter"/>:</span>
	<form:input path="filter" size="30" maxlength="40" />

	<spring:message var="searchButton" code="search.submit.label" text="GO"/>
	<spring:message var="searchTitle" code="search.submit.tooltip" text="Apply this filter"/>
	&nbsp;<input type="submit" class="button" name="FILTER" value="${searchButton}" title="${searchTitle}" />

	<a id="showProjectDetailsLink" href="#" onclick="showProjectDetails(event);">
		<spring:message code="workingset.projects.lessDetail" text="Less details.."/>
	</a>

	<spring:message var="searchToggle" code="search.what.toggle" text="Select/Clear All"/>
	<c:set var="checkAll">
		<input type="checkbox" title="${searchToggle}"
			name="select_all" value="on"
			onclick="setAllStatesFrom(this, 'selectedItemId')">
	</c:set>
		<br />
		<form:errors path="selectedItemId" cssClass="invalidfield"/>
		<%-- The "invisible" skin makes only the selected tab visible, which is switched by the showProjectDetailsLink above --%>
		<tab:tabContainer id="user-working-set-projects-container" skin="invisible">

		<tab:tabPane id="user-working-sets-projects-simple" tabTitle="projects">

			<display:table requestURI="/editWorkingSet.spr" name="${availableItems}" id="item" cellpadding="0" export="false" defaultsort="2">
				<display:column title="${checkAll}" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator"
					headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth"
				>
					<form:checkbox path="selectedItemId" value="${item.id}" onclick="onProjectSelected(this)" />
				</display:column>

				<spring:message var="projectName" code="project.name.label" text="Name"/>
				<display:column title="${projectName}" sortable="true" sortProperty="name" headerClass="textData" class="textData columnSeparator">
					<a class="${item.styleClass}" href="<c:url value="${item.urlLink}" />"><c:out value="${item.name}" /></a>
				</display:column>

				<spring:message var="projectCategory" code="project.category.label" text="Category"/>
				<display:column title="${projectCategory}" property="category" sortProperty="category" sortable="true" headerClass="textData" class="textData" />
			</display:table>
		</tab:tabPane>

		<tab:tabPane id="user-working-sets-projects-detailed" tabTitle="projects-detailed">
			<display:table requestURI="/editWorkingSet.spr" name="${availableItems}" id="item" cellpadding="0"
				export="false" defaultsort="2">

				<display:column title="${checkAll}" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" class="checkbox-column-minwidth">
					<form:checkbox path="selectedItemId" value="${item.id}" onclick="onProjectSelected(this)" />
				</display:column>

				<spring:message var="projectName" code="project.name.label" text="Name"/>
				<display:column title="${projectName}" sortable="true" sortProperty="name" headerClass="textData" class="textData columnSeparator">
					<c:url var="project" value="${item.urlLink}" />
					<a href="${project}"><c:out value="${item.name}" /></a>
				</display:column>

				<spring:message var="projectCreatedAt" code="project.createdAt.label" text="Created"/>
				<display:column title="${projectCreatedAt}" sortProperty="createdAt" sortable="true" headerClass="dateData" class="dateData columnSeparator">
					<tag:formatDate value="${item.createdAt}" />
				</display:column>

				<spring:message var="projectCreatedBy" code="project.createdBy.label" text="Created by"/>
				<display:column title="${projectCreatedBy}" sortProperty="createdBy.name" sortable="true" headerClass="textData" class="textData columnSeparator">
					<tag:userLink user_id="${item.createdBy}" />
				</display:column>

				<spring:message var="projectAdministrators" code="project.admins.label" text="Administrators"/>
				<display:column title="${projectAdministrators}" headerClass="textData" class="textData columnSeparator wrap-content">
					<c:set var="separator" value="" />

					<tag:joinLines newLinePrefix="">
						<c:forEach items="${projectAdmins[item.id]}" var="projectAdmin">
							<c:out value="${separator}" escapeXml="false" /><tag:userLink user_id="${projectAdmin}" />
								<c:set var="separator" value="," />
						</c:forEach>
					</tag:joinLines>
				</display:column>

				<spring:message var="projectCategory" code="project.category.label" text="Category"/>
				<display:column title="${projectCategory}" property="category" sortProperty="category" sortable="true"
					headerClass="textData" class="textData columnSeparator" />

				<spring:message var="projectDescription" code="project.description.label" text="Description"/>
				<display:column title="${projectDescription}" sortProperty="description" sortable="true"
					headerClass="textDataWrap" class="textDataWrap">
					<tag:transformText value="${item.description}" format="${item.descriptionFormat}" />
				</display:column>
			</display:table>
		</tab:tabPane>
		</tab:tabContainer>

</tab:tabPane>
</tab:tabContainer>
</div>

</form:form>
