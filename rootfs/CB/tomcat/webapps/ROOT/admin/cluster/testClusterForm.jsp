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
<meta name="decorator" content="main" />
<meta name="module" content="sysadmin" />
<meta name="moduleCSSClass" content="sysadminModule newskin" />

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="taglib" prefix="tag"%>

<spring:message var="saveButton" code="button.save" text="Save" />
<spring:message var="cancelButton" code="button.cancel" text="Cancel" />

<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="sysadmin.cluster.testing.label" text="Testing cluster configuration" />
	</ui:pageTitle>
</ui:actionMenuBar>

<fmt:formatDate value="${clusterTestingModel.lastCallAt}" pattern="${clusterTestingModel.dateTimeFormatPattern}" var="lastCallAt" />

<form:form autocomplete="off" commandName="clusterTestingCommand">

	<ui:actionBar>
		<input type="submit" class="button" value="${saveButton}" name="_save" />
		<input type="submit" class="button" value="${cancelButton}" name="_cancel" />
	</ui:actionBar>

	<table border="0" cellpadding="2" class="contentWithMargins formTableWithSpacing">
		<tbody>
			<tr>
				<td class="optional"><spring:message code="sysadmin.cluster.testing.status.label" /></td>
				<td><spring:message code="sysadmin.cluster.testing.status" arguments="${clusterTestingModel.serverMode},${lastCallAt}" /></td>
			</tr>
			<tr>
				<td class="optional"><spring:message code="sysadmin.cluster.testing.network.error" /></td>
				<td><form:checkbox path="networkError" /></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td>
					<span class="explanation">
						<spring:message code="sysadmin.cluster.testing.network.error.label" />
					</span>
				</td>
			</tr>
			<tr>
				<td class="optional"><spring:message code="sysadmin.cluster.testing.network.error.duration" /></td>
				<td><form:select path="duration" items="${clusterTestingModel.durationOptions}" /></td>
			</tr>
		</tbody>
	</table>

</form:form>
