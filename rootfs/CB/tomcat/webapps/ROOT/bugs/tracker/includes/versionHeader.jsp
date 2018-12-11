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

<div class="${! empty headerCenteredFragment ? 'versionHeaderWithCenteredFragment' : ''}">

<%--
	JSP fragment renders the header block for Versions-view

	Expected parameters
	- request.version		- the TrackerItemDto of the version
	- request.versionStat	- the VersionStatsDto object contains the version statistics
	- param.showActionLinks	- If the actionlinks/menu is shown. Optional, defaults to true
	- param.versionAsLink   - If false, versions will be displayed in plain text, not as a link.
	                          Optional, default is true.
	- request.headerCenteredFragment	- Optional html fragment to insert to the center of header
--%>

<c:set var="revision" value="${!empty baseline ? ('?revision='.concat(baseline.id)) : ''}"/>
<c:url var="versionLinkAction" value="/item/${version.id}/stats${revision}" />

<div class="leftPart" style="padding-right:${paddingAmount}px;">
${buttonsAheadOfVersion}
<c:choose>
	<c:when test="${param.versionAsLink == false || (version.id == releaseId)}">
		<span class="version"><ui:noSummaryPlaceholder value="${version.reqIfSummary}"/></span>
	</c:when>
	<c:otherwise>
		<ct:call object="${versionsViewModel}" method="isLinkToVersionActive" param1="${version}" return="activateLink" />
		<a class="version<c:if test='${isInvidualReleaseDashboard && !activateLink}'> expander-delegate</c:if>" href="${versionLinkAction}"><ui:noSummaryPlaceholder value="${version.reqIfSummary}"/></a>
	</c:otherwise>
</c:choose>

<span class="dueDate">
<c:choose>
	<c:when test="${version.resolvedOrClosed}">
		<%-- released --%>
		<c:if test="${not empty versionStat.actualReleaseDate}">
			<span class="subtext" >(<spring:message code="cmdb.version.released.label" text="Released"/>: <tag:formatDate value="${versionStat.actualReleaseDate}" type="date"/><c:if test="${version.closed}">&nbsp;<spring:message code="cmdb.version.endOfLife.label" text="end of life"/></c:if>)</span>
		</c:if>
	</c:when>
	<c:otherwise>
		<%-- not released yet --%>
		<c:choose>
			<c:when test="${not empty versionStat.plannedReleaseDate}">
				<c:choose>
					<c:when test="${versionStat.daysLeft >= 0}">
						<spring:message code="cmdb.version.dueIn.label" text="due in {0} days" arguments="${versionStat.daysLeft}"/>
					</c:when>
					<c:otherwise>
						<span class="late"><spring:message code="cmdb.version.lateBy.label" text="late by {0} days" arguments="${-versionStat.daysLeft}"/></span>
					</c:otherwise>
				</c:choose>
				<span class="plannedReleaseDate">(<tag:formatDate value="${versionStat.plannedReleaseDate}" type="date"/>)</span>
			</c:when>
			<c:otherwise>
				<span class="plannedReleaseDate" ><spring:message code="cmdb.version.notScheduled.label" text="(not scheduled)"/></span>
			</c:otherwise>
		</c:choose>
	</c:otherwise>
</c:choose>
</span>

<c:if test="${fn:length(version.description) > 0}">
	<div class="description subtext">
		<tag:transformText owner="${version}" value="${version.description}" format="${version.descriptionFormat}"/>
	</div>
</c:if>

<div class="release-notes-container">
	<ui:actionLink keys="releaseNotes" builder="versionsViewActionMenuBuilder" subject="${version}" />
</div>


</div>

<c:if test="${! empty headerCenteredFragment}">
	<div class="headerCenteredFragment">${headerCenteredFragment}</div>
</c:if>

<c:choose>
	<c:when test="${empty param.showActionLinks || param.showActionLinks != 'false'}">
		<div class="versionActionLinks">
			<div class="menuArrowDown versionMoreMenu" id="more-menu-${version.id}" data-id="${version.id}"></div>
			<div class="versionQuickAction">
				<ui:actionLink builder="versionsViewActionMenuBuilder" keys="planner" subject="${version}" withIcon="true" hideLabel="true"/>
			</div>
			<div class="versionQuickAction">
				<ui:actionLink builder="versionsViewActionMenuBuilder" keys="cardboard" subject="${version}" withIcon="true" hideLabel="true"/>
			</div>
			<div class="versionQuickAction">
				<ui:actionLink builder="versionsViewActionMenuBuilder" keys="traceability" subject="${version}" withIcon="true" hideLabel="true"/>
			</div>
			<div class="versionQuickAction">
				<ui:actionLink builder="versionsViewActionMenuBuilder" keys="coverageBrowser" subject="${version}" withIcon="true" hideLabel="true"/>
			</div>
		</div>
	</c:when>
</c:choose>

</div>



