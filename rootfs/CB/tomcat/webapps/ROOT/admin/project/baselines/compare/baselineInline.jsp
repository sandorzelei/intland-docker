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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="taglib" prefix="tag" %>

<tag:formatDate value="${baseline.dto.createdAt}" var="formattedCreatedAt" />

<c:set var="date">
	<span class="date"> (${formattedCreatedAt})</span>
</c:set>

<span class="baselineName">
	<c:choose>
		<c:when test="${not empty baseline.dto.id}">
			<a href="${pageContext.request.contextPath}${baseline.dto.urlLink}"><c:out value="${baseline.dto.name}" /></a>${date}
		</c:when>
		<c:otherwise>
			<c:out value="${baseline.dto.name}" />${date}
		</c:otherwise>
	</c:choose>
</span>
