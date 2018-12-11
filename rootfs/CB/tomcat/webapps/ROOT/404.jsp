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

<title><spring:message code="not.found.title" text="404 Page Not Found"/></title>

<div class="contentWithMargins not-found-content">
	<div class="not-found-big-text">404</div>
	<div class="not-found-header"><spring:message code="not.found.header" text="Page Not Found"/></div>
	<div class="not-found-explanation"><spring:message code="not.found.message" text="The page you are looking for was moved, removed, renamed or might never existed."/></div>
	<div class="not-found-buttons">
		<c:url var="startPage" value="/" />
		<spring:message var="homeButton" code="button.home" text="My Start"/>
		<spring:message var="backButton" code="button.back" text="Go Back"/>
		<input type="button" class="button" value="${backButton}" onclick="history.back();return false" />
		<input type="button" style="margin-left:1em;" class="button" value="${homeButton}" onclick="document.location.href='${startPage}'; return false" />
	</div>
</div>

