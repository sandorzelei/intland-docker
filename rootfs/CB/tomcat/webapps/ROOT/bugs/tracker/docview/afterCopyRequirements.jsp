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

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>



<ui:actionMenuBar >
	<ui:pageTitle>
		<spring:message code="tracker.view.layout.document.linking.requirements.page.title" text="Copying tracker items from library"/>
	</ui:pageTitle>
</ui:actionMenuBar>

<div class="actionBar">
	<spring:message var="closeText" code="button.close" />
	<input type="button" class="button" value="${closeText}" onclick="parent.refreshTrees(); inlinePopup.close();"/>
</div>
<div class="contentWithMargins">
	<c:if test="${noItemsFound }">
		<div class="error">
			<spring:message code="tracker.view.layout.document.copy.no.permission"
				text="The selected items were not copied because the current user has no permission to any of them"></spring:message>
		</div>
	</c:if>
	<div class="information">
		<c:choose>
			<c:when test="${copy }">
				<spring:message code="tracker.view.layout.document.copy.all.test.cases.linked" text="All selected items were successfully copied to the target tracker."/>
			</c:when>
			<c:otherwise>
				<spring:message code="tracker.view.layout.document.linking.all.test.cases.linked" text="All test cases were successfully linked to the requirement"/>
			</c:otherwise>
		</c:choose>
	</div>
</div>