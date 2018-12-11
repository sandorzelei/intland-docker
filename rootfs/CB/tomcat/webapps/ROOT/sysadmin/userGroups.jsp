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
<meta name="moduleCSSClass" content="sysadminModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib"   prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>


<ui:actionMenuBar verticalMiddleAlign="true">
	<span class="titlenormal">
		<ui:pageTitle><spring:message code="useradmin.groups.label" text="User Groups" /></ui:pageTitle>
	</span>
</ui:actionMenuBar>

<c:if test="${canCreateGroup}">
	<div class="actionBar">
		<c:url var="newGroupURL" value="/sysadmin/editGroup.spr" />
		<a class="actionLink" href="${newGroupURL}"><spring:message code="useradmin.newGroup.label" text="New Group" /></a>
		<c:url var="cancelUrl" value="/sysadmin.do"/>
		<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
		<input type="button" class="cancelButton" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>
	</div>
</c:if>

<ui:showErrors/>

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<display:table class="expandTable" requestURI="" name="${groups}" id="group" cellpadding="0" sort="external">

	<spring:message var="groupName" code="group.name.label" text="Group" />
	<display:column title="${groupName}" headerClass="textData" class="textData">
		<spring:message code="group.${group.name}.label" text="${group.name}"/>
	</display:column>

	<display:column title="" media="html" class="action-column-minwidth columnSeparator" >
		<ui:actionGenerator builder="userAccountsPageRolesContextMenuBuilder" actionListName="actions" subject="${group}">
			<ui:actionMenu actions="${actions}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
		</ui:actionGenerator>
	</display:column>

	<spring:message var="groupMembersLabel" code="group.members.label" text="Members" />
	<display:column title="${groupMembersLabel}" headerClass="numberData" class="numberData columnSeparator" style="width:5%;">
		<c:url var="groupMembersUrl" value="/sysadmin/users.spr">
			<c:param name="groupId" value="${group.id}"/>
		</c:url>

		<a href="${groupMembersUrl}">
			<c:out value="${groupMembers[group.id]}"/>
		</a>
	</display:column>

	<spring:message var="ldapGroupLabel" code="group.ldap.label" text="LDAP/AD Group Name" />
	<display:column title="${ldapGroupLabel}" headerClass="textData" class="textData columnSeparator">
		<c:set var="ldapGroup" value=""/>
		<c:if test="${group.attributes.attributes.containsKey('ldapGroup')}">
			<c:set var="ldapGroup" value="${group.attributes.attributes['ldapGroup']}"/>
		</c:if>
		<c:out value="${empty ldapGroup ? '--' : ldapGroup}" />
	</display:column>

	<spring:message var="groupDescription" code="group.details.label" text="Description" />
	<display:column title="${groupDescription}" headerClass="textData" class="textDataWrap columnSeparator">
		<c:choose>
			<c:when test="${group.name eq 'sysadmin' or empty group.shortDescription}">
				<spring:message code="group.${group.name}.tooltip" text="" />
			</c:when>
			<c:otherwise>
				<c:out value="${group.shortDescription}" />
			</c:otherwise>
		</c:choose>
	</display:column>

</display:table>
