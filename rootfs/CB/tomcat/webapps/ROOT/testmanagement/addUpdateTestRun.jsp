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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<meta name="decorator" content="${param.isPopup ? 'popup' : 'main' }"/>
<meta name="module" content="tracker"/>

<!--[if IE 8]>
	<style type="text/css">
		.qq-upload-list {
			min-width: 50px;
			left: 0px !important;
			top: 0px !important;
		}
	</style>
<![endif]-->

<script type="text/javascript">
	function submitWithInProgress(target) {
		var form = target.form;

		<c:if test="${addUpdateTaskForm.creatingTestRun}"> <%-- only show the in-progress dialog when creating because generation may take long... --%>
		inProgressDialog.show();
		</c:if>

		var submitForm = this.submitAction(form);
		return submitForm;
	}

	function showNotAcceptedWarning(target) {
		showModalDialog("warning",
				i18n.message("testrun.editor.creating.run.all.confirm"),
				[
			{  text: i18n.message("testrunner.no.test.case.is.runnable.run.all.testcases"),
			   click: function () {
					$("input[name='runOnlyAcceptedTestCases'][value='false']").prop("checked", true);
					$(this).dialog("destroy");

					$(target).click();
				}
			},
			{ text: i18n.message("button.cancel"),
			  click: function () {
						$(this).dialog("destroy");
					},
			  "class": "cancelButton"
			}
		]);
	}

	function doSave(target) {
	    // if all TestCases are not Accepted and run-only-accepted is selected then show a warning dialog and don't allow saving this
		var allTestCasesNotAccepted = ${inactiveTestCasesModel.getNoOfRunnableTestCases() == 0};
		if (allTestCasesNotAccepted) {
			var runOnlyAccepted = $("input[name='runOnlyAcceptedTestCases']:checked").val();

			if (runOnlyAccepted == "true") {
				showNotAcceptedWarning(target);
				return false;
			}
		}

		var form = target.form;
		var submitForm = submitWithInProgress(target);
		return submitForm;
	}

<%--
	function doSaveAndRun(target) {
		console.log("Executing save and run:");
		var form = target.form;

		var submitForm = submitWithInProgress(target);

		if (submitForm) {
			// wait a bit so the dialog can appear

			// submit the form with ajax
			var formData = $(form).serialize();	// serializes form elements
			var url = $(form).prop("action");
			formData += "&saveAndRun=true&rollbackIfCanNotRun=true";

			$("#inProgressDialogMarkup").dialog({
				modal: true
			});

			$.ajax({
           		type: "POST",
           		async: false,	// wait for complete, because we can only decide after
           		cache: false,
           		url: url,
           		data: formData,
           		success: function(data, success, xhr) {
           			if (data.executeSaveAndRun) {
           				// save was successful, now executing the action
           				// do not submit we have already executed this
           				submitForm = false;

           				testRuns.executeAction(data);
           			}
           		}
			});
		}
		return submitForm;
	}

	$(function() {
		$("input[name='saveAndRun']").on("mousedown", function() {
			console.log("mouse-up on save-and-run button!");
			window.setTimeout(function() {
				inProgressDialog.show();
			},10);
		});
	});
--%>
</script>

<head>
	<link rel="stylesheet" href="<ui:urlversioned value="/testmanagement/addUpdateTestRun.less" />" type="text/css" media="all" />
</head>

<c:url var="actionUrl" value="${action}" />
<form:form action="${actionUrl}" enctype="multipart/form-data" commandName="addUpdateTaskForm">
	<form:hidden path="testSetId"/>
	<form:hidden path="baseline" />
	<form:hidden path="orignalTestSetName" />

	<%-- remember the selected TestCases/Sets in the form --%>
	<c:forEach items="${addUpdateTaskForm.tests}" var="item"><input type="hidden" name="tests" value="<c:out value='${item}'/>"/></c:forEach>

	<%-- this is replacing buttons in addUpdateTask.jsp --%>
	<c:set var="controlButtons" scope="request">
		<c:if test="${empty missingEssentialFields }">
			<%-- show the save button only when all the necessary fields are available in the tracker. --%>
			<spring:message var="saveButton" code="button.save" />
			<input type="submit" class="button atttachInProgressDialog" value="${saveButton}" name="SUBMIT" onclick="return doSave(this);"/>

<%--
			<spring:message var="saveAndRun" code="testrun.editor.save.and.run"/>
			<input type="submit" class="button atttachInProgressDialog" value="${saveAndRun}" name="saveAndRun" onclick="return doSaveAndRun(this);" />
--%>
		</c:if>
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_cancel" value="${cancelTitle}" />

		<%-- show progress badge while the Run or Save&Run is being executed: that's when the TestRun is being generated --%>
		<spring:message var="inProgressMessage" code="issue.runTestRun.creating.in.progress" />
		<ui:inProgressDialog message="${inProgressMessage}" imageUrl="default" height="250" attachTo=".atttachInProgressDialog" triggerOnClick="false" />
	</c:set>

	<c:set var="beforePropertyEditorFragment" scope="request"></c:set>

	<c:if test="${addUpdateTaskForm.creatingTestRun}">
		<c:set var="beforePropertyEditorFragment" scope="request">
			${beforePropertyEditorFragment}
			<%-- missingEssentialFieldscontains all the field names that are necessary on each test run tracker and are missing from the current tracker. --%>
			<c:if test="${not empty missingEssentialFields }">
				<div class="error">
					<spring:message code="tracker.testRun.some.ssential.fields.missing.error"/>
				</div>
			</c:if>

			<c:if test="${testSetOrTestCaseMissing}">
				<div class="warning">
					<spring:message code="tracker.testRun.has.no.test.cases.error" text="You cannot run this test run because it has no Test Sets or Test Cases."/>
				</div>
			</c:if>

			<c:set var="noOfTestCases" value="${inactiveTestCasesModel.getNoOfTestCases()}" />
			<c:set var="noOfInactiveTestCases" value="${inactiveTestCasesModel.getNoOfInactiveTestCases()}"/>
			<h3>
				<spring:message code="testrun.editor.creating.testruns.begin" text="You are creating Test Runs for" />
					<c:if test="${!empty testSet}"><a style="font-size:inherit;" href="<c:url value='${testSet.urlLink}'/>" target="_blank"><c:out value="${testSet.name}"/></a>
					<spring:message code="testrun.editor.creating.testruns.testset" text="Test Set with"/></c:if>
					<spring:message code="testrun.editor.creating.testruns.num.testcases" text="${noOfTestCases} Tests." arguments="${noOfTestCases}"/>
					<c:if test="${noOfInactiveTestCases > 0 && addUpdateTaskForm.showNotAcceptedTestCasesWarning}">
						<span class="wiki-warning" style="font-size:11px;">
						<%--<img src="<c:url value='/images/newskin/action/permission-alert.png' />"/> --%>
						(<spring:message code="testrun.editor.creating.testruns.has.inactive.tests" text="${noOfInactiveTestCases} Test(s) is not Accepted" arguments="${noOfInactiveTestCases}"/>)
						<ui:helpLink helpURL="https://codebeamer.com/cb/wiki/95044#section-Running+only+_22Accepted_22+or+all+TestCases+_3F"/>
						</span></c:if>
			</h3>

	<spring:message code="testrun.editor.creation.options.label" var="creationOptionsLabel" />
	<ui:collapsingBorder label="${creationOptionsLabel}" hideIfEmpty="false" open="${addUpdateTaskForm.showIncludeTestsRecursively}"	cssClass="separatorLikeCollapsingBorder" >
			<div class="testRunOptions">
				<ul>
				<script type="text/javascript">
					// force the run-all option and disable the radio buttons visually too
					function setForceRunAll(force) {
						$("input[name='runOnlyAcceptedTestCases']").each(function() {
							var val = $(this).val();

							if (force && val == "false") {
								$(this).prop("checked", true);
							}

							$(this).prop("disabled", force ? "disabled" : "");
							$(this).closest("label").toggleClass("disabledOption", force);
						});
					}

					function resetRunAll() {
						setForceRunAll(${noOfInactiveTestCases == noOfTestCases});
					}

					$(resetRunAll);
				</script>

				<c:choose>
					<c:when test="${noOfInactiveTestCases > 0}">
						<li>
							<h4><spring:message code="testrun.editor.creation.options.accepted.question" text="Include non-Accepted Test Cases?" /></h4>
							<label>
								<form:radiobutton autocomplete="off" path="runOnlyAcceptedTestCases" value="true"/>
								<spring:message code="testrun.editor.creation.options.accepted.only.accepted" text="Run <b>only Accepted</b> TestCases" />
							</label>
							<label>
								<form:radiobutton autocomplete="off" path="runOnlyAcceptedTestCases" value="false"/>
								<spring:message code="testrun.editor.creation.options.accepted.all" text="Run <b>all TestCases</b>, even those which are not Accepted."/>
							</label>
						</li>
						<%-- default hidden value to send when the radios here are disabled because forced run-all  --%>
						<input type="hidden" name="_runOnlyAcceptedTestCases" value="${addUpdateTaskForm.runOnlyAcceptedTestCases}" />
					</c:when>
					<c:otherwise>
						<form:hidden path="runOnlyAcceptedTestCases"/>
					</c:otherwise>
				</c:choose>

				<li>
					<h4>
						<spring:message code="testrun.editor.distributeRunsStrategy.question" text="How would you like to distribute the work between the users/roles assignedTo ?"/>
					</h4>
					<c:forEach var="strategy" items="${addUpdateTaskForm.distributeRunsStrategies}">
						<c:set var="code" value="testrun.editor.distributeRunsStrategy.${strategy}" />
						<label for="${code}">
							<form:radiobutton autocomplete="off" id="${code}" path="distributeRunsStrategy" value="${strategy}" />
							<spring:message code="${code}" text="${strategy}" />
						</label>
					</c:forEach>
				</li>

				<%-- Don't show for TestSets or when coming from the document-view --%>
				<c:choose>
					<c:when test="${empty testSet && addUpdateTaskForm.showIncludeTestsRecursively}">
					<li>
						<h4><spring:message code="testrun.editor.creation.options.include.children.question" text="Include children of the selected Test Cases?" /></h4>
						<label>
							<form:radiobutton autocomplete="off" path="includeTestsRecursively" value="false" />
							<spring:message code="testrun.editor.creation.options.include.children.no" text="<b>No</b>, only selected Test Cases."/>
						</label>
						<label>
							<form:radiobutton autocomplete="off" path="includeTestsRecursively" value="true" />
							<spring:message code="testrun.editor.creation.options.include.children.yes" text="<b>Yes</b>, include all <b>children</b>/descendant TestCases recursively."/>
						</label>
					</li>
					</c:when>
					<c:otherwise>
						<form:hidden path="includeTestsRecursively"/>
					</c:otherwise>
				</c:choose>
				<form:hidden path="showIncludeTestsRecursively"/>

				<c:choose>
					<%-- Don't show for TestSets only when creating Run from TestCases--%>
					<c:when test="${empty testSet}">
						<li>
							<c:if test="${noOfTestCases > 1}">
								<h4>
									<spring:message code="testrun.editor.creation.options.one.testrun.per.testcase.question" text="Create one Test Run for each Test Cases?"/>
								</h4>
								<label>
									<form:radiobutton autocomplete="off" path="createTestRunForEachTestCase" value="false" onclick="resetRunAll();" />
									<spring:message code="testrun.editor.creation.options.one.testrun.per.testcase.no" text="<b>No</b>, the Test Run will contain all Test Cases."/>
								</label>
								<label>
									<form:radiobutton autocomplete="off" path="createTestRunForEachTestCase" value="true" onclick="setForceRunAll(true);" />
									<spring:message code="testrun.editor.creation.options.one.testrun.per.testcase.yes" text="<b>Yes</b>, create <b>separate</b> Test Runs for each Test Cases."/>
								</label>
							</c:if>
						</li>
					</c:when>
					<c:otherwise>
						<form:hidden path="createTestRunForEachTestCase"/>
					</c:otherwise>
				</c:choose>
				</ul>
			</div>

	</ui:collapsingBorder>
		</c:set>

	</c:if>

	<c:set var="numChildren" value="${fn:length(addUpdateTaskForm.trackerItem.children)}" />
	<c:set var="restarting" value="${addUpdateTaskForm.restarting && numChildren > 0}" />
	<c:if test="${restarting}">
		<c:set var="beforePropertyEditorFragment" scope="request">
			${beforePropertyEditorFragment}
			<%-- missingEssentialFieldscontains all the field names that are necessary on each test run tracker and are missing from the current tracker. --%>
			<c:if test="${not empty missingEssentialFields }">
				<div class="error">
					<spring:message code="tracker.testRun.some.ssential.fields.missing.error"/>
				</div>
			</c:if>

			<c:if test="${testSetOrTestCaseMissing }">
				<div class="warning">
					<spring:message code="tracker.testRun.has.no.test.cases.error" text="You cannot run this test run because it has no Test Sets or Test Cases."/>
				</div>
			</c:if>
			<script type="text/javascript">
				function _selectTestsToReRun(label) {
					console.log("Select which Tests to rerun!");
					var url = contextPath + "/proj/tracker/testmanagement/selectTestRunsForRerun.spr?task_id=${addUpdateTaskForm.trackerItem.id}";

					showPopupInline(url ,{
						geometry: "80%_80%"
					});
				}

				function updateOnrestartOnCopyChange() {
					var restartOnCopy = $("#restartOnCopy").is(":checked") || ($("#restartOnCopyHidden").val() == "true");
					$("body").toggleClass("restartOnCopy", restartOnCopy);
				}

				$(function() {
					$("#restartOnCopy").click(updateOnrestartOnCopyChange);
					updateOnrestartOnCopyChange();
				});
			</script>

			<div class="warning">
				<label><spring:message code="testrun.editor.restart.question.about.existing.test.cases" arguments="${numChildren}" /></label>

				<label for="restartOnCopy">
					<c:choose>
						<c:when test="${addUpdateTaskForm.forceCopyOnReRun}">
							<form:hidden id="restartOnCopyHidden" path="restartOnCopy" />
							<spring:message code="testrun.editor.restart.on.copy.forced" />
						</c:when>
						<c:otherwise>
							<form:checkbox id="restartOnCopy" path="restartOnCopy" autocomplete="off"/>
							<spring:message code="testrun.editor.restart.on.copy" />
						</c:otherwise>
					</c:choose>
				</label>

				<%-- the selected child runs to remove --%>
				<form:hidden path="removeSelectedChildRuns" id="removeSelectedChildRuns"/>
				<ul id="restartOptions">
				<c:forEach var="reRunOpt" items="${addUpdateTaskForm.getApplicableReRunSelectors()}">
					<li>
						<spring:message var="title" code="${reRunOpt.messageCode}.title" text="" />
						<label for="reRunOpt_${reRunOpt}" title="${title}" >
							<form:radiobutton id="reRunOpt_${reRunOpt}" path="reRunSelectorName" value="${reRunOpt}" autocomplete="off" />
							<spring:message code="${reRunOpt.messageCode}" text="${reRunOpt}" />
						</label>
					</li>
				</c:forEach>
				<script type="text/javascript">
					// add event handler to select the tests to re-run
				    $(function() {
						$("#reRunOpt_selected").click(function() {
							_selectTestsToReRun(this);
						});

					});
				</script>
				</ul>

				<label for="rerunClearsResults">
					<form:checkbox id="rerunClearsResults" path="rerunClearsResults" autocomplete="off"/>
					<spring:message code="testrun.editor.restart.clear.previous.results" />
				</label>
			</div>
		</c:set>
	</c:if>

<div class="${restarting ? 'testRunEditorWhenRestarting' : ''}">

	<%-- test run properties --%>
	<jsp:include page="/bugs/addUpdateTask.jsp?noForm=true&nestedPath=null&noAssociation=true&noComment=true&noTrackerField=true&isPopup=${param.isPopup}&minimumDescriptionHeight=true&collapseDescriptionIfEmpty=true" />

	<c:if test="${! restarting}">
	<%-- managed fields --%>
	<table class="staticLayout propertyEditor testRunManagedFields" >
		<colgroup>
			<col class="fieldLabel">
			<col class="fieldValue">
		</colgroup>

		<%-- release selector --%>
		<c:set var="testSetLink"><a target="_blank" href="<c:url value="${testSet.urlLink}"/>"><c:out value='${testSet.name}'/></a></c:set>
		<c:if test="${not empty releases}">
			<tr>
				<td class="fieldLabel optional" style="vertical-align: top;">
					<span class="force-bold"><spring:message code="tracker.field.Release.label" text="Release" />:</span>
				</td>
				<td class="fieldValue dataCell">
					<%-- select one release in a dropdown, using a top-level property in the form object --%>
					<form:select style="width: auto;" path="releaseId" >
						<c:forEach items="${releasesByTracker}" var="entry">
							<optgroup label="${entry.key.project.name} - ${entry.key.name}">
								<c:forEach items="${entry.value}" var="release">
									<c:choose>
										<c:when test="${release.id == defaultRelease}">
											<form:option selected="true" value="${release.id}"><c:out value='${release.name}'/></form:option>
										</c:when>
										<c:otherwise>
											<form:option value="${release.id}"><c:out value='${release.name}'/></form:option>
										</c:otherwise>
									</c:choose>
								</c:forEach>
							</optgroup>
						</c:forEach>
					</form:select>
				</td>
				<td>
					<c:if test="${not hasPossibleReleases}">
						<div class="subtext note" >
							<spring:message code="testrun.editor.has.no.possible.releases" arguments="${testSetLink}" />
						</div>
					</c:if>
				</td>
			</tr>
		</c:if>

		<%-- test configuration selector --%>
		<jsp:include page="./testRunTestConfigurations.jsp?multiple=${addUpdateTaskForm.creatingTestRun}" />
	</table>
	</c:if>
</div>

</form:form>

<script type="text/javascript">
	$(document).ready(function () {
		setupKeyboardShortcuts("addUpdateTaskForm");
		disableDoubleSubmit($("#addUpdateTaskForm"));
		<c:if test="${param.isPopup}">
			$(".cancelButton").click(function(){
				closePopupInline();
				return false;
			});
		</c:if>
	});
</script>

