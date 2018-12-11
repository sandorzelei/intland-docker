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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import="java.util.Map"%>
<%@ page import="java.util.Collections"%>

<c:url var="itemStaffURL" value="/proj/tracker/itemStaff.spr">
	<c:param name="task_id" value="${task.id}" />
</c:url>

<spring:message var="unsetButton" code="tracker.field.value.unset.label" text="Unset"/>

<form action="${itemStaffURL}" method="POST">
	<div class="actionBar">
		<c:if test="${canEditStaff}">
			<spring:message var="saveButton" code="button.save"/>
			&nbsp;&nbsp;<input type="submit" class="button" value="${saveButton}" />&nbsp;&nbsp;
		</c:if>
		<span style="margin-bottom:10px;">
			<spring:message code="issue.staff.tooltip"/>
		</span>
	</div>

	<table border="0" cellpadding="2" style="width: 100%; border-collapse: separate;border-spacing: 2px;">
		<c:forEach items="${itemStaff}" var="roleMembers">
			<tr>
				<td class="optional" align="right" width="10%" nowrap>
					<spring:message code="role.${roleMembers.key.name}.label" text="${roleMembers.key.name}" htmlEscape="true"/>
				</td>
				<td align="left" nowrap>
					<jsp:useBean id="roleMembers" type="java.util.Map.Entry"/>
					<bugs:userSelector fieldName="fieldReferenceData[role-${roleMembers.key.id}]" ids="${roleMembers.value}"
						disabled="${!canEditStaff}" singleSelect="false" allowRoleSelection="false"
						onlyCurrentProject="true" requiredRoles="<%=Collections.singletonList(roleMembers.getKey())%>"
						setToDefaultLabel="${unsetButton}" defaultValue=""
					/>
				</td>
			</tr>
		</c:forEach>
	</table>
</form>