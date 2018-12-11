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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import="com.intland.codebeamer.servlet.CBPaths" %>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=license&stepIndex=2"/>

	<div class="notificationText" id="saveLicenseNotification"><spring:message code="post.installer.license.save.icense.notification" text="You can view and save your license key in the License field."/></div>

	<div class="info"><spring:message code="post.installer.license.new.user.info" text="Create your new account at <a href=\"{0}\" target=\"_blank\">{0}</a>." arguments="<%= CBPaths.CB_API_URL %>"/></div>
	<div class="info"><spring:message code="post.installer.license.generate.license.info" text="To generate a new License Code for a <b>Free 1-Project License</b> or to keep using your current license, please leave the field labelled 'License Code' empty."/></div>
	<div class="info"><spring:message code="post.installer.license.connected.to.internet" text="Before proceeding, please make sure you are connected to the Internet."/></div>

	<c:if test="${not empty existingLicenseCode}">
		<input type="hidden" name="existingLicense" value="${fn:escapeXml(existingLicenseCode)}">
	</c:if>

	<form:form method="POST" modelAttribute="licenseUserForm">
		<input type="hidden" name="existing" value="false"/>
		<form:hidden path="address" id="address" value=""/>
		<form:hidden path="city" id="city" value=""/>
		<form:hidden path="zip" id="zip" value=""/>
		<form:hidden path="country" id="country" value="--"/>
		<form:hidden path="releaseId"/>

		<div class="form-fields">
			<div class="field"><label for="email"><spring:message code="post.installer.admin.email.label" text="Email address"/></label><form:input path="email" id="email" cssErrorClass="error"/></div>
			<div class="field"><label for="firstName"><spring:message code="post.installer.admin.first.name.label" text="First name"/></label><form:input path="firstName" id="firstName" cssErrorClass="error"/></div>
			<div class="field"><label for="lastName"><spring:message code="post.installer.admin.last.name.label" text="Last name"/></label><form:input path="lastName" id="lastName" cssErrorClass="error"/></div>
			<div class="field"><label for="company"><spring:message code="post.installer.admin.company.label" text="Company"/></label><form:input path="company" id="company" cssErrorClass="error"/></div>
			<div class="field"><label for="phone"><spring:message code="post.installer.admin.phone.label" text="Phone Number*"/></label><form:input path="phone" id="phone" cssErrorClass="error"/></div>
			<div class="field"><label for="password"><spring:message code="post.installer.admin.password.label" text="Password"/></label><form:password path="password" id="password" cssErrorClass="error" autocomplete="off"/></div>
			<div class="field"><label for="confirmPassword"><spring:message code="post.installer.admin.confirm.password.label" text="Confirm password"/></label><form:password path="confirmPassword" id="confirmPassword" cssErrorClass="error" autocomplete="off"/></div>
			<div class="field"><label for="hostId"><spring:message code="post.installer.license.host.id.label" text="Host ID"/></label>${licenseUserForm.hostId}<form:hidden path="hostId" id="hostId" cssErrorClass="error"/></div>
			<div class="field"><label for="license"><spring:message code="post.installer.license.code.label" text="License Code"/><span><spring:message code="post.installer.license.info.label" text="Keep this field empty to generate a code for your new <b>Free 1-Project License</b>, or to keep using your current license."/></span></label><form:textarea id="license" path="license"/></div>
			<c:if test="${not empty existingLicenseCode}">
				<div class="field"><label></label><a id="loadExistingLicense" href="#"><spring:message code="post.installer.license.load.existing.label" text="Load existing license"/></a></div>
			</c:if>

			<style type="text/css">
				.consentCheckbox {
					vertical-align: middle;
					position: relative;
					bottom: 1px;
				}
			</style>
			<tr>
				<td colspan="2">
					<p style="margin-top: 20px; font-weight: bold;"><spring:message code="user.privacy.note" /></p>
					<p>
						<form:checkbox cssClass="consentCheckbox" path="marketingConsentAccepted" id="agree1" />
						<label for="agree1" ><spring:message code="user.privacy.agree1" /></label>
					</p>
					<p>
						<form:checkbox cssClass="consentCheckbox" path="salesConsentAccepted" id="agree2"/>
						<label for="agree2"><spring:message code="user.privacy.agree2" /></label>
					</p>
				</td>
			</tr>
		</div>
		<jsp:include page="includes/footer.jsp?step=license&formName=licenseUserForm&nextButtonLabel=register&skipButton=true"/>
	</form:form>
</div>

<script type="text/javascript">
	$(function() {

		var skipAccepted = false;

		codebeamer.installer.initForm();
		$('input[name="ajax"]').click(function() {
			codebeamer.installer.submitNewUserData($('form').first());
			return false;
		});

		$('input[name="_eventId_skip"]').click(function() {
			if (!skipAccepted){
				codebeamer.installer.displayLicenseSkipConfirmDialog(function(){
					skipAccepted = true;
					$('input[name="_eventId_skip"]').click();
				});
			}
			return skipAccepted;
		});
	});
</script>
