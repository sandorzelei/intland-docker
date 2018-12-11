<%@ page import="com.intland.codebeamer.Config" %><%--
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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="uitaglib" prefix="ui"%>

<meta name="decorator" content="main" />
<meta name="module" content="mystart" />
<meta name="moduleCSSClass" content="workspaceModule newskin" />

<head>
	<link rel="stylesheet" href="<ui:urlversioned value='/workspace/userdata.css' />" type="text/css" media="all" />
	<script src='https://www.google.com/recaptcha/api.js'></script>
</head>

<script type="text/javascript">
	$(document).ready(function() {
		codebeamer.prefill.prevent($("input[type=password]"), getBrowserType());
	});
</script>

<ui:actionMenuBar cssClass="accountHeadLine">
	<ui:pageTitle>
		<spring:message code="project.newMember.invite.email.activation" />
	</ui:pageTitle>
</ui:actionMenuBar>

	<form:form commandName="userActivationForm">

		<form:hidden path="activationCode" />

		<ui:actionBar>
			<c:if test="${empty showForm}">
				<spring:message var="submitButton" code="button.save" text="Save"/>
				<input type="submit" class="button" value="${submitButton}" />
			</c:if>
		</ui:actionBar>

		<c:if test="${empty showForm}">
		<TABLE id="userDataTable" WIDTH="90%" CELLPADDING="0">
			<tbody>
				<tr VALIGN="top">
					<td WIDTH="40%" class="block">

						<h4>
							<spring:message code="user.personalDetails.label" text="Personal Details"/>
						</h4>

						<table width="100%" border="0" cellpadding="0" class="formTableWithSpacing">
							<tr>
								<td class="mandatory">
									<spring:message code="user.name.label" text="Account Name" />:
								</td>
								<td class="data">
									<form:input path="user.name" size="60" maxlength="50" />
									<br />
									<form:errors path="user.name" cssClass="invalidfield" />
								</td>
							</tr>

							<tr>
								<td class="mandatory">
									<spring:message code="user.password.label" text="Password" />:
								</td>
								<td class="data">
									<ui:password path="user.password" size="60" maxlength="70" showPlaceholder="false" autocomplete="off" />
									<br />
									<form:errors path="user.password" cssClass="invalidfield" /></td>
							</tr>
							<tr>
								<td class="mandatory"><spring:message code="user.password.confirm" text="Confirm Password" />:</td>
								<td class="data">
									<ui:password path="password2" size="60" maxlength="70" showPlaceholder="false" autocomplete="off" />
									<br />
									<form:errors path="password2" cssClass="invalidfield" />
								</td>
							</tr>
							<tr>
								<td class="mandatory"><spring:message code="user.firstName.label" text="First Name" />:</td>
								<td class="data"><form:input path="user.firstName" size="60" maxlength="70" /><br /> <form:errors path="user.firstName"
										cssClass="invalidfield" /></td>
							</tr>
							<tr>
								<td class="mandatory"><spring:message code="user.lastName.label" text="Last Name" />:</td>
								<td class="data"><form:input path="user.lastName" size="60" maxlength="70" /><br /> <form:errors path="user.lastName"
										cssClass="invalidfield" /></td>
							</tr>

							<tr class="blockStart">
								<td class="mandatory" valign="top"><spring:message code="user.email.label" text="Email" />:</td>
								<td class="data">
									<spring:message var="emailTitle" code="email.multiple.tooltip" />
									<form:input path="user.email" size="60"	maxlength="250" title="${emailTitle}" readonly="true"/>
									<br />
									<form:errors path="user.email" cssClass="invalidfield" />
								</td>
							</tr>

							<tr>
								<td class="optional"><spring:message code="user.timeZonePattern.label" text="Time zone"/>:</td>
								<td class="data">
									<form:select path="user.timeZonePattern">
										<form:options items="${timeZoneOptions}" itemLabel="name" itemValue="value" />
									</form:select>
								</td>
							</tr>

							<tr>
								<td class="optional"><spring:message code="user.dateFormatPattern.label" text="Date Format"/>:</td>
								<td class="data">
									<form:select path="user.dateFormatPattern">
										<form:options items="${availableDateFormats}" itemLabel="name" itemValue="value" />
									</form:select>
								</td>
							</tr>
							<%
								pageContext.setAttribute("requiredPhone", Config.isPhoneMandatory());
							%>
							<c:if test="${requiredPhone}">
								<tr>
									<td class="mandatory"><spring:message code="user.phone.label" text="Phone"/>:</td>
									<td class="data">
										<form:input path="user.phone" /><br />
										<form:errors path="user.phone" cssClass="invalidfield" /></td>
								</tr>
							</c:if>
							<%
								pageContext.setAttribute("requiredCompany", Config.isCompanyMandatory());
							%>
							<c:if test="${requiredCompany}">
								<tr>
									<td class="mandatory"><spring:message code="user.company.label" text="Company"/>:</td>
									<td class="data">
										<form:input path="user.company" /><br />
										<form:errors path="user.company" cssClass="invalidfield" /></td>
								</tr>
							</c:if>
							<%
								pageContext.setAttribute("requiredPostalAddress", Config.isPostalAddressMandatory());
							%>
							<c:if test="${requiredPostalAddress}">
								<tr>
									<td class="<c:choose><c:when test="${requiredPostalAddress}">mandatory</c:when><c:otherwise>optional</c:otherwise></c:choose>">
										<spring:message code="user.address.label" text="Address"/>:
									</td>
									<td class="data">
										<form:input path="user.address" size="60" maxlength="70" /><br/><form:errors path="user.address" cssClass="invalidfield"/>
									</td>
								</tr>
								<tr>
									<td class="<c:choose><c:when test="${requiredPostalAddress}">mandatory</c:when><c:otherwise>optional</c:otherwise></c:choose>">
										<spring:message code="user.city.label" text="City"/>:
									</td>
									<td class="data">
										<form:input path="user.city" size="60" maxlength="70" /><br/><form:errors path="user.city" cssClass="invalidfield"/>
									</td>
								</tr>
								<tr>
									<td class="<c:choose><c:when test="${requiredPostalAddress}">mandatory</c:when><c:otherwise>optional</c:otherwise></c:choose>">
										<spring:message code="user.zip.label" text="Zip/Postal Code"/>:
									</td>
									<td class="data">
										<form:input path="user.zip" size="60" maxlength="15" /><br/><form:errors path="user.zip" cssClass="invalidfield"/>
									</td>
								</tr>
								<tr>
									<td class="optional"><spring:message code="user.state.label" text="State/Province"/>:</td>
									<td class="data">
										<form:input path="user.state" size="60" maxlength="50" /><br/><form:errors path="user.state" cssClass="invalidfield"/>
									</td>
								</tr>
								<tr>
									<td class="mandatory"><spring:message code="user.country.label" text="Country"/>:</td>
									<td class="data">
										<form:select path="user.country">
											<form:option value="" label="--"/>
											<form:options items="${countryOptions}" itemLabel="key" itemValue="value" />
										</form:select>
										<br/><form:errors path="user.country" cssClass="invalidfield"/>
									</td>
								</tr>
							</c:if>

						</table>
						<br />
						<table>
							<%
								pageContext.setAttribute("requiredCaptcha", Config.isCaptchaEnabled());
							%>

							<c:if test="${requiredCaptcha}">
								<tr class="blockStart" valign="top">
									<td class="mandatory" style="vertical-align: top;padding-top: 60px !important;">
										<spring:message code="user.captcha.label" text="Please write the letters into the text field"/>:
									</td>
									<td class="data">
										<div id="captcha_paragraph">
											<div class="g-recaptcha" data-sitekey="6LcH3EkUAAAAABznQLtL7YWgXwOHBLLxMKyMFn0T">
										</div>
										<form:errors path="captcha" cssClass="invalidfield"/>
									</td>
								</tr>
							</c:if>
						</table>
					</td>
					<td WIDTH="40%" class="block">
						<div class="block">${userGroupMemberShipTable}</div>
						<div class="block">${timeZoneAndDateFormatTable}</div>
					</td>
				</tr>
			</tbody>
		</TABLE>
		</c:if>
	</form:form>


