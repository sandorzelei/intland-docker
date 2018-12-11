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
<meta name="module" content="docs"/>
<meta name="moduleCSSClass" content="documentsModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<ui:actionMenuBar>
    <ui:breadcrumbs showProjects="false">
       <span class='breadcrumbs-separator'>&raquo;</span> <ui:pageTitle><spring:message code="document.status.title" text="Status Choices" /></ui:pageTitle>
    </ui:breadcrumbs>
</ui:actionMenuBar>

<form:form>
<form:hidden path="doc_id" />
<form:hidden path="dir_id" />

<spring:message var="saveButton" code="button.save" text="Save" />
<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

<ui:actionBar>
	&nbsp;&nbsp; <input type="submit" class="button" value="${saveButton}" />
	&nbsp;&nbsp; <input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" />
</ui:actionBar>


<display:table requestURI="" name="${statusItems}" id="item">

	<spring:message var="statusLabel" code="document.status.label" text="Status" />
	<display:column title="${statusLabel}" sortable="false" headerClass="column-minwidth" class="column-minwidth">
		<form:input path="status_id" value="${item.id}" maxlength="5" size="5" />
	</display:column>

	<spring:message var="nameLabel" code="tracker.choice.name.label" text="Name" />
	<display:column title="${nameLabel}" sortable="false" headerClass="textData" class="textData" style="width:90%;">
		<spring:message var="statusName" code="document.status.${item.name}" text="${item.name}" htmlEscape="true" />
		<form:input path="name" value="${statusName}" maxlength="80" size="40" />
	</display:column>

</display:table>

</form:form>
