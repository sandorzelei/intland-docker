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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>


<div class="actionBar">
	<ui:actionLink builder="membersPageActionsMenuBuilder" subject="${project}" keys="newRole"/>
</div>

<ui:showErrors />

<display:table class="expandTable" requestURI="" name="${roles}" id="role" cellpadding="0" sort="external" decorator="roleTableDecorator">

	<spring:message var="roleName" code="role.label" text="Role"/>
	<display:column title="${roleName}" headerClass="textData" class="textData">
		<spring:message code="role.${role.name}.label" text="${role.name}" htmlEscape="true"/>
	</display:column>

	<display:column title="" media="html" class="action-column-minwidth columnSeparator" >
		<ui:actionGenerator builder="membersPageRoleContextActionListMenuBuilder" actionListName="actions" subject="${role}">
			<ui:actionMenu actions="${actions}"/>
		</ui:actionGenerator>
	</display:column>

	<spring:message var="roleMembersTitle" code="role.members.label" text="Members" />
	<display:column title="${roleMembersTitle}" headerClass="numberData" class="numberData columnSeparator" style="width:5%;">
		<c:url var="roleMembersUrl" value="/proj/members.spr">
			<c:param name="proj_id" value="${project.id}"/>
			<c:param name="role_id" value="${role.id}"/>
		</c:url>
		<a href="${roleMembersUrl}"><c:out value="${roleMembers[role.id]}"/></a>
	</display:column>

	<spring:message var="roleDescription" code="role.description.label" text="Description" />
	<display:column title="${roleDescription}" headerClass="textData" class="textDataWrap columnSeparator">
		<c:choose>
			<c:when test="${role.shortDescription != null}">
				<c:out value="${role.shortDescription}" />
			</c:when>
			<c:when test="${role.type.description != null}">
				<c:out value="${role.type.description}" />
			</c:when>
			<c:otherwise>
				<spring:message code="role.${role.name}.tooltip" text="" htmlEscape="true"/>
			</c:otherwise>
		</c:choose>
	</display:column>

<%--
		<c:if test="${canViewGroups && licenseCode.enabled.userGroups}">
			<spring:message var="roleGrants" code="role.groups.label" text="Granted to groups" />
			<display:column title="${roleGrants}" headerClass="textData" class="textDataWrap columnSeparator" style="width:25%;">
				<c:if test="${!empty roleGroups[role.id]}">
					<c:forEach items="${roleGroups[role.id]}" var="groupId" varStatus="loop">
						<c:set var="group" value="${groupMap[groupId]}"/>
						<c:url var="groupUrl" value="/sysadmin/users.spr">
							<c:param name="groupId" value="${groupId}"/>
						</c:url>

						<spring:message var="groupDesc" code="group.${group.name}.tooltip" text="${group.shortDescription}" htmlEscape="true"/>
						<a href="${groupUrl}" title="${groupDesc}">
							<spring:message code="group.${group.name}.label" text="${group.name}"/> (<c:out value="${groupMembers[groupId]}"/>)
						</a>
						<c:if test="${!loop.last}">,&nbsp;</c:if>
					</c:forEach>
				</c:if>
			</display:column>
		</c:if>
--%>
</display:table>
