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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%-- Edit repository properties --%>

<meta name="decorator" content="popup"/>
<meta name="module" content="sources"/>
<meta name="moduleCSSClass" content="sourceCodeModule"/>
<meta name="stylesheet" content="sources.css"/>

<ui:actionMenuBar>
		<ui:pageTitle prefixWithIdentifiableName="false" >
			<spring:message code="scm.repository.properties.page.title" arguments="${command.repository.name}" htmlEscape="true"/>
		</ui:pageTitle>
</ui:actionMenuBar>

<form:form autocomplete="off">
	<ui:actionBar>
		&nbsp; <input type="submit" class="button" name="submit" value="<spring:message code='button.save'/>"></input>
		&nbsp; <input type="submit" class="cancelButton" name="__cancel" value="<spring:message code='button.cancel'/>"></input>
	</ui:actionBar>

	<form:errors cssClass="error"/>

	<jsp:include page="./includes/repository-properties.jsp?propertyNameEditable=false"/>
</form:form>