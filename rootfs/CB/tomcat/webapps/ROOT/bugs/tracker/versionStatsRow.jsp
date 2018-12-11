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
	small JSP fragment renders a row in the filter table for versionStatsBox.jsp

	Parameters are expected to be passed in request variables. Oh, I hate JSP that there is no lightweight macros (don't tell me .tag files argh)!
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%--
Parameters:
		- versionStatsPageEventHandlers: true/false, tells whether version stats event handlers should be added or not
		- hideClosed: true/false, tells whether only open issues column should be shown
		- mergeOpenAndClosed: merge open and closed columns - used in Status based statistics where open/closed comcept is orthogonal to status value
		- isOpen: must be used in conjunction with mergeOpenAndClosed. Adds semantic value to current status row
		- filterArgs
		- totals
		- firstColumnClasses: Additional classes, which are added to the first td element.
		- dataTtId: adds data-tt-id atribute to tr element
		- dataTtParentId: adds data-tt-parent-id to tr element
--%>

<%@ page import="com.intland.codebeamer.persistence.dto.base.IdentifiableDto" %>
<%@ page import="com.intland.codebeamer.servlet.bugs.dynchoices.ReferenceHandlerSupport" %>

<%
	Object group = pageContext.findAttribute("group");
	String rowId = (group instanceof IdentifiableDto) ? ReferenceHandlerSupport.getReferenceId((IdentifiableDto) group) : null;
	pageContext.setAttribute("rowId", rowId);
%>

	<tr class="${param.cssClass} data-row"<c:if test="${!empty rowId}"> data-id="${rowId}"</c:if>
		<c:if test="${!empty dataTtId}">data-tt-id="${dataTtId}"</c:if>
		<c:if test="${!empty dataTtParentId}">data-tt-parent-id="${dataTtParentId}"</c:if>
	>
		<td class="firstColumn filterCell ${firstColumnClasses}
			<c:if test="${filterCategoryName == activeFilters.selectedFilterCategory && filterCategoryValue == activeFilters.selectedFilterValue && empty activeFilters.openOrClosedFilter}">
				selected
			</c:if>" data-filter-category="${filterCategoryName}" data-filter-value="${filterCategoryValue}"
			data-status-open="">
			${groupRendered}
		</td>
		<c:set var="data" value="${totals[group]}" />

		<c:choose>
			<c:when test="${not mergeOpenAndClosed}">
				<c:set var="statusFilter" scope="request">true</c:set>
				<!-- open issues count -->
				<c:set var="cellCssClass" value="openIssueCell" scope="request" />
				<c:set var="issueCount" value="${data.open}" scope="request" />
				<c:set var="storyPoints" value="${data.openStoryPoints}" scope="request" />
				<c:set var="storyPointsCssClass" value="open" scope="request" />
				<c:set var="colSpan" value="1" scope="request" />
				<jsp:include page="includes/versionStatsCellContents.jsp" />

				<c:if test="${!hideClosed}">
					<!-- resolved/closed issues count -->
					<c:set var="statusFilter" scope="request">false</c:set>
					<c:set var="cellCssClass" value="closedIssueCell" scope="request" />
					<c:set var="issueCount" value="${data.resolvedOrClosed}" scope="request" />
					<c:set var="storyPoints" value="${data.resolvedOrClosedStoryPoints}" scope="request" />
					<c:set var="storyPointsCssClass" value="closed" scope="request" />
					<c:set var="colSpan" value="1" scope="request" />
					<jsp:include page="includes/versionStatsCellContents.jsp" />
				</c:if>
			</c:when>
			<c:otherwise>
				<!-- merged cell, data will be the sum of open+closed counts -->
				<c:set var="statusFilter" value="${'merged'}" scope="request" />
				<c:set var="cellCssClass" value="${'openIssueCell'}" scope="request" />
				<c:set var="issueCount" value="${data.open + data.resolvedOrClosed}" scope="request" />
				<c:set var="storyPoints" value="${data.openStoryPoints + data.resolvedOrClosedStoryPoints}" scope="request" />
				<c:set var="storyPointsCssClass" value="${'open'}" scope="request" />
				<c:set var="colSpan" value="2" scope="request" />
				<jsp:include page="includes/versionStatsCellContents.jsp" />
			</c:otherwise>
		</c:choose>
	</tr>

	<c:remove var="statusFilter" scope="request" />
