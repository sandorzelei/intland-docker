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

<c:set var="requirementName">
	<c:out value="${requirement.name }" escapeXml="true"/>
</c:set>

<ui:actionMenuBar >
	<ui:pageTitle>
		<c:if test="${not empty requirement.name }">
			<spring:message code="tracker.view.layout.document.linking.page.title" text="Linking test cases to ${requirementName }" arguments="${requirementName }"/>
		</c:if>
		<c:if test="${empty requirement.name }">
			<spring:message code="tracker.view.layout.document.linking.page.empty.name.title" text="Linking Test Cases to Requirement"/>
		</c:if>
	</ui:pageTitle>
</ui:actionMenuBar>

<div class="actionBar">
	<spring:message var="closeText" code="button.close" />
	<input type="button" class="button" value="${closeText}" onclick="parent.refreshTrees(${requirement.id}); inlinePopup.close();"/>
</div>
<div class="contentWithMargins">
	<div class="information">
		<c:if test="${not empty notLinked }">
			<spring:message code="tracker.view.layout.document.linking.test.cases.not.linked" text="Some of the test cases were not linked to the requirement"/><br/>
			<a href="#" onclick="$(this).next().show(); $(this).hide(); return false;">
				<spring:message code="tracker.view.layout.document.linking.show.test.cases.label" text="Show Test Cases"/>
			</a>
			<div style="display:none;">
				<c:forEach items="${notLinked }" var="item" varStatus="status">
					<ui:itemLink item="${item }"></ui:itemLink>
					<c:if test="${!status.last }">, </c:if>
				</c:forEach>
			</div>
		</c:if>
		<c:if test="${empty notLinked }">
			<c:choose>
				<c:when test="${copy }">
					<spring:message code="tracker.view.layout.document.linking.all.test.cases.linked" text="All test cases were successfully linked to the requirement"/>
				</c:when>
				<c:otherwise>
					<spring:message code="tracker.view.layout.document.copy.all.test.cases.linked" text="All selected items were successfully copied to the target tracker."/>
				</c:otherwise>
			</c:choose>
		</c:if>
	</div>
</div>