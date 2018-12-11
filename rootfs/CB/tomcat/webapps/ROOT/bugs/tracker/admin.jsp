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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/choiceOptions.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/viewConfiguration.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/fieldAccessControl.css'/>" />

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect.less" />" type="text/css" media="all" />

<style type="text/css">

	a:hover {
		cursor:pointer;
	}

	.ditch-tab-skin-cb-box {
		margin: 15px 15px;
	}

	#tracker-customize-serviceDesk .ditch-tab-skin-cb-box {
		margin: 15px 0px;
	}

	td.overriddenFieldValue {
		border-right-width: 3px;
		border-right-style: solid;
		border-right-color: red;
	}

	#tracker-customize-serviceDesk-tab, tr.service-desk-row {
		background-color: #dcf5f2;
	}

	.trackerConfigTip {
		color: #aaa;
		margin-left: 1em;
		font-size: 11px;
	}

	.ui-dialog-buttonset .infoLink {
		display: inline-block;
		float: right;
		position: relative;
		top: 1em;
	}

	.ui-dialog-buttonset .infoLink a {
		display: block;
		min-height: 16px;
		font-weight: bold;
		padding-left: 20px;
		background: url("../../images/newskin/action/information-m.png") no-repeat;
	}

	.ui-dialog-buttonset .infoLink a:hover {
		text-decoration: underline;
	}

	.labelHintImg {
		padding: 0 0.3em;
		position: relative;
		top: 1px;
		cursor: pointer;
	}

	.refTypeWarning {
		display: block;
		white-space: normal;
	}

</style>

<script type="text/javascript" src="<ui:urlversioned value='/js/colorPicker.js'/>"></script>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/userInfoLink.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/choiceOptions.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/viewConfiguration.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldValueCombinations.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/referenceFieldConfiguration.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldMandatoryControl.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldDefaultValues.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldAccessControl.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldConfiguration.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/ajaxSubmitButton.js'/>"></script>

<bugs:branchStyle branch="${tracker }"/>

<ui:actionMenuBar showGlobalMessages="true">
	<jsp:body>
		<ui:breadcrumbs showProjects="false"><span class="breadcrumbs-separator">&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="tracker.customize.title" text="Customization"/></ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<c:if test="${not empty baseline}">
	<ui:baselineInfoBar projectId="${tracker.project.id}" baselineName="${baseline.name}" baselineParamName="revision" cssStyle="margin-bottom: 10px;" />
</c:if>

<c:if test="${not empty branch}">
	<ui:branchInfoBar branch="${branch}" masterUrlLink="${branchMasterUrlLink}"/>
</c:if>

<tab:tabContainer id="tracker-customize" skin="cb-box">

	<!-- General Panel -->
	<spring:message var="generalTitle" code="tracker.settings.title" text="General"/>
	<tab:tabPane id="tracker-customize-general" tabTitle="${generalTitle}">
		<jsp:include page="addUpdDelTracker.jsp"/>
	</tab:tabPane>

	<!-- Permissions -->
	<spring:message var="permissionsTitle" code="tracker.permissions.title" text="Permissions"/>
	<tab:tabPane id="tracker-customize-permissions" tabTitle="${permissionsTitle}">
		<c:if test="${linkedLayout}">
			<jsp:include page="./includes/linkToLinkedLayoutTracker.jsp">
				<jsp:param name="tracker_id" value="${tracker.templateId}"/>
				<jsp:param name="revision" value="${baseline != null ? baseline.id : ''}"/>
				<jsp:param name="orgDitchnetTabPaneId" value="tracker-customize-permissions"/>
				<jsp:param name="title" value="${permissionsTitle}" />
				<jsp:param name="negativeMargin" value="false" />
			</jsp:include>
		</c:if>

		<jsp:include page="adminPermissions.jsp"/>
	</tab:tabPane>

	<!-- Transitions -->
	<c:if test="${tracker.usingWorkflow}">
		<spring:message var="transitionsTitle" code="tracker.transitions.title" text="State transitions"/>
		<tab:tabPane id="tracker-customize-transitions" tabTitle="${transitionsTitle}">
			<c:if test="${linkedLayout}">
				<jsp:include page="./includes/linkToLinkedLayoutTracker.jsp">
					<jsp:param name="tracker_id" value="${tracker.templateId}"/>
					<jsp:param name="revision" value="${baseline != null ? baseline.id : ''}"/>
					<jsp:param name="orgDitchnetTabPaneId" value="tracker-customize-transitions"/>
					<jsp:param name="title" value="${transitionsTitle}" />
					<jsp:param name="negativeMargin" value="true" />
				</jsp:include>
			</c:if>

			<jsp:include page="adminTransitions.jsp"/>
		</tab:tabPane>
	</c:if>

	<!-- Field Properties -->
	<spring:message var="fieldPropertiesTitle" code="tracker.fieldProps.title" text="Field Properties"/>
	<tab:tabPane id="tracker-customize-field-properties" tabTitle="${fieldPropertiesTitle}">
		<c:if test="${linkedLayout}">
			<jsp:include page="./includes/linkToLinkedLayoutTracker.jsp">
				<jsp:param name="tracker_id" value="${tracker.templateId}"/>
				<jsp:param name="revision" value="${baseline != null ? baseline.id : ''}"/>
				<jsp:param name="orgDitchnetTabPaneId" value="tracker-customize-field-properties"/>
				<jsp:param name="title" value="${fieldPropertiesTitle}" />
				<jsp:param name="negativeMargin" value="true" />
			</jsp:include>
		</c:if>

		<jsp:include page="adminFieldConfig.jsp"/>
	</tab:tabPane>

	<!-- Escalation -->
	<c:if test="${canAdminTracker and tracker.issueTypeId < 900}">
		<spring:message var="escalationTitle" code="tracker.escalation.title" text="Escalation"/>
		<tab:tabPane id="tracker-customize-escalation" tabTitle="${escalationTitle}">
			<c:choose>
				<c:when test="${licenseCode.enabled.escalation}">
					<c:if test="${linkedLayout}">
						<jsp:include page="./includes/linkToLinkedLayoutTracker.jsp">
							<jsp:param name="tracker_id" value="${tracker.templateId}"/>
							<jsp:param name="orgDitchnetTabPaneId" value="tracker-customize-escalation"/>
							<jsp:param name="title" value="${escalationTitle}" />
							<jsp:param name="negativeMargin" value="false" />
						</jsp:include>
					</c:if>

					<jsp:include page="adminEscalation.jsp"/>
				</c:when>
				<c:otherwise>
					<div class="warning">
						<spring:message code="tracker.escalation.no.license.warning" text="You cannot use this feature because you don't have the necessary license. To read more about this feature visit our <a href='https://codebeamer.com/cb/wiki/85612'>Knowledge base</a>."/>
					</div>
				</c:otherwise>
			</c:choose>
		</tab:tabPane>
	</c:if>

	<!-- Notification -->
	<c:if test="${!isAnonymousUser && (canSubscribeOthers || canViewSubscribers) && !empty notificationConfigJSON}">
		<spring:message var="notificationsTitle" code="tracker.notifications.title" text="Notification"/>
		<tab:tabPane id="tracker-customize-notification" tabTitle="${notificationsTitle}">
			<c:if test="${linkedLayout}">
				<jsp:include page="./includes/linkToLinkedLayoutTracker.jsp">
					<jsp:param name="tracker_id" value="${tracker.templateId}"/>
					<jsp:param name="orgDitchnetTabPaneId" value="tracker-customize-notification"/>
					<jsp:param name="title" value="${notificationsTitle}" />
					<jsp:param name="negativeMargin" value="true" />
				</jsp:include>
			</c:if>

			<jsp:include page="adminSubscriptions.jsp"/>
		</tab:tabPane>
	</c:if>

	<c:if test="${isRiskTracker}">
		<spring:message var="riskMatrixTitle" code="tracker.riskManagement.config.label" text="Risk management"/>
		<tab:tabPane id="tracker-customize-riskMatrix" tabTitle="${riskMatrixTitle}">
			<jsp:include page="riskMatrixConfig.jsp"/>
		</tab:tabPane>
	</c:if>

    <spring:message var="historyTitle" code="tracker.configuration.history.tab.title" text="Audit Trail"/>
    <tab:tabPane id="tracker-customize-history" tabTitle="${historyTitle}">
        <jsp:include page="../../wikispace/trackerconfigurationhistory/tracker-configuration-history.jsp">
            <jsp:param name="isTrackerConfigurationPage" value="true"/>
        </jsp:include>
    </tab:tabPane>

	<c:if test="${serviceDeskEnabled}">
		<spring:message var="serviceDeskTitle" code="tracker.serviceDesk.title" text="Service Desk"/>
		<tab:tabPane id="tracker-customize-serviceDesk" tabTitle="${serviceDeskTitle}">
			<jsp:include page="trackerServiceDeskConfig.jsp"/>
		</tab:tabPane>
	</c:if>
</tab:tabContainer>