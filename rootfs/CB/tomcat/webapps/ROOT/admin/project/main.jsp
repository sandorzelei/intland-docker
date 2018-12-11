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
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<style type="text/css">
	#project-admin {
		padding-top: 15px !important;
		padding-left: 15px !important;
	}
	.ditch-tab-pane-wrap {
		margin-right: 15px;
	}
	#project-calendar, #project-trackers-config-defaults {
		margin-left: 0px;
		margin-right: 0px;
	}
	.actionBar {
		padding: 5px 15px !important;
	}
</style>

<%@page import="com.intland.codebeamer.persistence.dto.ProjectDto"%>
<%@page import="com.intland.codebeamer.controller.ControllerUtils"%>

<meta name="decorator" content="main"/>
<meta name="module" content="admin"/>
<meta name="moduleCSSClass" content="newskin adminModule"/>

<ui:actionMenuBar showGlobalMessages="true">
	<span class="titlenormal">
		<ui:breadcrumbs showProjects="false" strongBody="true">
			<ui:pageTitle><spring:message code="project.administration.title" text="Administration"/></ui:pageTitle>
		</ui:breadcrumbs>
	</span>
</ui:actionMenuBar>

<tab:tabContainer id="project-admin" skin="cb-box">

	<!-- General Panel -->
	<spring:message var="projAdminGeneral" code="project.administration.general.title" text="General"/>
	<tab:tabPane id="project-admin-general" tabTitle="${projAdminGeneral}">
		<jsp:include page="general.jsp"/>
	</tab:tabPane>

	<%--  Project's scheduled jobs --%>
	<c:if test="${!(empty scheduledJobs or scheduledJobs == '{}')}">
		<spring:message var="projJobsTitle" code="project.jobs.label" text="Jobs"/>
		<tab:tabPane id="project-jobs" tabTitle="${projJobsTitle}">
			<jsp:include page="/includes/scheduledJobs.jsp">
				<jsp:param name="objectId" 			  value="${project.objectId}" />
				<jsp:param name="scheduledJobsPrefix" value="project" />
			</jsp:include>
		</tab:tabPane>
	</c:if>

	<%--  Project's work-calendar config --%>
	<c:if test="${licenseCode.enabled.escalation}">
		<spring:message var="projCalendarTitle" code="project.administration.calendar.title" text="Calendar"/>
		<tab:tabPane id="project-calendar" tabTitle="${projCalendarTitle}">
			<c:url var="systemCalendarURL" value="/sysadmin/editCalendar.spr"/>

			<c:set var="editCalendarUrl" value="/proj/admin/editCalendar.spr?proj_id=${project.id}" />

			<c:set var="USE_IFRAME" value="true" />
			<c:choose>
				<c:when test="${USE_IFRAME}">
					<c:url var="iframe_url" value="${editCalendarUrl}" />
					<iframe style="width:100%; height: 600px; border:solid 0px silver;"
							src="${iframe_url}" frameborder="0"></iframe>
				</c:when>
				<c:otherwise>
					<jsp:include page="${editCalendarUrl}" flush="false"/>
				</c:otherwise>
			</c:choose>
		</tab:tabPane>
	</c:if>

	<%-- Disable approval workflows on Project Admin tab --%>
	<c:if test="${licenseCode.enabled.documentApproval}">
		<spring:message var="projApprovalWorkflow" code="project.administration.approvalWorkflow.title" text="Approval Workflows"/>
		<tab:tabPane id="project-admin-approvals" tabTitle="${projApprovalWorkflow}">
			<jsp:include page="/showArtifactApprovals.spr" />
		</tab:tabPane>
	</c:if>

<%--
	<spring:message var="projectTrackerConfigDefaults" code="project.administration.tracker.config.defaults" text="Trackers"/>
	<tab:tabPane id="project-trackers-config-defaults" tabTitle="${projectTrackerConfigDefaults}">
		<c:url var="iframe_url" value="/proj/admin/trackersConfiguration.spr?proj_id=${project.id}" />
		<iframe style="width:100%; height: 600px; border:solid 0px silver;"
							src="${iframe_url}" frameborder="0"></iframe>
	</tab:tabPane>
--%>

</tab:tabContainer>

<%-- fixing page title, because Sitemesh picks up the last meta tag, which is from the --%>
<ui:pageTitle printBody="false"><spring:message code="project.administration.title" text="Administration"/></ui:pageTitle>
