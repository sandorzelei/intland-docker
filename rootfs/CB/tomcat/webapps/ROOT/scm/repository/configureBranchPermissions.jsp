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
<%@page import="com.intland.codebeamer.controller.scm.branchpermissions.BranchPermissionsCommand"%>
<%@page import="com.intland.codebeamer.manager.scm.branchpermissions.BranchPermissions"%>
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

<style type="text/css">
	table#permission .permissionsVSroleCell {
		text-align: center;
		vertical-align: middle;
	}
	table#permission th {
  		padding-left: 5px;
  		padding-right: 5px;
  		text-align: center;
  	}
	th.permOwner, td.matrixCell {
		text-align: center;
		width: 4%;
	}
	.otherBranch {
		margin-left: 10px;
	}
	.defaultBranch {
		/*text-decoration: line-through;*/
		color: #858585 !important;
	}
</style>

<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false">
		<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
			<spring:message code="scm.repository.page.title" arguments="${command.repository.name}" htmlEscape="true"/>
		</ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<form:form class="repositoryPermissions">

	<c:if test="${command.canUpdate}">
		<div class="actionBar actionBarWithButtons" style="margin-bottom: 15px;">
			<input type="submit" id="saveButton" class='button' name="SAVE" value="<spring:message code='button.save'/>"/>
			&nbsp; <input type="submit" class="button cancelButton" name="_cancel" value="<spring:message code='button.cancel'/>"/>

			<div class="rightAlignedDescription">
				<c:url var="membersLink" value='/proj/members.spr?proj_id=${command.repository.project.id}'/>
				<spring:message code="scm.repository.permissions.hint.for.roles" arguments="${membersLink}"
					text="Only Roles which has access to the project's repositories are configurable here. For configuring the roles on project level go to <a href='{0}'>Members page</a>"
				/>
			</div>
		</div>
	</c:if>

	<c:set var="branches" value="${command.branches}" />
<div class="contentWithMargins">
	<ui:showErrors />

	<spring:message var="permissionTooltip" code='permission.${command.permission}.tooltip' />
	<p title="${permissionTooltip}">

		<c:set var="permissionText"><b><spring:message code='permission.${command.permission}.label' /></b></c:set>
		<c:set var="repositoryName"><c:out value='${command.repository.name}'/></c:set>
		<c:set var='mainLabel'><spring:message code="scm.repository.permission.branch.main.label" arguments="${permissionText},<b>${repositoryName}</b>" /></c:set>
		<ui:pageTitle prefixWithIdentifiableName="false" >${mainLabel}</ui:pageTitle>
		<%--
		<div class="explanation"><spring:message code='permission.${command.permission}.tooltip' /></div>
		--%>
	</p>
	<p>
		<spring:message code="scm.repository.permission.branch.default.inherited.from"  text="Default branch permissions:" />
		<form:select path="defaultInheritance" cssStyle="margin-left:10px;" disabled="${! command.canUpdate}">
			<c:forEach var="inheritance" items="${command.inheritances}">
				<form:option value="${inheritance}">
					<spring:message code="scm.repository.permission.branch.inheritance.${inheritance}.label" text="${inheritance}" />
				</form:option>
			</c:forEach>
		</form:select>
	</p>

	<script type="text/javascript">
		function updateVisibilityForBranchOptions() {
			var $this = $(this);
			var value = $this.val();
			var $tr = $this.closest("tr");

			// only show checkboxes if the custom is selected
			var visibleCheckboxes = (value == "custom");
			$tr.find("input[type=checkbox]").each(function() {
				var $td = $(this).closest("td");
				$td.css("visibility", visibleCheckboxes ? 'visible' : 'hidden');
			});

			// only show other branch selector if from_other_branch is selected
			$tr.find("select.otherBranch").each(function() {
				var visible = (value == "from_other_branch");
				$(this).css("visibility", visible ? 'visible' : 'hidden');
			});
		}

		$(function() {
			$(".branchOptions").change(updateVisibilityForBranchOptions).each(updateVisibilityForBranchOptions);
		});
	</script>

	<display:table list="${branches}" htmlId="permission" id="branch" cellpadding="0" export="false" >
		<spring:message var="branchesLabel" code="scm.branches.label" text="Branches"/>

		<c:set var="isDefaultBranch" value="${branch == command.defaultBranch}" />
		<display:column title="${branchesLabel}" headerClass="textData" class="textDataWrap columnSeparator ${isDefaultBranch ? 'defaultBranch' : '' }" >
			<c:out value="${branch}" />
		</display:column>

		<display:column title="Settings" headerClass="textData" class="textDataWrap columnSeparator ${isDefaultBranch ? 'defaultBranch' : '' }" >
			<c:choose>
				<c:when test="${isDefaultBranch}">
					<spring:message code="scm.repository.permission.branch.default.branch.permissions.not.configurable" />
				</c:when>
				<c:otherwise>
					<form:select class="branchOptions" path="settings[${branch}].inheritance" cssStyle="max-width: 20em;" title="Inherit from..." disabled="${! command.canUpdate}">
						<c:forEach var="opt" items="${inheritanceOptions}">
							<form:option value="${opt}"><spring:message code="scm.repository.permission.branch.options.${opt}" /></form:option>
						</c:forEach>
					</form:select>
					<form:select cssClass="otherBranch" path="settings[${branch}].branchToInheritFrom" cssStyle="min-width:10em; max-width: 20em;" title="branch" disabled="${! command.canUpdate}">
						<form:option value="">--</form:option>
						<c:forEach var="_branch" items="${branches}">
							<c:if test="${branch != _branch}">
								<form:option value="${_branch}"><c:out value="${_branch}"/></form:option>
							</c:if>
						</c:forEach>
					</form:select>
				</c:otherwise>
			</c:choose>
		</display:column>

		<spring:message var="ownerLabel" code="scm.repository.permission.repository.owner" />
		<c:set var="branchEscaped"><c:out value="${branch}"/></c:set>
		<spring:message var="checkboxTitle" code="scm.repository.permission.branch.for.label" arguments="${branchEscaped},${ownerLabel}" />
		<%-- TODO: missing check all checkbox for owners--%>
			<!-- prepare the checkbox in the column title -->
		<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
		<c:if test="${command.canUpdate}">
			<c:set var="checkAll">
				<br/>
				<input type="checkbox" title="${toggleButton}" name="select_all" value="on" onclick="setAllStatesFrom(this, 'ownerPermissions')">
			</c:set>
		</c:if>
		<c:set var="ownerLabel">
			<label for="checkAll_${branch_rowNum}">${ownerLabel}</label>${checkAll}
		</c:set>

		<display:column title="${ownerLabel}" class="columnSeparator permissionsVSroleCell" >
			<c:if test="${! isDefaultBranch}">
				<form:checkbox path="settings[${branch}].ownerPermissions" value="true" title="${checkboxTitle}" disabled="${! command.canUpdate}" id="ownerPermissions_${branch_rowNum}" />
			</c:if>
		</display:column>

		<c:forEach var="role" items="${command.roles}">	<!-- TODO: use rolesDecorated property ????-->
			<spring:message var="roleLabel" code="role.${role.name}.label" text="${role.name}" htmlEscape="true" />

			<!-- prepare the checkbox in the column title -->
			<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
			<c:if test="${command.canUpdate}">
				<c:set var="checkAll">
					<br/>
					<input type="checkbox" id="checkAllForRole_${role.id}" title="${toggleButton}" name="select_all" value="on" onclick="setAllStatesFrom(this, 'permissions_${role.id}')">
				</c:set>
			</c:if>
			<c:set var="checkboxForRoleInHeader">
				<label for="checkAllForRole_${role.id}">${roleLabel}</label>${checkAll}
			</c:set>

			<display:column title="${checkboxForRoleInHeader}" class="columnSeparator permissionsVSroleCell" headerClass="">
				<c:if test="${! isDefaultBranch}">
					<c:set var="checkboxid" value="permissions_${role.id}_${permission.id}" />
					<spring:message var="checkboxTitle" code="scm.repository.permission.branch.for.label" arguments="${branchEscaped},${roleLabel}"/>
					<form:checkbox path="settings[${branch}].rolesWithPermission" value="${role.id}" id="${checkboxid}"
						disabled="${! command.canUpdate}" title="${checkboxTitle}" 	/>
				</c:if>
			</display:column>
		</c:forEach>
	</display:table>
</div>

</form:form>
