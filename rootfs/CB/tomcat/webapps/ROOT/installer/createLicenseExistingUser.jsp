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

	<div class="info"><spring:message code="post.installer.license.existing.user.info" text="Please use your existing account info to log in at <a href=\"{0}\" target=\"_blank\">{0}</a>." arguments="<%= CBPaths.CB_API_URL %>"/></div>
	<div class="info"><spring:message code="post.installer.license.generate.license.info" text="To generate a new License Code for your 30-day evaluation copy or to keep using your current license, please leave the 'License Code' field below empty."/></div>
	<div class="info"><spring:message code="post.installer.license.connected.to.internet" text="Before proceeding, please make sure you are connected to the Internet."/></div>

	<c:if test="${not empty existingLicenseCode}">
		<input type="hidden" name="existingLicense" value="${fn:escapeXml(existingLicenseCode)}">
	</c:if>

	<form:form method="POST" modelAttribute="licenseUserForm">
		<input type="hidden" name="existing" value="true"/>
		<div class="form-fields">
			<div class="field"><label for="email"><spring:message code="post.installer.admin.userName.label" text="Username"/></label><form:input path="email" id="email" cssErrorClass="error"/></div>
			<div class="field"><label for="password"><spring:message code="post.installer.admin.password.label" text="Password"/></label><form:password path="password" id="password" cssErrorClass="error" autocomplete="off"/>
				<a href="https://codebeamer.com/cb/lostPassword.do" target="_blank"><spring:message code="post.installer.admin.forgot.password" text="Forgot password"/></a>
			</div>
			<div class="field"><label for="hostId"><spring:message code="post.installer.license.host.id.label" text="Host ID"/></label>${licenseUserForm.hostId}<form:hidden path="hostId" id="hostId" cssErrorClass="error"/></div>
			<div class="field"><label for="license"><spring:message code="post.installer.license.code.label" text="License Code"/><span><spring:message code="post.installer.license.info.label" text="Keep this field empty to generate a new code for your trial instance, or to keep using your current license."/></span></label><form:textarea id="license" path="license"/></div>
			<c:if test="${not empty existingLicenseCode}">
				<div class="field"><label></label><a id="loadExistingLicense" href="#"><spring:message code="post.installer.license.load.existing.label" text="Load existing license"/></a></div>
			</c:if>
		</div>

		<form:hidden path="releaseId"/>
		<jsp:include page="includes/footer.jsp?step=license&formName=licenseUserForm&nextButtonLabel=login&skipButton=true"/>
	</form:form>
</div>

<script type="text/javascript">
	$(function() {
		var skipAccepted = false;

		codebeamer.installer.initForm();

		$('input[name="ajax"]').click(function() {
			codebeamer.installer.submitExistingUserData($('form').first());
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