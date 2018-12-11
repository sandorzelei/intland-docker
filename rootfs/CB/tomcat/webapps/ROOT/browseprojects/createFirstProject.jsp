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
<%@ page import="com.intland.codebeamer.controller.project.ProjectProperties" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Map" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="newskin workspaceModule"/>

<h2><spring:message code="project.browser.createFirstProject.title" text="Create your first project" /></h2>
<p><spring:message code="project.browser.createFirstProject.content" text="You have no projects yet. Please click the button below to launch the New Project wizard." /></p>
<form action="${pageContext.request.contextPath}/createProject.spr">
	<input type="submit" class="button" value=" <spring:message code="project.browser.createFirstProject.submitLabel" text="Create project" htmlEscape="true" /> ">
</form>
