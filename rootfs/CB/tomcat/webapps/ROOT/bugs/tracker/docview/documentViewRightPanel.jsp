
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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="showTestPlanTree" value="${!empty defaultTestPlanTracker  && canCreateTestCase && canEditSubject}"/>
<c:set var="showReuseLibrary" value="${(tracker.requirementLike || tracker.risk || tracker.testCase) && canCreateIssue}"/>

<spring:message code="testManagement.categories.testCaseLibrary" var="testPlanTitle"/>
<spring:message code="${tracker.userStory? 'tracker.field.Sprint.plural.label' : 'tracker.type.Release.plural'}" var="releasesTitle"/>
<spring:message code="document.properties.label" var="propertiesTitle"/>
<script type="text/javascript">
	//generate the populate function for the test case tree
	var testPopulator = codebeamer.trackers.generateTreePopulator("", "${defaultTestPlanTracker.id}", "", false, false, function () {
		return {
			"selectedStatusMeaning": $("#testStatusMeaning").val()
		};
	});

	var populator = codebeamer.trackers.generateTreePopulator("${projectId}", "${defaultReleaseTracker.id}", "", true, true);
	var releaseTreePopulator = function (n) {
		var data = populator(n);
		data["releasesFor"] = "${tracker.id}";
		return data;
	};

	$(document).ready(function () {
		userSettings.load("LIBRARY_TREE_FILTERS", function (settings) {
			settings =  settings ? JSON.parse(settings) : {};
			var treesByType = {
					"REQUIREMENT": "libraryPane",
					"TESTCASE": "testTreePane",
					"EPIC": "libraryPane"
			};

			for (k in treesByType) {
				if (settings[k]) {
					var $pane = $("#" + treesByType[k]);
					var $select = $pane.siblings(".actionBar").find("select");
					$select.val(settings[k]);
					reloadLibraryTree(treesByType[k]);
				}
			}
		});
	});
</script>
<div style="height: calc(100% - 36px);">
	<c:set var="trackerType" value="${fn:toLowerCase(tracker.type)}" />
	<div id="accordion" data-item-inner-accordion-state="<c:out value="${itemAccordionStateJson}" />" style="height: 100%;">
		<div>
			<ul class="quick-icons" id="main-quick-icons">
				<c:if test="${revision == null && baseline == null}">
					<c:if test="${showTestPlanTree}">
						<li class="test-library" title="<spring:message code="testManagement.categories.testCaseLibrary"/>" data-tab="test-plan-pane"></li>
					</c:if>
					<c:if test="${showReuseLibrary }">
						<li class="requirement-library" title="<spring:message code="tracker.view.layout.document.${trackerType}.library.title"/>" data-tab="library-tab"></li>
					</c:if>
				</c:if>

				<c:if test="${!empty defaultReleaseTracker && revision == null && baseline == null}">
					<li class="release" title="${releasesTitle}" data-tab="release-pane"></li>
				</c:if>
				<li class="properties active" title="${propertiesTitle }" data-tab="properties-tab"></li>
			</ul>
		</div>
		<c:if test="${revision == null && baseline == null}">
			<c:if test="${showTestPlanTree}">
				<%-- these two tabs are hidden in baseline mode --%>
				<!--  <h3 class="accordionHeader">${testPlanTitle}</h3>-->
				<div id="test-plan-pane" class="tab">
					<div class="actionBar" style="margin: -10px -10px 0px -10px; padding-bottom: 10px;">
						<ui:treeFilterBox treeId="testTreePane"/>
						<div class="toolsContainer" style="width: 30px; display: inline;">
							<c:url var="libraryConfigUrl" value="/trackers/library/configure.spr">
								<c:param name="tracker_id" value="${tracker.id}"/>
								<c:param name="tree_id" value="testTreePane"/>
								<c:param name="tracker_type" value="testcase"/>
								<%-- we no longer need to make sure that the tracker is configured correctly to reference the requirement tracker --%>
								<c:param name="strictReference" value="false"/>
								<c:param name="fieldId" value="17"/>
							</c:url>
							<spring:message code="testLibrary.configuration.label" text="Configure" var="configureLibraryTitle"/>
							<select name="testStatusMeaning" id="testStatusMeaning" onchange="reloadLibraryTree('testTreePane', 'TESTCASE', $(this).val());">
								<option value="Any"><spring:message code="cmdb.version.issues.filter.all" text="All"/></option>
								<option value="Open"><spring:message code="cmdb.version.issues.filter.open" text="Open"/></option>
								<option value="ClosedOrResolved"><spring:message code="cmdb.version.issues.filter.resolvedOrClosed" text="Resolved/Closed"/></option>
								<option value="Closed"><spring:message code="cmdb.version.issues.filter.closed" text="Closed"/></option>
								<option value="Resolved"><spring:message code="cmdb.version.issues.filter.resolved" text="Resolved"/></option>
							</select>
							<a id="configureLibrary" href="#" onclick="showPopupInline('${libraryConfigUrl}');"><img class="action" src="<c:url value='/images/newskin/action/settings-s.png'/>" title="${configureLibraryTitle}" alt="${configureLibraryTitle}"></a>
						</div>
					</div>

					<ui:treeControl containerId="testTreePane" url="${pageContext.request.contextPath}/trackers/ajax/library/tree.spr?tracker_id=${tracker.id}&tracker_type=testcase&strictReference=false&fieldId=17&showOnlySuccessfulMeaning=true"
						populateFnName="testPopulator" dndDisabled="${!canEditSubject || !canEditTestCases}" treeVariableName="testTree" editable ="${canEditSubject && canEditTestCases}"
						checkMoveFnName="codebeamer.testCaseTree.tectCaseCheckMove" checkExternalDrop="codebeamer.testCaseTree.testCaseCheckExternalDrop" disableTreeCookies="true"
						nodeMovedHandler="codebeamer.testCaseTree.testCaseMoved"/>
					<div id="testTreePane" style="height:50%;overflow:visible;"></div>
				</div>
			</c:if>
			<c:if test="${showReuseLibrary}">
				<script type="text/javascript">
					var libraryPopulator = codebeamer.trackers.generateTreePopulator("", "${tracker.id}", "", true, true, function () {
						return {
							"selectedStatusMeaning": $("#requirementStatusMeaning").val()
						};
					});
				</script>
				<!--  <h3 class="accordionHeader"><spring:message code="tracker.view.layout.document.${trackerType}.library.title" text="${tracker.type} Library"/></h3>-->
				<div id="library-tab" class="library tab">
					<div class="actionBar" style="margin: -10px -10px 0px -10px; padding-bottom: 10px;">
						<div style="display: inline;">
							<ui:treeFilterBox treeId="libraryPane"/>
						</div>
						<div class="toolsContainer" style="width: 30px; display: inline;">
							<c:url var="libraryConfigUrl" value="/trackers/library/configure.spr">
								<c:param name="tracker_id" value="${tracker.id}"/>
								<c:param name="tree_id" value="libraryPane"/>
								<c:param name="tracker_type" value="${trackerType}"/>
							</c:url>
							<spring:message code="requirementLibrary.configuration.label" text="Configure" var="configureLibraryTitle"/>
							<c:set var="filterType" value="${tracker.requirement ? 'REQUIREMENT' : 'TESTCASE' }"></c:set>
							<select name="requirementStatusMeaning" id="requirementStatusMeaning" onchange="reloadLibraryTree('libraryPane', '${filterType }', $(this).val());">
								<option value="Any"><spring:message code="cmdb.version.issues.filter.all" text="All"/></option>
								<option value="Open"><spring:message code="cmdb.version.issues.filter.open" text="Open"/></option>
								<option value="ClosedOrResolved"><spring:message code="cmdb.version.issues.filter.resolvedOrClosed" text="Resolved/Closed"/></option>
								<option value="Closed"><spring:message code="cmdb.version.issues.filter.closed" text="Closed"/></option>
								<option value="Resolved"><spring:message code="cmdb.version.issues.filter.resolved" text="Resolved"/></option>
							</select>
							<a id="configureLibrary" href="#" onclick="showPopupInline('${libraryConfigUrl}');"><img class="action" src="<ui:urlversioned value='/images/newskin/action/settings-s.png'/>" title="${configureLibraryTitle}" alt="${configureLibraryTitle}"></a>
						</div>
					</div>
					<ui:treeControl containerId="libraryPane" url="${pageContext.request.contextPath}/trackers/ajax/library/tree.spr?tracker_type=${trackerType}"
						populateFnName="libraryPopulator" dndDisabled="false" treeVariableName="libraryTree" editable="true"
						disableTreeCookies="true" initTreeOnPageLoad="false" externalDropHandler="codebeamer.issueLibrary.libraryExternalDrop"
						checkMoveFnName="codebeamer.issueLibrary.libraryCheckDrop" disableMultipleSelection="true" cookieNameOpenNodes="false"
						checkExternalDrop="codebeamer.issueLibrary.libraryCheckExternalDrop" searchConfig="codebeamer.issueLibrary.searchConfig"
						config="{ canViewAssociations: ${canViewAssociations}, canCreateAssociations: ${canCreateAssociations}}"
					/>
					<div id="libraryPane" style="height: 100%;"></div>
				</div>
			</c:if>
			<c:if test="${!empty defaultReleaseTracker}">
				<!--  <h3 class="accordionHeader">${releasesTitle}</h3>-->
				<div id="release-pane" class="tab">
					<div class="textHint"><spring:message code="tracker.view.layout.document.release.planning.hint"/></div>
					<ui:treeFilterBox treeId="releaseTreePane"/>
					<ui:treeControl containerId="releaseTreePane" url="${pageContext.request.contextPath}/trackers/ajax/tree.spr"
						populateFnName="releaseTreePopulator" dndDisabled="false" treeVariableName="releaseTree" editable ="${canCreateRelease}"
						checkMoveFnName="codebeamer.releaseTree.releaseCheckMove" checkExternalDrop="codebeamer.testCaseTree.testCaseCheckExternalDrop"
						nodeMovedHandler="codebeamer.releaseTree.releaseNodeMoved" populateContextMenuFnName="codebeamer.releaseTree.releaseTreeContextMenu" disableTreeCookies="true"
						initTreeOnPageLoad="false"/>
					<div id="releaseTreePane" style="height:50%;overflow:visible;"></div>
				</div>
			</c:if>
		</c:if>
		<!--  <h3 class="accordionHeader">${propertiesTitle}</h3>-->
		<div id="properties-tab" class="tab">
			<div id="issuePropertiesPane"  style="height: 100%;"></div>
		</div>
	</div>
</div>
<script type="text/javascript">
	jQuery(function($) {
		var accordion = $("#accordion");
		var h = accordion.parent().height() - accordion.find("h3").size() * 40;
		$("#issuePropertiesPane").height(h);
		var resizeAccordion = throttleWrapper(function() {
			$.isFunction(codebeamer.common.adjustDocumentViewAccordionLayout) && codebeamer.common.adjustDocumentViewAccordionLayout();
		});
		$(window).resize(resizeAccordion);

		// set the accordion size after an item was loaded
		$(document).on("codebeamer:issueLoaded", resizeAccordion);
		$("#panes").bind("westResize", resizeAccordion).bind("eastResize", resizeAccordion);
		setTimeout(resizeAccordion, 250);
	});
</script>

<script type="text/javascript">
	jQuery(function($) {
		initializeTabs($("#accordion"), $("#main-quick-icons"));
	});
</script>