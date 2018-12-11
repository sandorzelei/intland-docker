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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import="com.intland.codebeamer.servlet.CBPaths" %>

<jsp:include page="header.jsp?step=login&stepIndex=1"></jsp:include>

<div class="container">

	<div class="info">
		<spring:message code="remote.issue.report.welcome.message" text="To create a new issue at {0} you must sign in with your account" arguments="<%= CBPaths.CB_API_URL %>"/>
	</div>

	<jsp:include page="/admin/loginBox.jsp">
		<jsp:param name="loginUrl" value="/remote/issue/login.spr"/>
		<jsp:param name="registerUrl" value="/remote/issue/register.spr"/>
	</jsp:include>

	<jsp:include page="footer.jsp?step=login"></jsp:include>
</div>
