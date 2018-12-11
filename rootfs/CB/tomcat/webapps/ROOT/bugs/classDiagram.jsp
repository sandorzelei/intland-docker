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
<meta name="decorator" content="popup"/>
<meta name="module" content="tracker"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<link type="text/css" rel="stylesheet" href="<ui:urlversioned value="/stylesheet/trackerHomePage.less"/>"/>
<script type="text/javascript" src="<ui:urlversioned value="/js/trackerHomePage.js" />"></script>

<c:if test="${!trackerMode}">
	<style type="text/css">
		#rightPane {
			display: none;
		}
	</style>
</c:if>

<ui:pageTitle prefixWithIdentifiableName="false" printBody="false">
	<c:out value="${project.name}"/> - <spring:message code="tracker.class.diagram.label" text="Class Diagram"/>
</ui:pageTitle>

 <spring:message var="graphEditorTitleLabel" code="tracker.class.diagram.label" />
 <div>
 	<ui:actionMenuBar><b><c:out value="${project.name}"/><c:if test="${not empty trackerName}"><span class="breadcrumbs-separator">&raquo;</span><c:out value="${trackerName}"/></c:if><span class="breadcrumbs-separator">&raquo;</span><c:out value="${graphEditorTitleLabel}"/></b></ui:actionMenuBar>
 </div>

<c:choose>
	<c:when test="${trackerMode}">
		${graphHtmlMarkup}
	</c:when>
	<c:otherwise>

		<ui:splitTwoColumnLayoutJQuery cssClass="layoutfullPage autoAdjustPanesHeight classDiagram" isPopup="true">
			<jsp:attribute name="leftPaneActionBar">
				<a class="scalerButton"></a>
				<div class="filterBoxContainer">
					<ui:treeFilterBox treeId="treePanePopup" />
				</div>
			</jsp:attribute>
			<jsp:attribute name="leftContent">
				<div id="treePanePopup" data-projectId="${project.id}" style="height: calc(100% - 30px);overflow:auto;"></div>
			</jsp:attribute>
			<jsp:attribute name="middlePaneActionBar">
			</jsp:attribute>
			<jsp:body>
				${graphHtmlMarkup}
			</jsp:body>
		</ui:splitTwoColumnLayoutJQuery>

		<ui:treeControl containerId="treePanePopup" url="${contextpath}/ajax/getTrackerHomePageTree.spr?proj_id=${projectId}&mode=references"
						layoutContainerId="panes" rightPaneId="rightPane" headerDivId="headerDiv" disableTreeCookies="true"
						editable="false" revision="{not empty pageRevision.baseline ? pageRevision.baseline.id : 'null'}"
						nodeMovedHandler="codebeamer.TrackerHomePage.moveNodeHandler"
						populateContextMenuFnName="codebeamer.TrackerHomePage.populateReferenceModeContextMenuFunction"
						useCheckboxPlugin="true" isPopup="true" restrictCheckboxCascade="true"/>

		<script type="text/javascript">
			window.parent.$("#inlinedPopupIframe").load(function() {
				var selectedTrackerIds = [];
				<c:forEach items="${selectedVisibleTrackers}" var="visibleTracker">
					selectedTrackerIds.push(${visibleTracker});
				</c:forEach>
				codebeamer.TrackerHomePage.init($("#treePanePopup"), false, true, selectedTrackerIds);
			});
		</script>
	</c:otherwise>
</c:choose>