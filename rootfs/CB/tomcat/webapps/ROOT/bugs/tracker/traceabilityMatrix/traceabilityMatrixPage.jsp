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
<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>
<meta name="bodyCSSClass" content="newskin" />

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<ui:actionMenuBar >
	<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
	<ui:pageTitle prefixWithIdentifiableName="false">
		<span>Traceability matrix: <c:out value='${horizontalTracker.name}'/> / <c:out value='${horizontalTrackerView.name}'/> <span style="font-size:150%">&harr;</span> <c:out value='${verticalTracker.name}'/> / <c:out value='${verticalTrackerView.name}'/></span>
	</ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<script type="text/javascript">
	function showFilterOverlay() {
		var url = "${pageContext.request.contextPath}/proj/tracker/traceabilitymatrix.spr?proj_id=${projectId}&mode=popup&tracker_id=${horizontalTracker.id}&h_view_id=${horizontalTrackerView.id}&v_tracker_id=${verticalTracker.id}&v_view_id=${verticalTrackerView.id}";
		inlinePopup.show(url);
		return false;
	}
</script>

<ui:actionBar>
	<input id="selectButton" type="button" class="button" onclick="return showFilterOverlay();" value="Change views" />
</ui:actionBar>

<div class="contentWithMargins">
 <c:set var="horizontalViewLabel"><c:out value='${horizontalTracker.name}'/> / <c:out value='${horizontalTrackerView.name}'/>: ${fn:length(horizontalTrackerItems)}</c:set>
 <c:set var="verticalViewLabel"><c:out value='${verticalTracker.name}'/> / <c:out value='${verticalTrackerView.name}'/>: ${fn:length(verticalTrackerItems)}</c:set>

 <c:set var="extraHeaderRow" scope="request">
	<th>
		<spring:message var="exportToExcel" code="tracker.traceability.browser.export" text="Export to Excel"/>
		<a href="${exportLink}" class="exportToExcel">${exportToExcel}</a>
	</th>
	<th class="horizontalLabel" colspan="${fn:length(horizontalTrackerItems)}">
		<label class="axisLabel">${horizontalViewLabel}</div>
		<div style="clear:both;"></div>
	</th>
 </c:set>
 <c:set var="topleftCorner" scope="request">
	<label class="axisLabel">${verticalViewLabel}</label>
	<div style="clear:both;"></div>
 </c:set>
 <jsp:include page="./traceabilityMatrix.jsp"/>
</div>
