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
 lists the branches of a tracker
--%>

<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<script src="<ui:urlversioned value='/js/branchesCommon.js' />"></script>
<script src="<ui:urlversioned value='/js/branching/trackerBranches.js' />"></script>

<c:choose>
	<c:when test="${canViewBranches }">
		<div class="actionBar">
	<spring:message var="createBranchButton"
		code="tracker.action.createBranch.label"
		text="Create Branch" />

	<spring:message var="mergeBranchesButton"
		code="tracker.action.mergeBranches.label"
		text="Merge Branches" />

	<c:url var="createBranchUrl" value="/branching/createBranch.spr">
		<c:param name="trackerId" value="${not empty param.branchId ? param.branchId : tracker.id }"></c:param>
		<c:if test="${not empty param.openEditableView}">
			<c:param name="openEditableView" value="${param.openEditableView}"></c:param>
		</c:if>
		<c:if test="${not empty baselineId }">
			<c:param name="baselineId" value="${baselineId}"></c:param>
		</c:if>
	</c:url>

	<c:if test="${canCreateBranch }">
		<a href="#" class="actionLink" onclick="window.top.showCreateBranchDialog('${createBranchUrl}');">${createBranchButton }</a>
	</c:if>

	<a href="#" class="actionLink" onclick="codebeamer.branches.mergeBranches();">${mergeBranchesButton }</a>

	<a href="#" class="cancelButton" onclick="inlinePopup.close();">
		<spring:message code="button.cancel" text="Cancel"/>
	</a>

	<input class="baselineFilterBox" type="text" data-type="branch" placeholder="<spring:message code="Filter"/>" autofocus="autofocus" value="">

		</div>
		<div class="contentWithMargins baselineListWrapper">
			<div class="hint">
				<spring:message code="branch.list.hint"/>
			</div>
			<display:table name="${branches}" id="branchNode" sort="external" htmlId="branch"
					export="false" class="expandTable" cellpadding="0"
					decorator="com.intland.codebeamer.controller.branching.TrackerBranchListDecorator">

					<c:set var="branch" value="${branchNode.branch }"/>
	                <display:column media="html">
	                    <input type="checkbox" name="selectedBranches" ${currentBranch == branch ? 'checked' : ''}
	                           value="${branch.id}" />
	                </display:column>

					<spring:message var="branchNameTitle"
						code="tracker.branching.branch.name.label" text="Name"/>
					<display:column title="${branchNameTitle}" headerClass="textData" class="textData"  style="padding-left: ${branchNode.level *20 }px;">
						<c:if test="${not empty branchIdItemIdMap[branch.id]}">
							<c:set var="itemIdOnBranch" value="${branchIdItemIdMap[branch.id]}"></c:set>
						</c:if>

						<tag:branchName trackerId="${branch.id }" var="branchName"></tag:branchName>

						<c:if test="${not empty originalItemId && not empty itemIdOnBranch}">
							<a href="#" data-trackerId="${branch.getTrackerIdOfBranch()}" data-branchId="${branch.id}" data-originalItemId="${originalItemId}" data-itemIdOnBranch="${itemIdOnBranch}" data-revision="${baselineId}">${branchName }</a>
						</c:if>
						<c:if test="${not empty originalItemId && empty itemIdOnBranch}">
							<a href="#" data-trackerId="${branch.getTrackerIdOfBranch()}" data-branchId="${branch.id}" data-originalItemId="${originalItemId}" data-revision="${baselineId}">${branchName }</a>
						</c:if>
						<c:if test="${empty originalItemId}">

							<c:set var="originalTrackerUrl" value="${not empty branchToOriginalTracker[branch.id] ?  branchToOriginalTracker[branch.id].urlLink : branch.urlLink}"/>
							<a href="#" data-trackerId="${branch.getTrackerIdOfBranch()}" data-branchId="${branch.id}" data-original-tracker-url="${originalTrackerUrl }" data-revision="${baselineId}">${branchName }</a>
						</c:if>
					</display:column>

					<spring:message var="branchDescription"
						code="tracker.branching.branch.description.label" text="Description" />
					<display:column title="${branchDescription}" property="description"
						escapeXml="true"
						headerClass="textData expand"
						class="textDataWrap smallerText columnSeparator" />

					<spring:message code="tracker.branching.branch.createdFrom.label" var="createdFromLabel" text="Created from"/>
					<display:column title="${createdFromLabel}" property="createdFrom"
						escapeXml="false"
						headerClass="textData expand"
						class="textData smallerText columnSeparator" />

					<spring:message code="baseline.createdAt.label" var="createdAtLabel" text="Created at"/>
					<display:column title="${createdAtLabel}" property="createdAt"
						escapeXml="true"
						headerClass="dateData expand"
						class="dateData smallerText columnSeparator" />

					<spring:message code="baseline.createdBy.label" var="createdByLabel" text="Created by"/>
					<display:column title="${createdByLabel}" property="createdBy"
						escapeXml="true"
						headerClass="textData expand"
						class="textDataWrap smallerText columnSeparator" />

					<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
						<ui:actionGenerator builder="allArtifactActionsMenuBuilder" actionListName="actions" subject="${branch}">
							<ui:actionLinkList actions="${actions}" keys="Properties,deleteBranch" cssClass="baselineActions" />
						</ui:actionGenerator>
					</display:column>

			</display:table>
				</div>
	</c:when>
	<c:when test="${!hasBranchLicense}">
		<div class="warning">
			<spring:message code="tracker.branching.branch.no.license.warning" text="You cannot use this feature because you don't have the <b>Branching</b> license. To read more about this feature visit our <a target=\"_blank\" href=\"https://codebeamer.com/cb/wiki/85612\">Knowledge base</a>."/>
		</div>
	</c:when>
</c:choose>


