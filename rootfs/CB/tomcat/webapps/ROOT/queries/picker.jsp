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

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<link rel="stylesheet" href="<ui:urlversioned value='/queries/queries.less' />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/js/reportSupport.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/reportPage.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/reportPicker.js'/>"></script>

<ui:actionMenuBar>
	<spring:message code="queries.picker.title.label" text="Query Finder"/>
	<br/>
</ui:actionMenuBar>

<c:set var="filterPart">
	<div class="pickerFilterContainer">
		<div class="treeSearchBoxContainer">
			<spring:message var="filterLabel" code="Filter" text="Filter"/>
			<div class="treeSearchContainer">
				<div class="treeSearchField">
					<input class="treeFilterBox withButton" type="text" id="filter" name="filter" autocomplete="off" placeholder="${filterLabel}" title="${filterLabel}" />
					<button id="filterSearch" class="treeSearchToggleButton" type="button"/>
				</div>
			</div>
		</div>
	</div>
	<div class="pickerTypeSelectorContainer">
		<select id="optionSelector" multiple="multiple">
			<option value="-1"<c:if test="${fn:contains(optionIds, -1)}"> selected="selected"</c:if>><spring:message code="queries.picker.myqueries.label" text="My Reports"/></option>
			<option value="0"<c:if test="${fn:contains(optionIds, 0)}"> selected="selected"</c:if>><spring:message code="queries.picker.sharedqueries.from.any.projects.label"/></option>
			<optgroup label="<spring:message code="queries.picker.sharedqueries.from.recent.projects.label"/>">
				<c:forEach items="${projects.get('recent')}" var="project">
					<option value="${project.get('id')}"<c:if test="${fn:contains(optionIds, project.get('id'))}"> selected="selected"</c:if>>${project.get('name')}</option>
				</c:forEach>
			</optgroup>
			<optgroup label="<spring:message code="queries.picker.sharedqueries.from.other.projects.label"/>">
				<c:forEach items="${projects.get('all')}" var="project">
					<option value="${project.get('id')}"<c:if test="${fn:contains(optionIds, project.get('id'))}"> selected="selected"</c:if>>${project.get('name')}</option>
				</c:forEach>
			</optgroup>
		</select>
	</div>
</c:set>

<c:if test="${reportSelectorMode}">
	<ui:actionBar>
		<spring:message var="setButton" code="button.set" text="Set"/>
		<input type="submit" class="button" name="setButton" value="${setButton}"/>
		<spring:message var="clearButton" code="issue.references.clear.tooltip" text="Clear selection"/>
		<input type="button" class="button" name="clearButton" value="${clearButton}"/>
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" onclick="inlinePopup.close()" />
		<span class="reportPickerFilterArea">${filterPart}</span>
	</ui:actionBar>
</c:if>

<div class="contentWithMargins">
	<c:if test="${reportSelectorMode}">
		<form>
		<input type="hidden" name="reportSelectorMode" value="true">
		<input type="hidden" name="selectedItem" value="${selectedItem}">
		<input type="hidden" name="opener_htmlId" value="${opener_htmlId}">
	</c:if>
	<c:if test="${!reportSelectorMode}">${filterPart}</c:if>
 	<div id="pickerTab" data-sort="${sort}" data-dir="${dir}">
		<jsp:include page="pickerTab.jsp"/>
 	</div>
	<c:if test="${reportSelectorMode}">
		</form>
	</c:if>
</div>

<script type="text/javascript">
	$(function() {
		codebeamer.ReportPicker.init();
	});
</script>