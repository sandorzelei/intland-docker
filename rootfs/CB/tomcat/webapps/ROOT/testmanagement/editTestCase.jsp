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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="${param.isPopup ? 'popup' : 'main' }"/>
<meta name="module" content="tracker"/>
<meta name="applyLayout" content="true"/>

<script type="text/javascript" src="<ui:urlversioned value="/js/editTestStep.js"/>"></script>
<script type="text/javascript" src="<ui:urlversioned value="/js/testLibrary.js"/>"></script>
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/editTestCase.css" />" type="text/css" media="all" />

<c:url value='/images/newskin/action/delete-grey-xs.png' var="deleteImgUrl"/>

<c:set var="editorContent">
	<script type="text/javascript">
		var generatedPopulator = codebeamer.trackers.generateTreePopulator("${tracker.project.id}", "${tracker.id}", "", true, true);
		var populator = generatedPopulator;
		<c:if test="${not empty addUpdateTaskForm.task_id}">
			populator = function (n) {
				var data = generatedPopulator(n);
				data["excludedIssueId"] = "${addUpdateTaskForm.task_id}";
				return data;
			};
		</c:if>

		var stepStore;

		/**
		 * handles the event of dropping a node from the tree to the table
		 */
		var externalDrop = function(node, $target, event) {
			var $placeToDrop = $target.closest("table").find(".treeToTableDropPlaceHolder");
			if (!$placeToDrop || $placeToDrop.length == 0) {
				console.log("Nowhere to drop!");
				return false;
			}
			// insert a new row after the target
			var $reference = $placeToDrop.prev("tr");
			if (!$reference || $reference.length == 0) {
				// the table is empty
				$reference = $placeToDrop;
			}

			var createdRows = [];
			for (var i = node.length - 1; i >= 0; i--) {
				var $newRow = editor_testSteps.insertRow($reference, "after");

				// fill the fields of the new row with the data of the copied step
				var $node = node[i];
				var stepData = stepStore[$node.id];
				var issueId = $node.li_attr.myReference.match(/\d+/g)[0];
				var inputs = $newRow.find("textarea.inlineInput");

				$(inputs[0]).html(codebeamer.TestStepEditor.attachmentRelinkingInWikiMarkup(stepData["action"], issueId));
				$(inputs[1]).html(codebeamer.TestStepEditor.attachmentRelinkingInWikiMarkup(stepData["expectedResult"], issueId));
				if (stepData["critical"]) {
					$newRow.find("[type=checkbox]").click();
				}
				var nodeReference = $node.li_attr["myReference"];
				$newRow.find("[name='referredTestSteps']").val(nodeReference);
				$newRow.find("[name='originalTestSteps']").val(nodeReference);

				var $generatedId = $newRow.find("[name='generatedId']");
				var generatedIdValue = node.id;
				if ($generatedId.length == 0) {
					var $hidden = $("<input>", {"type": "hidden", "name": "generatedId", "value": generatedIdValue});
					$newRow.find("td:first").append($hidden);
				} else {
					$generatedId.val(generatedIdValue);
				}

				var $domNode = $("li#" + node.id);
				$domNode.addClass("used");

				$.each(['.actionCell', '.expectedResultCell'], function(index, selector) {
					var $cell = $newRow.find(selector),
						$textarea = $cell.find('textarea.inlineInput');
					codebeamer.TestStepEditor.renderHtmlForCell($cell, $textarea);
				});

				createdRows.push($newRow);
			}

			codebeamer.TestStepEditor.updateTestStepEditorLook($("#testSteps"));

			// finish drag-drop
			TreeToTableDNDIntegration.markElementAsDroppingOver(null);

			/**
             * Make a copy or reference of the steps being dropped
             * @param table The table's selector
             * @param copy Boolean: if this is a copy or a reference
			 */
			function markDroppedStepsAsCopyOrReference(table, copy) {
            	for (var i= 0; i < createdRows.length; i++) {
            		var $createdRow = $(createdRows[i]);
            		if (copy) {
            			$createdRow.find("[name='referredTestSteps']").val(""); // remove the reference
            			$createdRow.removeClass("referrencingStep");
            		} else {
            			$createdRow.addClass("referrencingStep");
            		}
            	}

            	// update the look of the table
            	codebeamer.TestStepEditor.updateTestStepEditorLook(table);
			}

			// ask if the user wants to copy items or use as refrence?
			var msg = i18n.message("testcase.editor.use.as.reference.question");
			showModalDialog("warning", msg,
				[
				 	{ text: "Copy",
				 	  "class" : "button",
				 	  click: function() { markDroppedStepsAsCopyOrReference("#testSteps", true);  $(this).dialog("destroy"); }},
				 	{ text: "Use it as reference",
				 	  "class" : "button",
				 	  click: function() { markDroppedStepsAsCopyOrReference("#testSteps", false); $(this).dialog("destroy"); }},
				]
			, "40em");
			return false;
		};

		var externalDropCheck = function(data) {
			var target = data.event.target;
			if($(target).closest(".testStepsTableContainer").size() > 0) {
				TreeToTableDNDIntegration.markElementAsDroppingOver(target);
				return true;
			}
			return false;
		};

		function loadTestSteps(itemId, $target) {

			var createTable = function(data) {
				var alreadyUsed = [];
				$("[name=generatedId]").each(function () {
					alreadyUsed.push($(this).val());
				});
				$target.empty();
				$target.jstree("destroy"); // destroy the previous step tree reference
				if (data.length > 0) {
					stepStore = {};
					var stepTree = [];
					for (var i = 0; i < data.length; i++) {
						var d = data[i];
						var cssClass = "";
						if (alreadyUsed.contains(d["generatedId"])) {
							cssClass = "used";
						}
						stepTree.push({"data": d["action"],
							"text": d["action"],
							"id": d["generatedId"],
							"li_attr": {
								"id": d["generatedId"],
								"class": cssClass,
								"myReference" : d["myReference"]
							},
							"icon": false});
						stepStore[d["generatedId"]] = d;
					}
					var $tree = $target.jstree({
						"core": {
							"data": stepTree
						},
						"plugins": [ "json_data", "ui", "dnd", "crrm", "search" ],
						"search": {
							"case_insensitive": true,
							"show_only_matches": true
						}
					});

				}
			};

			$.ajax({
				"url": contextPath + "/testcase/ajax/getSteps.spr",
				"type": "GET",
				"data": {
					"task_id": itemId
				},
				"success": function(data) {
					if (! $.isArray(data)) {
						console.log("Invalid data has arrived, ignoring, probably a permission-denied error:" + data);
						data = [];
					}
					createTable(data);
				},
				"error": function(jqXHR) {
					createTable([]); // clear table
				}
			});
		};

		function nodeClickedHandler(node, obj) {
			var task_id = node.id;

			if (!task_id) return;

			if (node.li_attr["type"] != "tracker_item") {
				return;
			}

			var $reference = $("#" + node.id);
			if (obj && obj.hasOwnProperty("instance")) {
				$reference = obj.instance.element;
			}
			var $target = $reference.closest(".pane").find(".testStepsContainer");

			loadTestSteps(task_id, $target);
		}

		$(document).on('dnd_start.vakata.jstree', function () {
			// when drag-drop starts initialize the status indicators
			// only initializing lazy, because we want that this must run later than the standard jstree's "dnd_move.vakata.jstree" event, otherwise
			// that will overwrite our status indicators

			TreeToTableDNDIntegration.highlightTable($("#testSteps"));

			var initDragDropStatusIndicators = function() {
				if (this.initialized) {	// avoid double event handlers
					return;
				}
				console.log("initDragDropStatusIndicators() is initializing");
				this.initialized = true;

				$(document)
				.on('dnd_move.vakata.jstree', function (event, data) {
					var dropPossible = externalDropCheck(data);
					var $icon = data.helper.find('.jstree-icon').first();
					$icon.toggleClass('jstree-ok', dropPossible).toggleClass('jstree-er', !dropPossible);
					// console.log("Drop is " + (dropPossible? '' : 'not') + "possible " + (new Date()).getTime());
				})
				.on('dnd_stop.vakata', function (event, data) {

					TreeToTableDNDIntegration.removeHighlightTable($("#testSteps"));

					var dropPossible = externalDropCheck(data)

					var nodes = [];
					var tree = $.jstree.reference(data.element);
					for (var i = 0; i < data.data.nodes.length; i++) {
						nodes.push(tree.get_node(data.data.nodes[i]));
					}

					if (dropPossible) {
						externalDrop(nodes, $(data.event.target), data.event);
					}
				});
			};

			initDragDropStatusIndicators();
		});

		function populateContextMenu(node) {
			return {
				"showDetails": {
					"label": i18n.message("issue.details.view.label"),
					"action": function(node) {
						location.href = contextPath + "/item/" + node.attr("id");
					}
				}
			};
		}

		var testCaseTreeConfig = {
			data: codebeamer.trackers.generateTreePopulator("", "${tracker.id}", "", false, false, function () {
				return {
					"selectedStatusMeaning": $("#testStatusMeaning").val()
				};
			}),
			// these settings are merged to the tree config
			treeConfig: {
				core: {
					initially_open: ["${tracker.id}"]
				}
			}
		};

		jQuery(function($) {
			var triggerClickOnSelectedNodes = function() {
				var selectedNodes = $("#testCaseTreePane,#testCaseLibraryTreePane").jstree("get_selected");
				if (selectedNodes.length > 0) {
					nodeClickedHandler(selectedNodes);
				}
			};
			setTimeout(triggerClickOnSelectedNodes, 500);

			$("#testSteps").bind("teststep.delete", function (e, generatedId) {
				$("#" + generatedId).removeClass("used");
			});
		});


		// value used to for search for empty text too
		var EMPTY_SEARCH = "__EMPTY_SEARCH__";

		/**
		 * Custom jstree search function will keep only reference test-cases if that is set
		 */
		function filterByReleaseAndContent(filter, node, treeId) {
			// call the normal search, but ignore empty
			var match = true;
			if (!( filter == null || (EMPTY_SEARCH == filter)) ) {
				var txt = node.text;
				match = (txt != null) && (txt.toLowerCase().indexOf(filter.toLowerCase()) != -1);
			}

			if (match) {
				var a = $("#" + treeId).find("#" + node.id);

				// filter by "Release Test Cases" too if that is set
				var $tree=$(a).closest(".jstree");
				var onlyReferenceTestCases = $tree.hasClass("onlyReferenceTestCases");
				if (onlyReferenceTestCases) {
					var $li = $(a).closest("li");
					// check if this is a tracker_item type
					var type = $li.attr("type");
					var isTrackerItem = (type == "tracker_item");
					if (isTrackerItem) {
						var isReferenceTestCase = $li.hasClass("referenceTestCase");
						return isReferenceTestCase;
					} else {
						// console.log("Not a tracker-item:" + type);
					}
				}
			}
			return match;
		}
		$.expr[':'].filterByReleaseAndContent = filterByReleaseAndContent;

		var testCaseTreePane_searchConfig = {
			search_callback: function(filter, node) {
				return filterByReleaseAndContent(filter, node, "testCaseTreePane");
			},
			show_only_matches: true
		};

		var testCaseLibraryTreePane_searchConfig = {"ajax": {
				"url": contextPath + "/trackers/ajax/library/search.spr",
				"data": {
					"tracker_type": "testcase"
				},
				"success": function (data) {
					return data;
				}
			},
			search_callback: function(filter, node) {
				return filterByReleaseAndContent(filter, node, "testCaseLibraryTreePane");
			},
			show_only_matches: true
		};

		function redoSearch(treeId, forceIfEmpty) {
			var $filterBox = $("#searchBox_" + treeId);
			var filterValue = $filterBox.val();
			// if still the watermark is in the filter-box ignore that
			if (filterValue == $filterBox.attr("title")) {
				filterValue = "";
			}
			var $tree = $("#" + treeId);
			if (filterValue == "") {
				if (! forceIfEmpty) {
					$tree.jstree("clear_search");
					return;
				}
				filterValue = EMPTY_SEARCH;	// force search even when the filter is empty, jstree would not do the search this case
			}
			$tree.jstree("search", filterValue);
		}

		function filterReferenceTestCases(checkbox, tree) {
			var checked = $(checkbox).is(":checked");

			var treeId = tree.config.treeContainerId;
			$("#" + treeId).toggleClass("onlyReferenceTestCases", checked);
			console.log("filtering for reference test cases :" + checked + " in tree: "+ treeId);

			redoSearch(treeId, checked);
		}

	</script>

	<spring:message var="testCaseLabel" code="testManagement.categories.testCase" text="Test Plans" />
	<spring:message var="testCaseLibraryLabel" code="testManagement.categories.testCaseLibrary" text="Test Case Library" />
	<spring:message var="settingsTitle" code="tracker.tree.settings.title" text="Settings" />

	<div id="testAccordion">
		<h3 class="accordionHeader accordion-header">${testCaseLabel}</h3>
		<div id="testCasePane" class="accordion-content">
			<div class="actionBar treeFilters">
				<div class="treeFilterDiv">
					<ui:treeFilterBox treeId="testCaseTreePane" minFilterLength="0" emptyValue="__EMPTY_SEARCH__" hideTreeOnNoMatch="true" />
				</div>
				<div class="toolsContainer">
				   <label for="filterReferencesTestCases" class="filterReferenceTestCases withContextHelp" title="testcase.editor.filter.reference.test.cases.hint" >
				   		  <input id="filterReferencesTestCases" type="checkbox" onclick="filterReferenceTestCases(this, testTree);" autocomplete="off"/>
				   		  <spring:message code="testcase.editor.filter.reference.test.cases"/></label>
				   <span class="helpLinkButton withContextHelp" title="testcase.editor.filter.reference.test.cases.help"/>
				</div>
			</div>
			<div class="pane">
				<h4 class="header"><spring:message code="testcase.editor.copy.steps.hint"/></h4>
				<ui:treeControl containerId="testCaseTreePane" url="${pageContext.request.contextPath}/trackers/ajax/tree.spr"
								dndDisabled="true" treeVariableName="testTree" editable="false" populateFnName="populator"
								nodeClickedHandler="nodeClickedHandler" populateContextMenuFnName="populateContextMenu" searchConfig="testCaseTreePane_searchConfig"/>
				<div id="testCaseTreePane"></div>
				<div class="header"><spring:message code="testcase.editor.drop.steps.hint"/><ui:helpLink helpURL="https://codebeamer.com/cb/wiki/792788#section-Reference+Test+Steps" target="_blank" />
					<ui:treeFilterBox treeId="testStepsOfTestCase"/>
				</div>
				<div id="testStepsOfTestCase" class="testStepsContainer"></div>
			</div>
		</div>

		<h3 class="accordionHeader accordion-header">${testCaseLibraryLabel}</h3>
		<div id="testCaseLibraryPane" class=" accordion-content">
			<div class="actionBar treeFilters">
				<div class="treeFilterDiv" style="width: 27%;">
					<ui:treeFilterBox treeId="testCaseLibraryTreePane" minFilterLength="0" emptyValue="__EMPTY_SEARCH__"/>
				</div>
				<div class="toolsContainer" >
					<!-- Disabled Reusable only filter -->
					<%--<label for="filterReferencesLibrary" class="filterReferenceTestCases withContextHelp" title="testcase.editor.filter.reference.test.cases.hint" >--%>
				   		  <%--<input id="filterReferencesLibrary" type="checkbox" onclick="filterReferenceTestCases(this, testLibraryTree);" autocomplete="off"/>--%>
				   		  <%--<spring:message code="testcase.editor.filter.reference.test.cases"/></label>--%>

					<c:url var="libraryConfigUrl" value="/trackers/library/configure.spr">
						<c:param name="tracker_id" value="${tracker.id}"/>
						<c:param name="tree_id" value="testCaseLibraryTreePane"/>
						<c:param name="tracker_type" value="testcase"/>
					</c:url>
					<select name="testStatusMeaning" id="testStatusMeaning" onchange="reloadLibraryTree('testCaseLibraryTreePane');" style="margin-left: 10px;">
						<option value="Any"><spring:message code="cmdb.version.issues.filter.all" text="All"/></option>
						<option value="Open"><spring:message code="cmdb.version.issues.filter.open" text="Open"/></option>
						<option value="ClosedOrResolved"><spring:message code="cmdb.version.issues.filter.resolvedOrClosed" text="Resolved/Closed"/></option>
						<option value="Closed"><spring:message code="cmdb.version.issues.filter.closed" text="Closed"/></option>
						<option value="Resolved"><spring:message code="cmdb.version.issues.filter.resolved" text="Resolved"/></option>
					</select>
					<spring:message code="testManagement.configureTestLibraries.testcase.popup.title" text="Configure" var="configureLibraryTitle"/>
					<a id="configureLibrary" href="#" onclick="showPopupInline('${libraryConfigUrl}');"><img class="action" src="<c:url value='/images/newskin/action/settings-s.png'/>" title="${configureLibraryTitle}" alt="${configureLibraryTitle}"></a>
				</div>
			</div>
			<div class="pane">
				<h4 class="header"><spring:message code="testcase.editor.copy.steps.hint"/></h4>
				<ui:treeControl containerId="testCaseLibraryTreePane"
				url="${pageContext.request.contextPath}/trackers/ajax/library/tree.spr?tracker_id=${tracker.id}&tracker_type=testcase&excludedIssueId=${addUpdateTaskForm.task_id}"
								dndDisabled="true" treeVariableName="testLibraryTree" editable="false" config="testCaseTreeConfig" nodeClickedHandler="nodeClickedHandler"
								searchConfig="testCaseLibraryTreePane_searchConfig" />
				<div id="testCaseLibraryTreePane" data-tracker-id="${tracker.id }"></div>
				<div class="header"><spring:message code="testcase.editor.drop.steps.hint"/><ui:treeFilterBox treeId="testStepsOfLibraryTestCase"/></div>
				<div id="testStepsOfLibraryTestCase" class="testStepsContainer"></div>
			</div>
		</div>
	</div>

</c:set>

<c:set var="mainContent">
	<c:url var="actionUrl" value="${action}" />
	<spring:message code="tracker.field.Critical.label" var="criticalLabel" text="Critical"/>
	<spring:message code="tracker.field.Action.label" var="actionLabel" text="Action"/>
	<spring:message code="tracker.field.Expected\ result.label" var="expectedResultLabel" text="Expected result"/>
	<spring:message code="tracker.table.deleteStep.hint" var="deleteStepHint" text="Delete step"/>
	<spring:message code="tracker.table.insertStep.after.hint" var="insertAfterHint"/>
	<spring:message code="tracker.table.insertStep.before.hint" var="insertBeforeHint"/>

	<c:url value="/images/newskin/action/insert-after.png" var="rowAfterUrl"/>
	<c:url value="/images/newskin/action/insert-before.png" var="rowBeforeUrl"/>

	<form:form action="${actionUrl}" enctype="multipart/form-data" commandName="addUpdateTaskForm" class="dirty-form-check">
		<c:set var="insertAtEndOfTableFragment" scope="request">
			<%-- test-parameter management --%>
			<jsp:include page="/testmanagement/parameters/parametersConfiguration.jsp"/>
		</c:set>
		<jsp:include page="/bugs/addUpdateTask.jsp?noForm=true&nestedPath=null&noAssociation=true&noTrackerField=true&noActionMenuBar=true&noComment=true&minimumDescriptionHeight=true&collapseDescriptionIfEmpty=true" />
			<div class="testStepsTableContainer contentWithMargins">
				<spring:message var="testStepsLabel" code="tracker.field.Test Steps.label" />
				<c:set var="testStepsLabelWithHelp">${testStepsLabel}
					<ui:helpLink helpURL="https://codebeamer.com/cb/wiki/95044#section-Test+Step+Editor" target="_blank" />
				</c:set>

				<ui:collapsingBorder label="${testStepsLabelWithHelp}" title="${testStepsLabel}"
					hideIfEmpty="false" open="true"
					cssClass="separatorLikeCollapsingBorder" cssStyle="margin-bottom:0;" >

					<ui:testSteps readOnly="${! addUpdateTaskForm.testStepsTableEditable}" owner="${addUpdateTaskForm.trackerItem}" testSteps="${steps}" tableId="testSteps" droppable="true" uploadConversationId="${uploadConversationId}"/>
				</ui:collapsingBorder>
			</div>
	</form:form>

	<ui:testStepsNewRowTemplate uploadConversationId="${uploadConversationId}" />
</c:set>

<jsp:include page="/bugs/addUpdateTaskActionMenuBar.jsp"/>
<c:choose>
	<c:when test="${param.isPopup}">
		<c:choose>
			<c:when test="${supportsTestManagement}">
				${mainContent}
			</c:when>
			<c:otherwise>
				<jsp:include page="/bugs/addUpdateTask.jsp?noTrackerField=true&noActionMenuBar=true" />
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:when test="${supportsTestManagement}">
		<ui:splitTwoColumnLayoutJQuery cssClass="autoAdjustPanesHeight" hideRightPane="${!addUpdateTaskForm.testStepsTableEditable}" rightMinWidth="420">
			<jsp:attribute name="rightContent">
				${editorContent}
			</jsp:attribute>
			<jsp:body>
				${mainContent}
			</jsp:body>
		</ui:splitTwoColumnLayoutJQuery>
	</c:when>
	<c:otherwise>
		<jsp:include page="/bugs/addUpdateTask.jsp?noTrackerField=true&noActionMenuBar=true" />
	</c:otherwise>
</c:choose>

<script type="text/javascript">
	$(document).ready(function () {
		setupKeyboardShortcuts("addUpdateTaskForm");
		disableDoubleSubmit($("#addUpdateTaskForm"));

		// show a confirm dialog when a referenced TestStep has changed
		var $submitButtons = $("#addUpdateTaskForm").find("input[name='SUBMIT'],input[name='SUBMIT_AND_NEW']");
		$submitButtons.click(function(event) {
			var $testStepTable = $(this).closest("form").find(".testStepTable")
			var save = codebeamer.TestStepEditor.showChangingReferencedWarning($testStepTable);
			if (! save) {
				event.preventDefault();
			}
			return save;
		});
	});
</script>

