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

<div class="contentWithMargins">
	<c:set var="versions" value="${versionsViewModel.trackerItems}" />
	<c:choose>
		<c:when test="${! empty versions}">
			<table class="versions" id="versionsTable" data-tracker-id="${tracker.id}">
				<tr>
					<td class="leftColumn">
						<c:set var="hideReleasedVersionsByDefault" value="${true}" scope="request" />
						<jsp:include page="./versionsViewReleasesList.jsp" flush="true" />
					</td>
					<td class="rightColumn">
						<%-- shortcuts --%>
						<div class="versionShortcuts">
							<h1><spring:message code="tracker.${tracker.name}.label" text="${tracker.name}"/></h1>
							<div class="releasesControls">
								<div class="row">
									<div class="cell">
										<c:url var="plannerUrl" value="/category/${tracker.id}/planner?openProductBacklog=false" />
										<a class="plannerLink planReleasesLink" href="${plannerUrl}"><spring:message code="cmdb.version.planReleases.label" text="Plan releases"/></a>
									</div>
									<div class="cell">
										<label id="showReleasedLabel"><input id="showReleased" type="checkbox" autocomplete="off" ${showReleasedVersions ? ' checked="checked"' : ''}>
											<spring:message code="cmdb.version.showReleased.label" text="Show released"/>
										</label>
									</div>
								</div>
								<div class="row">
									<div class="cell">
										<c:url var="backlogUrl" value="/category/${tracker.id}/planner?openProductBacklog=true" />
										<a class="plannerLink openBacklog" href="${backlogUrl}"><spring:message code="cmdb.version.openBacklog.label" text="Open Product Backlog"/></a>
									</div>
								</div>
							</div>
							<ul class="versions-mini-tree">
								<c:set var="indent" value="true" />
								<c:forEach items="${versions}" var="version" >
									<c:set var="info" value="${versionsViewModel.info[version]}" />
									<li class="${version.resolvedOrClosed ? 'released' : ''}${info.itselfOrAnyParentIsReleased ? ' toggle-by-released' : ''}" data-target-version-id="${version.id}"
																				style="margin-left: ${indent ? info.level : 0}em;">
										<a href="#${version.id}" onclick="VersionUtils.expandVersion('${version.id}');"><c:out value="${version.name}"/></a>
										<c:if test="${version.resolvedOrClosed}"> <span class="released"> <spring:message code="cmdb.version.released.label" text="Released"/>
											<c:if test="${version.closed}"> (<spring:message code="cmdb.version.endOfLife.label" text="end of life"/>)</c:if></span>
										</c:if>
									</li>
								</c:forEach>
							</ul>
						</div>
					</td>
				</tr>
			</table>
		</c:when>
		<c:otherwise>
			<spring:message code="table.nothing.found" text="No items found."/>
		</c:otherwise>
	</c:choose>
</div>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/versionStats.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/release.js'/>"></script>

<script type="text/javascript">
	// setup showReleased checkbox
	jQuery(function($) {
		var cb = $("#showReleased");
		if (cb.prop("initialized") !== true) {
			cb.click(function() {
				VersionUtils.showHideAllReleased();
			});
			cb.prop("initialized", true);
		}
	});

	var reload = function () {
		location.reload();
	};
</script>
