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
 *
--%>
<%--
 adds the necessary style elements to the branch related page (currently only branch color)
 --%>

 <%@tag language="java" pageEncoding="UTF-8" %>

<%@ tag import="com.intland.codebeamer.persistence.dao.impl.EntityCache" %>
<%@ tag import="com.intland.codebeamer.controller.ControllerUtils" %>
<%@ tag import="com.intland.codebeamer.persistence.dto.BranchDto" %>
<%@ tag import="com.intland.codebeamer.persistence.dto.TrackerDto" %>
<%@ tag import="com.intland.codebeamer.persistence.dto.UserDto" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ attribute name="branch" required="false" type="com.intland.codebeamer.persistence.dto.TrackerDto" rtexprvalue="true"
	description="The branch to render"  %>

<c:if test="${not empty branch.color }">

	<%-- compute the darker version of the color --%>
	<%
		String hexColor = Integer.toHexString(java.awt.Color.decode(branch.getColor()).darker().getRGB() & 0xffffff);
		request.setAttribute("darker", "#" + hexColor);
	%>

	<c:url var="imagePrefix" value="/images/newskin/action/agile"/>

	<style type="text/css">
		.newskin.trackersModule .actionMenuBar .viewsMenuContainer.large .viewsMenu,
		.newskin.tracker-branch .actionMenuBar .viewsMenuContainer.large .viewsMenu,
		.newskin.CMDBModule .actionMenuBar .viewsMenuContainer.large .viewsMenu {
			background-color: transparent;
		}

		.newskin.trackersModule .actionMenuBar, .newskin.CMDBModule .actionMenuBar, .newskin.tracker-branch .actionMenuBar {
			background-color: ${branch.color};
			background: -moz-linear-gradient(left, #454545 0%, #454545 50%, ${branch.color} 66%, ${branch.color} 100%);
			background: -webkit-linear-gradient(left, #454545 0%, #454545 50%, ${branch.color} 66%, ${branch.color} 100%);
			background: linear-gradient(to right, #454545 0%, #454545 50%, ${branch.color} 66%, ${branch.color} 100%);
		}

		.newskin.trackersModule .actionMenuBar .breadcrumbs-item-version, .newskin.CMDBModule .actionMenuBar .breadcrumbs-item-version,
		.newskin.tracker-branch .actionMenuBar .breadcrumbs-item-version {
			background-color: ${branch.color};
		}

		.newskin.trackersModule .actionMenuBar .branchBaselineBadge, .newskin.CMDBModule .actionMenuBar .branchBaselineBadge,
		.newskin.tracker-branch .actionMenuBar .branchBaselineBadge{
			background-color: ${darker};
		}

		.newskin.trackersModule .actionMenuBar .branchBaselineBadge *, .newskin.CMDBModule .actionMenuBar .branchBaselineBadge *,
		.newskin.tracker-branch .actionMenuBar .branchBaselineBadge * {
			filter: brightness(100%);
		}

		.newskin.trackersModule .actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton,
		.newskin.tracker-branch .actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton,
		.newskin.CMDBModule .actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton{
			opacity: 0.6;
		}
		.actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton.tableViewActionIcon {
			background-image: url("${imagePrefix}/icon_table_dark_new.png");
		}

		.actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton.cardboardActionIcon {
			background-image: url("${imagePrefix}/icon_kanban_dark_new.png");
		}

		.actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton.documentViewEditActionIcon {
			margin-top: 0px;
			background-image: url("${imagePrefix}/icon_docview_edit_dark.png");
		}

		.actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton.documentViewActionIcon {
			background-image: url("${imagePrefix}/icon_docview_dark.png");
		}

		.actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton.coverageActionIcon {
			background-image: url("${imagePrefix}/icon_testcoverage_dark.png");
		}

		.actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton.traceabilityBrowserActionIcon {
			background-image: url("${imagePrefix}/icon_traceability_browser_dark_new.png");
		}

		.actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton.plannerActionIcon {
			background-image: url("${imagePrefix}/icon_planner_dark.png");
		}

		.actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton.detailsActionIcon {
			background-image: url("${imagePrefix}/icon_settings_dark.png");
		}

		.actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton.releaseStatsActionIcon {
			background-image: url("${imagePrefix}/icon_stat_dark.png");
		}

		.actionMenuBar .viewsMenuContainer.large .viewsMenu .viewControl.viewButton.releaseStatsActionIcon.active {
			position: relative;
			top: -1px;
		}

		.actionMenuBar .release-train-icon {
			background-image: url("${imagePrefix}/icon_train_white.png");
			background-color: ${branch.color};
		}

		.actionMenuBar .release-train {
			border: 1px solid white;
		}

	</style>
</c:if>


<%-- for branches use the parent tracker icon --%>
<%
	TrackerDto trackerOrParent = branch;
	if (branch.isBranch()) {
		UserDto user = ControllerUtils.getCurrentUser(request);
		trackerOrParent = EntityCache.getInstance(user).getTracker(BranchDto.getTrackerIdOfBranch(branch));
	}
	request.setAttribute("trackerOrParent", trackerOrParent);
%>

<c:if test="${not empty trackerOrParent.icon}">
	<c:url var="iconUrl" value="/displayDocument?doc_id=${trackerOrParent.icon}"/>

	<style type="text/css">

		.trackersModule .actionMenuBar .actionMenuBarIcon,
		.CMDBModule .actionMenuBar .actionMenuBarIcon,
		.planner.CMDBModule .actionMenuBar .actionMenuBarIcon,
		.releaseModule.CMDBModule .actionMenuBar .actionMenuBarIcon,
		.tracker-branch .actionMenuBar .actionMenuBarIcon {
			background-image: url('${iconUrl}');
			-webkit-background-size: cover;
			background-size: cover;
		}
	</style>
</c:if>