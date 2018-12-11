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

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title><spring:message code="login.title" text="Login" /></title>
<style>
html,body {
	width: 100%;
	height: 100%;
	background: #f5f5f5;
	font-family: arial;
	font: 13px/1.231 arial, helvetica, clean, sans-serif;
}

.login-box {
	margin-top: 10px;
	line-height: 20px;
	width: 220px;
}

.login-box p {
	padding: 0;
	margin: 0;
}

.login-text {
	padding: 18px 10px 20px 10px;
	font-size: 15px;
	background: url("images/newskin/login_page/header.png") no-repeat left
		top;
}

.login-box input {
	margin: 0px 0 10px 10px;
	padding: 1px 0;
	border-color: #aaa;
	width: 174px;
	padding: 1px 0;
}

.login-button {
	background: url("images/newskin/login_page/button_jf.png") no-repeat;
	text-align: center;
	font-weight: bold;
	display: block;
	height: 40px;
	width: 174px;
	margin: 10px 0 10px 10px !important;
	border-style: none;
	height: 40px;
	width: 174px;
	margin: 2px;
	padding: 1px 0;
	border: 1px solid;
	border-color: #aaaaaa;
}

.box-header {
	color: #fff;
	display: block;
	padding: 10px;
	font-weight: bold;
	background: #5f5f5f;
}

.error {
	background-color: #ffe8e9;
	color: #b31317;
}
</style>

</head>

<c:url var="loginUrl" value="/officelogin.spr" />

<body>
	<form:form action="${loginUrl}" id="loginForm" method="post">
		<div class="login-box">
			<div class="box-header">
				<spring:message code="login.title" text="Login" />
			</div>
			<div class="login-text">
				<c:if test="${not empty errorMessage}">
					<span class="error"><spring:message code="${ui:sanitizeHtml(errorMessage)}"/></span>
				</c:if>

				<p>
					<spring:message code="login.username" text="Account" />
					:
				</p>
				<p>
					<form:input path="user" tabindex="0" />
				</p>
				<p>
					<spring:message code="login.password" text="Password" />
					:
				</p>
				<p>
					<form:password path="password" autocomplete="off" />
				</p>

				<spring:message var="loginButton" code="Login" text="Login" />
				<input class="login-button" type="submit" value="${loginButton}" />
			</div>
		</div>
	</form:form>
</body>
</html>