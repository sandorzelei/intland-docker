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

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="sysadminModule newskin"/>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="useradmin.importUsers.assignColumns.title" text="Assign Columns of Imported Data"/></ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="importForm" action="${flowUrl}">

<form:errors cssClass="error"/>

<ui:actionBar>
	<spring:message var="nextButton" code="button.goOn" text="Next &gt;"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

	&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_next" value="${nextButton}" />

	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<input type="submit" class="button" name="_eventId_back" value="${backButton}" />

	<input type="submit" class="button linkButton cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<style type="text/css">
	fieldset {
		margin: 5px 0;
		border: solid 1px silver;
	}
	table .mandatory {
		width: 10em;
	}
	table th {
		padding: 2px 0.5em;
	}
</style>

<div style="margin: 15px;">
<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="0">
	<TR>
		<TD class="mandatory"><spring:message code="useradmin.importUsers.startImportAtRow.label" text="Start Import at Row"/>:</TD>
		<TD><form:input size="4" path="startImportAtRow" cssClass="fixSelectWidth" type="number" min="1" max="${importForm.dataSize}" /></TD>
	</TR>
</TABLE>

<jsp:include page="/bugs/importing/includes/showRawImportData.jsp"/>
</div>

</form:form>
