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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ taglib uri="uitaglib" prefix="ui" %>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="sysadmin.logging.title" text="Change Logging Configuration" /></ui:pageTitle>
</ui:actionMenuBar>

<form:form>

<style type="text/css">
	#logLevelChanges {
		border: 1px solid silver;
		margin-bottom: 20px;
		width: 70%;
	}
    #logLevelChanges tbody th {
        padding-top: 12px;
    }
	#logLevelChanges td {
		border-right: solid 1px silver;
	}
    #logLevelChanges tr.odd, #logLevelChanges tr.even {
        border-top: 0;
    }
	.explanation.information {
		display: inline-block;
		margin-top: 20px;
	}
</style>

<ui:actionBar>
	<spring:message code="sysadmin.logging.hint" text="Enter logging configuration changes and" />
	&nbsp;&nbsp;
	<spring:message var="applyButton" code="sysadmin.logging.apply" text="Apply" />
	<input type="submit" class="button" name="submit" value="${applyButton}"/>
	<c:url var="cancelUrl" value="/sysadmin.do"/>
	<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
	<input type="button" class="button cancelButton" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>
</ui:actionBar>

<div class="contentWithMargins">
<c:if test="${! empty param.submit}">
	<c:if test="${! empty loggingChanges}">
		<p><b><spring:message code="sysadmin.logging.changes" text="Following log levels has been changed"/>:</b></p>
		<table class="displaytag" id="logLevelChanges">
			<tr>
				<th><spring:message code="sysadmin.logging.logger" text="Logger"/></th>
				<th style="text-align: center;"><spring:message code="sysadmin.logging.oldLevel" text="Old level"/></th>
				<th style="text-align: center;"><spring:message code="sysadmin.logging.newLevel" text="New level"/></th>
			</tr>
			<c:forEach var="change" items="${loggingChanges}" varStatus="status">
				<tr class="${(status.count % 2 == 0) ? 'even' : 'odd'}">
					<td style="padding-left: 5px;">${change.logger.name}</td><td align="center"><c:out value="${change.oldLevel}" default="--" /></td><td align="center"><c:out value="${change.newLevel}" default="--"/></td>
				</tr>
			</c:forEach>
		</table>
	</c:if>
	<c:if test="${empty loggingChanges}">
		<p><b><spring:message code="sysadmin.logging.unchanged" text="No changes made in log levels by the last submit."/></b></p>
	</c:if>
</c:if>

<table border="0" width="100%" cellpadding="2" class="formTableWithSpacing">

<tr>
	<TD class="optional"><spring:message code="sysadmin.logging.command" text="Logging changes"/>:</TD>
	<td class="expandTextArea"><form:textarea path="log4jchanges" rows="10" cols="120" /></td>
</tr>

</table>

<div class="explanation information">
	<spring:message code="sysadmin.logging.example"/>
</div>

</div>

</form:form>
