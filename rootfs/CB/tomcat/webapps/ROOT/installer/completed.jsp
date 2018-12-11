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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=done" />
	<c:url value="/" var="actionUrl" />
	<div class="info">
		<spring:message code="post.installer.completed"
			text="Installation has successfully completed" />
		<br /> <br /> <a href="${actionUrl}"><spring:message
				code="post.installer.redirect"
				text="Click here to redirect to main page" /></a>
	</div>
	<jsp:include page="includes/footer.jsp?step=done&hideNavigation=true" />
</div>

