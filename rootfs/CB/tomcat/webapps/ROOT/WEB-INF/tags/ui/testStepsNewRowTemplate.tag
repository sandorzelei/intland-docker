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

<%--
  Tag renders the hidden template used when adding new Test-Steps
--%>
<%@tag import="com.intland.codebeamer.manager.testmanagement.TestStep"%>
<%@tag import="java.util.ArrayList"%>
<%@tag import="java.util.List"%>
<%@tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ attribute name="uploadConversationId" required="false" %>

<c:set var="tableId" value="___tableId___" />

<div style="display:none" id="newRowTemplate">
	<%
		List<TestStep> templateSteps = new ArrayList();
		templateSteps.add(new TestStep());
		jspContext.setAttribute("templateSteps", templateSteps);
	%>
	<ui:testSteps tableId="${tableId}" testSteps="${templateSteps}" uploadConversationId="${uploadConversationId}" onlyTable="true" />
</div>
