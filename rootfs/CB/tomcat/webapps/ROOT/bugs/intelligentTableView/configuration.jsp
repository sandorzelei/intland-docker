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
<meta name="decorator" content="popup"/>
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin trackersModule"/>

<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="<ui:urlversioned value="/bugs/tracker/traceabilityBrowser/traceabilityBrowser.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/intelligentTableView.less" />" type="text/css" media="all" />
<script src="<ui:urlversioned value='/js/intelligentTableView.js'/>"></script>

<ui:actionMenuBar>
	<spring:message code="intelligent.table.view.configuration.label"/>
</ui:actionMenuBar>

<ui:actionBar>
	<spring:message var="buttonTitle" code="button.save" text="Save"/>
	<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
	<input type="button" class="button" title="${buttonTitle}" value="${buttonTitle}" name="submit" onclick="codebeamer.IntelligentTableView.saveConfiguration(${reportId});return false;" />&nbsp;
	<input type="button" class="button cancelButton" title="${cancelTitle}" value="${cancelTitle}" name="_cancel" onclick="closePopupInline();return false;" />
</ui:actionBar>
<div class="accordion">
	<h3 class="accordion-header"><spring:message code="intelligent.table.view.rendering.method.label"/></h3>
	<div class="accordion-content">
		<form id="renderingMethod">
			<table>
				<tr>
					<td>
						<input type="radio" name="renderingMethod" value="DISABLED" id="renderingMethodDisabled">
						<label for="renderingMethodDisabled"><spring:message code="intelligent.table.view.disabled.label"/></label>
					</td>
					<td>
						<input type="radio" name="renderingMethod" value="HORIZONTALLY" id="renderingMethodHorizontally">
						<label for="renderingMethodHorizontally"><spring:message code="intelligent.table.view.horizontally.label"/></label>
					</td>
					<td>
						<input type="radio" name="renderingMethod" value="VERTICALLY" id="renderingMethodVertically">
						<label for="renderingMethodVertically"><spring:message code="intelligent.table.view.vertically.label"/></label>
					</td>
				</tr>
			</table>
		</form>
	</div>
	<h3 class="accordion-header"><spring:message code="intelligent.table.view.level.settings.label"/></h3>
	<div class="accordion-content">
		<div class="controlContainer">
			<table class="levelsTable">
				<tr class="initialTrackers levelTr">
					<td class="label">
						<spring:message code="intelligent.table.view.initial.label"/>
					</td>
					<td class="entities">
						<div class="levelContainer initialLevelContainer">
							<div class="entityContainerPlaceholder"></div>
							<span class="entityContainer trackerEntity" data-id="${trackerId}">
								<span class="issueHandle"></span>
								<span class="icon"><img src="${trackerIcon}" style="background-color: #5f5f5f"></span>
								<span class="name"><c:out value="${trackerName}"/></span>
								<span class="deleteButton" style="visibility: hidden"></span>
							</span>
							<span class="addButton firstLevelAddButton">&nbsp;</span>
						</div>
					</td>
				</tr>
				<tr class="levelTr">
					<td class="label"><spring:message code="tracker.traceability.browser.level"/> <span class="number">1</span></td>
					<td class="entities">
						<div class="levelContainer droppable">
							<div class="entityContainerPlaceholder"></div>
							<span class="addButton">+ <spring:message code="button.add" text="Add"/></span>
						</div>
					</td>
				</tr>
			</table>
		</div>
		<select class="addFieldSelector" id="addFieldSelector" multiple="multiple"></select>
	</div>
</div>

<div id="traceabilityAddCustomTrackerDialog" title="<spring:message code="planner.add.issue.select.tracker.title"/>">
	<table>
		<tr>
			<td class="label"><spring:message code="project.label" text="Project"/>:</td>
			<td><select class="selector project"></select></td>
			<td class="label"><spring:message code="tracker.label" text="Tracker"/>:</td>
			<td><select class="selector tracker"></select><select class="trackerSelectorHelper"></select></td>
		</tr>
	</table>
</div>

<script type="text/javascript">
	$(function() {

		var excludePreviousLevelTypeIds = [];
		<c:forEach var="typeId" items="${excludePreviousLevelTypes}">
			excludePreviousLevelTypeIds.push(${typeId});
		</c:forEach>

		var trackerTypeItems = {};
		<c:forEach var="item" items="${trackerTypeEntities}">
			trackerTypeItems["${item.name}"] = {
				name: "${item.name}",
				callback: function(key, opt) {
					codebeamer.IntelligentTableView.addEntityToLevel($(this), "${item.name}", ${item.id}, ${item.id}, "${contextPath}${item.iconUrl}");
				},
				id: ${item.id},
				iconUrl: "${contextPath}${item.iconUrl}"
			};
		</c:forEach>

		var trackerItems = {};
		<c:forEach var="item" items="${trackerEntities}">
			// the tracker key contains the tracker id as well because the name is not unique any more
			// (branches of different trackers can have the same name)
			var key = "<c:out value="${item.name}"/>-${item.id}";
			trackerItems[key] = {
				name: "<c:out value="${item.name}"/>",
				className: "${item.branch ? 'branchItem level-' : ''}${item.branch ? item.branchLevel : ''}",
				callback: function(key, opt) {
					codebeamer.IntelligentTableView.addEntityToLevel($(this), "<c:out value="${item.name}"/>", ${item.id}, ${item.trackerTypeId}, "${contextPath}${item.iconUrl}");
				},
				id: ${item.id},
				iconUrl: "${contextPath}${item.iconUrl}"
			};
		</c:forEach>

		var fieldList = [];
		<c:if test="${not empty layoutList}">
			<c:forEach var="field" items="${layoutList}">
				fieldList.push({
					id: ${field.id},
					name: i18n.message("tracker.field.${field.name}.label", "${field.name}")
				});
			</c:forEach>
		</c:if>

		codebeamer.IntelligentTableView.initConfiguration({
			trackerId: ${trackerId},
			trackerTypeMenuItems: trackerTypeItems,
			trackerMenuItems: trackerItems,
			existing: "${ui:escapeJavaScript(existing)}",
			fieldList: fieldList
		});
	});
</script>
