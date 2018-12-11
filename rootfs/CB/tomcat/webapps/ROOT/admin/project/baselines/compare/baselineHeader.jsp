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

<div class="baselineHeaderContainer">
	<table class="baselineHeader">
		<tbody>
			<tr>
				<td>
					<c:choose>
						<c:when test="${not empty param.url}">
							<a href="${request.contextPath}${param.url}" class="name">${param.name}</a>
						</c:when>
						<c:otherwise>
							<span class="name">${param.name}</span>
						</c:otherwise>
					</c:choose>
					<span class="meta">
						<spring:message code="baseline.createdBy.label" />: <c:out value="${param.createdBy}" />, <c:out value="${param.formattedCreatedDate}" />
					</span>
					<span class="description">${param.description}</span>
				</td>
				<td class="version"><spring:message code="document.version.label" text="Version" /></td>
			</tr>
		</tbody>
	</table>
</div>
