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

<%@ attribute name="value" required="true" type="java.lang.String" rtexprvalue="true" description="String to render."  %>

<c:choose>
	<c:when test="${not empty value}">
		<c:out value="${value}"/>
	</c:when>
	<c:otherwise>
		<spring:message code="tracker.view.layout.document.no.summary" text="[No Summary]"/>
	</c:otherwise>
</c:choose>