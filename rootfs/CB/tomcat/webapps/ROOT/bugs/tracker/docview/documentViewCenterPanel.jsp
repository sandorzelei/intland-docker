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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ page import="com.intland.codebeamer.persistence.util.Baseline"%>
<%@ page import="com.intland.codebeamer.persistence.util.Directory"%>
<%@ page import="com.ecyrd.jspwiki.providers.ProviderUtils"%>

<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/fieldAccessControl.css'/>" />

<ui:globalMessages/>

<input type="hidden" value="<c:out value='${subtreeRoot}'/>" id="subtreeRoot"/>

<%--
	Note: see documentView.less for some css definitions and the CB-Style.css for some others...
 --%>
<script src="<ui:urlversioned value="/bugs/tracker/docview/documentView.js"/>"></script>
<script src="<ui:urlversioned value='/js/overlayCommentEditor.js'/>"></script>
<script src="<ui:urlversioned value='/js/IssueDescriptionPoller.js'/>"></script>

<c:if test="${tracker.testCase}">
	<script type="text/javascript" src="<ui:urlversioned value="/js/editTestStep.js"/>"></script>
</c:if>

<script type="text/javascript">

	jQuery(function($) {
		ShowMenu.IE_FixForLeftAlignedMenus = true;
		codebeamer.descriptionRequired = ${descriptionRequired};
		codebeamer.showSuspectedInTree = ${markSuspected};
		codebeamer.loadedLevels = "${loadedLevels}" == "" ? 1000 : parseInt("${loadedLevels}");

		// set the editor description format to wiki
		codebeamer.templateDescriptionFormat = "W";
	});

	// make variable to boolean
	var isOfficeEditEnabled = ("${officeEditEnabled}" == "true");

</script>

<c:if test="${param.mode == 'edit'}">
	<script type="text/javascript">
		jQuery(function($){
			$($(".requirementTr#${param.issueId} .editable")[1]).dblclick();
		});
	</script>
</c:if>
<%
Baseline baseline = null;
try {
	baseline = (Baseline) request.getAttribute("baseline");
	if (baseline != null) {
		ProviderUtils.pushPageContext(baseline);
	}
%>

<c:set var="callbackUrl" value="${tracker.urlLink}" scope="request"/>

<c:if test="${!empty baseline}">
	<c:set var="callbackUrl" value="${callbackUrl}?revision=${baseline.id}" scope="request"/>
</c:if>

<spring:message var="toggleAll"   code="search.what.toggle" text="Select/Clear All"/>
<spring:message var="toggleTitle" code="tracker.view.layout.document.paragraph.expand.tooltip" text="Click here to expand/collapse attributes"/>

<jsp:useBean id="decorated" beanName="decorated" scope="request" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" />
<c:if test="${not empty foundIssueCount}">
	<c:if test="${editableView}">
		<spring:message var="warningMessage" code="tracker.view.layout.document.too.many.results.editable" arguments="${foundIssueCount},${issueLimit},${editViewUrl}"/>
	</c:if>
	<c:if test="${!editableView}">
		<spring:message var="warningMessage" code="tracker.view.layout.document.too.many.results" arguments="${foundIssueCount},${issueLimit}"/>
	</c:if>
	<script type="text/javascript">
		GlobalMessages.showMessage("warning", "${warningMessage}");	<%-- no need to adjust the layout, because the globalMessages is INSIDE of the middle part --%>
	</script>
</c:if>

<c:choose>
<c:when test="${fn:length(paragraphs) != 0}">
<table id="requirements" class="displaytag fullExpandTable ${not empty baseline ? 'baseline' : ''}" style="table-layout: fixed;">
	<c:if test="${!empty comparedBaseline}">
		<tr>
			<td class="control-bar"></td>
			<td style="padding: 0">
				<c:url value="/proj/tracker/compareBaselines.spr" var="compareUrl">
					<c:param name="tracker_id" value="${tracker.id }"/>
					<c:param name="revision1" value="${comparedBaseline.id }"/>
					<c:param name="revision2" value=""/>
				</c:url>
				<div id="docbaselineinfo">
					<spring:message code="baseline.view.item.diffs" arguments="${comparedBaseline.name},${compareUrl}"/>
				</div>
			</td>
		</tr>
	</c:if>
	<c:if test="${showOnlyOpen}">
		<tr>
			<td class="control-bar"></td>
			<td>
				<div class="smallWarning">
					<spring:message code="tracker.view.layout.document.onlyOpen.hint"
						text="Only the open items are shown in this view. You can change this under the tree settings."/>
				</div>
			</td>
		</tr>
	</c:if>
	<c:if test="${someLevelsRemoved}">
		<tr>
			<td class="control-bar"></td>
			<td>
				<div class="smallWarning"><spring:message code="tracker.view.layout.document.removed.levels.hint" text="Some children of the selected issue are not displayed. To be able to see them navigate deeper in the tree."/></div>
			</td>
		</tr>
	</c:if>
	<c:if test="${not empty pinnedItemId}">
		<tr>
			<td class="control-bar"></td>
			<td>
				<div class="smallWarning">
					<spring:message code="tracker.view.layout.document.item.pinned.hint"/>
				</div>
			</td>
		</tr>
	</c:if>
	<c:if test="${!empty pathToRoot }">
		<c:forEach items="${pathToRoot}" var="parent">
			<tr id="${item.id}">
				<td class="control-bar"></td>
				<td class="textSummaryData requirementTd">
					<h${parent.key.level} class="name">
						<span class="releaseid"><c:out value="${parent.key.release}" escapeXml="false"/></span>
						<span><c:out value="${parent.value.name}"/></span>
					</h${parent.key.level}>
				</td>
			</tr>
		</c:forEach>
	</c:if>

	<jsp:include page="documentViewRows.jsp"/>
</table>

</c:when>

<c:when test="${canCreateIssue && rootItemNotInTracker != true}">
	<c:url value="${tracker.createContainedUrlLink}" var="trackerUrl">
		<c:param name="isPopup" value="true"/>
	</c:url>
	<c:set var="jsUrl" value="javascript:(function(){trackerObject.addTopLevelRequirement(); return false;}())"/>
	<div id="emptyViewMessage" style="text-align: center; padding: 10px;">
		<spring:message code="document.no.issues.hint" arguments="${tracker.type.name}"/><br>
		<strong><a href="#" onclick="${jsUrl}"><spring:message code="document.add.first.item.label" arguments="${tracker.type.name}"/></a></strong>
	</div>
</c:when>
<c:when test="${not empty baseline and fn:length(paragraphs) == 0 }">
	<c:url value="${tracker.urlLink}" var="compareUrl">
		<c:param name="comparedBaselineId" value="${baseline.id }"></c:param>
	</c:url>
	<ui:baselineInfoBar projectId="${tracker.project.id}"
				baselineName="${baseline.name}" baselineParamName="revision" compareUrl="${compareUrl}" showCompareButton="true"/>

</c:when>
</c:choose>

<c:set var="branchOrTracker" value="${empty branch ? tracker : branch }"/>

<c:if test="${rootItemNotInTracker == true }">
	<div class="warning">
		<c:url var="trackerUrl" value="${ui:removeXSSCodeAndHtmlEncode(branchOrTracker.urlLink)}"/>
		<spring:message code="document.view.subtree.root.doesnt.exist"
			text="The selected subtree root item does not exist in this tracker. To load the whole tracker click on this link:"></spring:message>
		<a href="${trackerUrl }"><c:out value="${ui:removeXSSCodeAndHtmlEncode(branchOrTracker.name)}"></c:out></a>
	</div>
</c:if>

<div id="editorTemplateDiv" style="display: none;" data-entity-type-id="${decorated.trackerItemEntityId}"
	data-project-id="${item.project.id}" data-entity-id="cbEntityIDTemplate">
</div>

<div id="newItemTemplate" style="display:none">
	<table>
		<tr class="requirementTr" id="#new-item-id" data-summary-editable="true" data-summary-required="${summaryRequiredForNewItem }">
			<td class="control-bar"></td>
			<td class="textSummaryData requirementTd">
				<h2 class="name" draggable="false" data-issueid="#new-item-id" issueid="#new-item-id">
					<span class="editable"></span>
					<div style="clear:both;"></div>
				</h2>
				<div class="description">
					<div class="editable new-item description-container" data-description-format="W"></div>
				</div>
			</td>
		</tr>
	</table>
</div>

<%-- adding the new step template to the page - but only if the tracker is a test case tracker --%>
<c:if test="${tracker.testCase}">
	<ui:testStepsNewRowTemplate uploadConversationId="#uploadConversationId" />
</c:if>

<%
} finally {
	if (baseline != null) {
		ProviderUtils.popPageContext(baseline);
	}
}
%>

<ui:delayedScript flush="true" />

