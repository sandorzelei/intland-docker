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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>

<%@page import="com.intland.codebeamer.Config"%>
<%@page import="com.intland.codebeamer.controller.support.UserAgent"%>

<%--
	small fragment sets up an "userAgentClass" request variable which contains either the strings: "IE" "IE6", "IE7", "FF".
	Then this ${userAgent} is added to the <body> tag, so conditional css-es can be easily added.

	For example the following will put a red border around every <div> for IE6, but not for the other browsers:

	.IE6 div {
		border: solid 1px red;
	}

	So this is useful when playing with CSS differences of different browsers.
 --%>
 <%
 	UserAgent userAgent = UserAgent.get(request);

 	request.setAttribute("userAgentClass", userAgent.getUserAgentCSS());

 	request.setAttribute("userAgent", userAgent);
 	
 	request.setAttribute("userAgentString", userAgent.getName());
 	
 	if (Config.isDevelopmentMode()) {
 %>
<!--
<c:out value="<%=userAgent%>" escapeXml="true"/>
-->
<%  } %>
