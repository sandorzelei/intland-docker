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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<style type="text/css">
	input[type="checkbox"], input[type="radio"] {
	    vertical-align: text-bottom;
	    margin: 0;
	}
</style>


<div class="form-container">
	<jsp:include page="includes/header.jsp?step=mail&stepIndex=6"/>

	<div class="info"><spring:message code="post.installer.mail.info" text="Please set up your outgoing mail server and test the connection. You can skip this step to configure the mail server later."/></div>

	<form:form method="POST" modelAttribute="smtpForm">
		<div class="form-fields">
			<div class="field"><label for="host"><spring:message code="post.installer.mail.host.label" text="Outgoing SMTP Mail Server"/></label><form:input path="host" id="host" cssErrorClass="error"/></div>
			<div class="field"><label for="user"><spring:message code="post.installer.admin.user.name.label" text="Username"/></label><form:input path="user" id="user" cssErrorClass="error"/></div>
			<div class="field"><label for="password"><spring:message code="post.installer.admin.password.label" text="Password"/></label><form:password path="password" id="password" cssErrorClass="error" autocomplete="off"/></div>
			<div class="field"><label for="ssl"><spring:message code="post.installer.mail.connection.label" text="Connection"/></label>
			<form:checkbox path="ssl" id="ssl" cssErrorClass="error"/>
			<label class="secondary" for="ssl"><spring:message code="post.installer.mail.secure.connection.label" text="Secure connection (SSL)"/></label>

			<form:checkbox path="startTls" id="startTls" cssErrorClass="error" cssStyle="margin-left:10px;"/>
			<label class="secondary" for="startTls"><spring:message code="post.installer.mail.starttls.label" text="Use StartTLS" /></label>
			</div>
			<div class="field"><label for="port"><spring:message code="post.installer.mail.port.label" text="Port"/></label><form:input path="port" id="port" cssErrorClass="error"/></div>
			<div class="field"><label for="from"><spring:message code="post.installer.mail.email.from.label" text="Email from"/></label><form:input path="from" id="from" cssErrorClass="error"/></div>
			<div class="field"><label for="testEmail"><spring:message code="post.installer.mail.test.email.label" text="Send test email to"/></label><form:input path="testEmail" id="testEmail" cssErrorClass="error"/></div>
			<spring:message code="post.installer.test.mail.server.label" text="Test Mail Server" var="testMailLabel"/>
			<input type="button" class="button field" name="test-connection" id="test-mail" value="${testMailLabel}" />
			<div class="separatorText"><spring:message code="post.installer.mail.references.label" text="References to the server in the mails"/></div>
			<div class="field"><label for="serverHost"><spring:message code="post.installer.mail.server.name.label" text="Server name"/></label><form:input path="serverHost" id="serverHost" cssErrorClass="error"/></div>
			<div class="field"><label for="serverScheme"><spring:message code="post.installer.mail.scheme.label" text="Scheme"/></label><form:input path="serverScheme" id="serverScheme" cssErrorClass="error"/></div>
			<div class="field"><label for="serverPort"><spring:message code="post.installer.mail.port.label" text="Port"/></label><form:input path="serverPort" id="serverPort" cssErrorClass="error"/></div>
		</div>
		<jsp:include page="includes/footer.jsp?step=mail&formName=smtpForm&skipButton=true"/>
	</form:form>
</div>

<script type="text/javascript">
	$(function() {
		var $form = $('form').first();
		$('#test-mail').click(function() {
			codebeamer.installer.testSmtp(contextPath, $form);
			return false;
		});
		$('input[name="_eventId_next"]').click(function() {
			return codebeamer.installer.validateSmtpForm($form);
		});
	});
</script>
