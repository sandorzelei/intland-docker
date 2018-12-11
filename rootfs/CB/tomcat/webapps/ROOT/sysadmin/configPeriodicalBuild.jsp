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
<meta name="decorator" content="main"/>
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="newskin sysadminModule"/>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="cb.timerConfig.title" text="Periodic Process Timer"/></ui:pageTitle>
</ui:actionMenuBar>

<form:form >

<spring:message var="saveButton" code="button.save" text="Save"/>
<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	
<ui:actionBar>
	<input type="submit" class="button" value="${saveButton}" />
    &nbsp;&nbsp;
    <input type="submit" class="cancelButton button" name="_cancel" value="${cancelButton}" />
</ui:actionBar>

<ui:showErrors />

<div class="descriptionBox">
	<spring:message code="cb.timerConfig.info"/>
</div>

<TABLE BORDER="0" CELLPADDING="2" class="formTableWithSpacing" WIDTH="500">

<TR>
	<TD class="mandatory"><spring:message code="cb.timerConfig.hour.label" text="Hour (0-23)"/>:</TD>
	<TD><form:input type="number" path="hour" size="5" min="0" max="23" /></TD>
	<TD WIDTH="200"></TD>
</TR>

<TR>
	<TD class="mandatory"><spring:message code="cb.timerConfig.minute.label" text="Minute (0-59)"/>:</TD>
	<TD><form:input type="number" path="minute" size="5" min="0" max="59"/></TD>
	<TD>&nbsp;</TD>
</TR>

<TR>
	<TD class="mandatory"><spring:message code="cb.timerConfig.period.label" text="Period (minutes)"/>:</TD>
	<TD><form:input type="number" path="period" size="5" min="0" /></TD>
	<TD>&nbsp;</TD>
</TR>

<TR>
	<TD class="optional">
        <label for="runNow"><spring:message code="cb.timerConfig.startNow.label" text="Start Now"/>:</label></TD>
	<TD NOWRAP COLSPAN="2"><form:checkbox path="runNow" id="runNow"/>
        <span class="explanation"><spring:message code="cb.timerConfig.startNow.tooltip" text="(It might take a long time.)"/></span></TD>
</TR>

</TABLE>
</form:form>