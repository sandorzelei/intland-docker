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

<%@tag import="java.util.Collections"%>
<%@tag import="java.util.List"%>
<%@tag import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@tag import="com.intland.codebeamer.persistence.dto.base.ProjectAwareDto"%>
<%@tag import="com.intland.codebeamer.persistence.dto.ProjectDto"%>
<%@tag import="com.intland.codebeamer.persistence.dto.UserDto"%>
<%@tag import="com.intland.codebeamer.persistence.dao.impl.UserDaoImpl"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	Tag renders a list of users as links, those users who are member of a certain role.
--%>
<%@ attribute name="role"  required="true" rtexprvalue="true" type="com.intland.codebeamer.persistence.dto.RoleDto"	description="The role to list users for" %>
<%@ attribute name="scope" required="true" type="java.lang.Object" description="The group scope for listing the users of roles. For example a ProjectDto or ScmRepositoryDto" %>

<%
	UserDto       user          = ControllerUtils.getCurrentUser(request);
	ProjectDto 	  project       = null;
	List<UserDto> usersWithRole = Collections.emptyList();
	int       	  truncated     = 0;

	if (scope instanceof ProjectDto) {
		project = (ProjectDto) scope;
	} else if (scope instanceof ProjectAwareDto) {
		project = ((ProjectAwareDto) scope).getProject();
	}

	if (project != null && role != null) {
		usersWithRole = UserDaoImpl.getInstance().findByProjectIdAndRoles(user, project.getId(), Collections.singletonList(role.getId()), false);
		if (usersWithRole != null && usersWithRole.size() > 10) {
			truncated = usersWithRole.size() - 10;
			usersWithRole = usersWithRole.subList(0, 10);
		}
	}

	jspContext.setAttribute("usersWithRole", usersWithRole);
	jspContext.setAttribute("usersTruncated", Integer.valueOf(truncated));
%>
<tag:joinLines newLinePrefix="">
<c:choose>
	<c:when test="${empty usersWithRole}">--</c:when>
	<c:otherwise>
		<c:forEach items="${usersWithRole}" var="user" varStatus="status">
			${status.first ? "" : ", "}<tag:userLink user_id="${user.id}" />
		</c:forEach>
		<c:if test="${usersTruncated gt 0}"><span class="subtext">, <spring:message code="project.members.more" text="{0} more members ..." arguments="${usersTruncated}"/></span></c:if>
	</c:otherwise>
</c:choose>
</tag:joinLines>
