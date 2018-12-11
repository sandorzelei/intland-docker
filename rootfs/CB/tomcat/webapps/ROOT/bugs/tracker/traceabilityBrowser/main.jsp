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
<meta name="bodyCSSClass" content="newskin traceabilityBrowser"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<link rel="stylesheet" href="<ui:urlversioned value='/bugs/tracker/traceabilityBrowser/traceabilityBrowser.less' />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-waypoints/waypoints.js'/>"></script>

<spring:message var="tracBrowserTitle" code="tracker.traceability.browser.label" text="Traceability Browser"/>
<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span><span class="page-title">
			${tracBrowserTitle}
	</span>
		<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
			${tracBrowserTitle}
		</ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<c:choose>
	<c:when test="${not traceabilityEnabled}">
		<div class="warning">
			<spring:message code="license.tracebility.nolicense.message" text="To use this page you need a Traceability Browser license."/>
		</div>
	</c:when>
	<c:when test="${not empty projectLevel}">
		<ui:actionBar>
			<a class="actionBarLink" id="managePresets" href="#" style="margin: 0;"><spring:message code="tracker.traceability.browser.manage.presets" text="Load/Manage presets"/></a>
		</ui:actionBar>
		<div class="traceabilityBrowserDataCont">
			<div class="accordion">
				<h3 class="accordion-header">${tracBrowserTitle}</h3>
				<div class="accordion-content">
					<div class="information">
						<h3><spring:message code="tracker.traceability.browser.info.whatIs.title"/></h3>
						<p><spring:message code="tracker.traceability.browser.info.whatIs"/></p>
						<h3><spring:message code="tracker.traceability.browser.info.selectFilter.title"/></h3>
						<c:choose>
							<c:when test="${empty projectWorkTrackers && empty projectConfigTrackers}">
								<p><spring:message code="tracker.traceability.browser.noItemsInProject" text="There aren't any tracker items in this project."/></p>
							</c:when>
							<c:otherwise>
								<table class="initialFilterTable">
									<tr>
										<td><ui:reportSelector sticky="false" showGroupBy="false" showOrderBy="true" triggerResultAfterInit="false"/></td>
										<td class="goButton"><input data-trackerId="${projectWorkTrackers.get(0).getId()}" type="button" class="button initialFilterGoButton" value="<spring:message code="search.submit.label"/>"></td>
									</tr>
								</table>
								<h3><spring:message code="tracker.traceability.browser.info.selectTracker.title"/></h3>
								<p><spring:message code="tracker.traceability.browser.info.selectTracker"/></p>
								<table class="selectTrackerTable">
									<tr>
										<td class="trackers">
											<table class="referencingTypes">
												<c:forEach var="tracker" items="${projectWorkTrackers}">
													<spring:message var="trackerName" code="tracker.type.${tracker.name}.plural" text="${tracker.name}" htmlEscape="true"/>
													<tr data-visible="${tracker.visible}"<c:if test="${!tracker.visible}"> style="display: none;"</c:if>>
														<td class="refCode"><img style="background-color: ${tracker.iconBgColor}" src="${contextPath}${tracker.iconUrl}"></td>
														<td><b><a class="referenceTrackerType" href="${ui:removeXSSCodeAndHtmlEncode(browserUrl)}${tracker.id}"><c:out value="${ui:removeXSSCodeAndHtmlEncode(trackerName)}"/></a></b></td>
													</tr>
												</c:forEach>
											</table>
										</td>
										<td class="trackers">
											<table class="referencingTypes">
												<c:forEach var="tracker" items="${projectConfigTrackers}">
													<spring:message var="trackerName" code="tracker.type.${tracker.name}.plural" text="${tracker.name}" htmlEscape="true"/>
													<tr data-visible="${tracker.visible}"<c:if test="${!tracker.visible}"> style="display: none;"</c:if>>
														<td class="refCode"><img style="background-color: ${tracker.iconBgColor}" src="${contextPath}${tracker.iconUrl}"></td>
														<td><b><a class="referenceTrackerType" href="${ui:removeXSSCodeAndHtmlEncode(browserUrl)}${tracker.id}"><c:out value="${ui:removeXSSCodeAndHtmlEncode(trackerName)}"/></a></b></td>
													</tr>
												</c:forEach>
											</table>
										</td>
									</tr>
									<tr>
										<td colspan="2">
											<input id="showHiddenTrackers" type="checkbox"><label class="showHiddenTrackers" for="showHiddenTrackers"><spring:message code="tracker.label.showHiddenTrackers" text="Show hidden trackers"/></label>
										</td>
									</tr>
								</table>
							</c:otherwise>
						</c:choose>
					</div>
				</div>
			</div>
		</div>

	</c:when>
	<c:otherwise>

		<ui:actionBar>
			<spring:message code="tracker.coverage.browser.perma.link.hint" var="permaLinkHint"/>
			<a class="actionBarLink" id="permanentLink" href="#" title="${permaLinkHint}"><spring:message code="tracker.coverage.browser.perma.link.label" text="Permanent Link"/></a>
			<a class="actionBarLink" id="managePresets" href="#"><spring:message code="tracker.traceability.browser.manage.presets" text="Load/Manage presets"/></a>
			<c:if test="${userIsProjectAdmin}">
				<a class="actionBarLink" id="saveSetting" href="#"><spring:message code="tracker.traceability.browser.save.setting" text="Save current setting"/></a>
			</c:if>
			<a class="actionBarLink editOfficeActionIcon" id="export"><spring:message code="tracker.issues.exportToOffice.label" text="Export to Office"/></a>
		</ui:actionBar>

		<c:if test="${!empty baseline}">
			<ui:baselineInfoBar projectId="${currentTrackerDto.project.id}" baselineName="${baseline.name}" baselineParamName="revision"/>
		</c:if>

		<div id="traceabilityAccordion" class="accordion">
			<h3 class="accordion-header">${tracBrowserTitle} <spring:message code="tracker.traceability.browser.selected.trackers"/><span class=configImg><img src="<ui:urlversioned value="/images/newskin/action/settings-s.png"/>"></span></h3>
			<div class="accordion-content">
				<div class="controlContainer">
					<table class="levelsTable">
						<tr class="initialTrackers levelTr"<c:if test="${empty baseline && shouldDisplayFilter}"> style="display: none"</c:if>>
							<td class="label">
								<spring:message code="tracker.traceability.browser.initial.trackers"/>
								<c:if test="${empty baseline}">
									<br><a href="#" class="switchToFilter"><spring:message code="tracker.traceability.browser.add.filter"/></a>
								</c:if>
							</td>
							<td class="entities">
								<div class="levelContainer">
									<div class="entityContainerPlaceholder"></div>
									<span class="addInitialButton">+ <spring:message code="button.add" text="Add"/></span>
								</div>
							</td>
						</tr>
						<c:if test="${empty baseline}">
							<tr class="initialFilter levelTr"<c:if test="${empty shouldDisplayFilter}"> style="display: none"</c:if>>
								<td class="label">
									<spring:message code="tracker.traceability.browser.initial.filter"/>
									<br><a href="#" class="switchToTrackers"><spring:message code="tracker.traceability.browser.add.trackers"/></a>
								</td>
								<td class="entities">
									<div class="levelContainer filterLevelContainer">
										<ui:reportSelector sticky="false" showGroupBy="false" showOrderBy="true" triggerResultAfterInit="false"
														   queryString="${currentInitialCbQL}" traceabilityTrackerId="${currentTrackerDto.id}"/>
									</div>
								</td>
							</tr>
						</c:if>
						<tr class="levelTr">
							<td class="label"><spring:message code="tracker.traceability.browser.level"/> <span class="number">1</span></td>
							<td class="entitites">
								<div class="levelContainer droppable">
									<div class="entityContainerPlaceholder"></div>
									<span class="addButton">+ <spring:message code="button.add" text="Add"/></span>
									<span class="numberOfItems">
										<span class="ignore"><spring:message code="tracker.traceability.browser.ignored"/></span>
										<span class="resultNumber"></span><span> <spring:message code="tracker.traceability.browser.items"/></span>
									</span>
								</div>
							</td>
						</tr>
					</table>
					<table class="buttonContainerTable">
						<tr>
							<td class="label"></td>
							<td>
								<spring:message var="searchLabel" code="search.submit.label" text="GO"/>
								<input id="selectButton" type="button" class="button" value="${searchLabel}"/>
								<span id="noFollowWarning" class="warning" style="display: none">
									<spring:message code="tracker.traceability.browser.no.follow.warning"/>
								</span>
							</td>
						</tr>
					</table>
				</div>

				<span class="actionBarSection"><b><spring:message code="tracker.traceability.browser.show.associations" text="Associations:"></b></spring:message>
					<input type="checkbox" id="showAssociations"<c:if test="${showAssociationsSetting}"> checked="checked"</c:if>><label class="checkboxLabel" for="showAssociations"><spring:message code="tracker.traceability.browser.incoming" text="incoming"/></label>
					<input type="checkbox" id="showOutgoingAssociations"<c:if test="${showOutgoingAssociationsSetting}"> checked="checked"</c:if>><label class="checkboxLabel" for="showOutgoingAssociations"><spring:message code="tracker.traceability.browser.outgoing" text="outgoing"/></label>
				</span>
				<span class="actionBarSection"><b><spring:message code="tracker.traceability.browser.show.relations" text="Relations:"></b></spring:message>
					<input type="checkbox" id="showRelations"<c:if test="${showRelationsSetting}"> checked="checked"</c:if>><label class="checkboxLabel" for="showRelations"><spring:message code="tracker.traceability.browser.incoming" text="incoming"/></label>
					<input type="checkbox" id="showOutgoingRelations"<c:if test="${showOutgoingRelationsSetting}"> checked="checked"</c:if>><label class="checkboxLabel" for="showOutgoingRelations"><spring:message code="tracker.traceability.browser.outgoing" text="outgoing"/></label>
				</span>
				<span class="actionBarSection">
					<input type="checkbox" id="excludeFolders"<c:if test="${showFoldersSetting}"> checked="checked"</c:if>><label class="checkboxLabel" for="excludeFolders"><spring:message code="tracker.traceability.browser.show.folders" text="Show Folders and Information"/></label>
				</span>
				<span class="actionBarSection">
					<input type="checkbox" id="showChildren"<c:if test="${showChildrenSetting}"> checked="checked"</c:if>><label class="checkboxLabel" for="showChildren"><spring:message code="tracker.traceability.browser.show.children" text="Show Children"/></label>
				</span>
				<span class="actionBarSection">
					<input type="checkbox" id="showDescription"<c:if test="${showDescriptionSetting}"> checked="checked"</c:if>><label class="checkboxLabel" for="showDescription"><spring:message code="tracker.traceability.browser.show.description" text="Show Description"/></label>
				</span>
				<span class="actionBarSection">
					<input type="checkbox" id="ignoreRedundants"<c:if test="${ignoreRedundantsSetting}"> checked="checked"</c:if>><label class="checkboxLabel" for="ignoreRedundants"><spring:message code="tracker.traceability.browser.dont.show.redundant" text="Do not show redundant Items"/></label>
				</span>
			</div>
		</div>

		<div id="traceabilityBrowserResult" class="traceabilityBrowserDataCont">
			<div class="traceabilityBrowserCont">
				<c:if test="${showSuggestions && (not empty preferredReferencingTrackersAndTypes || not empty referencingTrackersAndTypes)}">
					<div class="information">
						<h3><spring:message code="tracker.traceability.browser.info.refTypes.title"/></h3>
						<table id="referencingTypes" class="referencingTypes">
							<c:if test="${not empty preferredReferencingTrackersAndTypes}">
								<c:forEach var="tracker" items="${preferredReferencingTrackersAndTypes}">
									<spring:message var="trackerName" code="tracker.type.${tracker.name}.plural" text="${tracker.name}"/>
									<tr>
										<c:if test="${!tracker.trackerType}"><td></td></c:if>
										<td class="refCode"><c:if test="${!tracker.branch}"><img style="background-color: ${tracker.iconBgColor}" src="${contextPath}${tracker.iconUrl}"></c:if></td>
										<td<c:if test="${tracker.trackerType}"> colspan="2" </c:if>>
											<b><a class="referenceTrackerType ${tracker.branch ? 'branchTracker level-' : ''}${tracker.branch ? tracker.branchLevel : ''}" href="#" data-id="${tracker.id}" data-tracker-type-id="${tracker.trackerType ? tracker.id : tracker.trackerTypeId}"><c:out value="${trackerName}"/></a></b>
										</td>
									</tr>
								</c:forEach>
							</c:if>
							<c:if test="${not empty referencingTrackersAndTypes}">
								<c:forEach var="tracker" items="${referencingTrackersAndTypes}">
									<spring:message var="trackerName" code="tracker.type.${tracker.name}.plural" text="${tracker.name}"/>
									<tr>
										<c:if test="${!tracker.trackerType}"><td></td></c:if>
										<td class="refCode"><c:if test="${!tracker.branch}"><img style="background-color: ${tracker.iconBgColor}" src="${contextPath}${tracker.iconUrl}"></c:if></td>
										<td<c:if test="${tracker.trackerType}"> colspan="2" </c:if>>
											<a class="referenceTrackerType ${tracker.branch ? 'branchTracker level-' : ''}${tracker.branch ? tracker.branchLevel : ''}" href="#" data-id="${tracker.id}" data-tracker-type-id="${tracker.trackerType ? tracker.id : tracker.trackerTypeId}"><c:out value="${trackerName}"/></a>
										</td>
									</tr>
								</c:forEach>
							</c:if>
						</table>
					</div>
				</c:if>
			</div>
		</div>
	</c:otherwise>
</c:choose>

<c:if test="${empty projectLevel}">
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

<div id="saveSettingDialog" title="<spring:message code="tracker.traceability.browser.save.setting" text="Save current setting"/>">
	<table>
		<tr>
			<td style="padding-right: 0.5em"><spring:message code="tracker.traceability.browser.preset.name" text="Preset name"/>:</td>
			<td><input type="text" class="name" size="40"></td>
		</tr>
	</table>
</div>
</c:if>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/traceabilityBrowser/traceabilityBrowser.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/traceabilityBrowser/traceability.js'/>"></script>

<script>

	$(function() {

		var accordion = $('.accordion');
		accordion.cbMultiAccordion();
		accordion.cbMultiAccordion("open", 0);

		<c:choose>

			<c:when test="${not projectLevel}">

				var initialMenuItems = {};
				<c:forEach var="item" items="${initialTrackerEntities}">
					initialMenuItems["<c:out value="${item.name}"/>"] = {
						name: "<c:out value="${item.name}"/>",
						callback: function(key, opt) {
							codebeamer.Traceability.addEntityToLevel($(this), "<c:out value="${item.name}"/>", ${item.id}, ${item.trackerTypeId}, "${contextPath}${item.iconUrl}", true, null, null, ${not empty revisionId ? revisionId : 'null'});
						}
					};
				</c:forEach>
				initialMenuItems["separator1"] = "---";
				initialMenuItems["addCustomTracker"] = {
					name: i18n.message("tracker.traceability.browser.custom.tracker"),
					callback: function() {
						codebeamer.Traceability.addCustomTracker($(this));
					}
				};

				var excludePreviousLevelTypeIds = [];
				<c:forEach var="typeId" items="${excludePreviousLevelTypes}">
					excludePreviousLevelTypeIds.push(${typeId});
				</c:forEach>

				var trackerTypeItems = {};
				<c:forEach var="item" items="${trackerTypeEntities}">
					trackerTypeItems["${item.name}"] = {
						name: "${item.name}",
						callback: function(key, opt) {
							codebeamer.Traceability.addEntityToLevel($(this), "${item.name}", ${item.id}, ${item.id}, "${contextPath}${item.iconUrl}", false);
						}
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
							codebeamer.Traceability.addEntityToLevel($(this), "<c:out value="${item.name}"/>", ${item.id}, ${item.trackerTypeId}, "${contextPath}${item.iconUrl}", false);
						},
						id: ${item.id}
					};
				</c:forEach>

				var defaultViews = [];
				<c:forEach items="${defaultViews}" var="view">
					defaultViews.push({
						id: ${view.id},
						name: "<spring:message code="tracker.view.${view.name}.label" text="${view.name}" />"
					});
				</c:forEach>

				var initialTrackerList = [];
				<c:if test="${currentInitialTrackerParameters != null}">
					<c:forEach items="${currentInitialTrackerParameters}" var="parameter">
						initialTrackerList.push({
							id: ${parameter.numericId},
							trackerTypeId: ${parameter.trackerType ? parameter.numericId : parameter.trackerTypeId},
							name: "<c:out value="${parameter.label}"/>",
							viewId: ${parameter.trackerViewId},
							branchId: ${empty parameter.branchId ? 'null' : parameter.branchId},
							iconUrl: "${contextPath}${parameter.iconUrl}"
						});
					</c:forEach>
				</c:if>

				var trackerList = [];
				<c:if test="${currentTrackerParameters != null}">
					<c:forEach items="${currentTrackerParameters}" var="level">
						var level = [];
						<c:forEach items="${level}" var="parameter">
							level.push({
								id: ${parameter.numericId},
								name: "<c:out value="${parameter.label}"/>",
								isTrackerType: ${parameter.trackerType},
								trackerTypeId: ${parameter.trackerType ? parameter.numericId : parameter.trackerTypeId},
								iconUrl: "${contextPath}${parameter.iconUrl}",
								isAll: ${parameter.all}
							});
						</c:forEach>
						trackerList.push(level);
					</c:forEach>
				</c:if>

				codebeamer.Traceability.init({
					trackerId: ${currentTrackerDto.id},
					currentViewId : ${currentViewId},
					currentShowAssociation: ${empty currentShowAssociation ? 'true' : currentShowAssociation},
					currentShowOutgoingAssociation: ${empty currentShowOutgoingAssociation ? 'true' : currentShowOutgoingAssociation},
					currentShowRelation: ${empty currentShowRelation ? 'true' : currentShowRelation},
					currentShowOutgoingRelation: ${empty currentShowOutgoingRelation ? 'true' : currentShowOutgoingRelation},
					currentExcludeFolders: ${empty currentExcludeFolders ? 'true' : currentExcludeFolders},
					currentShowChildren: ${empty currentShowChildren ? 'true' : currentShowChildren},
					currentShowDescription: ${empty currentShowDescription ? 'true' : currentShowDescription},
					currentIgnoreRedundants: ${empty currentIgnoreRedundants ? 'true' : currentIgnoreRedundants},
					currentTrackerList: '${empty currentTrackerList ? false : currentTrackerList}',
					currentInitialTrackerList: '${empty currentInitialTrackerList ? false : currentInitialTrackerList}',
					currentInitialCbQL: '${empty currentInitialCbQL ? 'null' : ui:escapeJavaScript(currentInitialCbQL)}',
					currentLevelReferenceTypes: '${empty levelReferenceTypes ? '' : levelReferenceTypes}',
					initialMenuItems: initialMenuItems,
					trackerTypeMenuItems: trackerTypeItems,
					trackerMenuItems: trackerItems,
					defaultViews: defaultViews,
					initialTrackerList: initialTrackerList,
					trackerList: trackerList,
					getTrackerViewsUrl: contextPath + "/ajax/traceabilitybrowser/getTrackerViews.spr",
					addCustomTrackerUrl: contextPath + "/ajax/traceabilityBrowser/addCustomTracker.spr",
					manageSettingUrl: "${manageSettingUrl}",
					saveSettingUrl: "${saveSettingUrl}",
					browserUrl: "${browserUrl}",
					configUrl: "${configUrl}",
					exportUrl: "${exportUrl}",
					revisionId: ${not empty revisionId ? revisionId : 'null'},
					selectedBranchId: ${not empty branchId ? branchId : 'null'},
					excludePreviousLevelTypeIds: excludePreviousLevelTypeIds
				});
			</c:when>

			<c:otherwise>
				codebeamer.Traceability.initProjectLevel({
					manageSettingUrl: "${manageSettingUrl}"
				});
			</c:otherwise>

		</c:choose>

	});

</script>

