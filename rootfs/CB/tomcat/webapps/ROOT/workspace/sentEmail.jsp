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
<meta name="decorator" content="main"/>
<meta name="module" content="login"/>
<meta name="moduleCSSClass" content="workspaceModule loginModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:set var="targetURL" value="${param.targetURL}" />
<c:if test="${empty targetURL}">
	<acl:isUserInRole var="isAdmin" value="system_admin" />

	<c:choose>
		<c:when test="${isAdmin}">
			<c:url var="targetURL" value="/sysadmin.do" />
		</c:when>
		<c:otherwise>
			<c:url var="targetURL" value="/" />
		</c:otherwise>
	</c:choose>
</c:if>

<c:choose>
	<c:when test="${empty param.text}">
		<spring:message code="email.sent.success" text="Email was sent successfully"/>.
	</c:when>

	<c:otherwise>
		<c:out value="${param.text}" escapeXml="false" />
	</c:otherwise>
</c:choose>

<P>

<spring:message var="continueButton" code="button.continue" text="Continue"/>
<html:button onclick="document.location.href='${targetURL}'"
	styleClass="button" property="CONTINUE" value="${continueButton}" />
