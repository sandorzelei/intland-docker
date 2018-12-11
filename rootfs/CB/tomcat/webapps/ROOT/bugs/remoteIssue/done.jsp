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

<jsp:include page="header.jsp?step=done&stepIndex=3"></jsp:include>

<div class="container">
	<div class="info">
		<c:url var="issueUrl" value="${trackerItem.urlLink}"></c:url>
		<spring:message code="remote.issue.report.done.message" text="Thank you for contacting Intland support. Your request has been received and is being reviewed. We will attempt to respond to your query in a timely manner. We thank you for your patience and we will get back to you as soon as possible. You can access the work item on this url:"/>
		<c:set var="itemName"><c:out value="${trackerItem.name}" /></c:set>
		<b><a href="${issueUrl}" target="_blank" title="${itemName}">#${trackerItem.id} - ${itemName}</a></b>
	</div>
	<jsp:include page="footer.jsp?step=done"></jsp:include>
</div>

