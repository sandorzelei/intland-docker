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
<meta name="decorator" content="popup"/>
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="sysadminModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<style type="text/css">
	.userSelector {
		margin: 5px;
		width: 99%;
	}
	.userSelector .label {
		width: 5%;
		padding-right: 0.5em;
	}
</style>

<c:url var="actionUrl" value="/sysadmin/assignMembersToGroup.spr"/>
<spring:message var="groupName" code="group.${group.name}.label" text="${group.name}"/>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="useradmin.assign.members.info" text="Assign members to the <b>{0}</b> User Group" arguments="${groupName}"/></ui:pageTitle>
</ui:actionMenuBar>

<form action="${actionUrl}" method="post" id="addForm">

<input type="hidden" name="referrer" value="${referrer}" />
<input type="hidden" name="groupId" value="${group.id}" />

<ui:actionBar cssStyle="padding-left: 10px;">
	<div class="okcancel" style="margin-top: 0px;">

		<spring:message var="assignButton" code="project.role.assign.label" text="Assign Members"/>
		<input type="submit" class="button" name="ADD" value="${assignButton}" style="margin-right: 5px;"/>

		<spring:message var="cancelButton" code="button.cancel"/>
		<a onclick="closePopupInline(); return false;">${cancelButton}</a>

	</div>
</ui:actionBar>

<div class="contentWithMargins">

	<div class="information">
		<spring:message code="project.newMember.info.members.step1"/>
	</div>

	<table class="userSelector">
		<tr>
			<td class="label"><spring:message code="tracker.field.valueType.member.label" text="Members" />:</td>
			<td class="selector">
				<bugs:userSelector htmlId="userSelector" singleSelect="false" allowRoleSelection="false"
								   defaultValue="" ids="" fieldName="members"
								   searchOnAllUsers="true" showPopupButton="false" ignoreCurrentProject="true"/>
			</td>
		</tr>
	</table>

</div>
</form>
