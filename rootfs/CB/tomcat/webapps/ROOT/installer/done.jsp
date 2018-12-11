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

<meta name="decorator" content="popup"/>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=done"/>

	<c:url value="/installer/restart.spr" var="actionUrl"/>
	<form:form method="POST" action="${actionUrl}">
		<div class="info"><spring:message code="post.installer.done.info" text="Congratulations! You just finished setting up your copy of codeBeamer ALM. Click the button below to start using it right away."/></div>

		<spring:message var="finishButton" code="post.installer.done.finish.button" text="Start working with codeBeamer"/>
		<spring:message var="pleaseWaitText" code="post.installer.done.please.wait" text="The database schema is being created. It will take a few minutes, please wait... Thank you!"/>

		<div class="info center">
			<input type="button" value="${finishButton}" class="button" onclick="codebeamer.installer.maskPage('${pleaseWaitText}'); $('form').submit(); $(this).attr('disabled', 'disabled'); "/>
		</div>

		<c:if test="${not empty summaryInformation}">
			<div class="summary-info"><spring:message code="post.installer.summary.info"/></div>
			<table class="summary">
				<c:forEach items="${summaryInformation}" var="entry">
					<c:if test="${not empty entry.value}">
						<tr>
							<td><b><spring:message code="${entry.key}"/>:</b></td>
							<td>${entry.value}</td>
						</tr>
					</c:if>
				</c:forEach>
			</table>
		</c:if>

		<jsp:include page="includes/footer.jsp?step=done&hideNavigation=true"/>
	</form:form>
</div>
