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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%--
	Tag to show Spring errors as a list-html tag.
	Use instead of <form:errors/> inside spring forms, and use <spring:hasBindErrors name=""/ to export BindingResult object for the current form

	for example (assuming that your command bean has standard name of "command"):

	<spring:hasBindErrors name="command">
		<ui:showSpringErrors errors="${errors}" />
	</spring:hasBindErrors>

--%>
<%@ attribute name="errors" required="true" description="The errors object." type="org.springframework.validation.BindingResult" %>
<ui:showErrors errors="<%=errors%>"/>
