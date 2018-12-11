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
<meta name="decorator" content="popup"/>
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="newskin sysadminModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!--
TODO: regisration: ${command}
created user: ${user}
password: ${user.password}
project: ${project}
-->
<style type="text/css">
	body {
		padding: 10px !important;
		color: #2B2B2B;
	}
	h2 * {
		font-size: 24px !important;
		font-weight: normal !important;
	}
	a {
		color:#0093B8;
		text-decoration: none;
	}
</style>
<c:choose>
<c:when test="${! empty userDisabled}">
	<h3>${userDisabled.message}</h3>
</c:when>
<c:otherwise>
	<c:if test="${userAlreadyExists}">
		<c:set var="loginURL" value="http://saas.codebeamer.com/login.spr?user=${command.email}" />
	<c:if test="${autoLoggedIn}">
		<c:set var="loginURL" value="http://saas.codebeamer.com/" />
	</c:if>

	<h3>Your account already exists <a href="${loginURL}" target="_top"/>click here to log in!</a></h3>
	</c:if>

	<c:if test="${! empty project}">
	<h3>
	<p>Congratulations!</p>
	<p>Your account has been successfully created.</p>
	<p>Click <a href="<c:url value='${project.urlLink}'/>" target="_top">${project.name}</a> to start your evaluation.</p>
	<p>Your login information has been also sent to your e-mail address.</p>
	</h3>
	</c:if>
</c:otherwise>
</c:choose>

