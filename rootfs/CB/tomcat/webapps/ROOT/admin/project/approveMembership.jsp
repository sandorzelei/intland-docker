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
<meta name="module" content="members"/>
<meta name="moduleCSSClass" content="membersModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<ui:pageTitle printBody="false">
	<spring:message code="project.member.${accept ? 'accept' : 'reject'}.tooltip" text="${accept ? 'Accept' : 'Reject'} this project membership application"/>
</ui:pageTitle>

<ui:actionMenuBar>
	<span class="titlenormal">
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<spring:message code="project.members.title" text="Members"/> :&nbsp;
		<spring:message code="project.member.${accept ? 'accept' : 'reject'}.label" text="${accept ? 'Accept' : 'Reject'}"/>
		<spring:message var="roleDesc" code="role.${role.name}.tooltip" text="${role.description}" htmlEscape="true"/>
		<span title="${roleDesc}"><spring:message code="role.${role.name}.label" text="${role.name}" /></span>

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

<c:url var="actionUrl" value="/proj/approveMembership.spr"/>

<form action="${actionUrl}" method="post">

	<input type="hidden" name="proj_id"     value="${project.id}"/>
	<input type="hidden" name="role_id"     value="${role.id}"/>
	<input type="hidden" name="member_type" value="${isGroup ? 5 : 1}"/>
	<input type="hidden" name="member_id"   value="${member.id}"/>
	<input type="hidden" name="accept"      value="<c:out value='${accept}'/>"/>
	<input type="hidden" name="referrer"    value="<c:out value='${referrer}'/>"/>

	<div class="actionBar">
		&nbsp;&nbsp;
		<spring:message var="submitButton" code="button.${accept ? 'accept' : 'reject'}"/>
		<input type="submit" class="button" name="SAVE" value="${submitButton}" />

		&nbsp;&nbsp;
		<spring:message var="cancelButton" code="button.cancel"/>
		<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" onclick="closePopupInline(); return false;"/>
	</div>

	<div class="contentWithMargins">

		<table border="0" cellspacing="0" cellpadding="0" width="100%">
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>

			<tr>
				<td valign="top" class="optional">
					<spring:message code="project.member.approval.comment.label" text="Notification Comment"/>:
				</td>

				<td class="expandTextArea">
					<textarea name="comment" rows="10" cols="80" maxlength="255"><spring:escapeBody htmlEscape="true">${comment}</spring:escapeBody></textarea>
				</td>
			</tr>
		</table>
	</div>
</form>


