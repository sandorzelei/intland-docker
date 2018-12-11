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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<head>
	<style type="text/css">
	<!--
		.matrixCell {
			vertical-align: middle;
			text-align: center;
			white-space: nowrap;
		}
	-->
	#tracker-customize-permissions {
		margin: 0px !important;
	}
	#tracker-customize-permissions .actionBar {
		margin: 0px !important;
	}
	#tracker-customize-permissions .actionBar input {
		margin-right: 5px;
	}
	#tracker-customize-permissions .tableContainer {
		margin: 8px 15px 8px 280px !important;
		overflow-x: auto;
	}
    #tracker-customize-permissions .tableContainer td.permission {
		position: absolute;
		left: 1em;
		top: auto;
    }

	#tracker-customize-permissions .tableContainer tr.head th:first-child {
		border: 0;
		left: 1em;
		position: absolute;
		top: 60px;
	}


	#tracker-customize-permissions  .rightAlignedDescription {
		padding-top: 3px;
	}
	.displaytag {
		margin: 0px !important;
	}
	.displaytag td {
		padding-top: 5px !important;
		padding-bottom: 5px !important;
	}
	.displaytag th {
		padding-right: 0px !important;
		padding-left: 0px !important;
	}

	th.permOwner, td.matrixCell {
		width: 4%;
	}

    .grantRevokeAll {
        background-color: #F5F5F5;
    }
	</style>
</head>


<form id="tracker-customize-permissions" action="${configurationUrl}" method="post">
	<div class="actionBar">
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		&nbsp;&nbsp;<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}"/>

		<div class="rightAlignedDescription">
			<spring:message code="tracker.permissions.tooltip" text="{0} permissions per role." arguments="${TrackerTypeName}"/>
		</div>
	</div>

	<div class="tableContainer">
	</div>
	<div class="information">
		<b><spring:message code="permission.matrix.dependencies"/>:</b><br/>
		<ul>
			<li><spring:message code="permission.matrix.rule1"/></li>
			<li><spring:message code="permission.matrix.rule2"/></li>
			<li><spring:message code="permission.matrix.rule3"/></li>
			<li><spring:message code="permission.matrix.rule4"/></li>
			<li><spring:message code="permission.matrix.rule5"/></li>
			<li><spring:message code="permission.matrix.rule6"/></li>
			<li><spring:message code="permission.matrix.rule7"/></li>
			<li><spring:message code="permission.matrix.rule8"/></li>
			<li><spring:message code="permission.matrix.rule9"/></li>
			<li><spring:message code="permission.matrix.rule10"/></li>
		</ul>
	</div>
</form>

<%-- true if the user has admin rights to the tracker even when the tracker is a branch --%>
<c:set var="canAdminTrackerOrBranch" value="${canAdminTracker || branchDisabledAdminRights}"/>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/permissionMatrix.js'/>"></script>
<script type="text/javascript">

	$('#tracker-customize-permissions > div.tableContainer').permissionMatrix( ${trackerAccessJSON}, {
		editable			: ${canAdminTrackerOrBranch},
		permissions			: [<c:forEach items="${trackerPermissionDep}" var="perm" varStatus="loop">{ id: ${perm.id}, name: "${perm.name}", title: "${perm.description}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
		fields				: [{ id: ${trackerOwnerField.id}, name: "${trackerOwnerField.name}", title: '' }],
		roles				: ${projectRoles},
		permissionLabel		: '<spring:message code="permission.label" 		 				 text="Permission"   javaScriptEscape="true"/>',
		fieldsLabel			: '<spring:message code="tracker.fieldAccess.memberFields.label" text="Participants" javaScriptEscape="true"/>',
		rolesLabel			: '<spring:message code="tracker.fieldAccess.roles.label" 		 text="Roles"		 javaScriptEscape="true"/>',
		grantAllText		: '<spring:message code="role.permissions.all.label"  text="All permissions" javaScriptEscape="true"/>',
		revokeAllText		: '<spring:message code="role.permissions.none.label" text="No permissions"  javaScriptEscape="true"/>',
		grantToAllText		: '<spring:message code="permission.grant.to.all" 	 text="Grant this permission to all" javaScriptEscape="true"/>',
		grantToAllHint		: '<spring:message code="permission.grant_revoke.all.hint" 	 text="The check box is checked when all possible check box is checked in the selected permission" javaScriptEscape="true"/>',
		revokeFromAllText	: '<spring:message code="permission.revoke.from.all" text="Revoke this permission from all" javaScriptEscape="true"/>',
		adminPermissions 	: ${adminPermissions},
		adminPermissionHint : '<spring:message code="permission.admin.default" text="Default Project Admin Permissions" javaScriptEscape="true"/>',
        grantRevokeAllLabel : '<spring:message code="permission.grant_revoke.all" text="Grant/revoke to/from all" javaScriptEscape="true"/>',
        projAdminRoleId     : ${projAdminRoleId}
	});

<c:if test="${canAdminTrackerOrBranch}">
	<c:choose>
		<c:when test="${isRepository}">
			$('#tracker-customize-permissions > div.tableContainer').repositoryPermissionDependencies();
		</c:when>
		<c:otherwise>
			$('#tracker-customize-permissions > div.tableContainer').trackerPermissionDependencies();
		</c:otherwise>
	</c:choose>

	$('#tracker-customize-permissions > div.actionBar').ajaxSubmitButton({
	    submitText	: '<spring:message code="button.save" text="Save" javaScriptEscape="true"/>',
	    submitUrl	: '${trackerPermissionsUrl}',
	    submitData	: function() {
	    					return $('#tracker-customize-permissions > div.tableContainer').getPermissions();
	    			  },
	    onSuccess: function() {
	    	showOverlayMessage(i18n.message("ajax.changes.successfully.saved"));
	    	location.reload();
	    }
	});

</c:if>
</script>

