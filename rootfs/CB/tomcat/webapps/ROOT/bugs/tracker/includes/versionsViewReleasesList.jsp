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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="callTag" prefix="ct" %>

<%@page import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@page import="com.intland.codebeamer.utils.MultiValue"%>
<%@page import="java.util.Stack"%>

<%--
	Shows a list of Releases (aka versions) available in the "versionsViewModel" model object
--%>

<%-- expandable tracker item view showing the issues belonging to different versions --%>

<c:set var="versions" value="${versionsViewModel.trackerItems}" />
<c:set var="isFilteringEnabled" value="${versionsViewModel.filteringEnabled}" />

<%!
	private Stack<MultiValue<TrackerItemDto, String>> getProductBacklogs(PageContext ctx) {
		Stack<MultiValue<TrackerItemDto, String>> productBacklogFragment = (Stack<MultiValue<TrackerItemDto, String>>) ctx.findAttribute("productBacklogFragment");
		if (productBacklogFragment == null) {
			productBacklogFragment = new Stack<MultiValue<TrackerItemDto, String>>();
			ctx.setAttribute("productBacklogFragment", productBacklogFragment);
		}
		return productBacklogFragment;
	}

	TrackerItemDto getVersion(PageContext ctx) {
		return (TrackerItemDto) ctx.findAttribute("version");
	}

	boolean isParent(TrackerItemDto suspectedParent, TrackerItemDto suspectedChild) {
		TrackerItemDto p = suspectedChild;
		while (p != null) {
			p = p.getParentItem();
			if (p!= null && suspectedParent.equals(p)) {
				return true;
			}
		}
		return false;
	}

	String printBacklog(TrackerItemDto version, String backlogFragment) {
		return backlogFragment;
	}

	String popProductBacklog(PageContext ctx, boolean popAll) {
		String result = "";
		TrackerItemDto version = getVersion(ctx);
		Stack<MultiValue<TrackerItemDto, String>> backlogs = getProductBacklogs(ctx);
		boolean stop = false;
		while (!backlogs.isEmpty() && !stop) {
			MultiValue<TrackerItemDto, String> last = backlogs.peek();
			if (popAll || ! isParent(last.getLeft(), version)) {
				backlogs.pop();
				result += printBacklog(last.getLeft(), last.getRight());
			} else {
				// stop here, no more to pop
				stop = true;
			}
		}
		return result;
	}

	void pushProductBacklog(PageContext ctx) {
		String versionIssuesFragment = (String) ctx.getAttribute("backlog");
		TrackerItemDto version = getVersion(ctx);
		getProductBacklogs(ctx).add(new MultiValue(version, versionIssuesFragment));
	}
%>

<c:choose>
	<c:when test="${! empty versions}">

		<c:set var="allowExpandIssues" value="${empty param.allowExpandIssues || param.allowExpandIssues == 'true'}" />

		<%-- expandable items --%>
		<c:set var="numberOfItems" value="${fn:length(versions)}" />
		<c:set var="releaseTreeDepth" value="${versionsViewModel.releaseTreeDepth}"/>
		<c:forEach var="version" items="${versions}" varStatus="status">

			<%-- Pop one backlog item and print it --%>
			<%=popProductBacklog(pageContext, false) %>

			<c:set var="versionStat" value="${versionsViewModel.versionStats[version.id]}" scope="request"/>    <%-- is of type VersionStatsDto --%>
			<c:set var="info" value="${versionsViewModel.info[version]}" />    <%-- is of type VersionsViewModel.Info --%>
			<c:set var="hasSprints" value="${not empty info.children}" />
			<c:set var="versionLevel" value="${info.level}" />
			<c:set var="isReleaseLevel" value="${versionLevel == 0}" />
			<c:set var="isReleased" value="${version.resolvedOrClosed}" />
			<c:set var="showReleaseBacklog" value="${isReleaseLevel and hasSprints}" />    <%-- Backlogs are only used in the Release level and are only shown if not empty --%>
			<c:set var="hasChildren" value="${versionStat.referencedByTrackerItems || hasSprints}" />
			<c:choose>
				<c:when test="${showReleaseBacklog}">
					<c:set var="versionId" value="${fn:trim(version.id)}" /> <%-- trim is needed to force type to String --%>
					<c:set var="backLogVersionId" value="backlog_${version.id}" />
				</c:when>
				<c:otherwise>
					<c:set var="versionId" value="${fn:trim(version.id)}" /> <%-- trim is needed to force type to String --%>
				</c:otherwise>
			</c:choose>

			<%-- Clean temporary variables --%>
			<c:remove var="isExpanded" />
			<c:remove var="hasIssues" />
			<c:remove var="isHidden" />
			<c:remove var="hasIssuesInBackLog"/>

			<ct:call object="${versionsViewModel}" method="isSingleTopLevelSprint" param1="${version}" return="isSingleTopLevelSprint"/>

			<c:choose>
				<%-- Sole sprints and there sub-sprints must be open every time. --%>
				<c:when test="${(status.index == 0 && isSingleTopLevelSprint) || openAllChildren}">
					<ct:call object="${versionsViewModel}" method="hasSubRelease" param1="${info}" return="hasSubRelease"/>
					<c:set var="isExpanded" value="${hasSubRelease || info.hasAnyChildren}" />
					<c:set var="hasIssues" value="${isExpanded}" />
					<c:set var="isHidden" value="${false}" />
					<c:set var="openAllChildren" value="${true}" />
					<span style="display: none" class="versionTreeState" data-restore-tree="false">${versionTreeState}</span>
				</c:when>
				<%-- Do not expand released releases due to performance optimization. Page is identified by the showReleasedVersions parameter. --%>
				<c:when test="${showReleasedVersions && isReleased && isReleaseLevel}">
					<c:set var="isExpanded" value="false" />
					<c:set var="hasIssues" value="${info.hasAnyChildren}" />
					<%-- If it has any items, then the sub release section must be expanded and displayed. --%>
					<c:set var="isHidden" value="false" />
					<span style="display: none" class="versionTreeState" data-restore-tree="false">${versionTreeState}</span>
				</c:when>
				<%-- Do not expand released sprints due to performance optimization. Page is identified by the showReleasedVersions parameter. --%>
				<c:when test="${showReleasedVersions && !isReleaseLevel}">
					<c:set var="isExpanded" value="false" />
					<ct:call object="${versionsViewModel}" method="hasSubRelease" param1="${info}" return="hasSubRelease"/>
					<c:set var="hasIssues" value="${hasSubRelease || info.hasAnyChildren}" />
					<%-- If it has any items, then the sub release section must be expanded and displayed. --%>
					<c:set var="isHidden" value="${info.anyParentIsClosedNodeOrAnyParentIsResolved}" />
					<span style="display: none" class="versionTreeState" data-restore-tree="false">${versionTreeState}</span>
				</c:when>
				<%-- Set variables for sub releases, when filtering is enabled. --%>
				<c:when test="${isFilteringEnabled && !isReleaseLevel}">
					<ct:call object="${versionsViewModel}" method="hasNonEmptySubRelease" param1="${info}" return="hasNonEmptySubRelease"/>
					<c:set var="isExpanded" value="${hasNonEmptySubRelease || info.hasAnyChildren}" />
					<c:set var="hasIssues" value="${isExpanded}" />
					<%-- If it has any items, then the sub release section must be expanded and displayed. --%>
					<c:set var="isHidden" value="${!isExpanded}" />
					<span style="display: none" class="versionTreeState" data-restore-tree="false">${versionTreeState}</span>
				</c:when>
				<%-- Set variables for top level releases with sprints, when filtering is enabled. --%>
				<c:when test="${isFilteringEnabled && showReleaseBacklog}">
					<c:set var="hasIssuesInBackLog" value="${versionStat.referencedByTrackerItems}" />
					<c:set var="isBacklogExpanded" value="${hasIssuesInBackLog}" />
					<ct:call object="${versionsViewModel}" method="hasNonEmptySubRelease" param1="${info}" return="hasNonEmptySubRelease"/>
					<c:set var="isExpanded" value="${(hasNonEmptySubRelease || info.hasAnyChildren)}" />
					<c:set var="hasIssues" value="${isExpanded}" />
					<%-- Top level release, so it must be expanded and displayed. --%>
					<c:set var="isHidden" value="false" />
				</c:when>
				<%-- Set variables for top level releases, when filtering is enabled. --%>
				<c:when test="${isFilteringEnabled && isReleaseLevel}">
					<ct:call object="${versionsViewModel}" method="hasNonEmptySubRelease" param1="${info}" return="hasNonEmptySubRelease"/>
					<c:set var="isExpanded" value="${(hasNonEmptySubRelease || info.hasAnyChildren)}" />
					<c:set var="hasIssues" value="${isExpanded}" />
					<%-- Top level release, so it must be expanded and displayed. --%>
					<c:set var="isHidden" value="false" />
					<span style="display: none" class="versionTreeState" data-restore-tree="false">${versionTreeState}</span>
				</c:when>
				<c:when test="${showReleaseBacklog}">
					<c:set var="hasIssuesInBackLog" value="${versionStat.referencedByTrackerItems}" />
					<c:set var="isBacklogExpanded" value="${versionsViewModel.treeNodeStates[backLogVersionId]}" />
					<ct:call object="${versionsViewModel}" method="hasSubRelease" param1="${info}" return="hasSubRelease"/>
					<c:set var="hasIssues" value="${hasSubRelease}" />
					<c:set var="isExpanded" value="${versionsViewModel.treeNodeStates[versionId]}" />
					<c:set var="isHidden" value="${info.anyParentIsClosedNode}" />
				</c:when>
				<c:when test="${!isReleaseLevel}">
					<ct:call object="${versionsViewModel}" method="hasSubRelease" param1="${info}" return="hasSubRelease"/>
					<c:set var="isExpanded" value="${versionsViewModel.treeNodeStates[versionId] && !info.anyParentIsClosedNode}" />
					<c:set var="hasIssues" value="${hasSubRelease || versionStat.referencedByTrackerItems}" />
					<c:set var="isHidden" value="${info.anyParentIsClosedNode}" />
					<span style="display: none" class="versionTreeState" data-restore-tree="true">${versionTreeState}</span>
				</c:when>
				<c:otherwise>
					<c:set var="isExpanded" value="${versionsViewModel.treeNodeStates[versionId]}" />
					<c:set var="hasIssues" value="${versionStat.referencedByTrackerItems}" />
					<c:set var="isHidden" value="${info.anyParentIsClosedNode}" />
					<span style="display: none" class="versionTreeState" data-restore-tree="true">${versionTreeState}</span>
				</c:otherwise>
			</c:choose>

			<c:if test="${!hideReleasedVersionsByDefault || !info.itselfOrAnyParentIsReleased || showReleasedVersions}">

				<c:set var="indent" value="true" />
				<c:if test="${indent}">
					<c:if test="${empty firstItemLevel}"><c:set var="firstItemLevel" value="${versionLevel}" /></c:if>
					<c:set var="indentStyle" value="margin-left:${(versionLevel - firstItemLevel)*20}px;" />
				</c:if>
				<c:set var="paddingAmount" value="${(releaseTreeDepth - versionLevel - firstItemLevel) * 20}" scope="request"/>

				<%-- DIV that represents a complete version: a header + its items --%>
				<div id="${version.id}" data-version-id="${version.id}" data-parent-id="${version.parentItem.id}"
					class="version ${isReleased ? 'released' : ''} ${isReleaseLevel ? 'release' : 'sprint'} ${status.first ? 'firstRelease' : ''} ${empty info.children ?'versionWithoutChildren':'versionWithChildren'} childOf_${version.parentItem.id} ${indent ? 'indented' : ''}"
					style="${indentStyle} ${isHidden ? 'display: none;' : ''}">
					<%-- Version header, contains basic information and some statistical data --%>
					<div class="versionHeader">
						<c:set var="buttonsAheadOfVersion" scope="request">
							<c:url var="ajaxUrl" value="/ajax/jsonVersionStats.spr?task_id=${version.id}" />
							<c:choose>
								<c:when test="${isReleaseLevel}">
									<c:if test="${allowExpandIssues && hasChildren}">
										<spring:message var="versionIssuesTitle" code="cmdb.version.issues.release.tooltip"/>
										<a href="#" class="expander subreleasesExpander ${isExpanded ? 'expanded' : ''}" title="${versionIssuesTitle}" longdesc="${ajaxUrl}"></a>
									</c:if>
								</c:when>
								<c:otherwise>
									<c:if test="${allowExpandIssues && hasIssues}">
										<spring:message var="versionIssuesTitle" code="cmdb.version.issues.sprint.tooltip"/>
										<a href="#" class="expander subreleasesExpander ${isExpanded ? 'expanded' : ''}" title="${versionIssuesTitle}" longdesc="${ajaxUrl}"></a>
										</c:if>
								</c:otherwise>
							</c:choose>
							<spring:message code="tracker.choice.${version.status.name }.label" text="${version.status.name }" var="versionStatus"/>
							<div class="large-icon ${isReleaseLevel ? 'release' : 'sprint' }" style="background-color:${info.backgroundColor}" title="${versionStatus }" <c:if test="${info.isEditable}"> data-role="status-icon"</c:if>><c:if test="${info.isEditable}"><span data-id="${version.id}" data-role="status-menu"/></c:if></div>

						</c:set>
						<c:set var="version" scope="request" value="${version}"/>

						<c:set var="headerCenteredFragment" scope="request">
							<c:if test="${isReleaseLevel and info.hasIncludedReleases}">
								<div class="art-progress-box">
									<div class="art-progress"></div>
									<spring:message code="cmdb.version.stats.agile.release.train.progress.tooltip"
										text="Show Agile Release Train Program Increment (PI) Statistics: This is a manual-based and interval calculation for managing value and feedback from the team and program level."
										var="artTooltip"></spring:message>
									<span style="float:right;"><a class="showArtProgressLink" data-id="${version.id}">Show ART Progress</a><span class="helpLink large" title="${artTooltip}"></span></span>
								</div>
							</c:if>
							<c:if test="${info.descendantsNumber > 0}">
								<div class="accumulatedStats">
									<span><spring:message code="cmdb.version.issues.sprint.count" arguments="${info.descendantsNumber}" /></span>
									<c:set var="greenPercentage" value="${(100.0 * info.descendantsResolvedOrClosed) / info.descendantsNumber}" />
									<c:set var="grayPercentage" value="${100.0 - greenPercentage}" />
									<fmt:formatNumber var="sprintProgressBarLabel" value="${greenPercentage}" maxFractionDigits="0"/>

									<ui:progressBar greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}" label="${sprintProgressBarLabel}%" totalPercentage="100" />
									<span><spring:message code="cmdb.version.issues.count.closed2" arguments="${info.descendantsResolvedOrClosed}" /></span>
									<span><spring:message code="cmdb.version.issues.count.open" arguments="${info.descendantsNumber - info.descendantsResolvedOrClosed}" /></span>
								</div>
							</c:if>

							<c:set var="stats" value="${info.accumulatedStats}" scope="request" />
							<jsp:include page="./versionProgressInfo.jsp"/>
						</c:set>

						<jsp:include page="./versionHeader.jsp"/>
						<div style="clear:both;"></div>
					</div>

					<c:choose>
						<c:when test="${showReleaseBacklog}">
							<c:url var="ajaxUrlToIssueList" value="/ajax/jsonVersionStats.spr?task_id=${version.id}"/>
							<c:set var="backlog">
								<div id="${backLogVersionId}" data-version-id="${backLogVersionId}" data-parent-id="${version.parentItem.id}" class="version backlog ${isReleased ? 'released' : ''} releaseBacklog childOf_${version.parentItem.id}"
									style="${indentStyle}">
									<div class="versionHeader versionHeaderWithCenteredFragment">

										<div class="leftPart" style="padding-right:${paddingAmount - 10}px;">
											<c:if test="${allowExpandIssues && hasIssuesInBackLog}">
												<a href="#" class="expander subreleasesExpander ${isBacklogExpanded ? 'expanded' : ''}" title="${versionIssuesTitle}" longdesc="${ajaxUrlToIssueList}"></a>
											</c:if>
											<div class="large-icon backlog"></div>
											<c:remove var="headerCenteredFragment" scope="request"/>
											<span class="version"><c:out value="${version.name}"/> Backlog</span>
										</div>

										<div class="headerCenteredFragment">
											<c:set var="stats" value="${info.stats}" scope="request" />
											<jsp:include page="./versionProgressInfo.jsp"/>
										</div>

									</div>
									<div id="versionIssues_${backLogVersionId}" class="versionIssuesContainer" ${isBacklogExpanded ? '' : 'style="display: none;"'}>
										<img class="loading" src="<c:url value="/images/ajax-loading_16.gif"/>" />
										<div class="versionIssues">
											<c:if test="${isBacklogExpanded}">${info.versionIssuesRendered}</c:if>
										</div>
									</div>
								</div>
							</c:set>
							<%-- push "versionIssuesFragment" to print out later as product backlog --%>
							<% pushProductBacklog(pageContext); %>
						</c:when>
						<c:otherwise>
							<c:set var="backlog" value="" />
							<div id="versionIssues_${version.id}" class="versionIssuesContainer" ${isExpanded ? '' : 'style="display: none;"'}>
							<img class="loading" src="<c:url value="/images/ajax-loading_16.gif"/>" />
							<div class="versionIssues">
								<c:if test="${isExpanded}">${info.versionIssuesRendered}</c:if>
							</div>
						</div>
						</c:otherwise>
					</c:choose>
				</div>
			</c:if>
		</c:forEach>

		<%-- Pop all remaining backlog items and print them --%>
		<%=popProductBacklog(pageContext, true) %>

		<script src="<ui:urlversioned value='/bugs/tracker/versionsview/versionUtils.js'/>"></script>
		<%-- add event handler to expander controls --%>
		<script type="text/javascript">
			jQuery(function($) {
				VersionUtils.init({
					referenceNodeExpandTitle: "${versionsViewModel.referenceNodeExpandTooltip}",
					referenceNodeCloseTitle: "${versionsViewModel.referenceNodeCloseTooltip}"
				});

				// initialize the tooltips
				$(".large.helpLink").tooltip({
					position: {my: "left top+5", collision: "flipfit"},
					tooltipClass : "tooltip"
				});

				$('#versionsTable').on('click', '.showArtProgressLink', function () {
					var $link = $(this);
					var releaseId = $link.data('id');
					var bs = ajaxBusyIndicator.showBusyPage();
					$.ajax(contextPath + "/ajax/versionStatsWithIncludes.spr", {
						"data": {
							"task_id": releaseId
						},
						"success": function (data) {
							ajaxBusyIndicator.close(bs);
							var $container = $link.parents('.art-progress-box').find('.art-progress');
							$container.empty();
							$container.append(data);
						},
						"error": function () {
							ajaxBusyIndicator.close(bs);
						}
					});
				});
			});
		</script>
	</c:when>
	<c:otherwise>
		<spring:message code="table.nothing.found" text="No items found."/>
	</c:otherwise>
</c:choose>
