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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ page import="com.intland.codebeamer.persistence.util.TrackerItemFieldHandler" %>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemRevisionDto"%>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils" %>
<%@ page import="com.intland.codebeamer.persistence.util.Baseline"%>
<%@ page import="com.intland.codebeamer.persistence.util.Directory"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>

<ui:urlversioned var="diffIcon" value="/images/newskin/action/popup.png"/>
<spring:message code="wiki.diff.label" text="Differences" var="diffLabel"/>
<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<jsp:useBean id="decorated" beanName="decorated" scope="request" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" />

<%
	Baseline baseline = (Baseline) request.getAttribute("baseline");
%>

<c:set var="item" value="${paragraph.value}"/>
	<c:set var="isGroupingItem" value="${item.groupingItem}"/>
	<jsp:useBean id="item" beanName="item" type="com.intland.codebeamer.persistence.dto.TrackerItemDto" />
	<%
		TrackerItemFieldHandler fieldHandler =  TrackerItemFieldHandler.getInstance(ControllerUtils.getCurrentUser(request));
	%>
	<c:set var="editableAtAll" value="<%= fieldHandler.isEditable(item) %>"/>

	<%
		decorated.initRow(new TrackerItemRevisionDto(item, baseline != null ? item.getVersion() : null, baseline), 0, 0);
	%>

	<spring:message code="tracker.view.layout.document.add.comment.tooltip" text="Click to view comments or add one ..." var="addCommentTitle"/>

	<c:set var="issueIsEditable" value="${empty baseline && (empty canEdit || canEdit) && editableAtAll}" />
	<ui:actionGenerator builder="documentViewActionsMenuBuilder" subject="${item}" actionListName="actions" deniedKeys="notification">
		<spring:message code="tracker.show.rating.title" var="ratingHoverTitle" text="Click to show the rating dialog"/>
		<c:set var="thisSummaryEditable" value="${issueIsEditable && summaryEditable[item]}" />
		<c:set var="thisDescriptionEditable" value="${issueIsEditable && descriptionEditable[item]}" />

		<tr class="requirementTr jstree-drop ${not empty changedInBaseline[item.id] ? 'changed-baseline': '' } ${thisDescriptionEditable ? '' : 'readonly-description'}"
			id="${item.id}" revision="${baseline.id}" ${dataAttribute}
			data-hasemptyrequired="${hasEmptyRequiredField[item]}" data-summary-editable="${thisSummaryEditable }"
			data-description-editable="${thisDescriptionEditable }" data-summary-required="${summaryRequired[item] }">
			<td class="control-bar ${compactMode ? 'compact' : '' }">
				<c:set var="item" value="${item }" scope="request"></c:set>
				<c:set var="thisSummaryEditable" value="${thisSummaryEditable }" scope="request"></c:set>
				<c:set var="thisDescriptionEditable" value="${thisDescriptionEditable }" scope="request"></c:set>
				<c:set var="issueIsEditable" value="${issueIsEditable }" scope="request"></c:set>
				<jsp:include page="documentViewControlButtons.jsp"/>
			</td>
			<td class="textSummaryData requirementTd">
				<input type="hidden" name="item-version" value="${item.version}">

				<c:set var="reqContextMenu">
					<div class="reqContextMenu">
							<table class="contextMenuTable"><tr>
								<c:choose>
									<c:when test="${not empty baseline }">
										<c:set var="keys" value="open, openInNewTab"/>
									</c:when>
									<c:otherwise>
										<c:set var="keys" value="generateReports, ---, open, openInNewTab, ---, newChildAjax, newItemBeforeAjax, newItemAfterAjax, ---, addAssociationOverlay, ---, cut, ajaxCopy, delete, pasteChild, pasteBefore, pasteAfter, [---], addAttachment, addCommentViaOffice, [---], createTestRuns*, [---], slackChannel"/>
										<c:if test="${not empty canEdit && !canEdit || requiredFieldWithoutDefault }">
											<c:set var="keys" value="generateReports, ---, open, openInNewTab, ---, addAssociationOverlay, ---, cut, ajaxCopy, delete, pasteChild, pasteBefore, pasteAfter, [---], addAttachment, addCommentViaOffice,[---], follow, [---], slackChannel"/>
											<c:if test="${requiredFieldWithoutDefault}">
												<c:set var="keys" value="open, openInNewTab, ---, newChildAjax, newItemBeforeAjax, newItemAfterAjax, ---, addAssociationOverlay, ---, cut, ajaxCopy, delete, [---], addAttachment, addCommentViaOffice, [---], follow, createTestRuns*, [---], slackChannel"/>
											</c:if>
										</c:if>
									</c:otherwise>
								</c:choose>
								<td>
									<ui:actionMenu actions="${actions}" keys="${keys}" leftAligned="true" lazyInit="true" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
								</td>
							</tr></table>
						</div>
				</c:set>

				<spring:message code="tracker.view.layout.document.dnd.issue.title"
					text="Drag this issue to an other browser window the create new associations or references" var="dndTitle"/>
				<c:set var="draggable" value="${dndSupported and empty baseline}"></c:set>
				<h${paragraph.key.level} class="name ${not reqifMode or item.name != null ? '' : 'empty-name'}" data-issueid="${item.id }" issueid="${item.id }"  title="${draggable ? dndTitle : ''}">
				<c:if test="${draggable}"><span class="dnd-icon" draggable="true"></span></c:if>
				<c:if test="${!isGroupingItem}">
					<a href="#" class="diff-link" title="${diffLabel}"><img src="${diffIcon}"/></a>
				</c:if>
				<c:if test="${showParagraphId }">
					<span class="releaseid"><c:out value="${paragraph.key.release}" escapeXml="false"/></span>
				</c:if>
					<c:choose>
						<c:when test="${decorated.nameVisible}">
							<span class="${thisSummaryEditable ? 'editable' : ''} ${showParagraphId ? '' : 'no-numbering'}"><c:out value="${item.name}"/></span>
						</c:when>
						<c:otherwise>
							<a class="noAccessPermsWarn" style="text-decoration: none"
								title="<spring:message code="reference.field.read.permission" text="At this time you have no permission to read this field."/>">
								<spring:message code="tracker.view.layout.document.summary.not.readable" text="[Summary not readable]"/>
							</a>
						</c:otherwise>
					</c:choose>

					${reqContextMenu}

					<div class="branch-badge-group">
						<bugs:itemBranchBadges item="${item }" itemDivergedOnMaster="${divergedOnMaster != null and fn:contains(divergedOnMaster, item) }"
							itemDivergedOnBranch="${divergedOnBranch != null and fn:contains(divergedOnBranch, item)  }"
							itemCreatedOnBranch="${createdOnBranch != null and fn:contains(createdOnBranch, item)  }" branch="${branch }"></bugs:itemBranchBadges>
					</div>

					<div style="clear:both;"></div>
				</h${paragraph.key.level}>


				<c:if test="${!empty truncatedParagraphs[paragraph.key] }">
					<table>
						<tr>
							<td>
								<div class="smallWarning">
									<spring:message code="tracker.view.layout.document.show.removed.node.hint"/>
									<a href="#" onclick="reloadIncompleteNode(${item.id})">${paragraph.key.release}</a>
								</div>
							</td>
						</tr>
					</table>
				</c:if>

				<%-- description --%>
				<div class="description thumbnailImages">
					<c:if test="${reqifMode && item.name == null }">
						${reqContextMenu}
					</c:if>
					<div class="${thisDescriptionEditable ? 'editable' : ''} description-container"
						data-description-format="${item.descriptionFormat == '' ? 'P' : item.descriptionFormat }">
						<c:if test="${item.description != '--' && not empty item.description}">
							<c:set var="descriptionDecorated" value="${decorated.description}"/>
							<c:if test="${descriptionDecorated != null }">
								<c:choose>
									<c:when test="${item.descriptionFormat != 'W'}">
										<span class="plainTextContent">
											<c:out value="${descriptionDecorated}" escapeXml="false"/>
										</span>
									</c:when>
									<c:otherwise>
										<c:out value="${descriptionDecorated}" escapeXml="false"/>
									</c:otherwise>
								</c:choose>

							</c:if>
						</c:if>
					</div>
				</div>

				<%-- test step editor --%>
				<%-- TODO: handle the permissions --%>
				<c:if test="${!empty testSteps && !isGroupingItem}">
					<c:set var="steps" value="${testSteps[item]}"/>
					<c:if test="${tracker.testCase}">
						<spring:message code="tracker.field.Test Steps.label" var="testStepsLabel"/>
						<div class="teststepwrapper">
							<div class="expander testStepContainer">
								<img class="expander noMarginExpander" src="<c:url value="/images/Gap.gif"/>"/>
								<span class="testStepCount">${fn:length(steps)} ${testStepsLabel}</span>
							</div>
							<div class="expandable" style="display:none;">
								<input type="hidden" value="${testStepsEditable[item]}" name="editable"/>
							</div>
						</div>
					</c:if>
				</c:if>
			</td>
		</tr>
	</ui:actionGenerator>