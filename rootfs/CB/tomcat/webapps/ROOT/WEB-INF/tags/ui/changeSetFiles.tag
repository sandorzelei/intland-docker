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
<%@tag import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@tag import="com.intland.codebeamer.manager.ScmRepositoryManager"%>
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	Tag renders the changed files in a changeset with expandable/collapsable diffs

	TODO: ${canBrowseFiles}	is a boolean request parameters
--%>
<%@ attribute name="changeSet" type="com.intland.codebeamer.persistence.dto.ScmChangeSetDto" required="true" description="Change set to render" %>
<%@ attribute name="showChangedRevisions" type="java.lang.Boolean" description="If it shows the original and new revision numbers in the header" %>

<%
	if (! Boolean.TRUE.equals(request.getAttribute("slowDiffs"))) {
		// turn off the script loads all diffs on page load if this is slow
		// note: this will be called many times, but this is fine because it is possible that change-sets are from different repositories (on an issue page)
	    // so we've to query for each repo
		ScmRepositoryManager scmRepositoryManager = ControllerUtils.getSpringBean(request, "scmRepositoryManager", ScmRepositoryManager.class);
		boolean slowDiffs = scmRepositoryManager.isDiffComputationSlow(changeSet.getRepository());
		if (slowDiffs) {
			request.setAttribute("slowDiffs", Boolean.TRUE); 	// putting it to request to avoid more calls to scmRepositoryManager
		}
	}
%>
<c:if test="${slowDiffs}">
<ui:delayedScript avoidDuplicatesOnly="true">
	<script type="text/javascript">
		showDiff.loadAllDiffsEnabled = false;
	</script>
</ui:delayedScript>
</c:if>

<ui:delayedScript avoidDuplicatesOnly="true">
<style type="text/css">
<!--
	.changesetHeader img {
		width: 16px;
		height: 16px;
		vertical-align: middle;
		padding: 0;
	}
-->
</style>
</ui:delayedScript>

	<c:set var="changeFilesLimit" value="100" />
	<c:set var="changeFiles" value="${changeSet.changeFiles}" />
	<c:set var="changes" value="${fn:length(changeFiles)}" />

	<c:url var="diffURL" value="/proj/sources/scmFileDiff">
		<c:param name="repositoryId" value="${changeSet.repository.id}" />
		<c:param name="changesetId" value="${changeSet.id}" />
	</c:url>

	<span class="subtext changesetHeader">
		<c:if test="${changeSet.externalUrl != null}">
		<spring:message code="scm.commit.${changes eq 1 ? 'change' : 'changes'}.label" text="Changes"/>
			<a href="${changeSet.externalUrl}" target="_blank">
						${changes}
		</c:if>
		<c:if test="${changeSet.externalUrl != null}">
			</a>
		</c:if>
		<c:if test="${changeSet.repository.possibleToManage}">
		<c:if test="${changes gt 0}">
			<%-- find the first modification --%>
			<c:set var="firstModification" value="${changeSet.firstModifiedFile}"/>
			<c:if test="${! empty firstModification}">
				<c:if test="${showChangedRevisions}">
					${firstModification.oldRevision} &rarr; ${firstModification.newRevision}
				</c:if>

				<spring:message var="diffTitle" code="scm.commit.diff.label" text="Diff"/>
				<a href="${diffURL}" title="${diffTitle}" target="_blank" onclick="launch_url('${diffURL}', 'full_half');return false;" style="margin-left:10px;">
					<img src='<c:url value="/images/newskin/action/popup.png" />' />
				</a>
				<spring:message var="expandDiffTitle" code="scm.commit.expand.diff.label" text="Click here to expand/collapse diff"/>
				<a href="#" title="${expandDiffTitle}">
					<img class="toggleLink" src='<c:url value="/images/space.gif" />'
						onclick="showDiff.toggleAllDiffs(this, 'changefiles_${changeSet.id}'); return false;"></img>
				</a>
			</c:if>
		</c:if>
		</c:if>
		</span>

		<ul class="changeset" id="changefiles_${changeSet.id}">
			<c:choose>
			<c:when test="${changes < changeFilesLimit}">
			<c:forEach var="changeFile" items="${changeFiles}">
				<c:set var="fileName" value="${changeFile.path}" />

				<c:url var="historyLink" value="${changeFile.historyUrlLink}"/>

				<li class="changeset">
					<c:choose>
						<c:when test="${changeFile.action eq 'A'}">
							<div class="added changeFileBox"><spring:message code="scm.commit.file.added" text="added"/></div>
						</c:when>
						<c:when test="${changeFile.action eq 'D'}">
							<div class="deleted changeFileBox"><spring:message code="scm.commit.file.deleted" text="deleted"/></div>
							<c:set var="historyLink" value="" />
						</c:when>
						<c:otherwise>
							<div class="modified changeFileBox"><spring:message code="scm.commit.file.modified" text="modified"/></div>
						</c:otherwise>
					</c:choose>

					<c:choose>
						<c:when test="${!empty historyLink}">
							<spring:message var="historyTitle" code="scm.browse.history.label" text="History"/>
							<a href="${historyLink}" title="${historyTitle}"><c:out value="${fileName}" /></a>
						</c:when>
						<c:otherwise>
							<c:out value="${fileName}" />
						</c:otherwise>
					</c:choose>
					<c:if test="${canBrowseFiles || empty canBrowseFiles}">
						<c:if test="${changeFile.action eq 'M'}">
							<c:set var="diffChangeFile" scope="request" value="${changeFile}"/>
							<jsp:include page="/scm/includes/showDiff.jsp"/>
						</c:if>
					</c:if>
				</li>
			</c:forEach>
			</c:when>
			<c:otherwise>
				<spring:message var="tooManyTitle" code="scm.commit.file.tooMany" text="Too many changed files"/>
				<li class="changeset" title="${tooManyTitle}">...</li>
			</c:otherwise>
			</c:choose>
		</ul>

</span>