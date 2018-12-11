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
 * $Id$
--%>
<%@ tag language="java" pageEncoding="UTF-8" %>
<%@ tag import="com.intland.codebeamer.controller.support.SimpleMessageResolver"%>
<%@ tag import="com.intland.codebeamer.controller.support.InfoMessages"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%--
	Tag to show Spring or Struts errors as a list-html tag.

	For Spring:

	Use instead of <form:errors/> inside spring forms, and use <spring:hasBindErrors name=""/ to export BindingResult object for the current form

	for example (assuming that your command bean has standard name of "command"):

	<spring:hasBindErrors name="command">
		<ui:showSpringErrors errors="${errors}" />
	</spring:hasBindErrors>

	For Struts:

	Simply use as <ui:showErrors /> tag instead of <html:errors/>
--%>
<%@ attribute name="errors" required="false" description="The errors object." type="org.springframework.validation.Errors" %>

<%@ attribute name="messages" required="false" description="Extra messages to add"
		type="com.intland.codebeamer.controller.support.InfoMessages" %>

<%
	InfoMessages mergedMessages = new InfoMessages();

	// add extra messages
	if (messages != null) {
		mergedMessages.addMessages(messages);
	}
	SimpleMessageResolver messageResolver = SimpleMessageResolver.getInstance(request);

	// transfer all Spring errors to messages
	mergedMessages.addSpringErrors(messageResolver, InfoMessages.Level.ERROR, errors);

	// transfer all Struts errors to messages
	mergedMessages.addStrutsGlobalErrors(messageResolver, InfoMessages.Level.ERROR, jspContext);

	jspContext.setAttribute("mergedMessages", mergedMessages);
%>
<ui:infoPanel infoMessages="${mergedMessages}"/>
