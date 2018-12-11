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
<%@ page import="com.intland.codebeamer.remoting.GroupType"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab"%>

<meta name="decorator" content="${param.isPopup ? 'popup' : 'main' }" />
<meta name="module" content="tracker" />
<meta name="applyLayout" content="true" />

<!--[if IE 8]>
	<style type="text/css">
		.qq-upload-list {
			min-width: 50px;
			left: 0px !important;
			top: 0px !important;
		}
	</style>
<![endif]-->

<%-- TODO: i18n everything here ! --%>

<head>
	<link rel="stylesheet" href="<ui:urlversioned value='/testmanagement/editTestSet.less' />" type="text/css" media="all" />
	<script type="text/javascript" src="<ui:urlversioned value='/testmanagement/editTestSet.js' />"></script>
</head>

<c:set var="testCasesEditable" value="${addUpdateTaskForm.testCasesEditable}" />
<c:set var="testCaseListing">
	<c:if test="${testCasesEditable}">
		<div class="warning" id="duplicatesWarning" style="display: none;">
			<spring:message code="testset.editor.testcases.confirm.remove.duplicates" />
			<spring:message var="removeDuplicatesButton" code="testset.editor.testcases.confirm.remove.duplicates.button"/>
			<input style="margin-left:10px;" type="button" class="button" onclick="duplicatesHandling.removeDuplicates($('#testCasesTable'));" value="${removeDuplicatesButton}" />
		</div>
	</c:if>

	<jsp:include page="./testSetsTestCases.jsp?editable=${testCasesEditable}" />
	<script type="text/javascript" src="<ui:urlversioned value="/js/treeToTableDndIntegration.js"/>"></script>

	<c:if test="${testCasesEditable}">
		<%-- drag-drop reordering of rows in testCasesTable table --%>
		<script type="text/javascript">
			duplicatesHandling.allowDuplicatesFieldId = '${! empty allowDuplicatesField ? allowDuplicatesField.id : ''}';
			duplicatesHandling.allowDuplicatesDefault = ${allowDuplicatesDefault};

			$(function() {
				editTestSet.initEvents("#testCasesTable");

				<%--
				   a helper with preserved width of cells
		  		   see here: http://www.foliotek.com/devblog/make-table-rows-sortable-using-jquery-ui-sortable/
				--%>
				function tableRowHelper (e, tr) {
				    var $originals = tr.children();
				    var $helper = tr.clone();
				    $helper.children().each(function(index) {
				      // Set helper cell sizes to match the original sizes
				      $(this).width($originals.eq(index).width());
				    });
				    return $helper;
				}

                var initTableDragDrop = function() {
                    console.log("initTableDragDrop starting");
                    var start = new Date().getTime();
                    $("#testCasesTable").find("tbody").sortable({
                        revert:true,
                        helper: tableRowHelper,
                        delay: 200, /* avoid unwanted drags when clicking on the delete button */
                        placeholder: "dragRowPlaceholder",
                        containment: "document",
                        update: function(event, ui) {
                            // trigger a changed event to fix zebra stripes of parent table
                            if (ui.item) {
                                var $table = $(ui.item).closest("table");
                                $table.trigger("changed");
                            }
                        }
                    }).disableSelection();
                    var end = new Date().getTime();
                    console.log("initTableDragDrop took " + (end - start) + " ms");
                };

                setTimeout(initTableDragDrop, 200);
			});
		</script>
	</c:if>
</c:set>

<c:if test="${testCasesEditable}">
	<c:set var="rightPane">
		<script type="text/javascript">
		// the field contains the ids from the tree
		var idFieldSelector = "input[name='testCaseIdsInOrder']";
		$(function() {
			var msg = "testset.editor.testcases.table.drop.testcases.here";
			TreeToTableDNDIntegration.init("#testCasesTable", "#testTreePane", msg, idFieldSelector);
			TreeToTableDNDIntegration.init("#testCasesTable", "#testSetsTreePane", msg, idFieldSelector);
			TreeToTableDNDIntegration.init("#testCasesTable", "#testLibraryTreePane", msg, idFieldSelector);
			TreeToTableDNDIntegration.init("#testCasesTable", "#testSetLibraryTreePane", msg, idFieldSelector);
		});

		var currentTestSetId = ${! empty addUpdateTaskForm.task_id? addUpdateTaskForm.task_id : -1};

		var testCaseTreeConfig = {
			data: codebeamer.trackers.generateTreePopulator("${testSetTracker.project.id}", "${testSetTracker.id}", "", true, true),

			// these settings are merged to the tree config
			treeConfig: {
				dnd: {
					drop_target: "#testCasesTable tbody tr"
				},
				core: {
					initially_open: ["${testPlanTracker.id}"]
				}
			},

			_addDroppedNodes: function($placeToDrop, tree, $nodes) {
				if ($nodes && $nodes.length >0) {
					var testCaseIds = [];
					var trackerIds = [];

					for (var i = 0; i< $nodes.length; i++) {
						var selectedNode = $nodes[i];
						var id = selectedNode.id;
						// var title =$(selectedNode).attr("title");
						var typeid = selectedNode.li_attr["typeId"];
						if (typeid == "<%=GroupType.TRACKER_ITEM%>") {
							if (currentTestSetId == id) {
								console.log("Not adding this TestSet to itself:" + currentTestSetId);
							} else {
								testCaseIds.push(id);
							}
						}
						if (typeid == "<%=GroupType.TRACKER%>") {
							// the complete TestCase tracker has been dropped, add all
							trackerIds.push(selectedNode.li_attr["trackerId"]);
						}
					}

					editTestSet.addTestCasesOrTestSets(testCaseIds, trackerIds, $placeToDrop, false);
				}
			},

			"externalDropCheck": function(node, $target, event) {
				var $placeToDrop = $target.closest("table").find(".treeToTableDropPlaceHolder");
				if (!$placeToDrop || $placeToDrop.length == 0) {
					return false;
				}
				return true;
			},

			updateDropIcon: true,	// update the drag-drop icon

			"externalDrop" : function(node, $target, event) {
				var $placeToDrop = $target.closest("table").find(".treeToTableDropPlaceHolder");
				if (!$placeToDrop || $placeToDrop.length == 0) {
					console.log("Nowhere to drop!");
					return false;
				}

				// TODO: this is called twice, why? using a flag to avoid the 2nd and further calls
				if (! event.alreadyHandled) {
					event.alreadyHandled = true;

					// add nodes being dragged
					var tree = $.jstree.reference(node[0]);
					// console.log("add-dropped-nodes:" + node);
					this._addDroppedNodes($placeToDrop, tree, node);
				}
				return false;
			},
			"checkMove" : function() {
				// no dnd inside the test case tree
				return false;
			}
		};

			var testSetTreeConfig = $.extend(true, {}, testCaseTreeConfig, {
				data : codebeamer.trackers.generateTreePopulator("${testSetTracker.project.id}", "${testSetTracker.id}", "", true, true, function () {
					return {
						"selectedStatusMeaning": $("#testStatusMeaning").val()
					};
				}),
				treeConfig: {
					core: {
						initially_open: ["${testSetTracker.id}"]
					}
				}
			});

			var testCaseLibraryTreeConfig = $.extend(true, {}, testCaseTreeConfig, {
				data : codebeamer.trackers.generateTreePopulator("", "", "", false, false, function () {
					return {
						"selectedStatusMeaning": $("#testStatusMeaning").val()
					};
				})
			});
			var testSetLibraryTreeConfig = $.extend(true, {}, testSetTreeConfig, {
				cookieNameOpenNodes: false,
				disableTreeCookies: true
			});

			var filterTreeBySearch = function(data, panelId) {
				// return the tracker ids that are actually present in the tree, because otherwise jstree will not show anything
				var $panel = $("#" + panelId);
				var filtered = $.grep(data, function (elem, index) {
					if ($panel.find(elem)) {
						return true;
					}
					return false;
				});
				return filtered;
			};

			var testSetSearchConfig = {
				"ajax": {
					"url": contextPath + "/trackers/ajax/library/search.spr",
					"data": {
						"tracker_type": "testset"
					},
					"success": function (data) {
						return filterTreeBySearch(data, "testSetLibraryTreePane");
					}
				}
			};

			var testCaseSearchConfig = {
				"ajax": {
					"url": contextPath + "/trackers/ajax/testlibrary/testcase/search.spr",
					"data": {
						"tracker_id": "${testSetTracker.id}"
					},
					"success": function (data) {
						return filterTreeBySearch(data, "testTreePane");
					}
				}
			};

			$(function() {
				// highlight the elements in cycle
				<c:if test="${! empty addUpdateTaskForm.testSetsInCycleIds}">
					var testSetsInCycle = ${addUpdateTaskForm.testSetsInCycleIds};
					console.log("testSetsInCycle:" + testSetsInCycle);

					$(idFieldSelector).each(function() {
						var id = parseInt($(this).val());
						if ($.inArray(id, testSetsInCycle) != -1) {
							$(this).closest("tr").addClass("testSetInCycle");
						}
					});
				</c:if>
			});
		</script>

		<spring:message var="testPlanLabel" code="testManagement.categories.testPlan" text="Test Plans" />
		<spring:message var="testPlanLibraryLabel" code="testManagement.categories.testPlanLibrary" text="Test Plan Library" />
		<spring:message var="testSetLabel" code="testManagement.categories.testSet" text="Test Sets" />
		<spring:message var="testSetLibraryLabel" code="testManagement.categories.testSetLibrary" text="Test Set Library" />
		<spring:message code="tracker.tree.settings.title" text="Settings" var="settingsTitle"/>

		<div id="testAccordion">
			<h3 class="accordionHeader accordion-header">${testPlanLabel}</h3>
			<div id="testPlanPane" class="accordion-content">
				<div class="actionBar"><ui:treeFilterBox treeId="testTreePane" /></div>
				<ui:treeControl containerId="testTreePane" url="${pageContext.request.contextPath}/trackers/ajax/testlibrary/testcase/tree.spr?tracker_id=${testSetTracker.id}"
								dndDisabled="false" treeVariableName="testTree" editable="true"	config="testCaseTreeConfig" searchConfig="testCaseSearchConfig"/>
				<div id="testTreePane" class="pane" data-tracker-id="${testSetTracker.id }"></div>
			</div>

			<h3 class="accordionHeader accordion-header">${testSetLabel}</h3>
			<div id="testSetPane" class="accordion-content">
				<div class="actionBar"><ui:treeFilterBox treeId="testSetsTreePane" /></div>
				<ui:treeControl containerId="testSetsTreePane" url="${pageContext.request.contextPath}/trackers/ajax/tree.spr"
								dndDisabled="false" treeVariableName="testSetTree" editable="true" config="testSetTreeConfig" />
				<div id="testSetsTreePane" class="pane" data-tracker-id="${testSetTracker.id}"></div>
			</div>

			<h3 class="accordionHeader accordion-header">${testSetLibraryLabel}</h3>
			<div id="testSetLibraryPane" class="accordion-content">
				<div class="actionBar"><!--
					--><div class="filterBoxContainer"><ui:treeFilterBox treeId="testSetLibraryTreePane" /></div><!--
					--><div class="toolsContainer">
						<select name="testStatusMeaning" id="testStatusMeaning" onchange="reloadLibraryTree('testSetLibraryTreePane');" style="margin-left: 10px;">
							<option value="Any"><spring:message code="cmdb.version.issues.filter.all" text="All"/></option>
							<option value="Open"><spring:message code="cmdb.version.issues.filter.open" text="Open"/></option>
							<option value="ClosedOrResolved"><spring:message code="cmdb.version.issues.filter.resolvedOrClosed" text="Resolved/Closed"/></option>
							<option value="Closed"><spring:message code="cmdb.version.issues.filter.closed" text="Closed"/></option>
							<option value="Resolved"><spring:message code="cmdb.version.issues.filter.resolved" text="Resolved"/></option>
						</select>
						<a id="configureTestSets" href="#"><img class="action" src="<c:url value='/images/newskin/action/settings-s.png'/>" title="${settingsTitle}" alt="Configure"></a>
					</div><!--
				--></div>
				<ui:treeControl containerId="testSetLibraryTreePane" url="${pageContext.request.contextPath}/trackers/ajax/library/tree.spr?tracker_id=${testSetTracker.id}&tracker_type=testset"
								dndDisabled="false" treeVariableName="testSetLibraryTree" editable="true" config="testCaseLibraryTreeConfig"
								searchConfig="testSetSearchConfig" initTreeOnPageLoad="false"/>
				<div id="testSetLibraryTreePane" class="pane" data-tracker-id="${testSetTracker.id }"></div>
			</div>
		</div>

		<script type="text/javascript" src="<ui:urlversioned value="/js/testLibrary.js"/>"></script>
	</c:set>
</c:if>

<spring:message scope="request" var="itemLabel" code="tracker.type.Testset" />

<c:url var="actionUrl" value="${action}">
	<%-- to stay on the same page when validation fails we must use the action --%>
	<c:param name="tracker_id" value="${addUpdateTaskForm.tracker_id}" />
	<c:param name="task_id" value="${addUpdateTaskForm.task_id}" />
</c:url>
<jsp:include page="/bugs/addUpdateTaskActionMenuBar.jsp"/>
<form:form action="${actionUrl}" enctype="multipart/form-data" commandName="addUpdateTaskForm" class="dirty-form-check">

	<ui:splitTwoColumnLayoutJQuery cssClass="autoAdjustPanesHeight" hideRightPane="${! testCasesEditable}" rightMinWidth="320">
		<jsp:attribute name="rightContent" trim="true">
			${rightPane}
		</jsp:attribute>
		<jsp:body>
			<%-- this is replacing buttons in addUpdateTask.jsp --%>
			<c:set var="controlButtons" scope="request">
				<script type="text/javascript">
					function submitForm(form) {
						if (! duplicatesHandling.allowDuplicates()) {
							var dupes = $(".duplicate");
							var hasDuplicates = dupes.length > 0;
							if (hasDuplicates) {
								showFancyAlertDialog(i18n.message('testset.editor.can.not.save.duplicates', contextPath));

								return false;
							}
						}

						return submitAction(form);
					}
				</script>

				<spring:message var="saveButton" code="button.save" />
				<input type="submit" class="button" value="${saveButton}" name="SUBMIT" onclick="return submitForm(this.form);" />

				<spring:message var="cancelTitle" code="button.cancel" text="Cancel" />
				<input type="submit" class="cancelButton" name="_cancel" value="${cancelTitle}" onclick="codebeamer.NavigationAwayProtection.reset()" />
			</c:set>

			<%--
				show Test Set issue's properties
				also adds breadcrumb, and action-bar with buttons
			 --%>

			<c:set var="insertAtEndOfTableFragment" scope="request">
				<%-- test-parameter management --%>
				<jsp:include page="/testmanagement/parameters/parametersConfiguration.jsp"/>

				${testCasesEditor}
			</c:set>
			<jsp:include page="/bugs/addUpdateTask.jsp?noForm=true&nestedPath=null&noAssociation=true&noTrackerField=true&noActionMenuBar=true&noComment=true&minimumDescriptionHeight=true&collapseDescriptionIfEmpty=true" />

			<div class="contentWithMargins" style="margin-top: -10px;">
				<spring:message var="testCasesOrTestSets" code="testset.editor.testcases.or.testsets.label" />
				<c:set var="testCasesLabel">
					${testCasesOrTestSets}
					<ui:helpLink target="_blank" helpURL="https://codebeamer.com/cb/wiki/95044#section-Organizing+Test+Cases+to+Test+Sets" />
				</c:set>

				<ui:collapsingBorder label="${testCasesLabel}" title="${testCasesOrTestSets}"
					hideIfEmpty="false" open="true"
					cssClass="separatorLikeCollapsingBorder" cssStyle="margin-bottom:0;" >
					${testCaseListing}
				</ui:collapsingBorder>
			</div>
		</jsp:body>
	</ui:splitTwoColumnLayoutJQuery>

</form:form>

<script type="text/javascript">
	$(document).ready(function () {
		setupKeyboardShortcuts("addUpdateTaskForm");
		disableDoubleSubmit($("#addUpdateTaskForm"));

		$(document).on('dnd_start.vakata.jstree', function () {
			TreeToTableDNDIntegration.highlightTable($("#testCasesTable"));
			$(document).on('dnd_stop.vakata', function () {
				TreeToTableDNDIntegration.removeHighlightTable($("#testCasesTable"));
			});
		});

	});
</script>

