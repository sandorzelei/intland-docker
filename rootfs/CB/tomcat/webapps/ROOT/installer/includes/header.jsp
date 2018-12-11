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
<%@ page import="com.intland.codebeamer.Config" %>
<%@ page import="com.intland.codebeamer.BuildInformation" %>
<%@ page import="java.util.Properties" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@page import="com.intland.codebeamer.controller.support.UserAgent"%>

<meta name="decorator" content="installer"/>

<%
	String version = " ";

	Properties build = BuildInformation.getProperties();
	if (build != null){
		version = build.getProperty("version.main") + build.getProperty("version.minor");
	}
	pageContext.setAttribute("fullVersion", version);

	UserAgent userAgent = UserAgent.get(request);
	request.setAttribute("userAgentClass", userAgent.getUserAgentCSS());

%>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/installer/installer.css" />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/js/json2.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/installer/installer.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/installer/jquery-serialize.js'/>"></script>

<c:set var="step" value="${param.step}"/>
<c:set var="stepIndex" value="${param.stepIndex}"/>

<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
	<spring:message code="post.installer.step.${step}.title" htmlEscape="true"/>
</ui:pageTitle>

<div class="actionMenuBar"><div class="header-icon"></div><span><spring:message code="post.installer.title" text="codeBeamer {0} Setup Wizard" arguments="${fullVersion}"/></span></div>
<div class="installation-steps">
	<span class="${step == 'welcome' ? 'current' : '' }"><spring:message code="post.installer.step.welcome.title" text="Welcome"/></span>
	<span class="${step == 'agreement' ? 'current' : '' }"><spring:message code="post.installer.step.agreement.title" text="License Agreement"/></span>
	<span class="${step == 'instance' ? 'current' : '' }">1. <spring:message code="post.installer.step.instance.title" text="Instance"/></span>
	<span class="${step == 'license' ? 'current' : '' }">2. <spring:message code="post.installer.step.license.title" text="License info"/></span>
	<span class="${step == 'database' ? 'current' : '' }">3. <spring:message code="post.installer.step.database.title" text="Database"/></span>
	<span class="${step == 'admin' ? 'current' : '' }">4. <spring:message code="post.installer.step.admin.title" text="Admin account"/></span>
	<span class="${step == 'repositories' ? 'current' : '' }">5. <spring:message code="post.installer.step.repositories.title" text="Repositories"/></span>
	<span class="${step == 'mail' ? 'current' : '' }">6. <spring:message code="post.installer.step.mail.title" text="Mail server"/></span>
	<span class="${step == 'done' ? 'current' : '' }"><spring:message code="post.installer.step.done.title" text="Done!"/></span>
</div>

<div class="step-info">
	<div class="step-title">
		<c:choose>
			<c:when test="${step != 'done' && step != 'welcome' && step!= 'agreement' && step !='databaseError'}">
				<spring:message code="post.installer.step.title" text="Step ${stepIndex}" arguments="${stepIndex}"/>
			</c:when>
			<c:otherwise>
				&nbsp;
			</c:otherwise>
		</c:choose>
	</div>
	<div class="step-name">
		<c:choose>
			<c:when test="${step == 'welcome'}">
				<spring:message code="post.installer.welcome" text="Welcome to codeBeamer Setup Wizard!"/>
			</c:when>
			<c:otherwise>
				<spring:message code="post.installer.step.${step}.title" text=""/>
			</c:otherwise>
		</c:choose>
	</div>
	<div class="step-icon ${step}"></div>
</div>