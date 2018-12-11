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
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="trackersModule newskin ${importForm.tracker.isBranch() ? 'tracker-branch' : '' }" />

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/documentView.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/multiselect.less' />" type="text/css" media="all" />

<style type="text/css">

	#east {
		overflow-y: auto !important;
	}

	#middleHeaderDiv, #rightHeaderDiv {
		height: 19px;
	}

	#treePane a {
		cursor: pointer;
	}

	#treePane a:hover {
		text-decoration: none;
		color: #0093B8;
	}

	#treePane a > .jstree-icon, .itemIcon, .legend {
		background-image: url("${trackerIconUrls.get(importForm.tracker)}");
		background-position: 0 !important;
		background-color: #27C27C;
	}

	#treePane a > .jstree-icon.deselected {
		background-color: #D2D2D2;
	}

	#treePane a > .jstree-checkbox {
		display: none;
	}

	#treePane .itemIcon, .legend {
		width:16px;
		height: 16px;
		display: inline-block;
		margin-right: 3px;
	}

	#wordStyles {
		width: 100%;
	}
	#wordStyles td label {
		font-size: 14px;
	}
	#wordStyles td.checkbox {
		/*width: 5%;*/
		display: none;
	}
	#wordStyles td.dataCell select {
		width: 100%;
		margin-bottom: 0.6em;
	}
	.newskin #requirements {
		margin-left: 0;
	}
	.elementContainer .summaryIcon {
		background-image: url("${trackerIconUrls.get(importForm.tracker)}");
		background-position: 0;
		width: 16px;
		height: 16px;
		display: inline-block;
		margin-top: 9px;
	}
	.elementContainer .toBeImported {
		color: #777;
		font-size: 11px;
		display: block;
	}
	.elementContainer .description {
		padding: 0 0.3em;
		margin-bottom: 0.5em !important;
	}
	.elementContainer .control-bar {
		vertical-align: top;
	}
	.elementContainer .switch {
		background-image: url("${pageContext.request.contextPath}/images/newskin/action/sprite_w_import_switch.png");
		display: inline-block;
		width: 16px;
		height: 32px;
		margin-top: 0.5em;
		cursor: pointer;
	}
	.elementContainer.include .switch {
		background-position: 0 0;
	}
	.elementContainer.notInclude .switch {
		background-position: 0 32px;
	}
	.elementContainer.include .control-bar {
		border-right: 5px solid #27C27C;
	}
	.elementContainer.notInclude .control-bar {
		border-right: 5px solid #D2D2D2;
	}
	.elementContainer.include .summaryIcon {
		background-color: #27C27C;
	}
	.elementContainer.notInclude .summaryIcon {
		background-color: #D2D2D2;
	}
	.elementContainer.notInclude .name {
		color: #BDBDBD;
	}
	.elementContainer.notInclude .name .releaseid {
		color: #DBDBDB;
	}
	.elementContainer.notInclude .description {
		color: #BDBDBD !important;
	}
	#rightContentAccordion .accordion-content {
		padding: 0 !important;
	}
	.stylesContainer, .ruleContainer {
		padding: 0.3em 0.7em;
		border-bottom: 1px solid #e2e2e2;
	}
	.ruleContainer .allConditionContainer, .branchContainer {
		margin-bottom: 0.5em;
		padding-left: 0.3em;
	}
	.branchContainer button {
		min-width: 300px !important;
		max-width: 300px;
	}
	.rule {
		padding: 0.5em;
		margin-bottom: 0.7em;
		background-color: #f2f2f2;
	}
	.ruleContainer select.styleAction {
		width: 100%;
		height: 22px;
		margin-bottom: 0.5em;
	}
	.ruleContainer .removeRule {
		position: relative;
		display: inline-block;
		width: 12px;
		height: 12px;
		float: right;
		top: -5px;
		right: -5px;
		cursor: pointer;
		background: url("${pageContext.request.contextPath}/images/newskin/action/delete-grey-12x12.png");
	}
	.ruleContainer .condition {
		margin-bottom: 0.5em;
	}
	.ruleContainer .condition table {
		width: 100%;
	}
	.ruleContainer .condition .conditionType {
		width: 10%;
	}
	.ruleContainer .condition .conditionRemoveTd {
		width: 5%;
	}
	.ruleContainer .condition .conditionRemoveTd span.conditionRemove {
		display: inline-block;
		width: 16px;
		height: 10px;
		cursor: pointer;
		background: url("${pageContext.request.contextPath}/images/newskin/action/delete-grey-xs.png") no-repeat 4px 1px;
	}
	.ruleContainer .condition .conditionType select {
		height: 23px;
		width: 170px;
	}
	.ruleContainer .condition .conditionText input {
		width: 100%;
		height: 13px;
		font-size: 12px;
		padding-left: 0;
		padding-right: 0;
	}
	.ruleContainer .condition .conditionText button {
		width: 100% !important;
		min-height: 23px;
	}
	.ruleContainer .addNewCondition {
		font-size: 12px !important;
		padding-left: 0.3em;
	}
	.importSettingLabel {
		padding: 0.3em 0.7em;
		font-weight: bold;
	}

	#addNewRuleButton {
		margin-bottom: 0.2em;
		font-size: 18px !important;
		padding: 0;
		min-width: 50px;
		width: 15px;
		min-height: unset;
		height: 20px;
		color: #5F5F5F !important;
	}

	.ruleInformation {
		margin: 0.3em 0 !important;
	}

	.buttonContainer {
		padding: 1em 0.3em 0.3em 0.3em;
	}
	.buttonContainer input,
	#middleHeaderDiv input {
		color: #0093b8 !important;
		padding: 3px 10px 3px 30px;
		background-position: 10px 3px;
		background-repeat: no-repeat !important;
		margin: 0.3em;
	}
	.buttonContainer .preview,
	#middleHeaderDiv .preview {
		background-image: url("${pageContext.request.contextPath}/images/newskin/action/icon_preview.png") !important;
	}
	.buttonContainer .import,
	#middleHeaderDiv .import {
		background-image: url("${pageContext.request.contextPath}/images/newskin/action/icon_word.png") !important;
	}
	.buttonContainer .cancelButton,
	#middleHeaderDiv .cancelButton {
		padding: 3px 10px;
		float: right;
	}
	#middleHeaderDiv .import {
		position: relative;
		top: -5px;
		height: 22px;
		background-color: white !important;
	}
	#middleHeaderDiv .cancelButton {
		position: relative;
		top: -5px;
	}
	#statisticsBox {
		width: 100%;
	}
	#statisticsBox tr.empty {
		display: none;
	}
	#statisticsBox td {
		padding: 0.3em;
		border-bottom: 1px solid #F5F5F5;
		white-space: normal !important;
	}
	#statisticsBox td.number {
		width: 5%;
		text-align: center;
		font-weight: bold;
	}
	#statisticsBox td.number span {
		font-size: 11px;
	}
	.disabledOption, .disabledOption a {
		color: #BDBDBD !important;
		cursor: default !important;
	}
	.ui-dialog-content a {
		color: #0093b8 !important;
	}
	#requirements .name .summaryText {
		cursor: pointer;
	}
	#requirements .description {
		padding-top: 3px !important;
	}
	#requirements .description p {
		padding: 0;
		margin: 0.5em;
	}
	#extraFormProperties {
		display: none;
	}
	#vakata-contextmenu li ul {
		background: white !important;
	}
	ul.ui-multiselect-checkboxes {
		min-height: auto !important;
	}
</style>

<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">
		<ui:branchBaselineBadge branch="${importForm.branch}"/>
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" projectAware="${importForm.tracker}" ><span class='breadcrumbs-separator'>&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="issue.import.title" text="Importing Items"/></ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<c:set var="size" value="${fn:length(allElements)}"/>
<spring:message var="importButton" code="button.save"/>
<spring:message var="previewButton" code="button.preview"/>
<spring:message var="cancelButton" code="button.cancel"/>

<form:form commandName="importForm" action="${flowUrl}">

<c:if test="${empty allElements}">
	<%-- show the go-back button if nothing is found --%>
	<ui:actionBar>
		<spring:message var="backButton" code="button.back" text="&lt; Back"/>
		<input type="submit" class="button" name="_eventId_cancel" value="${backButton}" />
	</ui:actionBar>
</c:if>
<ui:globalMessages/>

<form:hidden path="trackerId" id="trackerIdInput"/>
<ui:splitTwoColumnLayoutJQuery cssClass="layoutfullPage" rightMinWidth="400">
	<jsp:attribute name="leftPaneActionBar">
		&nbsp;
		<a class="scalerButton"></a>
	</jsp:attribute>
	<jsp:attribute name="leftContent">
		<div id="treePane" style="height:94%;overflow:auto;">
			${htmlPreViewMarkup}
		</div>
	</jsp:attribute>
	<jsp:attribute name="rightPaneActionBar">
		<a class="scalerButton" style="left: -8px;"></a>
	</jsp:attribute>
	<jsp:attribute name="middlePaneActionBar">
		<a class="scalerButton"></a>
	</jsp:attribute>
	<jsp:attribute name="rightContent">
		<div class="accordion" id="rightContentAccordion">
			<h3 class="accordion-header"><spring:message code="word.import.import.options.label" text="Import Settings"/></h3>
			<div class="accordion-content">
				<div class="ruleContainer">
					<div id="rules"></div>
					<spring:message var="addNewRuleLabel" code="word.import.add.new.rule.label" text="Add new Rule"/>
					<input type="button" id="addNewRuleButton" class="button" value="+" title="${addNewRuleLabel}">
					<div class="information ruleInformation">
						<spring:message code="word.import.rule.information"/>
					</div>
				</div>
			</div>
			<h3 class="accordion-header"><spring:message code="Statistics" text="Statistics"/></h3>
			<div class="accordion-content">
				<table id="statisticsBox">
					<c:set var="allElementCount" value="${fn:length(allElements)}"/>
					<c:forEach items="${styleActions}" var="styleAction">
						<spring:message var="styleActionLabel" code="word.import.style.action.${styleAction.name}"/>
						<c:choose>
							<c:when test="${styleAction.id == 3}">
								<c:forEach items="${availableTrackers}" var="availableTracker">
									<spring:message var="trackerName" code="tracker.${availableTracker.name}.label" text="${availableTracker.name}"/>
									<tr class="empty" data-action-id="${availableTracker.id}">
										<td class="number"><span class="storyPointsLabel open">0</span></td>
										<td><spring:message code="word.import.add.to.tracker.label" arguments="${trackerName}"/></td>
									</tr>
								</c:forEach>
							</c:when>
							<c:when test="${styleAction.id == 4}">
								<c:forEach items="${categories}" var="category">
									<spring:message var="categoryLabel" code="issue.flag.${category.name}.label" text="${category.name}"/>
									<tr class="empty" data-action-id="4-${category.id}">
										<td class="number"><span class="storyPointsLabel open">0</span></td>
										<td><spring:message code="word.import.import.as.category.label" arguments="${categoryLabel}"/></td>
									</tr>
								</c:forEach>
							</c:when>
							<c:otherwise>
								<tr class="${styleAction.id == 1 ? '' : 'empty'}" data-action-id="${styleAction.id}">
									<td class="number"><span class="storyPointsLabel open">${styleAction.id == 1 ? allElementCount : 0}</span></td>
									<td>${styleActionLabel}</td>
								</tr>
							</c:otherwise>
						</c:choose>
					</c:forEach>
				</table>
			</div>
		</div>
		<div class="buttonContainer">
			<input id="previewButton" type="button" class="button preview" value="${previewButton}" />
			<input type="submit" id="nextButton" class="button import" name="_eventId_next" value="${importButton}" ${size == 0 ? "disabled='disabled'" : "" }"/>
			<input type="submit" class="button cancelButton" name="_eventId_back" value="${cancelButton}" />
		</div>
	</jsp:attribute>
	<jsp:body>
		<div id="elementBox">
			<table id="requirements">
			<c:forEach var="element" items="${allElements}">

				<tr class="elementContainer include" data-id="${element.generatedId}" data-style-id="${element.properties.get('style-id')}">
					<td class="control-bar">
						<span class="summaryIcon"></span>
						<span class="switch"></span>
					</td>
					<td class="summary textSummaryData requirementTd">
						<div class="toBeImported"><spring:message code="word.import.style.action.add_new_item"/></div>
						<h2 class="name">
							<span class="releaseid">${element.generatedId}</span>
							<span class="summaryText"><c:out value="${element.name}"/></span>
							<img src="${pageContext.request.contextPath}/images/space.gif" class="menuArrowDown">
						</h2>
						<div class="description">
							<c:choose>
								<c:when test="${empty element.markup}">
									--
								</c:when>
								<c:otherwise>
									<tag:transformText value="${element.markup}" format="W"/>
								</c:otherwise>
							</c:choose>
						</div>
					</td>
				</tr>

			</c:forEach>
			</table>
		</div>
		<div id="extraFormProperties">
			<c:forEach items="${usedStyles}" var="style">
				<form:checkbox path="outlineStyles" value="${style.value}" id="box-${style.value}"/>
			</c:forEach>
		</div>
	</jsp:body>
</ui:splitTwoColumnLayoutJQuery>
</form:form>

<script type="text/javascript">

	(function($) {

		var USED_STYLES = {
			<c:forEach items="${usedStyles}" var="style">
				"${ui:escapeJavaScript(style.value)}" : "${ui:escapeJavaScript(style.name)}",
			</c:forEach>
		};

		var STYLE_ACTIONS = [
			<c:forEach items="${styleActions}" var="action">
				{
					actionId: ${action.id},
					name: '<spring:message code="word.import.style.action.${action.name}"/>'
				},
			</c:forEach>
		];

		var ALL_CONDITION_TYPES = [
			<c:forEach items="${allConditionTypes}" var="allConditionType">
				{ id: ${allConditionType.id}, name: '${allConditionType.name}', label: '<spring:message code="word.import.all.condition.type.${allConditionType.name}"/>'},
			</c:forEach>
		];

		var CONDITION_TYPES = [
			<c:forEach items="${conditionTypes}" var="conditionType">
				{
					id: ${conditionType.id},
					name: '${conditionType.name}',
					pattern: '<c:out value="${conditionType.pattern}"/>',
					modifiers: '${conditionType.modifiers}',
					label: '<spring:message code="word.import.condition.type.${conditionType.name}"/>'
				},
			</c:forEach>
		];

		var ELEMENT_NODES = [
			<c:forEach var="element" items="${allElements}">
				<c:if test="${!empty element.children}">
					{
						id: ${element.generatedId},
						name: "${ui:escapeJavaScript(element.name)}"
					},
				</c:if>
			</c:forEach>
		];

		var ICON_URLS = {
			<c:forEach items="${trackerIconUrls}" var="entry">
				'${entry.key.id}' : '${entry.value}',
			</c:forEach>
		};

		var folderIconUrl = "${pageContext.request.contextPath}/images/issuetypes/folder.gif";
		var informationIconUrl = "${pageContext.request.contextPath}/images/issuetypes/information.png";

		var AVAILABLE_TRACKERS = [
			<c:forEach items="${availableTrackers}" var="availableTracker">
				<c:set var="hasMandatoryField" value="false"/>
				<c:if test="${mandatoryFields.containsKey(availableTracker) && not empty mandatoryFields.get(availableTracker)}">
					<c:set var="hasMandatoryField" value="true"/>
				</c:if>
				{
					id: ${availableTracker.id},
					label: "<spring:message code="tracker.${availableTracker.name}.label" text="${ui:escapeJavaScript(availableTracker.name)}"/>",
					hasMandatoryField: ${hasMandatoryField}
				},
			</c:forEach>
		];

		var CATEGORIES = [
			<c:forEach items="${categories}" var="category">
				{
					id: ${category.id},
					label: "<spring:message code="issue.flag.${category.name}.label" text="${ui:escapeJavaScript(category.name)}"/>",
					folderMeaning: ${category.hasFolderMeaning()},
					informationMeaning: ${category.hasInformationMeaning()}
				},
			</c:forEach>
		];

		var CURRENT_TRACKER_ID = ${importForm.tracker.id};

		var treePane = $("#treePane");
		var elementBox = $("#elementBox");
		var styleContainer = $("#wordStyles");
		var rightPane = $("#rightPane");
		var statisticsBox = $("#statisticsBox");
		var extraFormProperties = $("#extraFormProperties");

		var previewMode = false;
		var treeAlreadyChanged = false;
		var conditionChanged = false;

		function initializeAccordion() {
			var accordion = $('#rightContentAccordion');
			accordion.cbMultiAccordion();
			accordion.cbMultiAccordion("open", 0);
			accordion.cbMultiAccordion("open", 1);
		}

		function refreshStatistics(previousActionId, newActionId) {
			var trNew = statisticsBox.find('tr[data-action-id="' + newActionId + '"]');
			var numberTdNew = trNew.find('.number span');
			var newNumberNew = parseInt(numberTdNew.text(), 10) + 1;
			numberTdNew.text(newNumberNew);
			trNew.show();
			var trPrev = statisticsBox.find('tr[data-action-id="' + previousActionId + '"]');
			var numberTdPrev = trPrev.find('.number span');
			var newNumberPrev = parseInt(numberTdPrev.text(), 10) - 1;
			numberTdPrev.text(newNumberPrev);
			if (newNumberPrev == 0) {
				trPrev.hide();
			}
			numberTdPrev.text(newNumberPrev);
		}

		function setIcon(jsTreeIcon, imageUrl) {
			jsTreeIcon.css("background-image", 'url("' + imageUrl + '")');
		}

		function setImportAsCategoryInput(elementId, categoryOptionId) {
			var existing = extraFormProperties.find('input[name="importAsCategory[' + elementId + ']"]');
			if (existing.length > 0) {
				existing.val(categoryOptionId);
			} else {
				extraFormProperties.append('<input type="hidden" name="importAsCategory[' + elementId + ']" value="' + categoryOptionId + '">');
			}
		}

		function removeImportAsCategoryInput(elementId) {
			extraFormProperties.find('input[name="importAsCategory[' + elementId + ']"]').remove();
		}

		function setChangedTrackerInput(elementId, trackerId) {
			var existing = extraFormProperties.find('input[name="changedTracker[' + elementId + ']"]');
			if (existing.length > 0) {
				existing.val(trackerId);
			} else {
				extraFormProperties.append('<input type="hidden" name="changedTracker[' + elementId + ']" value="' + trackerId + '">');
			}
		}

		function removeChangedTrackerInput(elementId) {
			extraFormProperties.find('input[name="changedTracker[' + elementId + ']"]').remove();
		}

		function setAttachToParentInput(elementId, parentId) {
			extraFormProperties.append('<input type="hidden" name="attachToParent[' + elementId + ']" value="' + parentId + '">');
		}

		function removeAttachToParentInput(elementId) {
			extraFormProperties.find('input[name="attachToParent[' + elementId + ']"]').remove();
		}

		function selectElement(nodeLi, actionId, actionLabel, iconUrl) {
			actionId = actionId ? actionId : 1;
			var elementId = nodeLi.attr('id');
			var previousActionId = nodeLi.data("actionId");
			nodeLi.find(".jstree-icon").removeClass("deselected");
			setIcon(nodeLi.find("a .jstree-icon"), ICON_URLS[CURRENT_TRACKER_ID]);
			nodeLi.data("actionId", actionId);
			refreshStatistics(previousActionId, actionId);
			nodeLi.removeClass("jstree-unchecked jstree-undetermined").addClass("jstree-checked");

			var element = elementBox.find('.elementContainer[data-id="' + elementId + '"]');
			element.removeClass("notInclude").addClass("include");
			setIcon(element.find(".summaryIcon"), ICON_URLS[CURRENT_TRACKER_ID]);
			var importedText = i18n.message("word.import.style.action.add_new_item");
			if (actionLabel) {
				importedText = actionLabel;
			}
			if (actionId > 1000) {
				importedText = i18n.message("word.import.add.to.tracker.label", actionLabel);
				setIcon(nodeLi.find("a .jstree-icon"), ICON_URLS[actionId]);
				setIcon(element.find(".summaryIcon"), ICON_URLS[actionId]);
				setChangedTrackerInput(elementId, actionId);
			} else {
				removeChangedTrackerInput(elementId);
			}
			if (actionId == 2) {
				var parents = nodeLi.parents("li");
				if (parents.length > 0) {
					importedText = i18n.message("word.import.style.action.attach_to_parent");
					setAttachToParentInput(elementId, parents.first().attr("id"));
				} else {
					actionId = 1;
					removeAttachToParentInput(elementId);
				}
			} else {
				removeAttachToParentInput(elementId);
			}
			if (actionId != 1 && actionId !== parseInt(actionId, 10) && actionId.indexOf("4-") == 0) {
				importedText = i18n.message("word.import.import.as.category.label", actionLabel);
				if (iconUrl) {
					setIcon(nodeLi.find("a .jstree-icon"), iconUrl);
					setIcon(element.find(".summaryIcon"), iconUrl);
				}
				setImportAsCategoryInput(elementId, actionId.slice(2));
			} else {
				removeImportAsCategoryInput(elementId);
			}
			element.find(".toBeImported").html(importedText);

			var children = $(nodeLi).find("li");
			if (children.length > 0) {
				children.each(function() {
					if (actionId == 2) { // deselect children if Append to parent selected
						deselectElement($(this));
					} else {
						selectElement($(this), actionId, actionLabel, iconUrl);
					}

				});
			}
		}

		function deselectElement(nodeLi) {
			var elementId = nodeLi.attr('id');
			var previousActionId = nodeLi.data("actionId");
			nodeLi.find(".jstree-icon").addClass("deselected");
			setIcon(nodeLi.find("a .jstree-icon"), ICON_URLS[CURRENT_TRACKER_ID]);
			nodeLi.data("actionId", 0);
			refreshStatistics(previousActionId, 0);
			nodeLi.removeClass("jstree-checked jstree-undetermined").addClass("jstree-unchecked");

			var element = elementBox.find('.elementContainer[data-id="' + elementId + '"]');
			setIcon(element.find(".summaryIcon"), ICON_URLS[CURRENT_TRACKER_ID]);
			element.removeClass("include").addClass("notInclude");
			removeChangedTrackerInput(elementId);
			removeAttachToParentInput(elementId);
			removeImportAsCategoryInput(elementId);
			element.find(".toBeImported").text("-");

			var children = $(nodeLi).find("li");
			if (children.length > 0) {
				children.each(function() {
					deselectElement($(this));
				});
			}
		}

		function toggleElement(nodeLi) {
			treeAlreadyChanged = true;
			selectElementInTree(nodeLi);
			if (nodeLi.hasClass("jstree-checked")) {
				deselectElement(nodeLi);
			} else {
				selectElement(nodeLi);
			}
		}

		function showMandatoryFieldAlert(trackerName, trackerId) {
			var url = '${trackerCustomizeUrl}' + "?tracker_id=" + trackerId + "&orgDitchnetTabPaneId=tracker-customize-field-properties";
			showFancyAlertDialog(i18n.message("word.import.mandatory.field.alert", trackerName, url));
		}

		function selectElementInTree(nodeLi) {
			var treeLink = nodeLi.find("a").first();
			treePane.find("li a").removeClass("jstree-clicked");
			treeLink.addClass("jstree-clicked");
			treePane.animate({
				scrollTop: treeLink.offset().top - treePane.offset().top + treePane.scrollTop()
			});
		}

		var trackerActionCallback = function(nodeLi, trackerId, trackerName) {
			selectElement(nodeLi, trackerId, trackerName);
			treeAlreadyChanged = true;
		};

		var importAsCategoryCallback = function(nodeLi, actionId, optionLabel, iconUrl) {
			selectElement(nodeLi, actionId, optionLabel, iconUrl);
			treeAlreadyChanged = true;
		};

		var actionCallback = function(nodeLi, actionId, actionLabel) {
			if (actionId == 0) {
				deselectElement(nodeLi);
			} else {
				selectElement(nodeLi, actionId, actionLabel);
			}
			treeAlreadyChanged = true;
		};

		function initializeTree() {

			treePane.bind("loaded.jstree", function(event, data) {
				data.instance.open_all();
			});

			treePane.on("click", "li a", function(e) {
				e.preventDefault();
				if(e.originalEvent.detail > 1){
					return;
				}
				var nodeId = $(this).closest("li").attr("id");
				treePane.find("li a").removeClass("jstree-clicked");
				$(this).addClass("jstree-clicked");
				rightPane.animate({
					scrollTop: elementBox.find('.elementContainer[data-id="' + nodeId + '"]').first().offset().top - rightPane.offset().top + rightPane.scrollTop()
				});
			});

			treePane.on("dblclick", "li a", function() {
				var nodeLi = $(this).closest("li");
				if (previewMode) {
					showFancyConfirmDialogWithCallbacks(i18n.message("word.import.import.options.overwrite.alert"),
							function() {
								previewMode = false;
								toggleElement(nodeLi);
							});
				} else {
					toggleElement(nodeLi);
				}
			});

			treePane.bind('contextmenu', function(e, data) {
				var nodeLi = $(e.target).closest("li");
				var parentElement = nodeLi.parents("li");
				var parentActionId = parentElement.length > 0 ? parentElement.first().data("actionId") : null;
				if (parentActionId == 2) {
					$("#vakata-contextmenu").data("disableAll", true);
					$("#vakata-contextmenu").find("li").addClass("disabledOption");
					$("#vakata-contextmenu").attr("title", i18n.message("word.import.attach.to.parent.action.warning"));
				} else {
					$("#vakata-contextmenu").data("disableAll", false);
					$("#vakata-contextmenu").attr("title", "");
					var attachToParent = $("#vakata-contextmenu").find(".attachToParent");
					if (nodeLi.attr("data-level") == 1 || parentActionId == 0 || parentActionId == 2) {
						attachToParent.addClass("disabledOption");
						attachToParent.attr("title", i18n.message("word.import.attach.to.parent.tooltip"));
					} else {
						attachToParent.removeClass("disabledOption");
						attachToParent.attr("title", "");
					}
				}

			});

			// create a tree from the issues found in the document
			treePane.jstree({
				"plugins": ["html_data", "grid", "cookies", "ui", "checkbox", "contextmenu"],
				"core": {
					"animation": 0
				},
				"grid": {
					"columns": [
						{width: 300, header: "Requirements", title:"_DATA_", wideCellClass: "firstColumn"}
					],
					"resizable":true
				},
				"checkbox": {
					"override_ui": true,
					"two_state": true
				},
				"contextmenu": {
					"items" : function(node) {
						return {
						<c:forEach items="${styleActions}" var="styleAction">
							<spring:message var="styleActionLabel" code="word.import.style.action.${styleAction.name}"/>
							<c:choose>
							<c:when test="${styleAction.id == 3}">
								"${styleAction.name}" : {
									separator_before: true,
									label: '${styleActionLabel}',
										submenu: {
											<c:forEach items="${availableTrackers}" var="availableTracker">
												<spring:message var="trackerName" code="tracker.${availableTracker.name}.label" text="${availableTracker.name}"/>
												<c:set var="hasMandatoryField" value="false"/>
												<c:if test="${mandatoryFields.containsKey(availableTracker) && not empty mandatoryFields.get(availableTracker)}">
													<c:set var="hasMandatoryField" value="true"/>
												</c:if>
												'<c:out value="${availableTracker.name}"/>' : {
													label: '<c:out value="${trackerName}"/>',
													<c:if test="${hasMandatoryField}">
														"_class": "disabledOption hasMandatoryField",
													</c:if>
													action: function() {
														return trackerContextMenuAction(node, '<c:out value="${trackerName}"/>', ${availableTracker.id}, ${hasMandatoryField});
													}
												},
											</c:forEach>
										}
									},
							</c:when>
							<c:when test="${styleAction.id == 4}">
								<c:if test="${not empty categories}">
									'<c:out value="${styleAction.name}"/>' : {
										label: '<c:out value="${styleActionLabel}"/>',
										submenu: {
											<c:forEach items="${categories}" var="categoryOption">
												<spring:message var="optionLabel" text="${categoryOption.name}" code="issue.flag.${categoryOption.name}.label"/>
												'<c:out value="${categoryOption.name}"/>' : {
													label : '<c:out value="${optionLabel}"/>',
													action: function() {
														return categoryOptionContextMenuAction(node, '<c:out value="${optionLabel}"/>', '${categoryOption.id}', ${categoryOption.hasFolderMeaning()}, ${categoryOption.hasInformationMeaning()});
													}
												},
											</c:forEach>
											}
										},
								</c:if>
							</c:when>
							<c:otherwise>
								"${styleAction.name}" : {
									label: '${styleActionLabel}',
									<c:if test="${styleAction.id == 2}">
										"_class" : "attachToParent",
									</c:if>
									action: function() {
										var actionId = ${styleAction.id};
										if ($("#vakata-contextmenu").data("disableAll")) {
											return false;
										}
										if (actionId == 2 && $("#vakata-contextmenu").find(".attachToParent").hasClass("disabledOption")) {
											return false;
										}

										var nodeLi = $("li#" + node.id);
										if (previewMode) {
											showFancyConfirmDialogWithCallbacks(i18n.message("word.import.import.options.overwrite.alert"),
												function() {
													previewMode = false;
													actionCallback(nodeLi, actionId, '<c:out value="${styleActionLabel}"/>');
											});
										} else {
											actionCallback(nodeLi, actionId, '<c:out value="${styleActionLabel}"/>');
										}
									}
								},
								</c:otherwise>
							</c:choose>
						</c:forEach>
						}
					}
				}
			});
		}

		function trackerContextMenuAction(node, trackerName, availableTrackerId, hasMandatoryField) {
			if ($("#vakata-contextmenu").data("disableAll")) {
				return false;
			}
			if (hasMandatoryField) {
				showMandatoryFieldAlert(trackerName, availableTrackerId);
				return false;
			}

			var nodeLi = $("li#" + node.id);
			if (previewMode) {
				showFancyConfirmDialogWithCallbacks(i18n.message("word.import.import.options.overwrite.alert"),
						function() {
							previewMode = false;
							trackerActionCallback(nodeLi, availableTrackerId, trackerName);
						});
			} else {
				trackerActionCallback(nodeLi, availableTrackerId, trackerName);
			}
		}

		function categoryOptionContextMenuAction(node, optionLabel, optionId, hasFolderMeaning, hasInformationMeaning) {
			if ($("#vakata-contextmenu").data("disableAll")) {
				return false;
			}
			var iconUrl;
			if (hasFolderMeaning) {
				iconUrl = folderIconUrl;
			} else if (hasInformationMeaning) {
				iconUrl = informationIconUrl;
			}
			var nodeLi = $("li#" + node.id);
			if (previewMode) {
				showFancyConfirmDialogWithCallbacks(i18n.message("word.import.import.options.overwrite.alert"),
						function() {
							previewMode = false;
							importAsCategoryCallback(nodeLi, '4-' + optionId, optionLabel, iconUrl);
						});
			} else {
				importAsCategoryCallback(nodeLi, '4-' + optionId, optionLabel, iconUrl);
			}
		}

		function initializeStyleContainer() {
			var styles = styleContainer.find("select");
			styles.first().find('option[value="2"]').prop("disabled", true);
			styleContainer.on("change", "select", function() {
				styles.find("option").prop("disabled", false);
				styles.first().find('option[value="2"]').prop("disabled", true);
				if ($(this).val() == 0) {
					var index = 0;
					for (var i = 0; i < styles.length; i++) {
						if ($(this).get(0) == styles.get(i)) {
							index = i;
							break;
						}
					}
					$(styles.get(i + 1)).find('option[value="2"]').prop("disabled", true);
				}
			});
		}

		function initializeEvents() {

			var ruleContainer = $("#rules");

			function renderRule(actionId, allConditionTypeId, conditions, first) {
				var actions = $('<select class="styleAction styleActionSelector"></select>');

				for (var i = 0; i < STYLE_ACTIONS.length; i++) {
					var styleAction = STYLE_ACTIONS[i];
					if (styleAction.actionId == 3) { // Import into other tracker
						var optGroup = $('<optgroup label="' + styleAction.name + '"></optgroup>');
						for (var j = 0; j < AVAILABLE_TRACKERS.length; j++) {
							var tracker = AVAILABLE_TRACKERS[j];
							optGroup.append($('<option value="' + tracker.id  + '"' + (tracker.hasMandatoryField ? ' class="disabledOption hasMandatoryField"' : '') + '>' + tracker.label + '</option>'));
						}
						actions.append(optGroup);
					} else if (styleAction.actionId == 4) { // Import as category
						if (CATEGORIES.length > 0) {
							var optGroup = $('<optgroup label="' + styleAction.name + '"></optgroup>');
							for (var j = 0; j < CATEGORIES.length; j++) {
								var categoryOption = CATEGORIES[j];
								optGroup.append($('<option value="' + styleAction.actionId + '-' + categoryOption.id  + '" class="' + (categoryOption.informationMeaning ? 'informationMeaning ' : (categoryOption.folderMeaning ? 'folderMeaning' : '')) + '">' + categoryOption.label + '</option>'));
							}
							actions.append(optGroup);
						}
					} else {
						actions.append($('<option value="' + styleAction.actionId + '">' + styleAction.name + '</option>'));
					}
				}

				if (actionId !== null) {
					actions.val(actionId);
				}

				var branchContainer = $('<div class="branchContainer"></div>');
				branchContainer.append($('<span>' + '<spring:message code="word.import.branch.in" text="in"/>' + ' </span>'));
				var branchSelect = $('<select></select>');
				branchSelect.append($('<option value="0">' + '<spring:message code="word.import.branch.whole.document" text="the whole Document"/>' + '</option>'));
				if (ELEMENT_NODES.length > 0) {
					var branchSelectGroup = $($('<optgroup label="' + '<spring:message code="word.import.branch.in.node" text="the following node:"/>' + '"></optgroup>'));
					for (var i = 0; i < ELEMENT_NODES.length; i++) {
						var branch = ELEMENT_NODES[i];
						branchSelectGroup.append($('<option value="' + branch.id +'">' + branch.name + '</option>'));
					}
					branchSelect.append(branchSelectGroup);
				}
				branchContainer.append(branchSelect);

				var allConditionTypeCont = $('<div class="allConditionContainer"></div>');
				allConditionTypeCont.append($('<span>' + '<spring:message code="word.import.condition.if" text="if"/>' + ' </span>'));
				var allConditionSelect = $('<select></select>');
				for (var i = 0; i < ALL_CONDITION_TYPES.length; i++) {
					var allCondType = ALL_CONDITION_TYPES[i];
					allConditionSelect.append($('<option value="' + allCondType.id + '">' + allCondType.label + '</option>'));
				}
				allConditionTypeCont.append(allConditionSelect);
				allConditionTypeCont.append($('<span> ' + '<spring:message code="word.import.condition.met" text="conditions are met."/>' + '</span>'));
				if (allConditionTypeId !== null) {
					allConditionSelect.val(allConditionTypeId);
				}

				var ruleDiv = $('<div class="rule"></div>');

				ruleDiv.append(actions);
				ruleDiv.append(branchContainer);
				ruleDiv.append(allConditionTypeCont);
				ruleDiv.append($('<div class="conditionContainer"></div>'));

				var addNewConditionButton = $('<a href="#" class="addNewCondition">+ ' + i18n.message("word.import.add.new.condition.label") + '</a>');
				addNewConditionButton.click(function(e) {
					e.preventDefault();
					renderCondition({}, false, ruleDiv);
				});
				ruleDiv.append(addNewConditionButton);

				if (conditions && $.inArray(conditions) && conditions.length > 0) {
					for (var i = 0; i < conditions.length; i++) {
						renderCondition(conditions[i], i == 0, ruleDiv);
					}
				} else {
					renderCondition({}, true, ruleDiv);
				}

				if (!first) {
					ruleContainer.append($('<span class="removeRule" title="' + i18n.message("word.import.remove.rule.label") + '"></span>'));
				}
				ruleContainer.append(ruleDiv);

				branchSelect.multiselect({
					selectedText: function(numChecked, numTotal, checkedItems) {
						var value = [];
						$(checkedItems).each(function() {
							value.push($(this).next().html());
						});
						return value.join(", ");
					},
					beforeopen: function() {
						$(this).multiselect('widget').css("min-width", "300px");
						$(this).multiselect('widget').css("width", "300px");
					}
				});
				branchSelect.val([0]);

			}

			function renderCondition(condition, first, ruleDiv) {
				var conditionDiv = $('<div class="condition"></div>');

				var conditionTable = $('<table></table>');
				var conditionTr = $('<tr></tr>');
				var conditionTypeTd = $('<td class="conditionType"></td>');

				var conditionType = $('<select name="conditionType"></select>');
				for (var i=0; i < CONDITION_TYPES.length; i++) {
					var type = CONDITION_TYPES[i];
					conditionType.append($('<option value="' + type.id + '">' + type.label + '</option>'));
				}
				conditionType.change(function() {
					var conditionTextTd = $(this).closest(".condition").find("td.conditionText");
					var conditionInput = conditionTextTd.find('input');
					var conditionSelect = conditionTextTd.find('button');
					if ($(this).val() == 0) {
						conditionInput.hide();
						conditionSelect.hide();
					} else if ($(this).val() == 7) {
						conditionInput.hide();
						conditionSelect.show();
					} else {
						conditionInput.show();
						conditionSelect.hide();
					}
				});
				if (!first) {
					conditionType.val(7); // set to has style condition if added
				}
				if (condition && condition.hasOwnProperty("type")) {
					conditionType.val(condition.type.id);
				}
				conditionTypeTd.append(conditionType);

				var conditionTextTd = $('<td class="conditionText"></td>');
				var conditionText = $('<input name="conditionText" type="text" placeholder="' + i18n.message('word.import.enter.words.label') + '">');
				var conditionStyleSelector = $('<select name="style" multiple="multiple"></select>');
				for (var styleId in USED_STYLES) {
					var styleName = USED_STYLES[styleId];
					conditionStyleSelector.append('<option value="' + styleId + '">' + styleName + '</option>');
				}
				conditionTextTd.append(conditionText);
				conditionTextTd.append(conditionStyleSelector);

				conditionStyleSelector.multiselect({
					selectedText: function(numChecked, numTotal, checkedItems) {
						if (numChecked == numTotal) {
							return i18n.message("word.import.condition.all.styles");
						} else {
							var value = [];
							$(checkedItems).each(function(){
								value.push($(this).next().html());
							});
							return value.join(", ");
						}
					},
					minWidth: 170
				});
				if (condition && condition.hasOwnProperty("value")) {
					if (condition.type.id == 7) {
						var selectedStyles = condition.value;
						var selectedOptionNumber = 0;
						for (var i = 0; i < selectedStyles.length; i++) {
							var style = selectedStyles[i];
							var option = conditionStyleSelector.find("option[value=" + style + "]");
							if (option.length > 0) {
								option.attr("selected", "selected");
								selectedOptionNumber++;
							}
						}
						if (selectedOptionNumber == 0) {
							conditionStyleSelector.multiselect("checkAll");
						}
						conditionStyleSelector.multiselect("refresh");
					} else {
						conditionText.val(condition.value);
					}
				} else { // select all style options
					conditionStyleSelector.find("option").attr("selected", "selected");
					conditionStyleSelector.multiselect("refresh");
				}

				var conditionRemoveTd = $('<td class="conditionRemoveTd"></td>');
				if (!first) {
					conditionRemoveTd.append($('<span class="conditionRemove" title="' + i18n.message('word.import.remove.condition.label') + '"></span>'));
				}

				conditionTr.append(conditionTypeTd);
				conditionTr.append(conditionTextTd);
				conditionTr.append(conditionRemoveTd);

				conditionTable.append(conditionTr);
				conditionDiv.append(conditionTable);

				ruleDiv.find(".conditionContainer").append(conditionDiv);

				conditionType.change();
			}

			function doPreview() {

				var getRules = function() {
					var rules = [];
					ruleContainer.find(".rule").each(function() {
						var actionId = $(this).find("select.styleAction").val();
						var allConditionId = $(this).find(".allConditionContainer select").val();
						var conditions = [];
						$(this).find(".conditionContainer .condition").each(function() {
							var conditionType = $(this).find('select[name="conditionType"]').val();
							if (conditionType == 7) {
								var styleSelector = $(this).find('select[name="style"]').first();
								var selected = styleSelector.multiselect("getChecked");
								var conditionText = [];
								selected.each(function() {
									conditionText.push($(this).val());
								});
							} else {
								var conditionText = $(this).find('input[name="conditionText"]').val();
							}
							conditions.push({
								typeId: conditionType,
								text: conditionText
							});
						});
						var branchSelect = $(this).find(".branchContainer select").first();
						var selected = branchSelect.multiselect("getChecked");
						var selectedBranches = [];
						selected.each(function() {
							selectedBranches.push(parseInt($(this).val(), 10));
						});
						rules.push({
							actionId: actionId,
							allConditionTypeId: allConditionId,
							branches: selectedBranches,
							conditions: conditions
						});
					});
					return rules;
				};

				var storeUserSetting = function(rules) {
					var userSetting = {
						rules: rules
					};
					var busy = ajaxBusyIndicator.showProcessingPage();
					$.ajax("${userSettingUrl}", {type: "POST", dataType: "json", contentType : 'application/json', data: JSON.stringify(userSetting) }).done(function(result) {
						// stored
					}).fail(function() {
						console.debug("Could not store Word import options in user settings.");
					}).always(function() {
						ajaxBusyIndicator.close(busy);
					});
				};

				var previewEvent = function() {

					previewMode = true;

					var escapeStringForRegExp = function(text) {
						return text.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
					};

					var findPattern = function(conditionTypeId) {
						for (var i = 0; i < CONDITION_TYPES.length; i++) {
							var condition = CONDITION_TYPES[i];
							if (condition.id == conditionTypeId) {
								return {
									pattern: condition.pattern,
									modifiers: condition.modifiers
								};
							}
						}
					};

					var replacePatternVariable = function(pattern, text) {
						return pattern.replace("__VALUE__", text);
					};

					var hasProperRule = function(li, rules) {

						var elementId = li.attr("id");
						var elementStyleId = li.attr("styleid");
						var element = elementBox.find('.elementContainer[data-id="' + elementId + '"]');

						var summaryText = $.trim(element.find(".summaryText").text());
						var description = $.trim(element.find(".description").text());

						for (var i= 0; i < rules.length; i++) {
							var rule = rules[i];
							var isAnd = rule.allConditionTypeId == 1;
							var actionId = rule.actionId;
							var conditions = rule.conditions;
							var branches = rule.branches;
							var hasProperBranch = true;
							if (branches.length > 0 && $.inArray(0, branches) === -1) {
								var parentElements = li.parents("li");
								var parentElementIds = [];
								parentElements.each(function() {
									parentElementIds.push(parseInt($(this).attr("id"), 10));
								});
								hasProperBranch = false;
								var elementId = parseInt(li.attr("id"), 10);
								for (var j = 0; j < branches.length; j++) {
									var providedBranchId = branches[j];
									if (providedBranchId == elementId || $.inArray(providedBranchId, parentElementIds) !== -1) {
										hasProperBranch = true;
									}
 								}
							}

							if (conditions.length > 0) {
								var result = isAnd;
								for (var n = 0; n < conditions.length; n++) {
									var condition = conditions[n];
									var conditionTypeId = condition.typeId;
									var patternString = findPattern(conditionTypeId);
									var testCondition = true;
									if (conditionTypeId == 7) {
										testCondition = $.inArray(elementStyleId, condition.text) > -1;
									} else {
										if (conditionTypeId > 100) { // regex
											var pattern = new RegExp(condition.text, patternString.modifiers);
										} else if (conditionTypeId == 0) {
											var pattern = new RegExp(patternString.pattern, patternString.modifiers);
										} else {
											var conditionText = escapeStringForRegExp(condition.text);
											var pattern = new RegExp(replacePatternVariable(patternString.pattern, conditionText), patternString.modifiers);
										}
										testCondition = pattern.test(summaryText) || pattern.test(description);
									}
									if (testCondition && hasProperBranch) {
										if (isAnd) {
											result = result && true;
										} else {
											result = result || true;
										}
									} else {
										if (isAnd) {
											result = result && false;
										} else {
											result = result || false;
										}
									}
								}
								if (result) {
									return actionId;
								}
							}
						}
						return result == false ? false : actionId;

					};

					var rules = getRules();
					rules.reverse();
					treePane.find('li').each(function() {
						var actionIdByRule = hasProperRule($(this), rules);
						if (!actionIdByRule || actionIdByRule == 0) {
							deselectElement($(this));
						} else {
							var actionLabel = null;
							if (actionIdByRule > 1000) {
								actionLabel = ruleContainer.find(".styleAction").first().find('option[value="' + actionIdByRule + '"]').text();
							}
							var iconUrl;
							if (actionIdByRule.indexOf("4-") == 0) {
								var option = ruleContainer.find(".styleAction").first().find('option[value="' + actionIdByRule + '"]');
								actionLabel = option.text();
								if (option.hasClass("folderMeaning")) {
									iconUrl = folderIconUrl;
								} else if (option.hasClass("informationMeaning")) {
									iconUrl = informationIconUrl;
								}
							}
							selectElement($(this), actionIdByRule, actionLabel, iconUrl);
						}
					});

					var hasAttachToParentRule = function(rules) {
						for (var i = 0; i < rules.length; i++) {
							var rule = rules[i];
							if (rule.actionId == 2) {
								return true;
							}
						}
						return false;
					};

					// If some of the rules has Append to parent action, we need to check if the parent of the selected
					// elements are not included (or also has Append to parent action), if so, we also need not ignore these
					if (hasAttachToParentRule(rules)) {
						var shouldDisplayWarning = false;
						treePane.find('li').each(function() {
							var actionId = $(this).data("actionId");
							if (actionId == 2) {
								var level = $(this).attr("data-level");
								var parentElement = $(this).parents("li");
								if (level == 1 ||
										(parentElement.length > 0 &&
										(parentElement.first().data("actionId") == 0 || parentElement.first().data("actionId") == 2))) {
									deselectElement($(this));
									shouldDisplayWarning = true;
								}
							}
						});
						if (shouldDisplayWarning) {
							showFancyAlertDialog(i18n.message("word.import.attach.to.parent.warning"));
						}
					}


					storeUserSetting(rules.reverse());

					conditionChanged = false;

				};

				if (treeAlreadyChanged) {
					showFancyConfirmDialogWithCallbacks(i18n.message("word.import.modification.overwrite.alert"),
							function() {
								treeAlreadyChanged = false;
								previewEvent();
							});
				} else {
					previewEvent();
				}

			}

			$("#previewButton").click(doPreview);

			$("#addNewRuleButton").click(function(e) {
				e.preventDefault();
				renderRule(null, null, {}, false);
				conditionChanged = true;
			});

			ruleContainer.on("click", ".conditionRemove", function() {
				var condition = $(this).closest(".condition");
				condition.remove();
			});

			ruleContainer.on("click", ".removeRule", function() {
				var rule = $(this).next(".rule");
				var removeButton = $(this);
				showFancyConfirmDialogWithCallbacks(i18n.message("word.import.remove.rule.alert"),
						function() {
							removeButton.remove();
							rule.remove();
						});
			});

			elementBox.on("click", ".switch", function() {
				var elementId = $(this).closest(".elementContainer").data("id");
				var nodeLi = $("#treePane #" + elementId);
				if (previewMode) {
					showFancyConfirmDialogWithCallbacks(i18n.message("word.import.import.options.overwrite.alert"),
							function() {
								previewMode = false;
								toggleElement(nodeLi);
							});
				} else {
					toggleElement(nodeLi);
				}
			});

			ruleContainer.on("change", "input, select", function() {
				conditionChanged = true;
			});

			elementBox.on("click", ".summaryText", function() {
				var elementId = $(this).closest(".elementContainer").data("id");
				selectElementInTree(treePane.find("#" + elementId));
			});

			$("#east").on("focus", "select.styleActionSelector", function() {
				$(this).data("prevValue", $(this).val());
			}).on("change", "select.styleActionSelector", function() {
				var option = $(this).find("option:selected");
				var currentValue = $(this).val();
				if (option.hasClass("hasMandatoryField")) {
					$(this).val($(this).data("prevValue"));
					showMandatoryFieldAlert(option.text(), currentValue);
				} else {
					$(this).data("prevValue", currentValue);
				}
			});

			$('#nextButton').click(function() {
				var $that = $(this);
				var $checked = treePane.find(".jstree-checked");
				var hasChecked = $checked.size() > 0;
				if (!hasChecked) {
					showFancyAlertDialog(i18n.message("word.import.empty.selection.alert"));
					return false;
				} else {

					var confirmedCallback = function() {
						ajaxBusyIndicator.showProcessingPage();
						var $importForm = $("#importForm");
						$checked.each(function () {
							var id = $(this).attr("id");
							var $input = $("<input>", {type: 'hidden', value: id, name: 'issues'});
							$importForm.append($input);
						});
					};

					var confirmed = true;
					if (conditionChanged) {
						confirmed = false;
						showFancyConfirmDialogWithCallbacks(i18n.message("word.import.rules.changed.warning"), function() {
							doPreview();
							conditionChanged = false;
							$that.click();
						});
					}

					if (confirmed) {
						confirmedCallback();
						return true;
					} else {
						return false;
					}
				}
			});

			function loadImportOptionUserSetting() {
				var busy = ajaxBusyIndicator.showProcessingPage();
				$.ajax("${userSettingUrl}", { type: "GET"}).done(function(result) {
					var noUserData = result.hasOwnProperty("success") && !result.success;
					if (result && !noUserData && result.hasOwnProperty("rules") && result["rules"].length > 0) {
						var rules = result["rules"];
						if (rules && $.isArray(rules) && rules.length > 0) {
							for (var i = 0; i < rules.length; i++) {
								var rule = rules[i];
								if (rule.hasOwnProperty("styleAction") && rule.hasOwnProperty("allConditionType") && rule.hasOwnProperty("conditions")) {
									var actionId = rule.styleAction.id;
									if (rule.styleAction.hasOwnProperty("trackerId")) {
										actionId = rule.styleAction.trackerId;
									}
									if (rule.styleAction.hasOwnProperty("categoryId")) {
										actionId = "4-" + rule.styleAction.categoryId;
									}
									renderRule(actionId, rule.allConditionType.id, rule.conditions, i == 0);
								}
							}
						} else {
							renderRule(null, null, {}, true);
						}
						setTimeout(function() {
							$("#previewButton").click();
							ajaxBusyIndicator.close(busy);
						}, 500);
					} else {
						renderRule(null, null, {}, true);
						ajaxBusyIndicator.close(busy);
					}
				}).fail(function() {
					renderRule(null, null, {}, true);
					ajaxBusyIndicator.close(busy);
				});
			}
			loadImportOptionUserSetting();

		}

		function initializeContextMenus() {

			function initCenterContextMenus() {

				var centerContextMenu = new ContextMenuManager({
					selector: ".elementContainer .menuArrowDown",
					trigger: "left",
					events: {
						show: function(options) {
							var elementId = $(this).closest(".elementContainer").data("id");
							var treeElement = treePane.find("li#" + elementId);
							var parentElement = treeElement.parents("li");
							var parentActionId = parentElement.length > 0 ? parentElement.first().data("actionId") : null;
							if (parentActionId == 2) {
								options.$menu.data("disableAll", true);
								options.$menu.find("li").addClass("disabledOption");
								options.$menu.attr("title", i18n.message("word.import.attach.to.parent.action.warning"));
							} else {
								options.$menu.data("disableAll", false);
								options.$menu.find("li:not(.hasMandatoryField)").removeClass("disabledOption");
								options.$menu.attr("title", "");
								var attachToParent = options.items.attach_to_parent.$node;
								if (treeElement.attr("data-level") == 1 || parentActionId == 0 || parentActionId == 2) {
									attachToParent.addClass("disabledOption");
									attachToParent.attr("title", i18n.message("word.import.attach.to.parent.tooltip"));
								} else {
									attachToParent.removeClass("disabledOption");
									attachToParent.attr("title", i18n.message("word.import.attach.to.parent.tooltip"));
								}
							}
						}
					},
					items: {
						<c:forEach items="${styleActions}" var="styleAction">
							<spring:message var="styleActionLabel" code="word.import.style.action.${styleAction.name}"/>
							<c:choose>
								<c:when test="${styleAction.id == 3}">
									separator: "-----",
									"${styleAction.name}" : {
										name: '${styleActionLabel}',
										items: {
										<c:forEach items="${availableTrackers}" var="availableTracker">
											<spring:message var="trackerName" code="tracker.${availableTracker.name}.label" text="${availableTracker.name}"/>
											<c:set var="hasMandatoryField" value="false"/>
											<c:if test="${mandatoryFields.containsKey(availableTracker) && not empty mandatoryFields.get(availableTracker)}">
												<c:set var="hasMandatoryField" value="true"/>
											</c:if>
											'<c:out value="${availableTracker.name}"/>' : {
												name: '<c:out value="${trackerName}"/>',
												<c:if test="${hasMandatoryField}">
													className: "disabledOption hasMandatoryField",
												</c:if>
												callback: function(key, options) {
													return trackerContextMenuCallback($(this), options, '<c:out value="${trackerName}"/>', ${availableTracker.id}, ${hasMandatoryField});
												}
											},
										</c:forEach>
										}
									},
								</c:when>
								<c:when test="${styleAction.id == 4}">
									<c:if test="${not empty categories}">
										'<c:out value="${styleAction.name}"/>' : {
											name: '<c:out value="${styleActionLabel}"/>',
											items: {
												<c:forEach items="${categories}" var="categoryOption">
												<spring:message var="optionLabel" text="${categoryOption.name}" code="issue.flag.${categoryOption.name}.label"/>
												'<c:out value="${categoryOption.name}"/>' : {
													name : '<c:out value="${optionLabel}"/>',
													callback: function(key, options) {
														return categoryOptionContextMenuCallback($(this), options, '<c:out value="${optionLabel}"/>', '${categoryOption.id}', ${categoryOption.hasFolderMeaning()}, ${categoryOption.hasInformationMeaning()});
													}
												},
												</c:forEach>
											}
										},
									</c:if>
								</c:when>
								<c:otherwise>
									"${styleAction.name}" : {
										name: '${styleActionLabel}',
										<c:if test="${styleAction.id == 2}">
											className : "attachToParent",
										</c:if>
										callback: function(key, options) {
											if (options.$menu.data("disableAll")) {
												return false;
											}
											if (key == "attach_to_parent" && options.$menu.find("li.attachToParent").hasClass("disabledOption")) {
												return false;
											}
											var actionId = ${styleAction.id};
											var elementId = $(this).closest(".elementContainer").data("id");
											var nodeLi = $("#treePane #" + elementId);
											if (previewMode) {
												showFancyConfirmDialogWithCallbacks(i18n.message("word.import.import.options.overwrite.alert"),
														function() {
															previewMode = false;
															actionCallback(nodeLi, actionId, '${styleActionLabel}');
														});
											} else {
												actionCallback(nodeLi, actionId, '${styleActionLabel}');
											}
										}
									},
								</c:otherwise>
							</c:choose>
						</c:forEach>
					},
					zIndex  : 20
				});
				centerContextMenu.render();
			}

			initCenterContextMenus();

		}

		function trackerContextMenuCallback($this, options, trackerName, availableTrackerId, hasMandatoryField) {
			if (options.$menu.data("disableAll")) {
				return false;
			}
			if (hasMandatoryField) {
				showMandatoryFieldAlert(trackerName, availableTrackerId);
				return false;
			}
			var elementId = $this.closest(".elementContainer").data("id");
			var nodeLi = $("#treePane #" + elementId);
			if (previewMode) {
				showFancyConfirmDialogWithCallbacks(i18n.message("word.import.import.options.overwrite.alert"),
						function() {
							previewMode = false;
							trackerActionCallback(nodeLi, availableTrackerId, trackerName);
						});
			} else {
				trackerActionCallback(nodeLi, availableTrackerId, trackerName);
			}
		}

		function categoryOptionContextMenuCallback($this, options, optionLabel, optionId, hasFolderMeaning, hasInformationMeaning) {
			if (options.$menu.data("disableAll")) {
				return false;
			}
			var elementId = $this.closest(".elementContainer").data("id");
			var nodeLi = $("#treePane #" + elementId);
			var iconUrl;
			if (hasFolderMeaning) {
				iconUrl = folderIconUrl;
			} else if (hasInformationMeaning) {
				iconUrl = informationIconUrl;
			}
			if (previewMode) {
				showFancyConfirmDialogWithCallbacks(i18n.message("word.import.import.options.overwrite.alert"),
						function() {
							previewMode = false;
							importAsCategoryCallback(nodeLi, '4-' + optionId, optionLabel, iconUrl);
						});
			} else {
				importAsCategoryCallback(nodeLi, '4-' + optionId, optionLabel, iconUrl);
			}
		}


		$(function() {
			initializeTree();
			initializeAccordion();
			initializeStyleContainer();
			initializeEvents();
			initializeContextMenus();
		});

	})(jQuery);

</script>
