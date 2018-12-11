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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>


<style type="text/css">

	th.permOwner, td.matrixCell {
		text-align: center;
		width: 4%;
	}

</style>

<form id="documentPermissionsForm">

	<div class="actionBar"></div>

	<div class="accessPerms" style="margin: 1em;"></div>

	<c:if test="${showRecursiveControl}">
		<div style="margin: 1em;">
			<label title='<spring:message code="document.permissions.recursive.tooltip" text="Check me to set same permssions on all childen!" htmlEscape="true"/>'>
				<input id="setPermissionsRecursively" type="checkbox">
				<spring:message code="document.permissions.recursive.label" text="Set same permissions recursively on all children" />
			</label>
		</div>
	</c:if>

</form>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/permissionMatrix.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/ajaxSubmitButton.js'/>"></script>
<script type="text/javascript">

	$('#documentPermissionsForm > div.accessPerms').permissionMatrix( ${artifactAccessJSON}, {
		editable			: ${canModifyPermission},
		permissionLabel		: '<spring:message code="permission.label" text="Permission" javaScriptEscape="true"/>',
		permissions			: [{ id: 1, name: '<spring:message code="document.permissions.read.label" text="Read" javaScriptEscape="true"/>', title: '' },
		           			   { id: 3, name: '<spring:message code="document.permissions.edit.label" text="Edit" javaScriptEscape="true"/>', title: '' }],
		fieldsLabel			: '<spring:message code="tracker.fieldAccess.memberFields.label" text="Participants" javaScriptEscape="true"/>',
		fields				: [{ id: ${artifactOwnerField.id}, name: '${artifactOwnerField.name}', title: '' }],
		rolesLabel			: '<spring:message code="tracker.fieldAccess.roles.label" 		 text="Roles"		 javaScriptEscape="true"/>',
		roles				: [<c:forEach items="${roles}" var="role" varStatus="loop">{ id: ${role.id}, name: '${ui:escapeJavaScript(role.name)}', title: '${ui:escapeJavaScript(role.description)}' }<c:if test="${!loop.last}">, </c:if></c:forEach>],
		grantAllText		: '<spring:message code="role.permissions.all.label"  text="All permissions" javaScriptEscape="true"/>',
		revokeAllText		: '<spring:message code="role.permissions.none.label" text="No permissions"  javaScriptEscape="true"/>',
		grantToAllText		: '<spring:message code="permission.grant.to.all" 	 text="Grant this permission to all" javaScriptEscape="true"/>',
		revokeFromAllText	: '<spring:message code="permission.revoke.from.all" text="Revoke this permission from all" javaScriptEscape="true"/>',
		grantToAllHint		: '<spring:message code="permission.grant_revoke.all.hint" 	 text="The check box is checked when all possible check box is checked in the selected permission" javaScriptEscape="true"/>',
		projAdminRoleId     : ${projAdminRoleId}
	});

<c:if test="${canModifyPermission}">

	$('#documentPermissionsForm > div.actionBar').ajaxSubmitButton({
	    submitText 	: '<spring:message code="button.save" text="Save" javaScriptEscape="true"/>',
	    submitUrl	: '${artifactPermissionsUrl}',
	    submitData	: function() {
	    					return {
	    				   		artifacts   : [<c:forEach items="${artifacts}" var="artifact" varStatus="loop">${artifact.id}<c:if test="${!loop.last}">, </c:if></c:forEach>],
	    				   		permissions : $('#documentPermissionsForm > div.accessPerms').getPermissions(),
	    				   		recursive   : $('#setPermissionsRecursively').is(':checked')
	    				    };
	    			  }
    <c:if test="${!empty param.onSuccess}">
    	, onSuccess : function(result) { ${param.onSuccess}; }
    </c:if>
	});

</c:if>

</script>
