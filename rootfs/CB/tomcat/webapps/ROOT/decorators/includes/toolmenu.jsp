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

<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>

<%@ page import="com.intland.codebeamer.ui.view.ToolMenuRenderer"%>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils"%>

<c:set var="module"><decorator:getProperty property="meta.module"/></c:set>

<%-- Toolbar --%>
<%
	String module = (String)pageContext.getAttribute("module");
	String beanName = "license".equals(module) ? "licenseMenuRenderer" : "toolMenuRenderer";

	ToolMenuRenderer toolMenuRenderer = (ToolMenuRenderer) ControllerUtils.getSpringBean(request, beanName);
	out.print(toolMenuRenderer.render(request, module));
%>
