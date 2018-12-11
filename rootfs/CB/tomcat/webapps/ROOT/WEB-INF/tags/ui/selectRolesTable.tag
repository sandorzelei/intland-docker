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
 * $Id$
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="callTag" prefix="ct" %>

<%--
	Tag renders a list of roles in a displaytag table. The roles can be selected.
	Use ReferenceHandlerSupport for parsing the selected roles.
--%>
<%@ attribute name="roles" required="true" rtexprvalue="true" type="java.util.Collection"
	description="The collection contains the selectable roles (RoleDtos)" %>
<%@ attribute name="fieldName" required="true"
	description="The field name where the selected roles' references are store" %>
<%@ attribute name="selectedRoleRefs" required="true" rtexprvalue="true" type="java.util.Collection"
	description="The reference-ids of the selected roles" %>
<%@ attribute name="disabled" type="java.lang.Boolean"
	description="If selecting roles are enabled" %>
<%@ attribute name="scope" required="true" type="java.lang.Object"
	description="The group scope for listing the users of roles. For example a ProjectDto or ScmRepositoryDto" %>

<spring:message var="toggleButton" code="search.what.toggle"/>

<c:if test="${! disabled}">
	<c:set var="checkAllRoles">
		<INPUT TYPE="CHECKBOX" TITLE="${toggleButton}"
				NAME="SELECT_ALL" VALUE="on"	ONCLICK="setAllStatesFrom(this, '${fieldName}')">
	</c:set>
</c:if>

<display:table name="${roles}" id="role" cellpadding="0" defaultsort="1">
	<display:column title="${checkAllRoles}" media="html" class="checkbox-column-minwidth" headerClass="checkbox-column-minwidth">
		<c:set var="ref" value="13-${role.id}" />
		<ct:call object="${selectedRoleRefs}" method="contains" param1="${ref}" return="roleSelected"/>
		<input type="checkbox" name="${fieldName}" value="${ref}"
			${roleSelected ? "checked='checked'" : "" }
			${disabled ? "disabled='disabled'" : "" }
		/>
	</display:column>

	<spring:message var="roleTitle" code="role.label" text="Role"/>
	<display:column title="${roleTitle}" headerClass="textData" class="textDataWrap columnSeparator">
		<spring:message code="role.${role.name}.label" text="${role.name}"/>
	</display:column>

	<spring:message var="membersTitle" code="members.label" text="Members"/>
	<display:column title="${membersTitle}" headerClass="textData" class="textDataWrap columnSeparator">
		<ui:listMembersOfRole scope="${scope}" role="${role}"/>
	</display:column>

	<spring:message var="descTitle" code="role.description.label" text="Description"/>
	<display:column title="${descTitle}" headerClass="textData" class="textDataWrap">
		<spring:message code="role.${role.name}.tooltip" text="${role.description}"/>
	</display:column>
</display:table>

