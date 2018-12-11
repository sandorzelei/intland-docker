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
<%@ page import="com.intland.codebeamer.controller.ControllerUtils"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<script type="text/javascript">
jQuery(function($) {
	$("#user").focus();
	clearCookiesAndLocaleStorage();
});
</script>

<c:set var="logTitle" value="Login" />
<c:if test="${pageContext.request.secure}">
	<c:set var="logTitle" value="SSL-Login" />
</c:if>

<c:url var="loginUrl" value="/login.spr"/>
<c:if test="${not empty param.loginUrl}">
	<c:url var="loginUrl" value="${param.loginUrl}"/>
</c:if>

<form:form action="${loginUrl}" id="loginForm">

	<div class="login-box">
		<div class="box_header_grey"><spring:message code="login.title" text="Login"/></div>
		<div class="login_text">

			<ui:showSpringErrors errors="${bindingResult}"/>

			<p class="fieldLabel"><spring:message code="login.username" text="Account"/>:</p><p><form:input path="user" tabindex="0" /></p>
				<p class="fieldLabel"><spring:message code="login.password" text="Password"/>:</p><p><form:password path="password" autocomplete="off" />
				<c:if test="${sendLostPasswordPerMailAllowed}">
					<a href="<c:url value="/lostPassword.do" />" target="_blank"><small><spring:message code="login.forgotPassword" text="Forgot it?"/></small></a>
				</c:if>
			</p>

			<c:if test="${isCookiesAllowed}">
				<p>
					<form:checkbox path="remember" id="remember"/>
					<label for="remember"><small><spring:message code="login.remember" text="Remember me"/></small></label>
				</p>
			</c:if>

			<spring:message var="loginButton" code="Login" text="Login"/>
			<input class="login_button" title="${logTitle}" type="submit" value="${loginButton}">

			<c:if test="${!empty sslLoginURL}">
				<a href="${sslLoginURL}" class="sslLogin"><spring:message code="login.secure" text="Login via SSL"/></a>
			</c:if>

			<c:if test="${!pageContext.request.secure and sslPort != -1}">
				<c:set var="sslLink" value="https://${pageContext.request.serverName}:${sslPort}" />
				<c:url var="sslLoginURL" value="${sslLink}${pageContext.request.contextPath}/login.spr"/>
				or <a href="${sslLoginURL}"><spring:message code="login.secure" text="Login via SSL"/></a>
			</c:if>

			<span class="urls">
				<c:if test="${canRegister}">
					<c:choose>
						<c:when test="${userAgent.robot}">
							Your browser's <i>User-Agent</i><small><c:out value="${userAgent.name}" /></small>
						</c:when>
						<c:otherwise>
							<c:url var="registerUrl" value="/createUser.spr" />
							<c:if test="${not empty param.registerUrl}">
								<c:url var="registerUrl" value="${param.registerUrl}" />
							</c:if>
							<spring:message code="login.registration" text="Not a Member yet? Register" arguments="${registerUrl}"/>
						</c:otherwise>
					</c:choose>
				</c:if>
			</span>
		</div>
	</div>

</form:form>
