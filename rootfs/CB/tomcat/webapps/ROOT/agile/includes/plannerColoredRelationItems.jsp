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
--%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<c:choose>
	<c:when test="${not empty groups}">
		<input type="hidden" id="plannerClosedGroups" value="${closedGroups}">
		${groups}
	</c:when>
	<c:when test="${categoryTreeIsNotEmpty}">
		<ol class="color-filters">${categoryTreeHtml}</ol>
	</c:when>
	<c:otherwise>
		<spring:message code="planner.colorCategories.hint" />
	</c:otherwise>
</c:choose>
