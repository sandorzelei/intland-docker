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
<meta name="moduleCSSClass" content="newskin sysadminModule" />

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import="com.intland.codebeamer.servlet.build.BackgroundBuildTimerTask"%>
<%@ page import="com.intland.codebeamer.inbox.BackgroundInboxTimerTask"%>
<%@ page import="java.util.List"%>

<%@ page import="com.intland.codebeamer.persistence.dao.impl.InboxDaoImpl"%>
<%@ page import="com.intland.codebeamer.persistence.dao.impl.ProjectDaoImpl"%>
<%@ page import="com.intland.codebeamer.persistence.dao.impl.UserDaoImpl"%>
<%@ page import="com.intland.codebeamer.persistence.dao.impl.ArtifactDaoImpl"%>
<%@ page import="com.intland.codebeamer.persistence.dao.impl.ScmRepositoryDaoImpl"%>
<%@ page import="com.intland.codebeamer.security.acl.SessionListener"%>
<%@ page import="com.intland.codebeamer.Config"%>
<%@ page import="com.intland.codebeamer.persistence.rdbms.DatabaseProviderFactory"%>

<%
	pageContext.setAttribute("users", Integer.valueOf(UserDaoImpl.getInstance().getUserCount()));
	pageContext.setAttribute("loggedInUsers", Integer.valueOf(SessionListener.getUserCount(null)));
	pageContext.setAttribute("projects", Integer.valueOf(ProjectDaoImpl.getInstance().getProjectCount()));
	pageContext.setAttribute("managedRepositories",
			Integer.valueOf(ScmRepositoryDaoImpl.getInstance().getManagedCount(null, true)));
	pageContext.setAttribute("documents",
			Integer.valueOf(ArtifactDaoImpl.getInstance().findCountAllNonRemovedFiles(null)));

	List<?> inboxes = InboxDaoImpl.getInstance().findAllEnabled();
	pageContext.setAttribute("inboxes", Integer.valueOf(inboxes.size()));
	pageContext.setAttribute("startBuildDate",
			BackgroundBuildTimerTask.getNextScheduledNightlyBuildExecutionTime(request));
	pageContext.setAttribute("startInboxDate",
			BackgroundInboxTimerTask.getNextScheduledInboxExecutionTime(request));
	pageContext.setAttribute("cluster", Config.getClusterConfig());
%>

<ui:actionMenuBar showGlobalMessages="true">
	<ui:pageTitle>
		<spring:message code="sysadmin.label" text="System Administration" />
	</ui:pageTitle>
</ui:actionMenuBar>

<c:set var="errorCodes" value="<%=DatabaseProviderFactory.getProvider().checkMissingAdditionalDatabaseComponents(false)%>" />
<c:if test="${errorCodes != null}">
	<c:forEach items="${errorCodes}" var="code">
		<div class="error">
			<spring:message code="${code}" />
		</div>
	</c:forEach>
</c:if>

<style type="text/css">
<!--
.tools-list ul {
	list-style-image: url(<c:url value="/images/r_arrow.gif"/>);
}

.tools-list li {
	margin-bottom: 12px;
}
-->
</style>

<ul class="tools-list">
	<li>
        <a href="<c:url value='/sysadmin/users.spr'/>" >
			<spring:message code="sysadmin.users.label" text="User Accounts ({0})" arguments="${users}" />
        </a>
		&nbsp;
		<spring:message var="loggedInUsersTitle" code="sysadmin.users.loggedIn.tooltip" text="List logged in user accounts" />
		(
        <a class="loggedinuser" title="${loggedInUsersTitle}" href="<c:url value='/sysadmin/loggedinUsers.spr'/>">
			<spring:message code="sysadmin.users.loggedIn.label" text="Logged in {0}" arguments="${loggedInUsers}" />
        </a>
		)

		<span class="explanation">
			<spring:message code="sysadmin.users.tooltip" text="-- add, import, configure or disable user accounts." />
		</span>
	</li>

	<c:if test="${licenseCode.enabled.userGroups}">
		<li>
            <a href="<c:url value='/sysadmin/userGroups.spr'/>">
				<spring:message code="sysadmin.userGroups.label" text="User Groups" />
            </a>
			<span class="explanation">
				<spring:message code="sysadmin.userGroups.tooltip" text="-- manage user groups." />
			</span>
		</li>
	</c:if>

	<li>
        <a href="<c:url value='/sysadmin/configConfiguration.spr'/>">
			<spring:message code="sysadmin.configuration" text="Application Configuration"></spring:message>
        </a>
		<span class="explanation">
			<spring:message code="sysadmin.configuration.tooltip" text="--" />
		</span>
	</li>

	<li>
        <a href="<c:url value='/sysadmin/projectsList.spr'/>">
			<spring:message code="sysadmin.projects.label" text="Projects ({0})" arguments="${projects}" />
		</a>
		<span class="explanation">
			<spring:message code="sysadmin.projects.tooltip" text="-- view the list of all existing projects." />
		</span>
	</li>

	<li>
        <a href="<c:url value='/sysadmin/remoteSystemConnections.spr'/>">
			<spring:message code="sysadmin.remoteSystemConnections.label" text="External/Remote connections" />
        </a>
		<span class="explanation">
			<spring:message code="sysadmin.remoteSystemConnections.tooltip" text="-- show projects and trackers, that are connected to external/remote systems." />
		</span>
	</li>

	<c:if test="${licenseCode.enabled.scm}">

		<c:url var="click_url" value="/sysadmin/resetManagedRepositoryAccess.spr" />

		<li>
			<script language="javascript">
                function resetManagedRepositorySecurity() {
                    if (confirm(i18n.message("sysadmin.managedRepositories.confirm"))) {
                        launch_url('${click_url}');
                    }
                    return false;
                }
            </script>

            <a href="${click_url}" onclick="return resetManagedRepositorySecurity();">
				<spring:message code="sysadmin.managedRepositories.label" text="Reset Access Control of all Managed Repositories ({0})" arguments="${managedRepositories}" />
			</a>
			<span class="explanation">
				<spring:message code="sysadmin.managedRepositories.tooltip" text="-- reset the SCM access control based on the current security settings in {0}." arguments="${licenseCode.type}" />
			</span>
		</li>
		<li>
            <a href="<c:url value='/sysadmin/setMRAccessUrl.spr'/>" >
				<spring:message code="sysadmin.setMRAccessUrl.label" text="Set Managed Repository Access URLs" />
			</a>
			<span class="explanation">
				<spring:message code="sysadmin.setMRAccessUrl.tooltip" text="-- configure managed repository base URL for different SCM types." />
			</span>
		</li>
	</c:if>

	<c:if test="${licenseCode.enabled.documents}">
		<li>
			<a href="<c:url value='/sysadmin/documentsSummary.do'/>">
				<spring:message code="sysadmin.documents.label" text="Documents ({0})" arguments="${documents}" />
			</a>
			<span class="explanation">
				<spring:message code="sysadmin.documents.tooltip" text="-- view document and directory counts and sizes by each project." />
			</span>
		</li>
	</c:if>

	<li>
        <a href="<c:url value='/sysadmin/indexing.spr'/>">
			<spring:message code="sysadmin.indexing.label" text="Indexing" />
        </a>
		<span class="explanation">
			<spring:message code="sysadmin.indexing.tooltip" text="-- re-index {0} artifacts." arguments="${licenseCode.type}" />
		</span>
	</li>

	<li>
        <a href="<c:url value='/sysadmin/languages.spr'/>">
			<spring:message code="sysadmin.languages.label" text="Languages" />
        </a>
		<span class="explanation">
			<spring:message code="sysadmin.languages.tooltip" text="-- configure available languages." />
		</span>
	</li>

	<li>
        <a href="<c:url value='/sysadmin/configWelcomeText.spr'/>">
			<spring:message code="sysadmin.loginWelcomeText.label" text="Login and Welcome Text" />
        </a>
		<span class="explanation">
			<spring:message code="sysadmin.loginWelcomeText.tooltip" text="-- customize the login and welcome texts." />
		</span>
	</li>

	<li>
		<a href="<c:url value='/sysadmin/serviceDeskConfiguration.spr'/>">
			<spring:message code="sysadmin.serviceDesk.config.label" text="Service Desk Configuration" />
        </a>
		<span class="explanation">
			<spring:message code="sysadmin.serviceDesk.config.tooltip" text="-- allows to configure some details of the service desk" />
		</span>
	</li>

	<c:if test="${licenseCode.enabled.escalation}">
		<li>
			<a href="<c:url value='/sysadmin/editCalendar.spr'/>">
				<spring:message code="sysadmin.calendar.label" text="System Calendar" />
            </a>
			<span class="explanation">
				<spring:message code="sysadmin.calendar.tooltip" text="-- configure the default system worktime calendar." />
			</span>
		</li>
	</c:if>

	<li>
		<a href="<c:url value='/sysadmin/misc.do'/>">
			<spring:message code="sysadmin.userRegistration.label" text="User Registration" />
		</a>
		<span class="explanation">
			<spring:message code="sysadmin.userRegistration.tooltip" text="-- configure the user account registration process." />
		</span>
	</li>
	<li>
        <a href="<c:url value='/sysadmin/configLDAP.spr'/>">
			<spring:message code="sysadmin.userAuthentication.label" text="User Authentication" />
        </a>
		<span class="explanation">
			<spring:message code="sysadmin.userAuthentication.tooltip" text="-- configure user authentication via LDAP/Active Directory." />
		</span>
	</li>

	<c:if test="${licenseCode.enabled.customLicense}">
		<li>
			<a href="<c:url value='/sysadmin/configLicense.spr'/>">
				<spring:message code="sysadmin.license.label" text="License" />
			</a>
			<span class="explanation">
				<spring:message code="sysadmin.license.tooltip" text="-- enter your license code." />
			</span>
		</li>
	</c:if>

	<c:url var="sendMailLink" value="/sysadmin/sendEmail.spr" />
	<li>
        <a href="${sendMailLink}">
			<spring:message code="sysadmin.sendEmail.label" text="Send Email" />
		</a>
		<span class="explanation">
			<spring:message code="sysadmin.sendEmail.tooltip" text="-- send emails to all or to the currently logged-in users." />
		</span>
	</li>

	<li>
		<a href="<c:url value='/sysadmin/configMail.spr'/>">
			<spring:message code="sysadmin.setupEmail.label" text="Outgoing Email Connection" />
		</a>
		<span class="explanation">
			<spring:message code="sysadmin.setupEmail.tooltip" text="-- configure the outgoing email connection (SMTP server) to be used by {0}." arguments="${licenseCode.type}" />
		</span>
	</li>

	<li>
		<a href="<c:url value='/sysadmin/configPeriodicalInbox.spr'/>">
			<spring:message code="sysadmin.inboxes.label" text="Email Inboxes and Polling ({0})" arguments="${inboxes}" />
        </a>
		<span class="explanation">
			<tag:formatDate var="nextScheduledDate" value="${startInboxDate}" />
			<spring:message code="sysadmin.inboxes.tooltip" text="-- configure Email Inboxes and polling frequency. (Next scheduled: {0})" arguments="${nextScheduledDate}" />
		</span>
	</li>

	<li>
		<a href="<c:url value='/sysadmin/configLogoAndSlogan.do'/>">
			<spring:message code="sysadmin.logoAndSlogan.label" text="GUI" />
		</a>
		<span class="explanation">
			<spring:message code="sysadmin.logoAndSlogan.tooltip" text="-- customize the logo and slogan in the header section." />
		</span>
	</li>

	<li>
		<a href="<c:url value='/sysadmin/configPeriodicalBuild.spr'/>">
			<spring:message code="sysadmin.buildTimer.label" text="Periodic Process Timer" />
		</a>
		<span class="explanation">
			<tag:formatDate var="nextScheduledDate" value="${startBuildDate}" />
			<spring:message code="sysadmin.buildTimer.tooltip" text="- modify the periodical task invocation time. (Next scheduled: {0})" arguments="${nextScheduledDate}" />
		</span>
	</li>

	<li>
		<a href="<c:url value='/sysadmin/isql.spr'/>">
			<spring:message code="sysadmin.isql.label" text="iSql" />
		</a>
		<span class="explanation">
			<spring:message code="sysadmin.isql.tooltip" text="-- enter SQL queries or statements via the built-in Interactive SQL console." />
		</span>
	</li>

	<li>
		<a href="<c:url value='/sysadmin/logging.spr'/>">
			<spring:message code="sysadmin.logging.label" text="Logging Configuration" />
		</a>
		<span class="explanation">
			<spring:message code="sysadmin.logging.tooltip" text="-- change logging configuration temporarily without restarting the server." />
		</span>
	</li>

	<li>
		<a href="<c:url value='/sysadmin/systemDashboard.spr'/>">
			<spring:message code="sysadmin.state" text="System State" />
		</a>
		<span class="explanation">
			<spring:message code="sysadmin.state.tooltip" text="-- check the current system state (memory usage or disk usage), export the log." />
		</span>
	</li>

	<li>
		<a href="<c:url value='/sysadmin/jobManager.spr'/>">
			<spring:message code="sysadmin.job.manager.label" text="Job Manager" />
		</a>
		<span class="explanation">
			<spring:message code="sysadmin.job.manager.tooltip" text="--" />
		</span>
	</li>

	<li>
		<a href="<c:url value='/sysadmin/slackIntegrationConfiguration.spr'/>">
			<spring:message code="sysadmin.slackIntegration.label" text="Slack integration settings"></spring:message>
		</a>
		<span class="explanation">
			<spring:message code="sysadmin.slackIntegration.tooltip" text="--"></spring:message>
		</span>
	</li>

	<li>
		<a href="<c:url value='/audit/entries.spr'/>">
			<spring:message code="sysadmin.audit" text="Audit"></spring:message>
        </a>
		<span class="explanation">
			<spring:message code="sysadmin.audit.tooltip" text="--"></spring:message>
		</span>
	</li>
	
	<c:if test="${cluster.testingEnabled}">
		<li>
			<a href="<c:url value='/sysadmin/clusterTesting.spr'/>">
				<spring:message code="sysadmin.cluster.testing" text="Test cluster configuration"></spring:message>
			</a>
		</li>
	</c:if>
	
</ul>
