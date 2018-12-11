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
<meta name="decorator" content="popup"/>
<meta name="module" content="members"/>
<meta name="moduleCSSClass" content="membersModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:url var="memberHistoryUrl" value="/proj/admin/memberHistory.spr">
	<c:param name="proj_id"     value="${project.id}"/>
	<c:param name="member_type" value="${isGroup ? 5 : 1}"/>
	<c:param name="member_id"   value="${member.id}"/>
	<c:param name="role_id"     value=""/>
</c:url>

<script language="JavaScript" type="text/javascript">
function showHideHistory(checkbox) {
	var roleId = checkbox.value;
	var historySection = document.getElementById('memberHistory_' + roleId);
	if (checkbox.checked) {
		historySection.className = '';
		if ($('#memberHistory_' + roleId + ' > table').length == 0) {
			$('#memberHistory_' + roleId).load('${memberHistoryUrl}' + roleId);
		}
	} else {
		historySection.className = 'invisible';
	}
}
</script>

<ui:pageTitle printBody="false">
	<spring:message code="proj.member.roles.title" text="Assign Roles to Member {0}" arguments="${member.name}"/>
</ui:pageTitle>

<ui:actionMenuBar>
	<span class="titlenormal">
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<span class="page-title"><spring:message code="project.members.title" text="Members"/></span><span class='breadcrumbs-separator'>&raquo;</span>

		<c:choose>
			<c:when test="${isGroup}">
				<spring:message var="groupDesc" code="group.${member.name}.tooltip" text="${member.shortDescription}" htmlEscape="true"/>
				<span title="${groupDesc}"><spring:message code="group.${member.name}.label" text="${member.name}"/></span>
			</c:when>
			<c:otherwise>
				<tag:userLink user_id="${member.id}" />
			</c:otherwise>
		</c:choose>
		</ui:breadcrumbs>
	</span>
</ui:actionMenuBar>

<c:url var="actionUrl" value="/proj/setMemberRoles.spr"/>

<form action="${actionUrl}" method="post">

	<input type="hidden" name="referrer"    value="<c:out value='${referrer}'/>"/>
	<input type="hidden" name="proj_id"     value="${project.id}"/>
	<input type="hidden" name="member_type" value="${isGroup ? 5 : 1}"/>
	<input type="hidden" name="member_id"   value="<c:out value='${member.id}'/>"/>

	<div class="actionBar">
		<c:if test="${canEdit}">
			&nbsp;&nbsp;
			<spring:message var="saveButton" code="button.save"/>
			<input type="submit" class="button" name="SAVE" value="${saveButton}" />
		</c:if>

		&nbsp;&nbsp;
		<spring:message var="cancelButton" code="button.cancel"/>
		<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" onclick="closePopupInline(); return false;"/>
	</div>

	<c:if test="${canEdit}">
		<spring:message var="showHistoryTitle" code="document.history.show" text="Show change history"/>
		<c:set var="historyTitle">
			<input id="showMemberHistory" type="checkbox" title="${showHistoryTitle}" name="SELECT_ALL" value="on" onclick="setAllStatesFrom(this, 'showHistory')">
			<label for="showMemberHistory">
				<spring:message code="document.history.title" text="History"/>
			</label>
		</c:set>
	</c:if>

	<display:table requestURI="" name="${roles}" id="role" cellpadding="0" sort="external" style="width: 97%">
		<c:set var="attributes" value="${memberRoles[role.id]}"/>

		<display:column title="" headerClass="textData checkbox-column-minwidth" class="textData checkbox-column-minwidth">
			<c:remove var="lastModifiedInfo"/>
			<c:if test="${!empty attributes}">
				<c:set var="lastModifiedInfo">
					<spring:message code="document.lastModifiedBy.tooltip" text="Last modified by"/> <c:out value="${attributes.lastModifiedBy.name}"/>, <tag:formatDate value="${attributes.lastModifiedAt}"/> <c:out value="${attributes.comment}"/>
				</c:set>
			</c:if>

			<input type="checkbox" name="role_id" id="role_${role.id}" value="${role.id}" title="${lastModifiedInfo}"
				<c:if test="${memberRoles[role.id].status.id eq 3}">checked="checked"</c:if>
				<c:if test="${!canEdit or (role.name eq 'Project Admin' and !hasAdminRole)}">disabled="disabled"</c:if>
			/>
		</display:column>

		<spring:message var="roleName" code="role.label" text="Role"/>
		<display:column title="${roleName}" headerClass="textData${canEdit ? ' column-minwidth' : ''}" class="textData columnSeparator${canEdit ? ' column-minwidth' : ''}>">
			<spring:message var="roleDesc" code="role.${role.name}.tooltip" text="${role.description}" htmlEscape="true"/>
			<c:choose>
				<c:when test="${isAdmin}">
					<c:url var="editRoleUrl" value="/proj/admin/editRole.spr">
						<c:param name="proj_id" value="${project.id}"/>
						<c:param name="role_id" value="${role.id}"/>
					</c:url>
					<a href="${editRoleUrl}" title="${roleDesc}"><spring:message code="role.${role.name}.label" text="${role.name}"/></a>
				</c:when>
				<c:otherwise>
					<label title="${roleDesc}" for="role_${role.id}"><spring:message code="role.${role.name}.label" text="${role.name}"/></label>
				</c:otherwise>
			</c:choose>
			&nbsp;
		</display:column>

		<c:if test="${canEdit}">
			<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
				<c:if test="${!empty attributes}">
					<input type="checkbox" name="showHistory" value="${role.id}" title="${showHistoryTitle}" onchange="showHideHistory(this);" style="display: none;"/>
				</c:if>
			</display:column>

			<display:column title="${historyTitle}" headerClass="textData" class="textData" style="vertical-align: middle;">
				<div id="memberHistory_${role.id}">
					<%-- Dynamically loaded via Ajax --%>
				</div>
			</display:column>
		</c:if>

	</display:table>

	<c:if test="${canEdit}">
		<table border="0" cellspacing="0" cellpadding="0" width="100%" style="margin-bottom: 1em">
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>

			<tr>
				<td valign="top" class="optional">
					<spring:message code="document.comment.label" text="Comment"/>:
				</td>

				<td class="expandTextArea">
					<textarea name="comment" rows="1" style="width: 97%; resize: none" maxlength="255"><spring:escapeBody htmlEscape="true">${comment}</spring:escapeBody></textarea>
				</td>
			</tr>
		</table>
	</c:if>

</form>
