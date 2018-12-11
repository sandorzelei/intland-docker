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
<%@page import="com.intland.codebeamer.controller.admin.errorhandling.ErrorHandlerFilter"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="newskin workspaceModule"/>

<%-- see errorHandler.jsp to see what is information is available here --%>
<c:set var="errorHandlerContext" value="<%=ErrorHandlerFilter.getLastError(session)%>" />

<div class="innerContentArea">
	<div class="error">
	<h3>Your request is still in progress, please wait until it completes...</h3>

	<a href="${errorHandlerContext.requestURL}?${errorHandlerContext.queryString}">Retry...</a>

	</div>
</div>
