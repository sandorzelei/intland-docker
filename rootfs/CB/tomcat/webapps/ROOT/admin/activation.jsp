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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="license"/>
<meta name="moduleCSSClass" content="sysadminModule"/>

<ui:actionMenuBar cssClass="accountHeadLine">
		<ui:pageTitle><spring:message code="cb.welcome.title" text="Welcome to {0}" arguments="${product}"/></ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="activationForm">
	<spring:message var="activateButton" code="button.activate" text="Activate"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<spring:message var="abortMessage" code="cb.abort.shudown.message" text="Do you really want to abort and shutdown ?"/>

	<ui:actionBar>
		&nbsp;&nbsp;<input type="submit" class="button" value="${activateButton}" />
		&nbsp;&nbsp;<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" onclick="return confirm('${abortMessage}');"/>
	</ui:actionBar>

	<c:url var="registrationUrl" value="https://codebeamer.com/cb/registerProduct.spr">
		<c:param name="product" value="${product}"/>
		<c:param name="hostId"  value="${hostId}"/>
	</c:url>

	<table width="100%" border="0" cellpadding="0" class="formTableWithSpacing">
		<tr>
			<td class="mandatory" width="5%"><spring:message code="cb.enter.activate.key" text="Please enter your Activation Key"/>:</td>

			<td nowrap>
				<form:input path="activationKey" size="16" maxlength="16"/>
				<form:errors path="activationKey" cssClass="invalidfield"/>
			</td>
		</tr>
	</table>

	<div class="messagetext">
		<p>
			<spring:message code="cb.register.message" arguments="${registrationUrl}"/>
		</p>
	</div>

</form:form>


