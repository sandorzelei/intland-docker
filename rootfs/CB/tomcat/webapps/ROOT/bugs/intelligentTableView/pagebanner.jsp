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

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<div class="pagebanner" style="float:right">
	${count} <spring:message code="intelligent.table.view.issues.found"></spring:message>
</div>
<c:if test="${count > pageSize}">
	<div class="pagelinks">
		<c:choose>
			<c:when test="${page eq 1}"><span class="nextprev"><spring:message code="intelligent.table.view.pagebanner.first"/></span></c:when>
			<c:otherwise><a href="?page=1&pageSize=${pageSize}"><spring:message code="intelligent.table.view.pagebanner.first"/></a></c:otherwise>
		</c:choose>
		<c:choose>
			<c:when test="${page eq 1}"><span class="nextprev">« <spring:message code="intelligent.table.view.pagebanner.previous"/></span></c:when>
			<c:otherwise><a href="?page=${page - 1}&pageSize=${pageSize}">« <spring:message code="intelligent.table.view.pagebanner.previous"/></a></c:otherwise>
		</c:choose>
		<c:forEach begin="1" end="${numberOfPages}" step="1" var="index">
			<c:choose>
				<c:when test="${page eq index}">
					<strong>${index}</strong>
				</c:when>
				<c:otherwise>
					<a href="?page=${index}&pageSize=${pageSize}">${index}</a>
				</c:otherwise>
			</c:choose>
		</c:forEach>
		<c:choose>
			<c:when test="${page eq numberOfPages}"><span class="nextprev"><spring:message code="intelligent.table.view.pagebanner.next"/> »</span></c:when>
			<c:otherwise><a href="?page=${page + 1}&pageSize=${pageSize}"><spring:message code="intelligent.table.view.pagebanner.next"/> »</a></c:otherwise>
		</c:choose>
		<c:choose>
			<c:when test="${page eq numberOfPages}"><span class="nextprev"><spring:message code="intelligent.table.view.pagebanner.last"/></span></c:when>
			<c:otherwise><a href="?page=${numberOfPages}&pageSize=${pageSize}"><spring:message code="intelligent.table.view.pagebanner.last"/></a></c:otherwise>
		</c:choose>
	</div>
</c:if>