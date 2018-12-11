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
<%@ page contentType="text/html; charset=UTF-8" %>

<%@ page import="com.intland.codebeamer.manager.WikiPageManager" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content=""/>

<ui:pageTitle printBody="false">
	<spring:message code="${param.file}.title"/>
</ui:pageTitle>

<div class="contentWithMargins">
<span id="pagecontent"><%-- JSPWiki javascript function rely on using this ID --%>
	<tag:transformText value='<%= WikiPageManager.getInstance().getTemplateContent(request, "/help/" + request.getParameter("file")) %>' format='W' />
</span>
</div>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers
$(window).load(resize);
//-->
</SCRIPT>

