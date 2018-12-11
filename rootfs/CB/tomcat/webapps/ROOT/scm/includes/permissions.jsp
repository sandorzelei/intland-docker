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
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<style type="text/css">
	table#permission .permissionsVSroleCell {
		text-align: center;
		vertical-align: middle;
	}
	table#permission th {
  		padding-left: 5px;
  		padding-right: 5px;
  	}
	th.permOwner, td.matrixCell {
		text-align: center;
		width: 4%;
	}
</style>

<c:url var="actionURL"  value="/proj/scm/repository.spr?repositoryId=${repository.id}&module=permissions"/>
<form:form action="${actionURL}" class="repositoryPermissions">

	<c:if test="${canUpdate}">
		<div class="actionBar actionBarWithButtons" style="margin-bottom: 15px;">
			<input type="submit" id="saveButton" class='button' name="SAVE" value="<spring:message code='button.save'/>"/>
			&nbsp; <input type="submit" class="button" name="__cancel" value="<spring:message code='button.reset'/>" />

			<span style="margin-left:20px;"><ui:actionLink keys="configBranchPermissions" builder="scmRepositoryActionMenuBuilder" subject="${repository}" /></span>

			<div class="rightAlignedDescription">
				<c:url var="membersLink" value='/proj/members.spr?proj_id=${repository.project.id}'/>
				<spring:message code="scm.repository.permissions.hint.for.roles" arguments="${membersLink}"
					text="Only Roles which has access to the project's repositories are configurable here. For configuring the roles on project level go to <a href='{0}'>Members page</a>"
				/>
			</div>
		</div>
	</c:if>
</form:form>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/permissionMatrix.js'/>"></script>

<script type="text/javascript">

	$('form.repositoryPermissions').permissionMatrix( ${trackerAccessJSON}, {
		editable			: ${canUpdate},
		showDescriptions	: true,
		permissions			: [<c:forEach items="${trackerPermissionDep}" var="perm" varStatus="loop">{ id: ${perm.id}, name: '${perm.name}', title: '${perm.description}' }<c:if test="${!loop.last}">, </c:if></c:forEach>],
		fields				: [{ id: ${trackerOwnerField.id}, name: '${trackerOwnerField.name}', title: '' }],
		roles				: [<c:forEach items="${roles}" var="role" varStatus="loop">{ id: ${role.id}, name: '${ui:escapeJavaScript(role.name)}', title: '${ui:escapeJavaScript(role.description)}' }<c:if test="${!loop.last}">, </c:if></c:forEach>],
		permissionLabel		: '<spring:message code="permission.label" 		 				 text="Permission"   javaScriptEscape="true"/>',
		fieldsLabel			: '<spring:message code="tracker.fieldAccess.memberFields.label" text="Participants" javaScriptEscape="true"/>',
		rolesLabel			: '<spring:message code="tracker.fieldAccess.roles.label" 		 text="Roles"		 javaScriptEscape="true"/>',
		grantAllText		: '<spring:message code="role.permissions.all.label"  text="All permissions" javaScriptEscape="true"/>',
		revokeAllText		: '<spring:message code="role.permissions.none.label" text="No permissions"  javaScriptEscape="true"/>',
		contextPath			: '${pageContext.request.contextPath}',
		grantToAllText		: '<spring:message code="permission.grant.to.all" 	 text="Grant this permission to all" javaScriptEscape="true"/>',
		revokeFromAllText	: '<spring:message code="permission.revoke.from.all" text="Revoke this permission from all" javaScriptEscape="true"/>',
		grantToAllHint		: '<spring:message code="permission.grant_revoke.all.hint" 	 text="The check box is checked when all possible check box is checked in the selected permission" javaScriptEscape="true"/>',
		projAdminRoleId     : ${projAdminRoleId}
	});

<c:if test="${canUpdate}">
	$('form.repositoryPermissions').repositoryPermissionDependencies();

	$('#saveButton').click(function(event) {
	    event.preventDefault();

		var accessPerms = $('form.repositoryPermissions').getPermissions();

		$.ajax('${trackerPermissionsUrl}', {type: 'POST', data : JSON.stringify(accessPerms), contentType : 'application/json', dataType : 'json' }).done(function(result) {
			showOverlayMessage(i18n.message("ajax.changes.successfully.saved"));
    	}).fail(function(jqXHR, textStatus, errorThrown) {
    		try {
	    		var exception = eval('(' + jqXHR.responseText + ')');
	    		alert(exception.message);
    		} catch(err) {
	    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
    		}
        });

		return false;
	});
</c:if>

</script>

