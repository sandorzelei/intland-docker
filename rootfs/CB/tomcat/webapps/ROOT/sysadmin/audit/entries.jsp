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

<%@ page import="com.intland.codebeamer.date.PredefinedDateRangeSupport" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib"   prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/filter.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/user-profile-information.less' />" type="text/css" media="all" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/choiceOptions.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/viewConfiguration.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/fieldAccessControl.css'/>" />
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect.less" />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldConfiguration.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldAccessControl.js'/>"></script>
<script src="<ui:urlversioned value='/js/dashboard/trackerEditor.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/permissionMatrix.js'/>"></script>

<style>

	.chooseReferences {
		margin: 0px;
	}

	.userPhotoPlaceholder.tableIcon {
		vertical-align: middle;
	    height: 28px;
	    width: 28px;
	    border-radius: 50%;
	}

	.ui-multiselect.ui-widget.ui-state-default.ui-corner-all.dashboard-widget-editor-select {
		width: 300px;
		max-width: 300px;
	}

	.ui-multiselect-menu.ui-widget-content .ui-widget-header {
    	display: block !important;
    }

    .chooseReferences.fullExpandTable {
    	width: 300px;
    	max-width: 300px;
    }

    .tooltip-marker span {
    	position: relative;
    	top: 1px;
    }

    .permissionMatrix {
    	margin: 0 !important;
    }

    img.tableIcon {
    	position: relative;
    	top: 3px;
    }

    .userIntials img.tableIcon {
    	top: 0px;
    }

    .accordion .accordion-content.opened {
    	border-bottom: 0px;
    }

    .accordion-content.opened table td {
    	padding-top: 2px;
    }
</style>

<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="sysadmin.audit" text="Audit" />
	</ui:pageTitle>
</ui:actionMenuBar>

<div style="margin: 15px;">
	<tab:tabContainer id="audit-entries" skin="cb-box" selectedTabPaneId="${auditTab}">
		<spring:message var="loginsTabLabel" code="sysadmin.audit.tab.logins" text="Logins" />
		<tab:tabPane id="logins" tabTitle="${loginsTabLabel}">
			<ui:actionBar>
				<div id="auditActionBar" style="position: relative;top: 2px;display: inline-block;cursor: pointer;">
					<spring:message code="sysadmin.audit.export.excel" text="Export to Excel" var="excelExportTitle"/>
					<img class="action" title="${excelExportTitle}" src="<ui:urlversioned value="/images/newskin/action/icon_excel_export_blue.png"/>" onclick="javascript:download('EXCEL');">

					<spring:message code="sysadmin.audit.export.pdf" text="Export to PDF" var="pdfExportTitle"/>
					<img class="action" title="${pdfExportTitle}" src="<ui:urlversioned value="/images/newskin/action/icon_pdf.png"/>" onclick="javascript:download('PDF');">

					<c:url var="cancelUrl" value="/sysadmin.do"/>
					<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
					<input type="button" class="button cancelButton" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>
				</div>
			</ui:actionBar>
			<c:if test="${!loginsEnabled}">
				<div class="warning"><spring:message code="sysadmin.audit.logins.disabled" text="All event types of login is disabled, please enable it on Configs tab or in general.xml!"/></div>
			</c:if>
			<div class="accordion advancedSearchParameters logins">
					<h3 class="search-title accordion-header">
						<span class="icon">
						</span>
						<spring:message var="searchParametersLabel" code="sysadmin.audit.search.parameters" text="Search parameters" />
						<c:out value="${searchParametersLabel}" />
						</h3>
				<form action="${pageContext.request.contextPath}/audit/entries.spr" method="get">
					<input type="hidden" name="submitTime" />
					<input type="hidden" name="auditTab" value="logins" />
					<div class="accordion-content">
						<table cellspacing="5" cellpadding="5">
							<tr>
								<td width="200" class="optional" align="right">
									<spring:message var="usersLabel" code="sysadmin.audit.search.users" text="Users" />
									<c:out value="${usersLabel}:" />
								</td>
								<td>
									<div style="display:inline-block; width: 300px; max-width: 300px; overflow: hidden; margin: 0px;">
										<bugs:userSelector htmlId="userSelector" singleSelect="false" allowRoleSelection="false" title=""
														   setToDefaultLabel="" defaultValue="" ids="${userIds}" fieldName="userId"
											   			   searchOnAllUsers="true" showPopupButton="false" onlyMembers="false" allowUserSelection="true"
											   			   useAllProjects="true" ignoreCurrentProject="true" includeDisabledUsers="true"/>
									</div>
								</td>
							</tr>
							<tr>
								<td width="200" class="optional" align="right"><spring:message code="sysadmin.audit.search.eventtype" text="Event Types" />:</td>
								<td>
									<input type="hidden" name="loginsEventTypes" id="loginsEventTypes" value="${loginsEventTypeIds}" />
									<select id="loginsEventTypesSelector" multiple="multiple">
										<c:forEach items="${loginsEventTypes}" var="loginsEventType">
											<c:choose>
												<c:when test="${loginsEventType.selected}">
													<option value="${loginsEventType.id}" selected="selected">${loginsEventType.name}</option>
												</c:when>
												<c:otherwise>
													<option value="${loginsEventType.id}">${loginsEventType.name}</option>
												</c:otherwise>
											</c:choose>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<td width="200" class="optional" align="right">
									<spring:message var="loginRangeLabel" code="sysadmin.audit.search.login.range" text="Login range" />
									<c:out value="${loginRangeLabel}:" />
								</td>
								<td class="durationFilters">
									<ui:duration property="duration" value="${loginsDuration.duration}" allowFutureDuration="false">
										<spring:message code="duration.after.label" text="After"/>:
										<%-- tag:formatDate value="${from}" var="fromValue"></tag:formatDate --%>
										<input type="text" size="12" maxlength="30" id="from" name="from" value="${loginsDuration.from}" />
										<ui:calendarPopup textFieldId="from" otherFieldId="to"/>

										<spring:message code="duration.before.label" text="Before"/>:
										<%-- tag:formatDate value="${to}" var="toValue"></tag:formatDate --%>
										<input type="text" size="12" maxlength="30" id="to" name="to" value="${loginsDuration.to}" />
										<ui:calendarPopup textFieldId="to" otherFieldId="from"/>
									</ui:duration>
								</td>
							</tr>
							<tr>
								<td></td>
								<td class="optional" align="left" style="text-align: left;">
									<spring:message var="searchSubmit" code="search.submit.label" text="GO"/>
									<input type="submit" class="button" name="" title="${searchSubmit}" value="${searchSubmit}" style="position: relative;left: -2px;" />
								</td>
							</tr>
						</table>
					</div>
				</form>
			</div>

			<c:if test="${auditTab eq 'logins'}">
				<div class="users-container">
					<display:table
						name="logInOutEntries"
						sort="external"
						pagesize="${pageSize}"
						id="entries"
						partialList="true"
						requestURI="${requestURI}"
						cellpadding="0"
						export="false"
						decorator="com.intland.codebeamer.ui.view.table.LogInOutDecorator"
						size="size">

						<display:setProperty name="pagination.pagenumber.param"    	value="page" />
						<display:setProperty name="pagination.sort.param"          	value="sort" />
						<display:setProperty name="pagination.sortdirection.param" 	value="sortDirection" />
						<display:setProperty name="paging.banner.placement" 		value="bottom"/>
						<display:setProperty name="paging.banner.onepage" 			value="" />
						<display:setProperty name="paging.banner.one_item_found" 	value="" />
						<display:setProperty name="paging.banner.all_items_found" 	value="" />
						<display:setProperty name="paging.banner.some_items_found" 	value="" />
						<display:setProperty name="paging.banner.group_size" 		value="5" />

						<spring:message var="loginsUserLabel" code="sysadmin.audit.logins.user" text="User" />
						<display:column title="${loginsUserLabel}" property="user" sortable="true">
						</display:column>

						<spring:message var="actionsEventTypeLabel" code="sysadmin.audit.actions.eventtype" text="Event Type" />
						<display:column title="${actionsEventTypeLabel}" property="event" sortable="true">
						</display:column>

						<spring:message var="actionsCreatedAtLabel" code="sysadmin.audit.actions.createdAt" text="Created at" />
						<display:column title="${actionsCreatedAtLabel}" property="createdAt" sortable="true">
						</display:column>
					</display:table>
				</div>
			</c:if>
		</tab:tabPane>
		<spring:message var="actionsTabLabel" code="sysadmin.audit.tab.actions" text="Actions" />
		<tab:tabPane id="actions" tabTitle="${actionsTabLabel}">
			<ui:actionBar>
				<div id="auditActionBar" style="position: relative;top: 2px;display: inline-block;cursor: pointer;">
					<spring:message code="sysadmin.audit.export.excel" text="Export to Excel" var="excelExportTitle"/>
					<img class="action" title="${excelExportTitle}" src="<ui:urlversioned value="/images/newskin/action/icon_excel_export_blue.png"/>" onclick="javascript:download('EXCEL');">

					<spring:message code="sysadmin.audit.export.pdf" text="Export to PDF" var="pdfExportTitle"/>
					<img class="action" title="${pdfExportTitle}" src="<ui:urlversioned value="/images/newskin/action/icon_pdf.png"/>" onclick="javascript:download('PDF');">

					<c:url var="cancelUrl" value="/sysadmin.do"/>
					<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
					<input type="button" class="button cancelButton" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>
				</div>
			</ui:actionBar>
			<c:if test="${!actionsEnabled}">
				<div class="warning"><spring:message code="sysadmin.audit.actions.disabled" text="All event types of action is disabled, please enable it on Configs tab or in general.xml!"/></div>
			</c:if>
			<div class="accordion advancedSearchParameters actions">
					<h3 class="search-title accordion-header">
						<span class="icon">
						</span>
						<spring:message var="searchParametersLabel" code="sysadmin.audit.search.parameters" text="Search parameters" />
						<c:out value="${searchParametersLabel}" />
						</h3>
				<form action="${pageContext.request.contextPath}/audit/entries.spr" method="get">
					<input type="hidden" name="submitTime" />
					<input type="hidden" name="auditTab" value="actions" />
					<div class="accordion-content">
						<table cellspacing="5" cellpadding="5">
							<tr>
								<td width="200" class="optional" align="right">
									<spring:message var="usersLabel" code="sysadmin.audit.search.users" text="Users" />
									<c:out value="${usersLabel}:" />
								</td>
								<td>
									<bugs:userSelector htmlId="actionsUserSelector" singleSelect="false" allowRoleSelection="false" title=""
													   setToDefaultLabel="" defaultValue="" ids="${actionsUserIds}" fieldName="actionsUserId"
										   			   searchOnAllUsers="true" showPopupButton="false" onlyMembers="false" allowUserSelection="true"
										   			   useAllProjects="true" ignoreCurrentProject="true" />
								</td>
							</tr>
							<tr>
								<td width="200" class="optional" align="right"><spring:message code="sysadmin.audit.search.projects" text="Projects" />:</td>
								<td>
									<input type="hidden" name="actionsProjectIds" id="actionsProjectIds" value="${actionsProjectIds}" />
									<select id="actionsProjectsSelector" multiple="multiple">
										<c:forEach items="${actionsListSelector.projectSelectors}" var="actionsProject">
											<c:choose>
												<c:when test="${actionsProject.selected}">
													<option value="${actionsProject.id}" selected="selected">${actionsProject.name}</option>
												</c:when>
												<c:otherwise>
													<option value="${actionsProject.id}">${actionsProject.name}</option>
												</c:otherwise>
											</c:choose>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<td width="200" class="optional" align="right"><spring:message code="sysadmin.audit.search.trackers" text="Trackers" />:</td>
								<td>
									<input type="hidden" name="actionsTrackerIds" id="actionsTrackerIds" value="${actionsTrackerIds}" />
									<select id="actionsTrackersSelector" multiple="multiple">
										<c:forEach items="${actionsListSelector.groupedTrackerSelectors}" var="group">
											<optgroup label="${group.name}">
											<c:forEach items="${group.selectors}" var="actionsTracker">
												<c:choose>
													<c:when test="${actionsTracker.selected}">
														<option value="${actionsTracker.id}" selected="selected">${actionsTracker.name}</option>
													</c:when>
													<c:otherwise>
														<option value="${actionsTracker.id}">${actionsTracker.name}</option>
													</c:otherwise>
												</c:choose>
											</c:forEach>
											</optgroup>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<td width="200" class="optional" align="right"><spring:message code="sysadmin.audit.search.eventtype" text="Event Types" />:</td>
								<td>
									<input type="hidden" name="actionsEventTypes" id="actionsEventTypes" value="${actionsEventTypeIds}" />
									<select id="actionsEventTypesSelector" multiple="multiple">
										<c:forEach items="${actionsEventTypes}" var="actionsEventTypeGroup">
											<optgroup label="${actionsEventTypeGroup.name}">
											<c:forEach items="${actionsEventTypeGroup.selectors}" var="actionsEventType">
												<c:choose>
													<c:when test="${actionsEventType.selected}">
														<option value="${actionsEventType.id}" selected="selected">${actionsEventType.name}</option>
													</c:when>
													<c:otherwise>
														<option value="${actionsEventType.id}">${actionsEventType.name}</option>
													</c:otherwise>
												</c:choose>
											</c:forEach>
											</optgroup>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<td width="200" class="optional" align="right">
									<spring:message var="actionsRangeLabel" code="sysadmin.audit.search.action.range" text="Created at range" />
									<c:out value="${actionsRangeLabel}:" />
								</td>
								<td class="durationFilters">
									<ui:duration property="actionsDuration" value="${actionsDuration.duration}" allowFutureDuration="false">
										<spring:message code="duration.after.label" text="After"/>:
										<%-- tag:formatDate value="${actionsFrom}" var="actionsFromValue"></tag:formatDate --%>
										<input type="text" size="12" maxlength="30" id="actionsFrom" name="actionsFrom" value="${actionsDuration.from}" />
										<ui:calendarPopup textFieldId="actionsFrom" otherFieldId="actionsTo"/>

										<spring:message code="duration.before.label" text="Before"/>:
										<%-- tag:formatDate value="${actionsTo}" var="actionsToValue"></tag:formatDate --%>
										<input type="text" size="12" maxlength="30" id="actionsTo" name="actionsTo" value="${actionsDuration.to}" />
										<ui:calendarPopup textFieldId="actionsTo" otherFieldId="actionsFrom"/>
									</ui:duration>
								</td>
							</tr>
							<tr>
								<td></td>
								<td class="optional" align="left" style="text-align: left;">
									<spring:message var="searchSubmit" code="search.submit.label" text="GO"/>
									<input type="submit" class="button" name="actionsSubmit" id="actionsSubmit" title="${searchSubmit}" value="${searchSubmit}" style="position: relative;left: -2px;" />
								</td>
							</tr>
						</table>
					</div>
				</form>
			</div>

			<c:if test="${auditTab eq 'actions'}">
				<div class="users-container">

					<display:table
						name="actionEntries"
						sort="external"
						pagesize="${pageSize}"
						id="actionEntries"
						partialList="true"
						requestURI="${requestURI}"
						cellpadding="0"
						export="false"
						decorator="com.intland.codebeamer.ui.view.table.ActionDecorator"
						size="size">

						<display:setProperty name="pagination.pagenumber.param"    	value="page" />
						<display:setProperty name="pagination.sort.param"          	value="sort" />
						<display:setProperty name="pagination.sortdirection.param" 	value="sortDirection" />
						<display:setProperty name="paging.banner.placement" 		value="bottom"/>
						<display:setProperty name="paging.banner.onepage" 			value="" />
						<display:setProperty name="paging.banner.one_item_found" 	value="" />
						<display:setProperty name="paging.banner.all_items_found" 	value="" />
						<display:setProperty name="paging.banner.some_items_found" 	value="" />
						<display:setProperty name="paging.banner.group_size" 		value="5" />

						<spring:message var="actionsUserLabel" code="sysadmin.audit.actions.user" text="User" />
						<display:column title="${actionsUserLabel}" property="user" sortable="true">
						</display:column>

						<spring:message var="actionsWorkitemLabel" code="sysadmin.audit.actions.workitem" text="Work Item" />
						<display:column title="${actionsWorkitemLabel}" property="objectId" sortable="true">
						</display:column>

						<spring:message var="actionsEventTypeLabel" code="sysadmin.audit.actions.eventtype" text="Event Type" />
						<display:column title="${actionsEventTypeLabel}" property="event" sortable="true">
						</display:column>

						<spring:message var="actionsProjectLabel" code="sysadmin.audit.actions.project" text="Project" />
						<display:column title="${actionsProjectLabel}" property="project" sortable="true">
						</display:column>

						<spring:message var="actionsTrackerLabel" code="sysadmin.audit.actions.tracker" text="Tracker" />
						<display:column title="${actionsTrackerLabel}" property="tracker" sortable="true">
						</display:column>

						<spring:message var="actionsMessageLabel" code="sysadmin.audit.actions.message" text="Message" />
						<display:column title="${actionsMessageLabel}" property="details" sortable="false"  style="max-width:200px;word-wrap: break-word;">
						</display:column>

						<spring:message var="actionsCreatedAtLabel" code="sysadmin.audit.actions.createdAt" text="Created at" />
						<display:column title="${actionsCreatedAtLabel}" property="createdAt" sortable="true">
						</display:column>
					</display:table>
				</div>
			</c:if>
		</tab:tabPane>
		<spring:message var="permissionsTabLabel" code="sysadmin.audit.tab.permissions" text="Permissions" />
		<tab:tabPane id="permissions" tabTitle="${permissionsTabLabel}">
			<ui:actionBar>
				<div id="auditPermissionBar" style="position: relative;top: 2px;display: inline-block;cursor: pointer;">
					<spring:message code="sysadmin.audit.export.excel" text="Export to Excel" var="excelExportTitle"/>
					<img class="action" title="${excelExportTitle}" src="<ui:urlversioned value="/images/newskin/action/icon_excel_export_blue.png"/>" onclick="javascript:download('EXCEL');">

					<spring:message code="sysadmin.audit.export.pdf" text="Export to PDF" var="pdfExportTitle"/>
					<img class="action" title="${pdfExportTitle}" src="<ui:urlversioned value="/images/newskin/action/icon_pdf.png"/>" onclick="javascript:download('PDF');">

					<c:url var="cancelUrl" value="/sysadmin.do"/>
					<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
					<input type="button" class="button cancelButton" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>
				</div>
			</ui:actionBar>
			<c:if test="${!permissionsEnabled}">
				<div class="warning"><spring:message code="sysadmin.audit.permissions.disabled" text="All event types of permission is disabled, please enable it on Configs tab or in general.xml!"/></div>
			</c:if>
			<div class="accordion advancedSearchParameters permissions">
					<h3 class="search-title accordion-header">
						<span class="icon">
						</span>
						<spring:message var="searchParametersLabel" code="sysadmin.audit.search.parameters" text="Search parameters" />
						<c:out value="${searchParametersLabel}" />
						</h3>
				<form action="${pageContext.request.contextPath}/audit/entries.spr" method="get">
					<input type="hidden" name="submitTime" />
					<input type="hidden" name="auditTab" value="permissions" />
					<div class="accordion-content">
						<table cellspacing="5" cellpadding="5">
							<tr>
								<td width="200" class="optional" align="right">
									<spring:message var="usersLabel" code="sysadmin.audit.search.users" text="Users" />
									<c:out value="${usersLabel}:" />
								</td>
								<td>
									<bugs:userSelector htmlId="permissionsUserSelector" singleSelect="false" allowRoleSelection="false" title=""
													   setToDefaultLabel="" defaultValue="" ids="${permissionsUserIds}" fieldName="permissionsUserId"
										   			   searchOnAllUsers="true" showPopupButton="false" onlyMembers="false" allowUserSelection="true" useAllProjects="true"
										   			   ignoreCurrentProject="true"/>
								</td>
							</tr>
							<tr>
								<td width="200" class="optional" align="right"><spring:message code="sysadmin.audit.search.projects" text="Projects" />:</td>
								<td>
									<input type="hidden" name="permissionsProjectIds" id="permissionsProjectIds" value="${permissionsProjectIds}" />
									<select id="permissionsProjectsSelector" multiple="multiple">
										<c:forEach items="${permissionsListSelector.projectSelectors}" var="permissionsProject">
											<c:choose>
												<c:when test="${permissionsProject.selected}">
													<option value="${permissionsProject.id}" selected="selected">${permissionsProject.name}</option>
												</c:when>
												<c:otherwise>
													<option value="${permissionsProject.id}">${permissionsProject.name}</option>
												</c:otherwise>
											</c:choose>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<td width="200" class="optional" align="right"><spring:message code="sysadmin.audit.search.trackers" text="Trackers" />:</td>
								<td>
									<input type="hidden" name="permissionsTrackerIds" id="permissionsTrackerIds" value="${permissionsTrackerIds}" />
									<select id="permissionsTrackersSelector" multiple="multiple">
										<c:forEach items="${permissionsListSelector.groupedTrackerSelectors}" var="group">
											<optgroup label="${group.name}">
											<c:forEach items="${group.selectors}" var="permissionsTracker">
												<c:choose>
													<c:when test="${permissionsTracker.selected}">
														<option value="${permissionsTracker.id}" selected="selected">${permissionsTracker.name}</option>
													</c:when>
													<c:otherwise>
														<option value="${permissionsTracker.id}">${permissionsTracker.name}</option>
													</c:otherwise>
												</c:choose>
											</c:forEach>
											</optgroup>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<td width="200" class="optional" align="right"><spring:message code="sysadmin.audit.search.eventtype" text="Event Types" />:</td>
								<td>
									<input type="hidden" name="permissionsEventTypes" id="permissionsEventTypes" value="${permissionsEventTypeIds}" />
									<select id="permissionsEventTypesSelector" multiple="multiple">
										<c:forEach items="${permissionsEventTypes}" var="permissionsEventType">
											<c:choose>
												<c:when test="${permissionsEventType.selected}">
													<option value="${permissionsEventType.id}" selected="selected">${permissionsEventType.name}</option>
												</c:when>
												<c:otherwise>
													<option value="${permissionsEventType.id}">${permissionsEventType.name}</option>
												</c:otherwise>
											</c:choose>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<td width="200" class="optional" align="right">
									<spring:message var="permissionsRangeLabel" code="sysadmin.audit.search.permission.range" text="Created at range" />
									<c:out value="${permissionsRangeLabel}:" />
								</td>
								<td class="durationFilters">
									<ui:duration property="permissionsDuration" value="${permissionsDuration.duration}" allowFutureDuration="false">
										<spring:message code="duration.after.label" text="After"/>:
										<%-- tag:formatDate value="${actionsFrom}" var="actionsFromValue"></tag:formatDate --%>
										<input type="text" size="12" maxlength="30" id="permissionsFrom" name="permissionsFrom" value="${permissionsDuration.from}" />
										<ui:calendarPopup textFieldId="permissionsFrom" otherFieldId="permissionsTo"/>

										<spring:message code="duration.before.label" text="Before"/>:
										<%-- tag:formatDate value="${actionsTo}" var="actionsToValue"></tag:formatDate --%>
										<input type="text" size="12" maxlength="30" id="permissionsTo" name="permissionsTo" value="${permissionsDuration.to}" />
										<ui:calendarPopup textFieldId="permissionsTo" otherFieldId="permissionsFrom"/>
									</ui:duration>
								</td>
							</tr>
							<tr>
								<td></td>
								<td class="optional" align="left" style="text-align: left;">
									<spring:message var="searchSubmit" code="search.submit.label" text="GO"/>
									<input type="submit" class="button" name="permissionsSubmit" id="permissionsSubmit" title="${searchSubmit}" value="${searchSubmit}" style="position: relative;left: -2px;" />
								</td>
							</tr>
						</table>
					</div>
				</form>
			</div>

			<c:if test="${auditTab eq 'permissions'}">
				<div class="users-container">

					<display:table
						name="permissionEntries"
						sort="external"
						pagesize="${pageSize}"
						id="permissionEntries"
						partialList="true"
						requestURI="${requestURI}"
						cellpadding="0"
						export="false"
						decorator="com.intland.codebeamer.ui.view.table.PermissionDecorator"
						size="size">

						<display:setProperty name="pagination.pagenumber.param"    	value="page" />
						<display:setProperty name="pagination.sort.param"          	value="sort" />
						<display:setProperty name="pagination.sortdirection.param" 	value="sortDirection" />
						<display:setProperty name="paging.banner.placement" 		value="bottom"/>
						<display:setProperty name="paging.banner.onepage" 			value="" />
						<display:setProperty name="paging.banner.one_item_found" 	value="" />
						<display:setProperty name="paging.banner.all_items_found" 	value="" />
						<display:setProperty name="paging.banner.some_items_found" 	value="" />
						<display:setProperty name="paging.banner.group_size" 		value="5" />

						<spring:message var="permissionsUserLabel" code="sysadmin.audit.permissions.user" text="User" />
						<display:column title="${permissionsUserLabel}" property="user" sortable="true">
						</display:column>

						<spring:message var="permissionsArtifactLabel" code="sysadmin.audit.permissions.artifact" text="Artifact" />
						<display:column title="${permissionsArtifactLabel}" property="objectId" sortable="true">
						</display:column>

						<spring:message var="permissionsEventTypeLabel" code="sysadmin.audit.permissions.eventtype" text="Event Type" />
						<display:column title="${permissionsEventTypeLabel}" property="event" sortable="true">
						</display:column>

						<spring:message var="permissionsProjectLabel" code="sysadmin.audit.permissions.project" text="Project" />
						<display:column title="${permissionsProjectLabel}" property="project" sortable="true">
						</display:column>

						<spring:message var="permissionsTrackerLabel" code="sysadmin.audit.permissions.tracker" text="Tracker" />
						<display:column title="${permissionsTrackerLabel}" property="tracker" sortable="true">
						</display:column>

						<spring:message var="permissionsMessageLabel" code="sysadmin.audit.permissions.message" text="Message" />
						<display:column title="${permissionsMessageLabel}" property="details" sortable="false"  style="max-width:200px;word-wrap: break-word;">
						</display:column>

						<spring:message var="permissionsCreatedAtLabel" code="sysadmin.audit.permissions.createdAt" text="Created at" />
						<display:column title="${permissionsCreatedAtLabel}" property="createdAt" sortable="true">
						</display:column>
					</display:table>
				</div>
			</c:if>
		</tab:tabPane>
		<spring:message var="configTabLabel" code="sysadmin.audit.tab.config" text="Config" />
		<tab:tabPane id="Config" tabTitle="${configTabLabel}">
			<ui:actionBar>
				<spring:message var="configSaveLabel" code="sysadmin.audit.config.save" text="Save"/>
				<input type="button" class="button" name="configSubmit" id="configSubmit" title="${configSaveLabel}" value="${configSaveLabel}" onClick="submitConfig('config')"/>

				<c:url var="cancelUrl" value="/sysadmin.do"/>
				<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
				<input type="button" class="button cancelButton" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>
			</ui:actionBar>
			<form:form method="post" action="saveConfig.spr" modelAttribute="config" id="config">
				<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All" />
				<c:set var="loginsCheckAll">
					<input type="CHECKBOX" title="${toggleButton}" id="loginsCheckAll-loginEventTypes" name="SELECT_ALL" value="on">
				</c:set>
				<div class="accordion advancedSearchParameters config login">
					<h3 class="search-title accordion-header">
						<spring:message var="loginEventTypesConfigLabel" code="sysadmin.audit.logins.config" text="Login event types"/>
						<c:out value="${loginEventTypesConfigLabel}" />
					</h3>
					<div class="accordion-content">
						<display:table id="loginSelector" name="config.logins" pagesize="${fn:length(eventTypesConfig.logins)}" defaultsort="2" defaultorder="ascending" requestURI="${pageContext.request.contextPath}/audit/entries.spr" excludedParams="*">
							<display:setProperty name="pagination.pagenumber.param"    	value="page" />
							<display:setProperty name="pagination.sort.param"          	value="sort" />
							<display:setProperty name="pagination.sortdirection.param" 	value="sortDirection" />
							<display:setProperty name="paging.banner.placement" 		value="bottom"/>
							<display:setProperty name="paging.banner.onepage" 			value="" />
							<display:setProperty name="paging.banner.one_item_found" 	value="" />
							<display:setProperty name="paging.banner.all_items_found" 	value="" />
							<display:setProperty name="paging.banner.some_items_found" 	value="" />
							<display:setProperty name="paging.banner.group_size" 		value="5" />
							<display:column title="${loginsCheckAll}" media="html" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
								<form:checkbox path="logins" label="" value="${loginSelector.id}"/>
							</display:column>
							<display:column title="Event Type" sortable="true">
								<c:out value="${loginSelector.name}" />
							</display:column>
						</display:table>
					</div>
				</div>
				<c:set var="workitemsCheckAll">
					<input type="CHECKBOX" title="${toggleButton}" id="workitemsCheckAll-workitemEventTypes" name="SELECT_ALL" value="on">
				</c:set>
				<div class="accordion advancedSearchParameters config workitem">
					<h3 class="search-title accordion-header">
						<spring:message var="workitemEventTypesConfigLabel" code="sysadmin.audit.workitmes.config" text="Work item event types"/>
						<c:out value="${workitemEventTypesConfigLabel}" />
					</h3>
					<div class="accordion-content">
						<display:table id="workitemSelector" name="config.workItems" pagesize="${fn:length(eventTypesConfig.workItems)}" defaultsort="2" defaultorder="ascending" requestURI="${pageContext.request.contextPath}/audit/entries.spr" excludedParams="*">
							<display:setProperty name="pagination.pagenumber.param"    	value="page" />
							<display:setProperty name="pagination.sort.param"          	value="sort" />
							<display:setProperty name="pagination.sortdirection.param" 	value="sortDirection" />
							<display:setProperty name="paging.banner.placement" 		value="bottom"/>
							<display:setProperty name="paging.banner.onepage" 			value="" />
							<display:setProperty name="paging.banner.one_item_found" 	value="" />
							<display:setProperty name="paging.banner.all_items_found" 	value="" />
							<display:setProperty name="paging.banner.some_items_found" 	value="" />
							<display:setProperty name="paging.banner.group_size" 		value="5" />
							<display:column title="${workitemsCheckAll}" media="html" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
								<form:checkbox path="workItems" label="" value="${workitemSelector.id}"/>
							</display:column>
							<display:column title="Event Type" sortable="true">
								<c:out value="${workitemSelector.name}" />
							</display:column>
						</display:table>
					</div>
				</div>
				<c:set var="artifactsCheckAll">
					<input type="CHECKBOX" title="${toggleButton}" id="artifactsCheckAll-artifactEventTypes" name="SELECT_ALL" value="on">
				</c:set>
				<div class="accordion advancedSearchParameters config artifact">
					<h3 class="search-title accordion-header">
						<spring:message var="artifactEventTypesConfigLabel" code="sysadmin.audit.artifacts.config" text="Artifact event types"/>
						<c:out value="${artifactEventTypesConfigLabel}" />
					</h3>
					<div class="accordion-content">
						<display:table id="artifactSelector" name="config.artifacts" pagesize="${fn:length(eventTypesConfig.artifacts)}" defaultsort="2" defaultorder="ascending" requestURI="${pageContext.request.contextPath}/audit/entries.spr" excludedParams="*">
							<display:setProperty name="pagination.pagenumber.param"    	value="page" />
							<display:setProperty name="pagination.sort.param"          	value="sort" />
							<display:setProperty name="pagination.sortdirection.param" 	value="sortDirection" />
							<display:setProperty name="paging.banner.placement" 		value="bottom"/>
							<display:setProperty name="paging.banner.onepage" 			value="" />
							<display:setProperty name="paging.banner.one_item_found" 	value="" />
							<display:setProperty name="paging.banner.all_items_found" 	value="" />
							<display:setProperty name="paging.banner.some_items_found" 	value="" />
							<display:setProperty name="paging.banner.group_size" 		value="5" />
							<display:column title="${artifactsCheckAll}" media="html" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
								<form:checkbox path="artifacts" label="" value="${artifactSelector.id}"/>
							</display:column>
							<display:column title="Event Type" sortable="true">
								<c:out value="${artifactSelector.name}" />
							</display:column>
						</display:table>
					</div>
				</div>
				<c:set var="permissionsCheckAll">
					<input type="CHECKBOX" title="${toggleButton}" id="permissionsCheckAll-permissionEventTypes" name="SELECT_ALL" value="on">
				</c:set>
				<div class="accordion advancedSearchParameters config permission">
					<h3 class="search-title accordion-header">
						<spring:message var="permissionEventTypesConfigLabel" code="sysadmin.audit.permissions.config" text="Permission event types"/>
						<c:out value="${permissionEventTypesConfigLabel}" />
					</h3>
					<div class="accordion-content">
						<display:table id="permissionSelector" name="config.permissions" pagesize="${fn:length(eventTypesConfig.permissions)}" defaultsort="2" defaultorder="ascending" requestURI="${pageContext.request.contextPath}/audit/entries.spr" excludedParams="*">
							<display:setProperty name="pagination.pagenumber.param"    	value="page" />
							<display:setProperty name="pagination.sort.param"          	value="sort" />
							<display:setProperty name="pagination.sortdirection.param" 	value="sortDirection" />
							<display:setProperty name="paging.banner.placement" 		value="bottom"/>
							<display:setProperty name="paging.banner.onepage" 			value="" />
							<display:setProperty name="paging.banner.one_item_found" 	value="" />
							<display:setProperty name="paging.banner.all_items_found" 	value="" />
							<display:setProperty name="paging.banner.some_items_found" 	value="" />
							<display:setProperty name="paging.banner.group_size" 		value="5" />
							<display:column title="${permissionsCheckAll}" media="html" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
								<form:checkbox path="permissions" label="" value="${permissionSelector.id}"/>
							</display:column>
							<display:column title="Event Type" sortable="true">
								<c:out value="${permissionSelector.name}" />
							</display:column>
						</display:table>
					</div>
				</div>
			</form:form>
		</tab:tabPane>
	</tab:tabContainer>
</div>

<script>

	function showTrackerPermissions(fieldId, entryId) {
		var config;
		$.ajax({
			url: contextPath + '/audit/entries/message.spr',
			dataType: 'json',
			async: false,
			data: { entryId: entryId },
			success: function(data) {
				config = data;
			}
		});
		var div = $('#' + fieldId);
		var popup = $('#popup_' + fieldId);
		if (popup.length == 0) {
			div.append(popup);
			popup = $('<div>', { id : '#popup_' + fieldId, "class" : 'accessPermissionsDialog', style : 'display: None;' });
			popup.permissionMatrix( config.permissions, {
				editable			: false,
				permissions			: config.trackerPermissions,
				roles				: config.roles,
				permissionLabel		: '<spring:message code="permission.label" 		 				 text="Permission"   javaScriptEscape="true"/>',
				fieldsLabel			: '<spring:message code="tracker.fieldAccess.memberFields.label" text="Participants" javaScriptEscape="true"/>',
				rolesLabel			: '<spring:message code="tracker.fieldAccess.roles.label" 		 text="Roles"		 javaScriptEscape="true"/>',
				grantAllText		: '<spring:message code="role.permissions.all.label"  text="All permissions" javaScriptEscape="true"/>',
				revokeAllText		: '<spring:message code="role.permissions.none.label" text="No permissions"  javaScriptEscape="true"/>',
				grantToAllText		: '<spring:message code="permission.grant.to.all" 	 text="Grant this permission to all" javaScriptEscape="true"/>',
				grantToAllHint		: '<spring:message code="permission.grant_revoke.all.hint" 	 text="The check box is checked when all possible check box is checked in the selected permission" javaScriptEscape="true"/>',
				revokeFromAllText	: '<spring:message code="permission.revoke.from.all" text="Revoke this permission from all" javaScriptEscape="true"/>',
				adminPermissionHint : '<spring:message code="permission.admin.default" text="Default Project Admin Permissions" javaScriptEscape="true"/>',
		        grantRevokeAllLabel : '<spring:message code="permission.grant_revoke.all" text="Grant/revoke to/from all" javaScriptEscape="true"/>'
			});

			popup.trackerPermissionDependencies();

			popup.dialog({
					title			: '<spring:message code="permission.label" text="Permission"   javaScriptEscape="true"/>', //(field.displayLabel || field.label) + ' - ' + settings.permissionsTitle,
					appendTo		: "body",
					position		: { my: "center", at: "center", of: window, collision: 'fit' },
					modal			: true,
					editable		: false,
					closeOnEscape	: true,
					dialogClass		: 'popup',
					width			: '90%'
				});
		}
		$("div[aria-describedby*='" + '#popup_' + fieldId + "'] input").attr('disabled', 'disabled');

		return false;
	}

	function createPermissionsTable(permissions, accessPermissions, $field) {
		var table = $('<table>', { width: '100%'});
		$field.append(table);
		var body = $('<tbody>');
		table.append(body);

		for (var i = 0; i < permissions.length; ++i) {
			var row = $('<tr>', { "class": (i % 2 == 0 ? 'permission even' : 'permission odd'), style: 'vertical-align: middle;' }).data("permission", permissions[i]);
			body.append(row);

			var cell = $('<td>', { style: "padding: 12px 5px 12px 5px;"});
			row.append(cell);
			var cb = $('<input>', { type: "checkbox", checked: isSelected(accessPermissions, permissions[i].id), disabled: true});
			cell.append(cb);
			var cell2 = $('<td>', {});
			row.append(cell2);
			var cb = permissions[i].name;
			cell2.append(cb);
		}
	}

	function showProjectRolePermissions(fieldId, entryId) {
		var config;
		$.ajax({
			url: contextPath + '/audit/entries/message.spr',
			dataType: 'json',
			async: false,
			data: { entryId: entryId },
			success: function(data) {
				config = data;
			}
		});
		var div = $('#' + fieldId);
		var popup = $('#popup_' + fieldId);
		if (popup.length == 0) {
			div.append(popup);
			popup = $('<div>', { id : '#popup_' + fieldId, "class" : 'accessPermissionsDialog', style : 'display: None;' });

			createPermissionsTable(config.projectPermissions, config.permissions, popup);

			popup.dialog({
					title			: '<spring:message code="permission.label" text="Permission"   javaScriptEscape="true"/>', //(field.displayLabel || field.label) + ' - ' + settings.permissionsTitle,
					appendTo		: "body",
					position		: { my: "center", at: "center", of: window, collision: 'fit' },
					modal			: true,
					editable		: false,
					closeOnEscape	: true,
					dialogClass		: 'popup'
				});
		}

		return false;
	}

	function showUserRolePermissions(fieldId, entryId) {
		var config;
		$.ajax({
			url: contextPath + '/audit/entries/message.spr',
			dataType: 'json',
			async: false,
			data: { entryId: entryId },
			success: function(data) {
				config = data;
			}
		});
		var div = $('#' + fieldId);
		var popup = $('#popup_' + fieldId);
		if (popup.length == 0) {
			div.append(popup);
			popup = $('<div>', { id : '#popup_' + fieldId, "class" : 'accessPermissionsDialog', style : 'display: None;' });

			createPermissionsTable(config.userPermissions, config.permissions, popup);

			popup.dialog({
					title			: '<spring:message code="permission.label" text="Permission"   javaScriptEscape="true"/>', //(field.displayLabel || field.label) + ' - ' + settings.permissionsTitle,
					appendTo		: "body",
					position		: { my: "center", at: "center", of: window, collision: 'fit' },
					modal			: true,
					editable		: false,
					closeOnEscape	: true,
					dialogClass		: 'popup'
				});
		}

		return false;
	}

	function isSelected(accessPerms, perm) {
		for (var i = 0; i < accessPerms.length; ++i) {
			if (accessPerms[i] != null && accessPerms[i].id == perm) {
				return true;
			}
		}
		return false;
	}

	function showTrackerFieldPermissioins(fieldId, entryId) {
		var config;
		$.ajax({
			url: contextPath + '/audit/entries/message.spr',
			dataType: 'json',
			async: false,
			data: { entryId: entryId },
			success: function(data) {
				config = data;
			}
		});
		var anchor = $("#" + fieldId);
		var popup = $('#popup_' + fieldId);
		if (popup.length == 0) {
			anchor.append(popup);
			popup = $('<div>', { id : '#popup_' + fieldId, "class" : 'popup', style : 'display: None;' });
			popup.showAccessPermissionsDialog(config.accessCtrl, config.accessPerms, config.accessSameAs, false, {statusOptions	: config.options, roles: config.roles}, {
				title			: '<spring:message code="permission.label" text="Permission"   javaScriptEscape="true"/>', //(field.displayLabel || field.label) + ' - ' + settings.permissionsTitle,
				appendTo		: "body",
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				editable		: false,
				closeOnEscape	: true,
			}, function(accessMode, accessPerms, accessSameAs) {
				field.accessCtrl  = accessMode;
				field.accessPerms = accessPerms;
				field.accessSameAs = accessSameAs;

				showAccessControl($('#' + fieldId), config);
			});
		} else {
			popup.dialog("open");
		}
		return false;
	}

	function initAllEventField(inputTypeName, allEventFieldId) {
		var allLoginsChecked = true;
		$("input[name='" + inputTypeName + "']").each(function () {
            if (!$(this).is(':checked')) {
            	allLoginsChecked = false;
            }
        });

		if (allLoginsChecked) {
			$("#" + allEventFieldId).prop("checked", true);
		}

		$("#" + allEventFieldId).click(function () {
	        if ($("#" + allEventFieldId).is(':checked')) {
	      	  	$("input[name='" + inputTypeName + "']").each(function () {
	                $(this).prop("checked", true);
	            });

	        } else {
	      	  	$("input[name='" + inputTypeName + "']").each(function () {
	                $(this).prop("checked", false);
	            });
	        }
	    });
	}

	function initMultiSelect(selectorId, event, valueFieldId, childSelectorId, childSelectorValueFieldId, childSelectorURLSource) {
		codebeamer.dashboard.multiSelect.init(selectorId, event, null, null, null);
		codebeamer.dashboard.multiSelect.attachEventListener(event, function(selectedIds) {
			var ids = "";
			if (selectedIds != null && selectedIds.length > 0) {
				ids = selectedIds.join(",");
			}
			$("#" + valueFieldId).val(ids);
			if (childSelectorId != null && childSelectorValueFieldId != null && childSelectorURLSource != null) {
				codebeamer.dashboard.trackerEditor.getTrackers(selectedIds, null, contextPath + childSelectorURLSource, childSelectorId);
				$("#" + childSelectorId).multiselect("uncheckAll");
				$("#" + childSelectorValueFieldId).val("");
			}
		});
	}

	function initWorkItemDiff() {
		$(".compare-versions-link").click(function(event) {
			var $element, targetItemId, itemId, $selectedVersions, versions, newVersion, version, tmp;

			$element = $(this);

			newVersion = $element.data("version");
			oldVersion = $element.data("prev-version");

			itemId = $element.data("item-id");

			inlinePopup.show(
				contextPath + "/issuediff/editable/diffVersion.spr?issue_id=" + itemId + "&revision=" + oldVersion + "&newVersion=" + newVersion + "&editable=false&targetItemId=" + itemId,
				{
					geometry: "large"
				}
			);

			event.preventDefault();
			event.stopPropagation();
		});
	}

	function iniArtifactDiff() {
		$(".compare-artifacts-link").click(function(event) {
			var $element, targetItemId, itemId, $selectedVersions, versions, newVersion, version, tmp;

			$element = $(this);

			var entryId = $element.data("entryid");

			inlinePopup.show(
				contextPath + "/audit/entries/diff.spr?entryId=" + entryId,
				{
					geometry: "large"
				}
			);

			event.preventDefault();
			event.stopPropagation();
		});
	}

	function refreshSubmitTime() {
		var submitTime = new Date().getTime();
		$("input[name*='submitTime']").val(submitTime);
	}

	function submitConfig(formId) {
		refreshSubmitTime();
		$("#" + formId).submit();
	}

	function getSelectedTabId() {
		var selectedTabPaneId = $('#audit-entries .ditch-focused').attr('id');
		return selectedTabPaneId.substring(0, selectedTabPaneId.lastIndexOf('-tab'));
	}

	function download(exporter) {
		var urlParams = new URLSearchParams(window.location.search);
		var query = urlParams.toString();

		if (query == null || !query.includes('auditTab')) {
			showFancyAlertDialog(i18n.message("sysadmin.audit.run.search"));
			return ;
		}

		if (query.length > 0) {
			query += '&';
		}
		// add export type
		query += 'type=' + exporter;

		var url = contextPath + '/audit/export.spr?' + query;
		window.open(url,'_blank');
	}

	jQuery(function() {
		$(".advancedSearchParameters").each(function() {
		  $(this).cbMultiAccordion({
				active: 0
			});
		});

		initMultiSelect('loginsEventTypesSelector', 'loginsEventTypeSelector:project:changed', 'loginsEventTypes');
		initMultiSelect('actionsEventTypesSelector', 'actionsEventTypeSelector:project:changed', 'actionsEventTypes');
		initMultiSelect('permissionsEventTypesSelector', 'permissionsEventTypeSelector:project:changed', 'permissionsEventTypes');
		initMultiSelect('actionsTrackersSelector', 'trackerSelector:project:changed', 'actionsTrackerIds');
		initMultiSelect('permissionsTrackersSelector', 'permissionTrackerSelector:project:changed', 'permissionsTrackerIds');
		initMultiSelect('actionsProjectsSelector', 'projectSelector:project:changed', 'actionsProjectIds', 'actionsTrackersSelector', 'actionsTrackerIds', '/ajax/select/getTrackers.spr');
		initMultiSelect('permissionsProjectsSelector', 'permissionProjectSelector:project:changed', 'permissionsProjectIds', 'permissionsTrackersSelector', 'permissionsTrackerIds', '/ajax/select/getTrackers.spr');

		initWorkItemDiff();
		iniArtifactDiff();

		initAllEventField('logins', 'loginsCheckAll-loginEventTypes');
		initAllEventField('workItems', 'workitemsCheckAll-workitemEventTypes');
		initAllEventField('artifacts', 'artifactsCheckAll-artifactEventTypes');
		initAllEventField('permissions', 'permissionsCheckAll-permissionEventTypes');
	});
</script>