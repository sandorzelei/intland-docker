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
<%@ taglib uri="http://www.springframework.org/tags/form"  prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="newskin sysadminModule"/>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="sysadmin.setMRAccessUrl.label" text="Managed Repository Access Base URLs"/></ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="mrAccessUrlFrom">

<ui:actionBar>
	<spring:message var="saveButton" code="button.save" text="Save"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	&nbsp;&nbsp;<input type="submit" class="button" value="${saveButton}" name="_submit" />
	&nbsp;&nbsp;<input type="submit" class="cancelButton button" value="${cancelButton}" name="_cancel" />
</ui:actionBar>

<spring:hasBindErrors name="mrAccessUrlFrom">
	<ui:showSpringErrors errors="${errors}" />
</spring:hasBindErrors>

<table border="0" class="formTableWithSpacing" cellpadding="0">

<c:forEach var="key" items="${mrAccessUrlFrom.keys}">
	<tr>
		<TD class="optional" nowrap><spring:message code="sysadmin.setMRAccessUrl.${key}" text="${key}"/></TD>

		<td class="expandText">
			<form:input path="accessUrls[${key}]" size="60" cssClass="expandText"/>
			<br/>
		</td>
	</tr>
</c:forEach>

</table>

<spring:message code="sysadmin.setMRAccessUrl.hint"/>

</form:form>