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
<%@ page import="com.intland.codebeamer.controller.support.GlobalMessages"%>
<%@ page import="com.intland.codebeamer.controller.support.UserAgent"%>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="com.intland.codebeamer.persistence.dto.UserDto"%>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ page import="com.intland.codebeamer.Config"%>
<%@ page import="com.intland.codebeamer.taglib.performance.RequestResourceManager"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.text.DecimalFormatSymbols"%>
<%@ page import="com.intland.codebeamer.taglib.UrlVersioned"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@ taglib uri="taglib" prefix="taglib" %>

<%--
	TODO: binding locale-resolver to request: should be somewhere in the SecurityFilter (or an other filter),
			and not here in the "view" part
--%>
<%
	ControllerUtils.checkLocaleResolver(request);
%>

<%
	DecimalFormatSymbols symbols = new DecimalFormatSymbols(ControllerUtils.getLocale(request));
%>
<meta http-equiv="x-ua-compatible" content="IE=Edge">

<fmt:bundle basename="com.intland.codebeamer.utils.Bundle">
	<fmt:message key="meta.description" var="metaDescription" />
	<fmt:message key="meta.keywords" var="metaKeywords" />
	<fmt:message key="favicon.url" var="faviconUrl" />
</fmt:bundle>

<meta name="description" content="${metaDescription}"/>
<meta name="keywords" content="${metaKeywords}"/>
<link rel="icon" href="<ui:urlversioned value="${faviconUrl}" />" type="image/png" />

<c:set var="developmentMode" value="<%=Boolean.valueOf(Config.isDevelopmentMode())%>" />

<c:set var="loadScmDiffs" value="<%=Boolean.valueOf(Config.isLoadDiffs())%>" />

<%-- Use this if you want to do performance test in the browser
<c:set var="perftest" value="true"/>
<script type="text/javascript">
	var perftest = new Object();
	perftest.startTime = (new Date()).getTime();
</script>
--%>

<%-- set few javascript variables, so it is available for all javascripts --%>
<script type="text/javascript">
	<%-- create a dummy console if firebug is not installed (IE), so it is safe to use console.log() for logging --%>
	if (typeof console == "undefined") {
		var consoleLog = function(any) { /*alert(any); */ };
		console = {
			log: consoleLog,
			debug: consoleLog,
			warn: consoleLog,
			error: consoleLog
		};
	} else if (!("debug" in console)) { /* IE8 does not support debug method */
		console.debug = console.log;
	}

	var contextPath = '${pageContext.request.contextPath}';
	// current language
	var language = '<%=ControllerUtils.getLocale(request).getLanguage()%>';
	<%--
		using the "country" key from the applicationResources.properties, because that will always match
		with the current translations being used in the server
		the Locale may contain different or empty country
	--%>
	<spring:message code="language" var="languageCode" text="" />
	<spring:message code="country" var="countryCode" text="" />

	var country = '${countryCode}';
	console.log("Javascript is using localization: language:" + language +" (resource-language:${languageCode}), country:" + country);

	var developmentMode = ${developmentMode};
	// add the CB version, can be used to make urls of css/js files versioned so they will get refreshed when CB upgraded automatically
	var urlVersionParam = '<%=UrlVersioned.getVersionParam()%>';

	var serverStartupTime = <%=Config.getStartDate().getTime()%>;	// i18n js uses this to refresh i18n caches
</script>

<script type="text/javascript">
	mxBasePath = contextPath + "/mxGraph/src";
	mxLoadResources = false;
	mxLanguage = language;
</script>

<%-- wro4j filter produces all.css and all.js --%>
<c:choose>
<c:when test="${empty param.normalize || param.normalize==true}">
<%
UserAgent ua = UserAgent.get(request);
if (ua.ie > 0 && ua.ie < 8) {%>
	<!-- IE7 specific normalization -->
	<link rel="stylesheet" href="<ui:urlversioned value='/wro/all-legacy.css' />" type="text/css" media="all" />
<% } else { %>
	<link rel="stylesheet" href="<ui:urlversioned value='/wro/all.css' />" type="text/css" media="all" />
<%}; %>
</c:when>
<c:otherwise>
	<!-- without normalization -->
	<link rel="stylesheet" href="<ui:urlversioned value='/wro/all-base.css' />" type="text/css" media="all" />
</c:otherwise>
</c:choose>

<link rel="stylesheet" href="<ui:urlversioned value='/wro/newskin.css' />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/wro/all.js' />"></script>

<%-- Selenium - Collecting JavaScript errors in all pages --%>
<script type="text/javascript">
	window.jsErrors = [];
	window.onerror = function(errorMessage) {
		(!!window['jsErrors']) || (window.jsErrors = []);
		window.jsErrors[window.jsErrors.length] = errorMessage;
	}
</script>

<%-- Comment it out to overwrite some CSS definitions.
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/overrides.css" />" type="text/css" media="all" />
--%>

<c:if test="${perftest}" >
	<script type="text/javascript">
		$(function() {
			perftest.firstDOMReady = (new Date()).getTime();
		});
	</script>
</c:if>

<%--
	IMPORTANT: IE ignores if there are more than 31 CSS-es! be careful!
 --%>
<style id="jstree-stylesheet"></style>

<%
// to avoid duplicate load of this script marking it as loaded
// Note: the toolbarTag.js is already included in the sitemesh decoration and in the "all.js" file
//RequestResourceManager.getInstance(request).markResourceLoaded("/js/toolbarTag.js");
%>

<%-- script will highlight all table-rows where checkboxes are checked --%>
<%--
<script type="text/javascript" src="<ui:urlversioned value="/js/TableHighlighter.js" />"></script>
--%>

<!-- Using the user specific date-format in Calendar component -->
<c:catch>
	<c:set var="userDateFormat" value="${pageContext.request.userPrincipal.dateFormatPattern}" />
	<c:if test="${! empty userDateFormat}">
		<script type="text/javascript">
		$(function() {
			DateParsing.dateFormat = "${userDateFormat}";
		});
		</script>
	</c:if>
</c:catch>

<c:if test="${perftest}" >
	<script type="text/javascript">
		perftest.headerLoaded = (new Date()).getTime();
	</script>
</c:if>

<decorator:head /><%-- Note: on IE don't use more than 31 stylesheets/css! see: http://john.albin.net/css/ie-stylesheets-not-loading --%>

<script type="text/javascript">
// fixing JSPwikis' collapsable shows a bullet on IE by default
Collapsable.bullet.innerHTML = "&nbsp;";

showDiff.loadAllDiffsEnabled = ${loadScmDiffs};

$(document).ready(function () {
	initializeHighchartLocalization("<%=symbols.getGroupingSeparator()%>", "<%=symbols.getDecimalSeparator()%>");
	initializeJumpToDocumentViewHandler();
});
</script>

