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

<meta name="decorator" content="main"/>
<c:choose>
<c:when test="${flowDef == 'createProject'}">
	<meta name="module" content="project_browser"/>
	<meta name="moduleCSSClass" content="projectModule newskin"/>
	<spring:message var="titleContext" code="project.creation.title" text="Create New Project"/>
</c:when>
<c:otherwise>
	<meta name="module" content="sources"/>
	<meta name="moduleCSSClass" content="newskin sourceCodeModule"/>
	<spring:message var="titleContext" code="scm.repository.creation.title"/>
</c:otherwise>
</c:choose>

<style type="text/css">
<!--
 .newskin input[type="checkbox"] {
	vertical-align: text-bottom;
 }
-->
</style>

<wysiwyg:froalaConfig />

<spring:message var="scmTypeName" code="scc.name.${scmType}" />

<ui:actionMenuBar>
	<c:choose>
		<c:when test="${flowDef != 'createProject'}">
			<ui:breadcrumbs showProjects="false" projectAware="${scmForm.repositoryDto}"/>
			<ui:breadcrumbs showProjects="false">
				<ui:pageTitle>
					<span class='breadcrumbs-separator'>&raquo;</span>
					${titleContext} <span class='breadcrumbs-separator'>&raquo;</span>
					<spring:message code="project.administration.scm.managed.repository.title" text="New Managed {0} Repository" arguments="${scmTypeName}"/>
				</ui:pageTitle>
			</ui:breadcrumbs>
		</c:when>
		<c:otherwise>
			<ui:pageTitle>
				${titleContext} <span class='breadcrumbs-separator'>&raquo;</span>
				<spring:message code="project.administration.scm.managed.repository.title" text="New Managed {0} Repository" arguments="${scmTypeName}"/>
			</ui:pageTitle>
		</c:otherwise>
	</c:choose>
</ui:actionMenuBar>

<script type="text/javascript">
function submitForm() {
    var $editor = $('#editor');

    if (codebeamer.WYSIWYG.getEditorMode($editor) == 'wysiwyg') {
        codebeamer.WikiConversion.saveEditor($editor, true);
    }

	return true;
}
</script>

<form:form commandName="${flowForm}" enctype="multipart/form-data" action="${flowUrl}">

<c:if test="${not uploadFileValid}">
	<span class="error"><spring:message code="project.administration.scm.managed.repository.dump.error" text="Unable to upload dump file. Please try again!" /></span>
</c:if>

<form:hidden path="projectId"/>

<ui:actionBar>
	<input type="submit" name="_eventId_submit" value="Finish" style="display:none;" onclick="return submitForm(this);"/>

<%-- Since CB-5.7 source files are not parsed/analyzed any more
	<c:if test="${flowDef == 'createProject'}">
		<spring:message var="advButton" code="project.administration.scm.managed.repository.advanced.button" text="Advanced Options &gt;"/>
		&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_advanced" value="${advButton}" />
	</c:if>
--%>
	<spring:message var="finishButton" code="project.creation.finish.button" text="Finish"/>
	&nbsp;&nbsp;<input id="finishButton" type="submit" class="button" name="_eventId_submit" value="${finishButton}" onclick="return submitForm(this);"/>

	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<input type="submit" class="linkButton button" name="_eventId_back" value="${backButton}" />

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<input type="submit" class="cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<form:errors cssClass="error"/>

<div class="contentWithMargins" style="margin-top:20px;">
<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="2">

<TR>
	<TD class="mandatory"><spring:message code="project.administration.scm.managed.repository.name.label" text="Repository Name"/>:</TD>
	<TD NOWRAP>
		<form:input path="repositoryName" size="80" maxlength="255"/>
		<BR/>
		<form:errors path="repositoryName" cssClass="invalidfield"/>
	</TD>
</TR>

<tr>
	<td class="optional labelcell">
		<spring:message code="scm.repository.description.label" text="Description"/>:
	</td>
	<td>
		<wysiwyg:editor editorId="editor" disablePreview="true" useAutoResize="false" formatSelectorSpringPath="descriptionFormat" height="200" overlayHeaderKey="wysiwyg.repository.description.editor.overlay.header">
		    <form:textarea id="editor" path="repositoryDescription" rows="10" cols="90" />
		</wysiwyg:editor>
		<form:errors path="repositoryDescription" cssClass="invalidfield"/>
	</td>
</tr>

<tr>
	<td class="optional labelcell">
		<spring:message code="scm.repository.publicRead.label" text="Public access"/>:
	</td>
	<td class="expandText">
		<form:checkbox path="publicRead"/>
	</td>
</tr>

<c:if test="${createProjectForm.supportCommitOnlyWithTaskId || scmForm.supportCommitOnlyWithTaskId}">
	<tr>
		<td class="optional"><spring:message code="scm.repository.scmLoop.label" text="Tracker SCM Loop"/>:</td>
		<td>
			<form:checkbox path="commitOnlyWithTaskId" id="commitOnlyWithTaskId"/>
			<label for="commitOnlyWithTaskId">
				<spring:message code="scm.repository.commitOnlyWithTaskId.label" text="Allow checkins/commits only with valid CodeBeamer Issue IDs"/>
			</label>
		</td>
	</tr>
</c:if>

<c:if test="${sourceCopied != 'true'}">
<TR VALIGN="TOP">
	<TD class="optional"><spring:message code="project.administration.scm.managed.repository.dump.label" text="Load dump file"/>:</TD>

	<TD NOWRAP>
		<ui:fileUpload single="true" uploadConversationId="${currentFormObject.uploadConversationId}" />
		<br/>
		<form:errors path="uploadConversationId" cssClass="invalidfield"/>

		<p class="explanation" style="margin-left:10px;clear:both">
			<c:choose>
				<c:when test="${scmType eq 'hg'}">
					<c:set var="dumpTool" value="hg bundle"/>
				</c:when>
				<c:when test="${scmType eq 'git'}">
					<c:set var="dumpTool" value="git bundle"/>
				</c:when>
				<c:when test="${scmType eq 'svn'}">
					<c:set var="dumpTool" value="svnadmin dump"/>
				</c:when>
				<c:otherwise>
					<spring:message var="dumpTool" code="project.administration.scm.managed.repository.dump.tool" text="dump creation command of the provider"/>
				</c:otherwise>
			</c:choose>
			<spring:message code="project.administration.scm.managed.repository.dump.tooltip" text="(Must be created with {0})" arguments="${dumpTool}"/>
		</p>
	</TD>
</TR>
</c:if>

</TABLE>
</div>

</form:form>

<c:if test="${projectCreation}">
	<spring:message var="dialogMessage" code="project.creation.dialog.content" />
	<ui:inProgressDialog message="${dialogMessage}" imageUrl="${pageContext.request.contextPath}/images/newskin/project_create_in_progress.gif" height="250" attachTo="#finishButton" triggerOnClick="true" />
</c:if>
