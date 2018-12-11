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

<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<spring:message var="previewButton" code="button.preview"/>
<spring:message var="cancelButton" code="button.cancel"/>
<spring:message var="introduction" code="tracker.issues.importFromWord.introduction"/>
<spring:message var="rules" code="tracker.issues.importFromWord.rules"/>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<ui:pageTitle prefixWithIdentifiableName="false">
			${introduction}
		</ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<p>
</p>
${rules}
<p>
	<form:form commandName="command" enctype="multipart/form-data">
		<form:hidden path="trackerId"/>

		<input type="file" size="70" name="importFile"/> <form:errors path="importFile" cssClass="invalidfield"/>
		<br/><br/>

		&nbsp;&nbsp;<input type="submit" class="button" value="${previewButton}" name="_preview"/>
		&nbsp;&nbsp;<input type="submit" class="button cancelButton" value="${cancelButton}" name="_cancel"/>
	</form:form>
</p>
