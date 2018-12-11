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
<%@ page import="com.intland.codebeamer.remoting.GroupType"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="callTag" prefix="ct" %>

<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>

<meta name="decorator" content="main"/>
<meta name="module" content="sources"/>
<meta name="moduleCSSClass" content="sourceCodeModule newskin"/>
<meta name="stylesheet" content="sources.css"/>

<%--
	Page displays/edits directory based permissions of a Repository
	See ScmRepositoryDirectoryPermissionsController
 --%>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false">
		<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
			<spring:message code="scm.repository.page.title" arguments="${repository.name}" htmlEscape="true"/>
		</ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<c:choose>
<c:when test="${doesNotSupport}">
	<div class="warning">
		<spring:message code="scm.repository.permission.dir.permissions.not.supported.by.repository" arguments="${repository.type}" />
	</div>
</c:when>
<c:otherwise>

<c:url var="actionURL" value="/proj/scm/repository/directoryPermissions.spr"/>

<style type="text/css">
	.directories {
		margin-bottom: 10px;
	}
	.directories .dirlist {
		font-family: monospace;
		font-weight: bold;
	}
</style>

<form:form action="${actionURL}">
	<form:hidden path="repositoryId"/>
	<form:hidden path="basedir" />

	<%-- include hidden directory names --%>
	<c:if test="${!empty command.dirname}">
		<c:forEach items="${command.dirname}" var="dirname">
			<form:hidden path="dirname" value="${dirname}" />
		</c:forEach>
	</c:if>

	<c:set var="isRepoRootDirectory" value="${empty command.basedir && empty command.dirname}"/>

	<c:if test="${canUpdate}">
	<%-- TODO: not sure if checkbox or dedicated buttons are the best? --%>
	<ui:actionBar>
		&nbsp;<input type="submit" class="button" name="submit" value="<spring:message code='button.save'/>"/>
		&nbsp;<input type="submit" class="button" name="recursive"
					value="<spring:message code='scm.repository.permissions.recursive.button.label' text="Save Recursive"/>"
					title="<spring:message code='scm.repository.permissions.recursive.button.tooltip' text="Save Recursive"/>"
			  />
		&nbsp;<input type="submit" class="button cancelButton" name="__cancel" value="<spring:message code='button.cancel'/>"/>
	</ui:actionBar>
	</c:if>

<div class='contentWithMargins'>
	<div class="directories">
		<c:choose>
			<c:when test="${isRepoRootDirectory}">
				<c:choose>
					<c:when test="${canUpdate}">
						<spring:message code="scm.repository.permissions.root.directory.explanation"
								text="Configuring permissions for the repository root directory."/>
					</c:when>
					<c:otherwise>
						<spring:message code="scm.repository.permissions.root.directory.explanation.readonly"
								text="Viewing permissions for the repository root directory."/>
					</c:otherwise>
				</c:choose>
			</c:when>
			<c:otherwise>
				<c:choose>
					<c:when test="${canUpdate}">
						<spring:message code="scm.repository.permissions.directories.explanation"
								text="Configuring permissions for directories:"/><br/>
					</c:when>
					<c:otherwise>
						<spring:message code="scm.repository.permissions.directories.explanation.readonly"
								text="Viewing permissions for directories:"/><br/>
					</c:otherwise>
				</c:choose>
				<span class="dirlist">
				<c:forEach var="dir" items="${command.directories}" varStatus="status">${not status.first ? ', ' :''}<c:out value="${dir}"/></c:forEach>
				</span>
			</c:otherwise>
		</c:choose>
	</div>

<%--
	<label id="recursiveCheckboxLabel" for="recursiveCheckbox">
		<form:checkbox path="recursive" value="true" id="recursiveCheckbox"/>
		<spring:message code="scm.repository.permissions.recursive.label" text="Recursive"/>
		<from:hidden path="recursive" value="false" />
	</label>
--%>

	<spring:message var="toggleButton" code="search.what.toggle"/>
	<c:set var="checkAllReadRoles">
		<c:if test="${canUpdate}">
			<INPUT TYPE="CHECKBOX" TITLE="${toggleButton}" NAME="SELECT_ALL" VALUE="on" ONCLICK="setAllStatesFrom(this, 'rolesWithReadPermissions')">
		</c:if>
		<spring:message code="scm.repository.permission.read.label" text="Read"/>
	</c:set>

	<c:set var="checkAllWriteRoles">
		<c:if test="${canUpdate}">
			<INPUT TYPE="CHECKBOX" TITLE="${toggleButton}" NAME="SELECT_ALL" VALUE="on"	ONCLICK="setAllStatesFrom(this, 'rolesWithWritePermissions')">
		</c:if>
		<spring:message code="scm.repository.permission.write.label" text="Write"/>
	</c:set>

	<script type="text/javascript">
		function onReadPermissionChange(checkbox) {
			var writePermissionId = checkbox.id.replace("readPermission", "writePermission");
			$("#"+writePermissionId).attr("disabled", !checkbox.checked);
		}
	</script>

	<display:table name="${roles}" id="role" cellpadding="0" defaultsort="1">
		<spring:message var="roleTitle" code="role.label" text="Role"/>
		<display:column title="${roleTitle}" headerClass="textData" class="textDataWrap columnSeparator">
			<spring:message code="role.${role.name}.label" text="${role.name}" htmlEscape="true"/>
		</display:column>

		<spring:message var="membersTitle" code="members.label" text="Members"/>
		<display:column title="${membersTitle}" headerClass="textData" class="textDataWrap columnSeparator">
			<ui:listMembersOfRole scope="${repository}" role="${role}"/>
		</display:column>

		<display:column title="${checkAllReadRoles}" media="html" headerClass="textData" class="textData columnSeparator">
			<ct:call object="${command}" method="hasReadPermission" param1="${role.id}" return="readChecked"/>
			<input type="checkbox"" name="rolesWithReadPermissions" value="${role.id}" id="readPermission_${role.id}"
				<c:if test="${readChecked}">checked="checked"</c:if>
				onchange="onReadPermissionChange(this);"
				<c:if test="${! canUpdate}">disabled="disabled"</c:if>
			/>
		</display:column>

		<display:column title="${checkAllWriteRoles}" media="html" headerClass="textData" class="textData">
			<ct:call object="${command}" method="hasWritePermission" param1="${role.id}" return="checked"/>
			<input type="checkbox"" name="rolesWithWritePermissions" value="${role.id}" id="writePermission_${role.id}"
				<c:if test="${checked}">checked="checked"</c:if>
				<c:if test="${!readChecked || !canUpdate}">disabled="disabled"</c:if>
			/>
		</display:column>

	</display:table>
</div>
</form:form>

</c:otherwise>
</c:choose>