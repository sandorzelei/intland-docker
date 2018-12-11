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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="uitaglib" prefix="ui"%>

<meta name="decorator" content="main" />
<meta name="module" content="mystart" />
<meta name="moduleCSSClass" content="workspaceModule newskin" />

<style type="text/css">
	.formTableWithSpacing {
		margin: 15px;
		margin-top: 0px;
		border: none;
	}
</style>

<script type="text/javascript">
	$(document).ready(function() {
		codebeamer.prefill.prevent($("input[type=password]"), getBrowserType());
	});
</script>

<c:if test="${empty showForm || showForm}">

	<ui:actionMenuBar cssClass="accountHeadLine">
		<ui:pageTitle>
			<spring:message code="password.reset.title" />
		</ui:pageTitle>
	</ui:actionMenuBar>

	<form:form commandName="resetPasswordForm">

		<form:hidden path="resetPasswordCode" />
		<form:hidden path="userEmail" />

		<ui:actionBar>
			<spring:message var="submitButton" code="password.reset.change" text="Change Password"/>
			<input type="submit" class="button" value="${submitButton}" />
		</ui:actionBar>

		<div class="information"><spring:message code="password.reset.enter" text="Please enter your new password!"/></div>

		<table>
			<tbody>
				<tr valign="top">
					<td class="block">

						<table class="formTableWithSpacing">

							<tr>
								<td class="mandatory">
									<spring:message code="user.password.label" text="Password" />:
								</td>
								<td class="data">
									<ui:password path="password" size="60" maxlength="70" showPlaceholder="false" autocomplete="off" />
									<br />
									<form:errors path="password" cssClass="invalidfield" /></td>
							</tr>
							<tr>
								<td class="mandatory"><spring:message code="user.password.confirm" text="Confirm Password" />:</td>
								<td class="data">
									<ui:password path="passwordAgain" size="60" maxlength="70" showPlaceholder="false" autocomplete="off" />
									<br />
									<form:errors path="passwordAgain" cssClass="invalidfield" />
								</td>
							</tr>

						</table>
					</td>
				</tr>
			</tbody>
		</table>
	</form:form>
</c:if>