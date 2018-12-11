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
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ tag import="com.intland.codebeamer.controller.support.InfoMessages"%>
<%@ tag import="java.util.List"%>
<%@ tag import="java.util.ArrayList"%>
<%@ tag import="com.intland.codebeamer.controller.support.InfoMessages.Level"%>
<%@ tag import="com.intland.codebeamer.controller.support.SimpleMessageResolver"%>

<%-- JSP tag renders a set of error/warning/info messages similar as in GlobalMessages --%>

<%@ attribute name="infoMessages" required="true" type="com.intland.codebeamer.controller.support.InfoMessages"
	description="The InfoMessages object shows the messages to show" %>
<%@ attribute name="id" required="false"
	description="The html id of the container" %>

<%
	Level[] levels = new Level[] {InfoMessages.Level.ERROR, InfoMessages.Level.WARNING, InfoMessages.Level.INFO };
	// css classes for each level
	String[] cssClasses = new String[] {"error", "warning", "information"};
	SimpleMessageResolver messageResolver = SimpleMessageResolver.getInstance(request);
	String[] tooltips = new String[] { messageResolver.getMessage("ui.infoPanel.error.tooltip"), messageResolver.getMessage("ui.infoPanel.warning.tooltip"), messageResolver.getMessage("ui.infoPanel.information.tooltip")};
%>

<div class="infoMessages<c:if test='<%=infoMessages.isEmpty()%>'> invisible</c:if>"
	<c:if test="${! empty id}">id="${id}"</c:if> >
		<% for (int i=0; i<levels.length;i++) {
			List<String> messages = new ArrayList<String>(infoMessages.getMessages(levels[i]));
			String cssClass = cssClasses[i];
			if (messages != null && messages.size() == 1) {
				cssClass += " onlyOneMessage";
			}
			String tooltip = tooltips[i];
		%>
			<div class="<%=cssClass%> <c:if test="<%=messages.isEmpty()%>">invisible</c:if>" title="<%=tooltip%>" >
				<ul>
					<c:forEach var="msg" items="<%=messages%>">
						<li>${msg}</li><!-- do not escape here, because messages can be HTML -->
					</c:forEach>
				</ul>
			</div>
		<% } %>
</div>
