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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag"%>

<meta name="decorator" content="main"/>
<meta name="module" content="admin"/>
<meta name="moduleCSSClass" content="adminModule newskin"/>

<c:url var="historicPermissionsUrl" value="/proj/admin/rolePermissions.spr">
	<c:param name="proj_id"  value="${project.id}"/>
	<c:param name="role_id"  value="${role.genericReferenceId}"/>
	<c:param name="revision" value=""/>
</c:url>

<script type="text/javascript">
	function confirmDelete(form) {
		return confirm('<spring:message code="role.delete.item.confirm" />');
	}

	function showHistoricPermissions(selector) {
		var version = selector.value;
		if (version == null || version == "") {
			$('input[type="checkbox"][name="historicPermission"]').hide();
		} else {
			$.getJSON('${historicPermissionsUrl}' + version, function(data) {
				$.each(data, function(key, val) {
					$("#historicPermission_" + key).attr('checked', val);
				});
				$('input[type="checkbox"][name="historicPermission"]').show();
			});
		}
	}

	function findPermissionCheckbox(id){
		return $('input[id="permission_' + id + '"][type="checkbox"][name="permission"]');
	}

	function enableDisablePermissionsCheckbox(id, enable){
		var currentPermission = findPermissionCheckbox(id);
		currentPermission.prop('disabled', !enable);
		if (!enable){
			currentPermission.prop('checked', false);
		}
	}

	function isPermissionChecked(id){
		return findPermissionCheckbox(id).prop('checked');
	}

	function checkProjectPermissionDependencies(){
		var wiki_space_view 					= 1
		var document_view 						= 2
		var document_view_history 				= 4
		var document_add 						= 8
		var document_unpack						= 16
		var document_subscribe					= 32
		var document_subscribe_others			= 64
		var document_subscribers_view			= 128
		var tracker_view						= 256
		var tracker_admin						= 512
		var tracker_report						= 1024
		var cmdb_view							= 2048
		var cmdb_admin							= 4096
		var baseline_view						= 8192
		var baseline_admin						= 16384
		var scm_view							= 65536
		var scm_admin							= 131072
		var members_view						= 262144
		var members_admin						= 524288
		var member_role_view					= 1048576
		var project_admin						= 4194304
		var branch_view							= 8388608
		var branch_admin						= 16777216
		/* Artifact (Document/Wiki) permissions depend on document/wiki view */
		if (!isPermissionChecked(wiki_space_view) && !isPermissionChecked(document_view)) {
			enableDisablePermissionsCheckbox(document_subscribe, false);
			enableDisablePermissionsCheckbox(document_subscribers_view, false);
			enableDisablePermissionsCheckbox(document_view_history, false);
		} else {
			enableDisablePermissionsCheckbox(document_subscribe, true);
			enableDisablePermissionsCheckbox(document_subscribers_view, true);
			enableDisablePermissionsCheckbox(document_view_history, true);
		}

		/* Document add depend on document view */
		if (!isPermissionChecked(document_view)) {
			enableDisablePermissionsCheckbox(document_add, false);
			enableDisablePermissionsCheckbox(baseline_view, false);
		} else {
			enableDisablePermissionsCheckbox(document_add, true);
			enableDisablePermissionsCheckbox(baseline_view, true);
		}

		/* Document unpack depends on document add */
		if (!isPermissionChecked(document_add)) {
			enableDisablePermissionsCheckbox(document_unpack, false);
			enableDisablePermissionsCheckbox(baseline_admin, false);
		} else {
			enableDisablePermissionsCheckbox(document_unpack, true);
			enableDisablePermissionsCheckbox(baseline_admin, true);
		}

		/* Only subscribe others is can subscribe itself */
		if (!isPermissionChecked(document_subscribe)) {
			enableDisablePermissionsCheckbox(document_subscribe_others, false);
		} else {
			enableDisablePermissionsCheckbox(document_subscribe_others, true);
		}

		/* Only can admin Trackers when can see Trackers */
		if (!isPermissionChecked(tracker_view)) {
			enableDisablePermissionsCheckbox(tracker_admin, false);
		} else {
			enableDisablePermissionsCheckbox(tracker_admin, true);
		}

		/* Only can admin CMDB when can see CMDB */
		if (!isPermissionChecked(cmdb_view)) {
			enableDisablePermissionsCheckbox(cmdb_admin, false);
		} else {
			enableDisablePermissionsCheckbox(cmdb_admin, true);
		}

		/* SCM permissions depend on scm view */
		if (!isPermissionChecked(scm_view)) {
			enableDisablePermissionsCheckbox(scm_admin, false);
		} else {
			enableDisablePermissionsCheckbox(scm_admin, true);
		}

		/* Only can admin members when can see members */
		if (!isPermissionChecked(members_view)) {
			enableDisablePermissionsCheckbox(members_admin, false);
		} else {
			enableDisablePermissionsCheckbox(members_admin, true);
		}

		/* Only can admin of branches when can see branches */

		if (!isPermissionChecked(cmdb_view) && !isPermissionChecked(tracker_view)) {
			enableDisablePermissionsCheckbox(branch_view, false);
		} else {
			enableDisablePermissionsCheckbox(branch_view, true);
		}

		if (!isPermissionChecked(branch_view)) {
			enableDisablePermissionsCheckbox(branch_admin, false);
		} else if (isPermissionChecked(branch_view)) {
			enableDisablePermissionsCheckbox(branch_admin, true);
		}

		/* Only can admin roles when can see roles
		 if (member_role_view.check(bitmask) == false) {
		 bitmask = member_role_admin.clear(bitmask);
		 } */
	}

	$(function() {
		checkProjectPermissionDependencies();
	});
</script>

<style>

#permission th {
	vertical-align: middle;
	padding: 8px 5px;
}

#permission th.check-all-title input {
	padding: 0 !important;
	margin: 0 !important;
}

.editRoleTable.fieldsTable td.labelCell {
	width: auto;
}

.editRoleTable td {
	vertical-align: baseline !important;
}

</style>

<c:url var="actionUrl" value="/proj/admin/editRole.spr">
	<c:param name="proj_id" value="${project.id}"/>
</c:url>

<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
	<c:if test="${role.id != null}">
		<span><spring:message code="role.${role.name}.label" text="${name}" htmlEscape="true" javaScriptEscape="true"/></span><span class='breadcrumbs-separator'>&raquo;</span>
	</c:if>
	<ui:pageTitle>
		<span><spring:message code="role.${actionType}.title" text="${actionType} Role"/></span>
	</ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<form:form action="${actionUrl}" method="post" commandName="command">

	<ui:actionBar>
		<c:if test="${editable}">
			<spring:message var="submitButton" code="button.save" text="Save"/>
			<input type="submit" class="button" value="${submitButton}" name="SUBMIT"/>
		</c:if>

		<c:if test="${role.id != null and editable}">
			<spring:message var="deleteButton" code="button.delete" text="Delete..."/>
			<input type="submit" class="linkButton" value="${deleteButton}" name="DELETE" onclick="return confirmDelete(this);" />
		</c:if>

		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" />
	</ui:actionBar>

	<input type="hidden" name="role_id" value="${role.genericReferenceId}"/>

	<div class="contentWithMargins">
		<table border="0" cellpadding="0" cellspacing="0" style="margin-bottom:5px;" class="fieldsTable editRoleTable">
			<c:choose>
				<c:when test="${editable}">
					<tr>
						<td class="mandatory labelCell"><spring:message code="role.label" text="Role"/>:</td>
						<td class="expandText" style="padding-bottom: 10px; white-space: nowrap">
							<form:input path="name" id="roleName" size="80" maxlength="80"/>

							<c:if test="${!empty roles}">
								&nbsp;
								<spring:message code="role.template.label" text="Based on"/>
								<select name="templateId" onchange="document.location.href='${actionUrl}&amp;templateId=' + this.value + '&amp;name=' + encodeURI($('#roleName').val()) + '&amp;description=' + encodeURI($('#roleDesc').val());">
									<c:forEach items="${roles}" var="template">
										<spring:message var="templateTitle" code="role.${template.name}.tooltip" text="${template.shortDescription}" htmlEscape="true"/>
										<option value="${template.id}" title="${templateTitle}" <c:if test="${templateId eq template.id}">selected="selected"</c:if>>
											<spring:message code="role.${template.name}.label" text="${template.name}" htmlEscape="true"/>
										</option>
									</c:forEach>
								</select>
							</c:if>
						</td>
						<c:if test="${role.id != null}">
							<td class="optional"><spring:message code="document.createdBy.label" text="Created by"/>:</td>
							<td nowrap>&nbsp;<c:out value="${role.owner.name}"/>, <tag:formatDate value="${role.createdAt}"/> &nbsp;</td>
						</c:if>
					</tr>
					<tr>
						<td class="optional labelCell"><spring:message code="role.description.label" text="Description"/>:</td>
						<td class="expandText dataCell" nowrap>
							<form:input id="roleDesc" name="description" path="description"  size="120" maxlength="255" cssClass="expandText"/>
						</td>
						<c:if test="${role.id != null}">
							<td class="optional"><spring:message code="document.lastModifiedBy.tooltip" text="Last modified by"/>:</td>
							<td nowrap>&nbsp;<c:out value="${role.lastModifiedBy.name}"/>, <tag:formatDate value="${role.lastModifiedAt}"/>&nbsp;</td>
						</c:if>
					</tr>
				</c:when>

				<c:otherwise>
					<tr>
						<td class="optional"><spring:message code="role.label" text="Role"/>:</td>
						<td class="tableItem">&nbsp;<c:out value="${name}" />&nbsp;</td>
						<td class="optional"><spring:message code="document.createdBy.label" text="Created by"/>:</td>
						<td nowrap>&nbsp;<c:out value="${role.owner.name}"/>, <tag:formatDate value="${role.createdAt}"/> &nbsp;</td>
					</tr>
					<tr>
						<td class="optional"><spring:message code="role.description.label" text="Description"/>:</td>
						<td class="tableItem">&nbsp;<c:out value="${description}" />&nbsp;</td>
						<td class="optional"><spring:message code="document.lastModifiedBy.tooltip" text="Last modified by"/>:</td>
						<td nowrap>&nbsp;<c:out value="${role.lastModifiedBy.name}"/>, <tag:formatDate value="${role.lastModifiedAt}"/>&nbsp;</td>
					</tr>
				</c:otherwise>
			</c:choose>

			<tr>
				<td colspan="4" style="padding-top: 6px;">
					<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
					<c:set var="checkAll">
						<input type="checkbox" title="${toggleButton}" name="select_all" value="on" onclick="setAllStatesFrom(this, 'permission')" <c:if test="${!editable}">disabled="disabled"</c:if>>
					</c:set>

					<display:table name="${permissions}" id="permission" cellpadding="0" export="false" sort="external">
						<display:column title="${checkAll}" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" headerClass="check-all-title" class="checkbox-column-minwidth" style="text-align: center;">
							<input id="permission_${permission.key.id}" type="checkbox" name="permission" onchange="checkProjectPermissionDependencies();" value="${permission.key.id}" <c:if test="${permission.value}">checked="checked"</c:if><c:if test="${!editable}">disabled="disabled"</c:if> />
						</display:column>

						<spring:message var="permissionLabel" code="permission.label" text="Permission"/>
						<display:column title="${permissionLabel}" headerClass="textData" class="textDataWrap columnSeparator" >
							<label for="permission_${permission.key.id}"><spring:message code="permission.${permission.key.name}.label"/></label>
						</display:column>

						<spring:message var="permissionDesc" code="permission.description.label" text="Description"/>
						<display:column title="${permissionDesc}" headerClass="textData" class="textDataWrap columnSeparator">
							<spring:message code="permission.${permission.key.name}.tooltip"/>
						</display:column>

						<c:if test="${role.id != null and !empty history}">
							<c:set var="historicPermissionLabel">
								<spring:message code="document.history.title" text="History"/>:
								<select onchange="showHistoricPermissions(this);">
									<option value=""><spring:message code="document.baselines.head.label" text="Head revision"/></option>
									<c:forEach items="${history}" var="revision">
										<option value="${revision.version}">
											<c:out value="${revision.lastModifiedBy.name}"/>, <tag:formatDate value="${revision.lastModifiedAt}"/>
										</option>
									</c:forEach>
								</select>
							</c:set>

							<display:column title="${historicPermissionLabel}" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" class="checkbox-column-minwidth" style="text-align: center;">
								<input id="historicPermission_${permission.key.id}" type="checkbox" name="historicPermission" value="${permission.key.id}" disabled="disabled" style="display:none;" />
							</display:column>
						</c:if>
					</display:table>
				</td>
			</tr>
		</table>
	</div>
</form:form>
