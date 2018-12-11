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
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import="com.intland.codebeamer.license.LicenseCode"%>
<%@ page import="com.intland.codebeamer.controller.support.GlobalMessages"%>
<%@ page import="java.util.Locale"%>
<%@ page import="com.intland.codebeamer.manager.UserManager"%>
<%@ page import="com.intland.codebeamer.utils.MemoryUtils"%>
<%@ page import="com.intland.codebeamer.ui.view.TopMenuRenderer"%>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ page import="com.intland.codebeamer.ui.view.actionmenubuilder.LanguageChoiceMenuBuilder"%>

<c:set var="mainMenuStyleClass"><decorator:getProperty property="meta.mainMenuStyleClass"/></c:set>

<fmt:bundle basename="com.intland.codebeamer.utils.Bundle">
	<fmt:message key="slogan.text" var="sloganText" />
	<fmt:message key="slogan.format" var="sloganFormat" />
	<fmt:message key="logo.link.target.url" var="logoLinkTargetUrl" />
	<fmt:message key="logo.selected" var="logoSelectedType" />
	<fmt:message key="logo.url" var="defaultLogoUrl" />
	<fmt:message key="custom.logo.url" var="customLogoUrl" />
</fmt:bundle>

<c:set var="logoUrl" value="${logoSelectedType eq 'default' ? defaultLogoUrl : customLogoUrl}" />

<spring:eval expression="logoLinkTargetUrl.startsWith('???') || T(org.apache.commons.lang.StringUtils).isBlank(logoLinkTargetUrl)" var="isLogoLinkTargetUrlBlank" />
<c:if test="${isLogoLinkTargetUrlBlank}">
	<c:set var="logoLinkTargetUrl" value="http://www.intland.com" />
</c:if>

<div style="width: 100%;" class="headerTopContainer noPrint">
	<a href="<c:url value="${logoLinkTargetUrl}"/>" style="text-decoration: none;" class="logoLink">
		<img class="logo" src="<ui:urlversioned value="${logoUrl}"/>"
			border="0" alt="${fn:escapeXml(logoLinkTargetUrl)}" title="Visit ${fn:escapeXml(logoLinkTargetUrl)}" />
	</a>

	<div class="headerCenter">
		<span id="slogan"><tag:transformText value="${sloganText}" format="${sloganFormat}" /></span>
		<c:if test="${(licenseCode.hostId eq 'EVAL') || (licenseCode.enabled.evaluation)}">
			<div class="warningtext" style="font-weight: normal;"><spring:message code="cb.evaluation.warning" /></div>
		</c:if>
	</div>

	<div id="toprightmenuContainer" class="mainmenu">
		<div class="toprightmenu">
			<tag:searchBoxAndUserMenu isHeader="true" />
		</div>
	</div>
</div>
<div style="clear:both;"></div>
