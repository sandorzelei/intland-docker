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
<%@page import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="main"/>
<meta name="module" content="login"/>
<meta name="bodyCSSClass" content="newskin"/>

<%
	//send access-denied error for ajax requests so the error handling will be activated there
	// TODO: this should probably always send 403, but that is not
	if (ControllerUtils.isAjaxRequest(request)) {
		response.sendError(403);
	}
%>

<div class="contentWithMargins">
	<h2><spring:message code="error.accessDenied.title" text="Access Denied"/></h2>
	<div><spring:message code="error.accessDenied.message" text="You have tried to access a page that is not available to you."/></div>
	<div style="margin-top:1em">
		<c:url var="startPage" value="/" />
		<spring:message var="homeButton" code="button.home" text="My Start"/>
		<spring:message var="backButton" code="button.back" text="Go Back"/>
		<input type="button" class="button" value="${backButton}" onclick="history.back();return false" />
		<input type="button" style="margin-left:1em;" class="button" value="${homeButton}" onclick="document.location.href='${startPage}'; return false" />
	</div>
</div>

