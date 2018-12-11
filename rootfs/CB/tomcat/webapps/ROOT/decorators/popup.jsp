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
--%><%-- DO NOT PUT anything before this, because IE6 will otherwise switch to QUIRKS mode! --%><%=com.intland.codebeamer.servlet.IWebConstants.HTML_DOCTYPE%>
<%-- Useful with Html-Checker.
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
--%>
<%@ page language="java" session="false"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<html>
<head>

<%@include file="includes/userAgentCSS.jsp" %>
<%@include file="includes/moduleDefaults.jsp" %>

<c:set var="stylesheet"><decorator:getProperty property="meta.stylesheet" default="${moduleDefaults.stylesheet}"/></c:set>
<c:set var="wysiwyg"><decorator:getProperty property="meta.wysiwyg"/></c:set>

<%@include file="includes/title.jsp" %>
<%@include file="includes/htmlHeader.jsp" %>

<c:if test="${!empty stylesheet}">
	<link REL="stylesheet" HREF="<ui:urlversioned value="/stylesheet/${stylesheet}" />" TYPE="text/css"/>
</c:if>

<script LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers
// This function will be overwritten by the application page.
function resize() {
}
// -->
</script>

${param.extraHeaderLines}

	<script type="text/javascript">
		// initialize the form related hotkeys
		new codebeamer.FormHotkeys({isPopup: true});
		if (window.parent != window) {
			codebeamer.userPreferences = window.parent.codebeamer.userPreferences || {};
		}
	</script>
</head>

<c:choose>
<c:when test="${!empty wysiwyg}">
<body class="newskin" >
<decorator:body />
<ui:delayedScript flush="true" />
</body>
</c:when>
<c:otherwise>

<ui:isMac var="isMac" />

<body class="${userAgentClass} ${isMac ? 'Mac ' : ''}yui-skin-cb popupBody newskin ${moduleCSSClass}" onresize="resize();" onload="resize();" bgcolor="white"
		link="#000000" vlink="#000000" alink="#000000" topmargin="0" leftmargin="0" marginwidth="0" marginheight="0"
>

<c:set var="applyLayout" scope="request"><decorator:getProperty property="meta.applyLayout" default="false" /></c:set>
<%--
	applying layout on popups has the following rules:
	- turn on applyLayout meta tag
	- use "popupLayoutContentArea" id for the container of the layout
	- use "ui-layout-north" / "ui-layout-center" / "ui-layout-south" for the north/center/south parts
 --%>
<c:if test="${applyLayout == 'true'}">
	<script type="text/javascript">
	$(function() {
		if ($("#popupLayoutContentArea").size() > 0) {
			console.log("initializing popup layout for #popupLayoutContentArea");
			layoutScripts.initLayoutFor('#popupLayoutContentArea');
		}
	});
	</script>
</c:if>


<div class="contentArea">
	<c:set var="showGlobalMessages"><decorator:getProperty property="meta.showGlobalMessages" default="true" /></c:set>
	<c:if test="${showGlobalMessages}"><ui:globalMessages/></c:if>
	<decorator:body />
</div>

<ui:delayedScript flush="true" />
</body>
</c:otherwise>
</c:choose>
</html>