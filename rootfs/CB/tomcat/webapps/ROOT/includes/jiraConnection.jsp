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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<script type="text/javascript" src="<ui:urlversioned value='/includes/jiraConnection.js'/>"></script>
<script type="text/javascript">
	var jiraSync = {
		label  : '<spring:message code="project.job.Jira Sync.label"   text="Update from Atlassian Jira" javaScriptEscape="true"/>',
		title  : '<spring:message code="project.job.Jira Sync.tooltip" text="Update the project from the remote Atlassian Jira project, where it was originally cloned from." javaScriptEscape="true"/>',
		helpURL: 'https://codebeamer.com/cb/wiki/680423',

		minIntervalMillis	: 120000,

		config : {
			serverLabel   	: '<spring:message code="remote.connection.server.label"      text="Server" javaScriptEscape="true"/>',
			serverTitle   	: '<spring:message code="remote.connection.server.tooltip"    text="The URL (web address) of the remote server/host" javaScriptEscape="true"/>',
			serverRequired	: '<spring:message code="remote.connection.server.required"   text="Please enter the URL (web address) of the remote server/host" javaScriptEscape="true"/>',

			usernameLabel 	: '<spring:message code="remote.connection.username.label"    text="Username" javaScriptEscape="true"/>',
			usernameTitle	: '<spring:message code="remote.connection.username.tooltip"  javaScriptEscape="true"/>',
			usernameRequired: '<spring:message code="remote.connection.username.required" javaScriptEscape="true"/>',

			passwordLabel	: '<spring:message code="remote.connection.password.label"    text="Password" javaScriptEscape="true"/>',
			passwordTitle	: '<spring:message code="remote.connection.password.tooltip"  text="The password to authenticate at the remote server/host. Can be ommitted, if the remote server allows anonymous access." javaScriptEscape="true"/>',

			projectLabel	: '<spring:message code="project.creation.kind.jira.project.label" text="Project" javaScriptEscape="true"/>',
			projectTitle	: '<spring:message code="project.creation.kind.jira.project.tooltip" text="Please select the Atlassian Jira project to import" javaScriptEscape="true"/>',
			projectReload   : '<spring:message code="project.creation.kind.jira.project.reload.tooltip" text="Click here, to reload the list of available projects from the specified Atlassian Jira server" javaScriptEscape="true"/>',
			projectURL		: '<c:url value="/ajax/jira/projects.spr"/>',
			refreshImage	: '<c:url value="/images/refreshtopic.gif"/>',
			syncLabel		: '<spring:message code="project.creation.kind.jira.synchronize.label" text="Synchronize" javaScriptEscape="true"/>',
			syncTitle		: '<spring:message code="project.creation.kind.jira.synchronize.tooltip" text="How should the local CodeBeamer project be synchronized with the remote Atlassian Jira project, where it was originally cloned from ?" javaScriptEscape="true"/>',
			syncMode		: [{
				value  : 'one-way',
				label  : '<spring:message code="project.creation.kind.jira.synchronize.one-way.label" text="One-way" javaScriptEscape="true"/>',
				title  : '<spring:message code="project.creation.kind.jira.synchronize.one-way.tooltip" text="Update the project from the remote Atlassian Jira project, where it was originally cloned from" javaScriptEscape="true"/>'
			}, {
				value  : 'bidirect',
				label  : '<spring:message code="project.creation.kind.jira.synchronize.bidirect.label" text="Bi-directional" javaScriptEscape="true"/>',
				title  : '<spring:message code="project.creation.kind.jira.synchronize.bidirect.tooltip" text="Synchronize changes between the local CodeBeamer project and the remote Atlassian Jira project in both directions" javaScriptEscape="true"/>'
			}]
		},

		dialog : {
			title	        : '<spring:message code="project.creation.kind.jira.server.title" text="Jira Server Connection" javaScriptEscape="true"/>',
			submitText		: '<spring:message code="button.save"     text="Save" javaScriptEscape="true"/>',
			cancelText		: '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>',
			validateURL		: '<c:url value="/ajax/jira/connection.spr"/>'
		},

		edit : function(popup, job, connection, callback) {
			popup.showJiraConnectionDialog(job, connection, jiraSync.config, jiraSync.dialog, callback);
		}
	};
</script>

