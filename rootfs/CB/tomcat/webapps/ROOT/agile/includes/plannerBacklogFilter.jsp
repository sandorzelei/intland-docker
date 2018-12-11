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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:choose>
	<c:when test="${!empty items}">
		<jsp:include page="plannerIssueList.jsp" />
	</c:when>
	<c:otherwise>
		<div class="empty-filtered">
			<spring:message code="table.nothing.found" text="Nothing found to display"></spring:message>
		</div>
	</c:otherwise>
</c:choose>
