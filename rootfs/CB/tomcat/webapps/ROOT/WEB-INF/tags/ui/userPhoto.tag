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
<%@tag import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@tag import="com.intland.codebeamer.manager.UserPhotoManager"%>
<%@tag import="com.intland.codebeamer.manager.UserPhotoManager"%>
<%@tag import="com.intland.codebeamer.persistence.dao.UserDao"%>
<%@tag import="com.intland.codebeamer.persistence.dto.UserDto"%>
<%@tag import="com.intland.codebeamer.manager.util.BadgeColors"%>

<%@tag import="com.intland.codebeamer.utils.Common"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ attribute name="userId"  required="true" description="ID of the user or -1 if it is unknown." %>
<%@ attribute name="userName" required="false" description="Name to display as title of the photo." %>
<%@ attribute name="large" required="false" description="Whether to show the large version of the photo. Defaults to false (show the small version)." %>
<%@ attribute name="url" required="false" description="Relative URL of the link. Defaults to the user profile page." %>
<%@ attribute name="placeholderGeneration" required="false" description="Whether to create a placeholder content, if the user hasn't uploaded any photo yet." %>

<c:if test="${empty placeholderGeneration}">
	<c:set var="placeholderGeneration" value="${false}" />
</c:if>

<%
	UserPhotoManager userPhotoManager = ControllerUtils.getSpringBean(request, null, UserPhotoManager.class);

	String userPhotoUrl = userPhotoManager.getUserPhotoUrl(userId, Boolean.valueOf(large).booleanValue());
	jspContext.setAttribute("userPhotoUrl", userPhotoUrl);

	Integer userIdConverted = Common.tryToCreateInteger(userId);
	if (userIdConverted != null) {
		jspContext.setAttribute("hasUserPhoto", Boolean.valueOf(userPhotoManager.hasPhoto(request, userIdConverted)));
	} else {
		jspContext.setAttribute("hasUserPhoto", Boolean.FALSE);
	}
%>

<c:if test="${empty url}">
	<c:set var="url" value="/userdata/${userId}" />
</c:if>

<c:choose>
	<c:when test="${placeholderGeneration && !hasUserPhoto}">
		<%
			final UserDao userDao = ControllerUtils.getSpringBean(request, null, UserDao.class);
			final UserDto targetUser = userDao.findById(userIdConverted);

			if (targetUser != null) {
				jspContext.setAttribute("userInitials", targetUser.getInitials());
				final BadgeColors badgeColors = userPhotoManager.getUniqueHexColor(userIdConverted);
				jspContext.setAttribute("userBackgroundColor", badgeColors.getBackground());
				jspContext.setAttribute("userForegroundColor", badgeColors.getForeground());
			}
		%>

		<c:if test="${userId != -1}">
			<a href="<c:url value="${url}"/>">
		</c:if>

			<div class="user-photo-placeholder" style="background-color: ${userBackgroundColor}">
				<span style="color: ${userForegroundColor}">${userInitials}</span>
			</div>

		<c:if test="${userId != -1}">
			</a>
		</c:if>

	</c:when>
	<c:otherwise>
		<c:if test="${empty url}">
			<c:set var="url" value="/userdata/${userId}" />
		</c:if>

		<c:set var="cssClass" value="${large ? 'largePhoto' : 'smallPhoto'}"/>
		<c:if test="${userId < 0}">
			<c:set var="cssClass" value="${cssClass} emptyPhoto" />
		</c:if>

		<c:if test="${userId != -1}">
			<a href="<c:url value="${url}"/>">
		</c:if>
		<img class="${cssClass} photoBox" src="<c:url value="${userPhotoUrl}"/>" title="<c:out value="${userName}"/>"/>
		<jsp:doBody />
		<c:if test="${userId != -1}">
			</a>
		</c:if>
	</c:otherwise>
</c:choose>
