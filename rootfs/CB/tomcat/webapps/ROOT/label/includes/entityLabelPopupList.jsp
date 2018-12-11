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

<meta name="decorator" content="popup"/>
<meta name="module" content="labels"/>
<meta name="bodyCSSClass" content="newskin"/>

<%--
	Parameters (in request scope):
		title		Title of list
		labels		Labels to display
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<spring:message var="moreText" code="tags.more" text="More..."/>
<spring:message var="lessText" code="tags.less" text="Less..."/>

<c:set var="displayLimit" value="16"/>

<c:if test="${!empty labels}">
	<div class="tag-list">
		<b>${title}:</b><br/>
		<c:forEach items="${labels}" var="label" varStatus="status" end="${displayLimit - 1}">
			<a href="#" onclick="addLabel('${label.escapedDisplayName}'); return false;">${label.escapedDisplayName}</a><c:if
				test="${!status.last}">; </c:if>
		</c:forEach>
		<c:if test="${fn:length(labels) > displayLimit}">
			<a href="#" class="toggleMoreLink">(${moreText})</a>
			<div style="display: none;">
				<c:forEach items="${labels}" var="label" varStatus="status" begin="${displayLimit}">
					<a href="#" onclick="addLabel('${label.escapedDisplayName}'); return false;">${label.escapedDisplayName}</a><c:if
						test="${!status.last}">; </c:if>
				</c:forEach>
				<a href="#" class="toggleLessLink">(${lessText})</a>
			</div>
		</c:if>
		<div>
</c:if>
