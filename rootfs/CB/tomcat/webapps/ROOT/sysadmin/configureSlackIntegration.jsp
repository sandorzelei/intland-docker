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

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<script type="text/javascript">
jQuery(function($) {
	var labelColumn = $("#notificationChannelsSelectorLabelColumn");
	$("#notificationsEnabled").on('click', function() {
		if (this.checked) {
			labelColumn.removeClass("optional");
			labelColumn.addClass("mandatory");
		} else {
			labelColumn.removeClass("mandatory");
			labelColumn.addClass("optional");
		}
	});

	if ($("#notificationsEnabled").attr('checked')) {
		labelColumn.removeClass("optional");
		labelColumn.addClass("mandatory");
	}

	$("#notificationChannelsSelector").multiselect();
});
</script>

<style class="text/css">
table.formTableWithSpacing {
	width: 50%
}
table.formTableWithSpacing > tbody > tr > td.data {
	width: 50%;
}
table.formTableWithSpacing > tbody > tr > td.data > input {
	width: 90%;
}
.readonlyFormInput {
	background-color: rgb(235, 235, 228);
}
</style>

<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="sysadmin.slackIntegration.label" text="Slack integration configuration" />
	</ui:pageTitle>
</ui:actionMenuBar>

<form:form action="saveSlackConfig.spr" modelAttribute="config" method="post">
	<spring:message var="saveButton" code="button.save" text="Save"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<c:url var="cancelUrl" value="/sysadmin.do" />

	<ui:actionBar>
		<input type="submit" value="${saveButton}" class="button" name="save" />
		<input type="button" class="cancelButton button" onclick="window.location.href='${cancelUrl}'" value="${cancelButton}" />
	</ui:actionBar>

	<span class="error" style="display: none;"></span>
	<span class="notification" style="display: none;"></span>

	<div class="contentWithMargins">
		<table class="formTableWithSpacing">
			<tr>
				<td class="optional">
				</td>
				<td class="data">
					<label for="slackIntegrationEnabledCheckbox">
						<form:checkbox id="slackIntegrationEnabledChecbox" path="enabled" />
						<spring:message code="sysadmin.slackIntegration.enable.label" text="Slack integration enabled"/>
					</label>
					<br/>
					<form:errors path="enabled" class="invalidfield"/>
				</td>
			</tr>
			<tr>
				<td class="mandatory">
					<label for="botTokenInput">
						<spring:message code="sysadmin.slackIntegration.botToken.label" text="Enter slack app bot's token"/>:
					</label>
				</td>
				<td class="data">
					<form:input id="botTokenInput" path="botOauthToken" />
					<br/>
					<form:errors path="botOauthToken" class="invalidfield"/>
				</td>
				<td>
					<spring:message code="sysadmin.slackIntegration.botToken.validate" text="Validate token" var="validateButtonLabel"/>
					<input type="submit" value="${validateButtonLabel}" class="button" name="validateToken"/>
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td colspan="2">
					<div class="hint">
						<spring:message code="sysadmin.slackIntegration.botToken.validate.hint" text="After entering the bot token, click on this button to validate it and the read only inputs will be filled out automatically if the token is valid."/>
					</div>
				</td>
			</tr>
			<tr>
				<td class="mandatory">
					<label for="teamUrlInput">
						<spring:message code="sysadmin.slackIntegration.teamUrl.label" text="Team URL (slack workspace URL)"/>:
					</label>
				</td>
				<td class="data">
					<form:input id="teamUrlInput" path="slackWorkspaceUrl" readonly="true" cssClass="readonlyFormInput" />
					<br/>
					<form:errors path="slackWorkspaceUrl" class="invalidfield"/>
				</td>
			</tr>
			<tr>
				<td class="mandatory">
					<label for="teamIdInput">
						<spring:message code="sysadmin.slackIntegration.teamId.label" text="Team ID (slack workspace ID)"/>:
					</label>
				</td>
				<td class="data">
					<form:input id="teamIdInput" path="teamId" readonly="true" cssClass="readonlyFormInput" />
					<br/>
					<form:errors path="teamId" class="invalidfield"/>
				</td>
			</tr>
			<tr>
				<td class="mandatory">
					<label for="teamNameInput">
						<spring:message code="sysadmin.slackIntegration.teamName.label" text="Team name (slack workspace name)"/>:
					</label>
				</td>
				<td class="data">
					<form:input id="teamNameInput" path="slackWorkspaceName" readonly="true" cssClass="readonlyFormInput" />
					<br/>
					<form:errors path="slackWorkspaceName" class="invalidfield"/>
				</td>
			</tr>
			<tr>
				<td class="mandatory">
					<label for="clientIdInput">
						<spring:message code="sysadmin.slackIntegration.clientId.label" text="Client ID"/>:
					</label>
				</td>
				<td class="data">
					<form:input id="clientIdInput" path="clientId" />
					<br/>
					<form:errors path="clientId" class="invalidfield"/>
				</td>
			</tr>
			<tr>
				<td class="mandatory">
					<label for="clientSecretInput">
						<spring:message code="sysadmin.slackIntegration.clientSecret.label" text="Client secret"/>:
					</label>
				</td>
				<td class="data">
					<form:input id="clientSecretInput" path="clientSecret" />
					<br/>
					<form:errors path="clientSecret" class="invalidfield"/>
				</td>
			</tr>
			<tr>
				<td class="mandatory">
					<label for="verificationTokenInput">
						<spring:message code="sysadmin.slackIntegration.verificationToken.label" text="Verification token"/>:
					</label>
				</td>
				<td class="data">
					<form:input id="verificationTokenInput" path="verificationToken" />
					<br/>
					<form:errors path="verificationToken" class="invalidfield"/>
				</td>
			</tr>
			<tr>
				<td class="optional">
				</td>
				<td class="data">
					<label for="notificationsEnabled">
						<form:checkbox id="notificationsEnabled" path="notificationsEnabled" disabled="${not empty channelError}"/>
						<spring:message code="sysadmin.slackIntegration.notificationsEnabled.label" text="Notifications enabled"/>
					</label>
					<c:if test="${not empty channelError}">
						<br/>
						<span class="invalidfield">
							<spring:message code="${channelError}"></spring:message>
						</span>
					</c:if>
				</td>
			</tr>
		</table>
	</div>
</form:form>