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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<h1><spring:message code="Statistics" text="Statistics" /></h1>

<c:set var="firstHtml">
	<c:set var="baseline" value="${first}" scope="request" />
	<jsp:include page="baselineInline.jsp" />
</c:set>

<c:set var="secondHtml">
	<c:set var="baseline" value="${second}" scope="request" />
	<jsp:include page="baselineInline.jsp" />
</c:set>

<p class="compareInfo">
	<spring:message code="project.baselines.comparing.text" text="Comparing {0} to {1}" arguments="${firstHtml}*/*${secondHtml}" argumentSeparator="*/*" />:
</p>

<table class="statsPerCategory">
	<thead>
		<tr>
			<th class="filler"></th>
			<c:forEach var="diffType" items="${diffTypes}">
			<th class="count ${diffType}"><span class="baselineDiffTablet baselineStatus${diffType}">${diffType}</span></th>
			</c:forEach>
		</tr>
	</thead>
	<tbody>
		<c:forEach var="statsPerCategory" items="${stats}" varStatus="status">
			<c:set var="category" value="${statsPerCategory.key}" />
			<c:set var="statsPerType" value="${statsPerCategory.value}" />
			<tr ${status.first ? 'class="total"' : ''}>
				<td class="categoryHeader">
					<c:if test="${!status.first}"><a href="#"></c:if>
					<spring:message code="${category}" text="${category}" />
					<c:if test="${!status.first}"></a></c:if>
				</td>
				<c:forEach var="stats" items="${statsPerType}">
					<td class="count ${stats.key} ${stats.value eq 0 ? 'zero' : ''}"><c:out value="${stats.value}" /></td>
				</c:forEach>
			</tr>
		</c:forEach>
	</tbody>
</table>
