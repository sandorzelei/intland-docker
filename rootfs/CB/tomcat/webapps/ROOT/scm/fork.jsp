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
<meta name="module" content="sources"/>
<meta name="bodyCSSClass" content="newskin" />

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<style type="text/css">
.newskin .formTableWithSpacing textarea {
  	border-top: none !important;
  	width: 100% !important;
}
</style>

<ui:actionMenuBar>
		<ui:pageTitle prefixWithIdentifiableName="false" >
			<spring:message code="scm.repository.fork.page.title" arguments="${command.repository.name}" htmlEscape="true"/>
		</ui:pageTitle>
</ui:actionMenuBar>

<c:url var="actionUrl" value="/scm/fork.spr">
	<c:param name="repositoryId" value="${command.repository.id}"/>
</c:url>
<form:form action="${actionUrl}" method="POST">
	<input type="hidden" name="type" value="<c:out value='${command.type}'/>"/>

	<ui:actionBar>
		<spring:message var="buttonTitle" code="scm.repository.fork.label" text="Fork"/>
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="submit" class="button" title="${buttonTitle}" value="${buttonTitle}" name="submit" />&nbsp;
		<input type="submit" class="cancelButton" title="${cancelTitle}" value="${cancelTitle}" name="_cancel" />
	</ui:actionBar>

	<form:errors cssClass="error"/>

	<jsp:include page="./includes/repository-properties.jsp?propertyNameEditable=true"/>
</form:form>

