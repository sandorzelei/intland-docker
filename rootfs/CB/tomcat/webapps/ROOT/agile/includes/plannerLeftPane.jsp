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

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<spring:message var="sprintsTitle" code="planner.sprints" text="Sprints" />
<spring:message var="teamsTitle" code="planner.teams" text="Teams"></spring:message>
<spring:message var="teamCommitmentTitle" code="planner.teamCommitment" text="Team Commitment" />
<spring:message var="relationsTitle" code="planner.relations" text="Relations" />
<spring:message var="issueCountTooltip" code="planner.issue.count.tooltip" />

<!-- Comment sections are intentional, see fixWhitespacesIE8 in planner.js -->
<ul class="quick-icons" id="left-pane-quick-icons"><!--
	--><li class="sprints" title="<c:out value="${sprintsTitle}" />"></li><!--
	--><li class="teams" title="<c:out value="${teamsTitle}" />"></li><!--
	--><li class="team-commitment" title="<c:out value="${teamCommitmentTitle}" />"></li><!--
	--><li class="relations" title="<c:out value="${relationsTitle}" />"></li><!--
--></ul>

<div class="overflow">

	<c:url value="/images/newskin/action/add-new-lightgrey-s.png" var="addIcon"/>

	<div class="accordion" data-quick-icons="left-pane-quick-icons">

		<h3 class="sprints-title accordion-header">
			<span class="icon"></span><c:out value="${sprintsTitle}"/>
			<spring:message code="xplanner.create.new.release.hint" text="Click here to add a new release or sprint" var="addReleaseHint"/>
			<a href="#" class="add-sprint-icon add-icon" title="${addReleaseHint}"></a>
		</h3>
		<div class="sprints-accordion accordion-content" data-section-id="sprints">
			<ol class="version-list">
				<c:forEach items="${versionsViewModel.trackerItems}" var="version" >
					<c:set var="info" value="${versionsViewModel.info[version]}" />
					<c:set var="isReleaseLevel" value="${info.level == 0}" />
					<c:set var="leftSpace" value="${info.level * 10}px" />
					<c:if test="${info.level == 0}">
						${backlog}
						<c:set var="backlog">
							<li class="backlog virtual filter" style='margin-left: ${leftSpace}<c:if test="${empty(version.children)}">;display:none</c:if>' data-version-id="${version.id}">
								<span class="title"><strong><c:out value="${version.name}"/></strong> <spring:message code="planner.backlog.label" text="Backlog"/></span>
								<span class="issue-count" title="${issueCountTooltip}"></span>
							</li>
						</c:set>
					</c:if>
					<ct:call object="${sortableReleases}" method="contains" param1="${version.id}" return="releaseSortable"/>
					<li style='margin-left: ${leftSpace}' class="version filter ${isReleaseLevel ? 'is-release' : ''}" data-version-id="${version.id}"
						data-parent-version-id="${!empty version.parent ? version.parent.id : ''}"
						data-parent-list-version-ids="${versionParentSetMap[version.id]}"
						data-type="${version.parent != null ? 'sprint' : 'release' }"
						data-release-sortable="${releaseSortable}" data-level="${info.level}">
						<c:if test="${hasAgileLicense }"><div class="knob"></div></c:if>
						<c:if test="${fn:length(info.children) > 0 }"><a class="expander expanded"></a></c:if>

						<div class="state-indicator"></div>

						<span class="title"><ui:noSummaryPlaceholder value="${version.reqIfSummary}"/></span>

					<span class="release-date">
						<c:if test="${!empty version.startDate}">
							<tag:formatDate value="${version.startDate}" type="date"/>
						</c:if>
						<c:if test="${!empty version.startDate || !empty version.endDate}">&ndash;</c:if>
						<c:if test="${!empty version.endDate}">
							<tag:formatDate value="${version.endDate}" type="date"/>
						</c:if>
						<br>
					</span>

						<span class="issue-count" title="${issueCountTooltip}"></span>

					<c:choose>
						<c:when test="${isTrackerScope and isReleaseLevel}"><c:set var="menuKeys" value="planThis,newSprint,createSprintSchedule,generateNextSprint,sendToReview,sendMergeRequest,coverageBrowser,traceability,edit,delete,slackChannel" /></c:when>
						<c:when test="${currentVersion == version}"><c:set var="menuKeys" value="planParent,newSprint,createSprintSchedule,generateNextSprint,sendToReview,sendMergeRequest,coverageBrowser,traceability,edit,delete,slackChannel" /></c:when>
						<c:when test="${currentVersion == version.parent}"><c:set var="menuKeys" value="planThis,newSprint,createSprintSchedule,generateNextSprint,sendToReview,sendMergeRequest,coverageBrowser,traceability,moveUp,edit,delete,slackChannel" /></c:when>
						<c:otherwise><c:set var="menuKeys" value="planThis,planParent,newSprint,sendToReview,sendMergeRequest,moveUp,edit,delete" /></c:otherwise>
					</c:choose>

					<span class="extendedReleaseMenu" id="left-panel-context-menu-${version.id}" data-id="${version.id}" data-keys="${menuKeys}"></span>

						<br style="clear:both;">
					</li>
				</c:forEach>
				${backlog}
				<li class="project-backlog virtual filter" style="padding-left: 8px" data-version-id="-1">
					<span class="issue-count" title="${issueCountTooltip}"></span>
					<span class="title"><spring:message code="planner.project.backlog" text="Project Backlog"/></span>
				</li>
			</ol>
		</div>

		<h3 class="teams-title accordion-header">
			<span class="icon"></span><c:out value="${teamsTitle}"/>
			<spring:message code="xplanner.create.new.team.hint" text="Click here to add a new Team" var="addTeamHint"/>
			<a class="add-team-icon add-icon" href="#" title="${addTeamHint }"></a>
		</h3>
		<div class="teams-accordion accordion-content" data-section-id="teams">
			<img id="team.accordion-placeholder" class="loading" src="<c:url value="/images/ajax-loading_16.gif"/>" />
			<jsp:include page="teamList.jsp"/>
		</div>

		<h3 class="release-stats-title accordion-header"><span class="icon"></span><c:out value="${teamCommitmentTitle}" /></h3>
		<div class="release-stats-accordion accordion-content" data-section-id="stats"></div>

		<h3 class="relations-title accordion-header"><span class="icon"></span><c:out value="${relationsTitle}" /></h3>
		<div class="relations-accordion accordion-content" data-section-id="relations">
			<img id="colored-realtions-placeholder" class="loading" src="<c:url value="/images/ajax-loading_16.gif"/>" />
		</div>

	</div>
</div>

<script type="text/javascript">
	// Refresh version view model after reload left pane
	codebeamer.plannerConfig = jQuery.extend(codebeamer.plannerConfig || {}, {
		"versionsViewModel": ${versionsViewModelJson}
	});
</script>
