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
<meta name="decorator" content="main"/>
<meta name="module" content="login"/>
<meta name="moduleCSSClass" content="newskin workspaceModule loginModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<ui:actionMenuBar>
	<spring:message code="login.title" text="Login"/>
</ui:actionMenuBar>
<ui:globalMessages/>

<c:set var="loginTextPrefix" value="${param.loginText}" />
<fmt:bundle basename="com.intland.codebeamer.utils.Bundle">
	<fmt:message var="loginText" key="login.text" />
	<fmt:message var="loginTextFormat" key="login.format" />
</fmt:bundle>

<tag:transformText var="transformedText" value="${loginTextPrefix}${loginText}" format="${loginTextFormat}" cleanup="false" />

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/login.less" />" type="text/css" media="all" />

<%-- the complete content can be replaced if the html text contains a "LOGIN_FORM_PLACEHOLDER" text.
	For backwards compatibility it works as before otherwise. --%>
<c:choose>
	<c:when test="${ssoFailed}" >
		<c:url var="retryLoginURL" value="login.spr"/>
		<spring:message var="retryLoginLabel" code="login.openIDConnect.retry.label"   text="Retry" />
		<spring:message var="retryLoginTitle" code="login.openIDConnect.retry.tooltip" text="Retry to sign-on via OAuth/OpenID Connect" />
		<p style="margin-left: 16px;">
			<a href="${retryLoginURL}" title="${retryLoginTitle}">
				<input type="button" class="button" value="${retryLoginLabel}">
			</a>
		</p>
		<div class="subtext" style="margin-top: 2em; margin-left: 16px;">
			<spring:message code="login.openIDConnect.retry.hint" text="If you did not deny the sign-on yourself and retrying did also not work: Please contact your system administrator." />
		</span>
	</c:when>
	<c:when test="${fn:contains(transformedText, 'LOGIN_FORM_PLACEHOLDER')}" >
		<c:set var="loginForm"><jsp:include flush="true" page="login.jsp" /></c:set>
		<c:set var="content" value="${fn:replace(transformedText , 'LOGIN_FORM_PLACEHOLDER', loginForm)}" />
		${content}
	</c:when>
	<c:otherwise>
		<div class="login-grid login-page ${isCustomLoginText ? 'custom' : 'default'}"><!--
		--><div class="left column">
			<jsp:include flush="true" page="login.jsp" />
		</div><c:choose><c:when test="${isCustomLoginText}"><div class="right column">${transformedText}</div></c:when><c:otherwise>${transformedText}</c:otherwise></c:choose><!--
	--></div>
	</c:otherwise>
</c:choose>