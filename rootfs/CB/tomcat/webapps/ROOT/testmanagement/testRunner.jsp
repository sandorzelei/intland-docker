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
<%@ page import="com.intland.codebeamer.manager.testmanagement.TestRun.TestRunResult"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<meta name="decorator" content="popup" />
<meta name="module" content="tracker" />

<wysiwyg:froalaConfig />
<wysiwyg:editorInline />

<c:choose>
<c:when test="${canNotRun}">
	<%-- can not run this Test, the message is shown in the GlobalMessages--%>
</c:when>
<c:when test="${! empty sequentialTestSetLocked}">
	<div class="ui-layout-center">
		<jsp:include page="/testmanagement/showSequentialTestSetLockedException.jsp" />
	</div>
</c:when>
<c:when test="${empty engine || empty engine.currentTestCase}">
	<ui:pageTitle printBody="false" prefixWithIdentifiableName="false">
		<spring:message code="testrunner.page.completed.title.template"
			arguments="${testSetRun.delegate.name}" htmlEscape="true" />
	</ui:pageTitle>

	<div class="ui-layout-center">
		<div class="information">
			<spring:message code="testrunner.no.more.test.case" text="There is no more Test Case to run, testing is complete!"/>
		</div>
	</div>
</c:when>
<c:otherwise>

<script type="text/javascript" src="<ui:urlversioned value="/testmanagement/testRunner.js"/>"></script>

<c:set var="testCase" value="${engine.currentTestCase}"/>
<c:set var="hasSteps" value="${! empty testCase.testSteps}"/>

<ui:delayedScript avoidDuplicatesOnly="true" trim="true">
	<link rel="stylesheet" href="<ui:urlversioned value="/testmanagement/testRunner.less" />" type="text/css" media="all" />
</ui:delayedScript>

<script type="text/javascript">
var updateLayout = function() {
	console.log("updating window layout");
	$("#command").height($(window).height());
};

$(function () {
	updateLayout();
	$(window).resize(updateLayout);
	layoutScripts.initLayoutFor("#command");

	// update layout a bit later too to avoid layout problems
	setTimeout(updateLayout, 1000);

	GlobalMessages.enableAnimation = false;
});
</script>

<form:form id="command" cssClass="test-runner-form">
<input type="hidden" name="missingParameterValues" value="" />
<input type="hidden" name="index" value="${engine.index + 1}" />
<form:hidden path="reportedBugIds" />
<input type="hidden" name="defaultResult" value="" />
<input type="hidden" name="editedTestRunId" value="${! empty editedTestRun ? editedTestRun.delegate.id : ''}" />

<c:set var="testSetRun" value="${engine.testSetRun}" />
<c:set var="testCaseIssue" value="${testCase.issue}" />

<c:if test="${! empty testCaseIssue}">
<ui:pageTitle printBody="false" prefixWithIdentifiableName="false">
	<spring:message code="testrunner.page.title.template"
		arguments="${testCaseIssue.name},${testSetRun.delegate.name}" htmlEscape="true"/>
</ui:pageTitle>
</c:if>

<c:set var="testSetRunLink">
	<ui:trackerItemPath item="${testSetRun.delegate}" target="_blank" showVersionBadges="false" versionedLinks="false" />
</c:set>
<c:set var="testCaseLink">
	<ui:trackerItemPath item="${testCaseIssue}" target="_blank" showVersionBadges="false" rewriteRevisionToVersion="true"/>
</c:set>

<c:set var="runInfo">
<div class="row infobar">
<div class="row" id="progressRow">
	<div class="progressSection">
		<label><spring:message code="testrunner.progress.label" text="Progress"/>:</label>
		<ui:testingProgressBar engine="${engine}" />
		<span style="margin-left: 2em;">
			<ui:testingProgressStats engine="${engine}" />
		</span>
		<div id="totalRunTimeContainer">
			<label><spring:message code="testrunner.total.running.time" />:</label>
			<span id="totalTime">${engine.timeSpentHuman}</span>
		</div>
		<div class="clearer" ></div>
	</div>
	<div class="clearer"></div>
</div>

<div class="row" id="inforRow" style="margin-bottom:0;">
	<label><spring:message code="testrunner.testSet.label" />:</label>
	${testSetRunLink}

	<label><spring:message code="testrunner.configuration.label" text="Configuration" />:</label>
	<c:choose>
		<c:when test='${empty testSetRun.testConfiguration}'>--</c:when>
		<c:otherwise>
			<a href="<c:url value='${testSetRun.testConfiguration.urlLink}'/>" target="_blank" ><c:out value='${testSetRun.testConfiguration.name}'/></a>
		</c:otherwise>
	</c:choose>

	<label><spring:message code="testrunner.release.label" text="Release"/>:</label>
	<c:choose>
		<c:when test="${empty testSetRun.release}">--</c:when>
		<c:otherwise>
			<a href="<c:url value='${testSetRun.release.urlLink}' />" target="_blank" ><c:out value='${testSetRun.release.name}' /></a>
		</c:otherwise>
	</c:choose>

	<label><spring:message code="testrunner.build.label" text="Build"/>:</label>
	<c:choose>
		<c:when test="${empty testSetRun.build}">--</c:when>
		<c:otherwise>
			<c:out value="${testSetRun.build}"/>
		</c:otherwise>
	</c:choose>

</div>
</div>

<div class="row" id="pauseTitleStepper" >
	<table id="ptsTable">
	<tr>
	<td id="pauseTd">
		<a href="#" class="pauseButton" >
			<img src="<c:url value='/images/newskin/action/testrunner-pause-l.png'/>" title="<spring:message code='testrunner.pause.button.label' text='Pause' />"/>
		</a>
		<a href="#" class="continueButton" >
			<img src="<c:url value='/images/newskin/action/testrunner-play-l.png'/>" title="<spring:message code='testrunner.resume.button.label' text='Continue' />"/>
		</a>
	</td>
	<td id="timerTd">
		<div id="timer" title='<spring:message code="testrunner.timer.title" text="Time spent so far on this Test" />'>0s</div>
		<input type="hidden" value="" name="timeSpent" />
		<script type="text/javascript">
			$(function() { timer.init(${engine.timeSpent}, ${command.timeSpent})});
		</script>
	</td>
	<td id="summaryTd">
		<h2 class="summary">${testCaseLink}</h2>
	</td>
	<td id="stepperTd">
		<c:set var="total" value="${engine.totalNumberOfRunsTillFinished}" />
		<spring:message var="progressCounter"
			code="testrunner.progress.counts" arguments="${engine.index + 1},${total}"
			text="${engine.index + 1} of ${total}" />

		<c:choose>
		<c:when test="${testSetRun.sequential || sequentialTestSetLocked != null}">
			<div class="navigationLinks"><div>${progressCounter}</div></div>
		</c:when>
		<c:otherwise>
			<c:set var="atFirst" value="${engine.atFirstPendingTestWithoutWrapping}"/>
			<c:set var="atLast"  value="${engine.atLastPendingTestWithoutWrapping}" />
			<c:set var="hasMoreTests" value="${!(atFirst && atLast)}"/>
			<script type="text/javascript">
				SubmitDialog.hasMoreTests = ${hasMoreTests};
			</script>

			<spring:message var="navigationLinksLabel" code="testrunner.navigationlinks.title" text="Step to next/previous test in this run"  />
			<div class="navigationLinks" title="${navigationLinksLabel}">
				<a id="first" class="${atFirst ? 'navDisabled' : 'stepCursor'}" ><img src="<c:url value='/images/space.gif'/>" /></a>
				<a id="prev" class="${!hasMoreTests ? 'navDisabled' : 'stepCursor'}" ><img src="<c:url value='/images/space.gif'/>" /></a>
				<div>
					<input type="number" name="jumpTo" id="jumpTo" value="${engine.index + 1}" min="1" max="${total}" style="width:4em;"
						maxlength="4" size="4" title="<spring:message code='testrunner.progress.jumpTo.title'/>"
					/>
					<spring:message var="progressCounter"
						code="testrunner.progress.counts" arguments=",${total}"
						text=" of ${total}" />
					${progressCounter}
				</div>
				<a id="next" class="${!hasMoreTests ? 'navDisabled' : 'stepCursor'}" ><img src="<c:url value='/images/space.gif'/>" /></a>
				<a id="last" class="${atLast ? 'navDisabled' : 'stepCursor'}" ><img src="<c:url value='/images/space.gif'/>" /></a>

				<a class="nowarn stepCursor" onclick="showSelectTestDialog();"><img src="<c:url value='/images/newskin/queries/icon_search.png'/>" title="Choose a Test..." /></a>
			</div>

			<input type="hidden" name="navigation" />
			<script type="text/javascript">
				navigation.initNavigationLinks();
			</script>
		</c:otherwise>
		</c:choose>

	</td>
	</tr>
	</table>
</div>
</c:set>
<c:set var="parametersInfoBox">
	<c:set var="currentParametersHash" ><c:out value="${param.currentParametersHash}" /></c:set>
	<c:if test="${empty currentParametersHash}">	<%-- avoid duplicate currentParametersHash: one in the url, one in the hidden field --%>
		<c:set var="currentParametersHash" value="${testCase.parametersHash}" />
		<%-- remembering which parameters were used by keeping the hash of them from the test-case --%>
		<input type="hidden" name="currentParametersHash" value="${currentParametersHash}" />
		<%-- remembering hashes of skipped parameters --%>
		<form:hidden path="skippedParameters" />
	</c:if>

	<c:if test="${! empty testCase.usedParameterNames || ! empty testCase.currentParameters}">
	<div class="parametersInfoBox">
		<c:choose>
			<c:when test="${empty testCase.currentParameters}">
				<label class="subtitle"><spring:message code="testing.parameters.config.label"/></label><br/>
				<div class="warning">
					<spring:message code="testrunner.missing.parameter.values.warning" />&nbsp;<b><c:out value="${ui:sanitizeHtml(testCase.usedParameterNames)}"/></b>
					<spring:message code="testrunner.missing.some.parameter.values.fill.out"/>
				</div>
			</c:when>
			<c:otherwise>
				<spring:message var="selectParameter" code="testrunner.select.parameter.button.label" text="Select..." />
				<input type="button" id="selectParameter" value="${selectParameter}" onclick="showSelectParameterDialog('${currentParametersHash}'); return false;"
					title="<spring:message code='testrunner.select.parameter.button.label.title'/>"
				 />

				<spring:message var="skipLabel" code="testrunner.parameters.skip.button.label" />
				<input type="button" id="skipParameters" name="" value="${skipLabel}"
						title="<spring:message code='testrunner.parameters.only.skip.current.parameter.title'/>"
						onclick="skipCurrentParameters(); return false;" />

				<spring:message var="skipAllLabel" code="testrunner.parameters.skip.all.button.label" />
				<input type="button" id="skipParameters" name="" value="${skipAllLabel}"
						title="<spring:message code='testrunner.parameters.only.skip.all.parameters.title'/>"
						onclick="confirmSkipParameters(this); return false;" />

				<c:set var="parameterRows" value="${engine.testParametersProgressCount}" />
				<spring:message var="paramsTitle" code="testrunner.using.parameters.label" arguments="${parameterRows.left +1},${parameterRows.right}" />
				<label class="subtitle">${paramsTitle}</label>
				<div style="clear:both;margin-bottom:5px;"></div>

				<c:set var="missingParameters" value="${testCase.missingParameterNames}" />
				<c:if test="${! empty missingParameters}">
					<div class="warning">
						<spring:message code="testrunner.missing.some.parameter.values.warning" />&nbsp;<b><c:out value="${ui:sanitizeHtml(missingParameters)}"/></b>&nbsp;
						<spring:message code="testrunner.missing.some.parameter.values.fill.out"/>
					</div>
				</c:if>

				<tag:transformText value="${testCase.currentParametersAsWiki}" owner="${testCase.issue}" format="W"/>
			</c:otherwise>
		</c:choose>
		<div style="clear:both;"></div>
	</div>
	</c:if>
</c:set>

<div class="ui-layout-north" style="overflow:hidden;border:0;">
${runInfo}
</div>
<div class="ui-layout-center">
<ui:globalMessages/>
<div class="contentWithMargins thumbnailImages">

${parametersInfoBox}

<c:if test="${! empty testCaseIssue.description && testCaseIssue.description != '--'}">
<div class="row" id="description">
	<label class="subtitle"><spring:message code="tracker.description.label" text="Description"/>:</label>
	<div class="description">
	  ${testCaseDecorator.description}	<%-- renders the description as wiki --%>
	</div>
</div>
</c:if>

<c:if test="${! empty attachments}">
<div class="row">
	<label class="subtitle"><spring:message code="attachments.label" text="Attachments" />:</label>
	<ul class="attachmentGroup">
	<c:forEach items="${attachments}" var="attachment">
		<li>
			<ui:trackerItemAttachmentLink trackerItemAttachment="${attachment}" /> <%-- TODO: baselines are not happening here? would be a  revision="${baseline.id}" parameter --%>
		</li>
	</c:forEach>
	</ul>
</div>
</c:if>

<c:if test="${! empty testCase.preAction}">
<div class="row" id="preAction">
	<label class="subtitle"><spring:message code="tracker.field.Pre-Action.label" text="Pre-Action" /></label>
	<tag:transformText value="${testCase.preAction}" owner="${testCase.issue}" format="W"/>
</div>
</c:if>

<c:set var="hasReferenceResolutionProblem" value="${testCase.hasReferenceResolutionProblem()}" />
<c:if test="${hasSteps}">
<div class="row" id="testSteps" style="margin-top: 0px;">
	<label class="subtitle"><spring:message code="tracker.field.Test Steps.label" text="Test Steps"/></label>
	<c:if test="${hasReferenceResolutionProblem}">
		<script type="text/javascript">
			$(document).ready(handleReferenceResolutionProblems);
		</script>
	</c:if>

	<!-- Order of the test steps must not change, otherwise the following logic will not pair the rows with the upload controls properly. -->
	<ui:testSteps tableId="testStepsTable" testSteps="${testCase.testSteps}" readOnly="true" showReferences="${hasReferenceResolutionProblem}" owner="${testCase.issue}"
	/>

	<c:set var="uploadConversationId"><c:out value="${command.uploadConversationId}"/></c:set>

	<script type="text/javascript">
		codebeamer.conversationId = "${uploadConversationId}";
	</script>
</div>
<input type="hidden" value="${uploadConversationId}" name="uploadConversationId"/>
</c:if>

<c:if test="${hasSteps}">
	<div class="row" style="margin-top: 10px; display: none;">
		<fieldset id="currentStepEditor">
			<legend><spring:message code="testrunner.steps.to.execute" text="Test Step to execute"/></legend>
			<div class="row">
				<label><spring:message code="tracker.field.Action.label" text="Action" />:</label>
				<span id="action">--</span>
				<div class="clearer" ></div>
			</div>
			<div class="row">
				<label><spring:message code="tracker.field.Expected result.label" text="Expected Result" />:</label>
				<span id="expectedResult">--</span>
				<div class="clearer" ></div>
			</div>
			<div class="row">
				<label><spring:message code="tracker.field.Actual result.label" text="Actual result"/>:</label>
				<%-- TODO: this should be a wysiwyg editor --%>
				<%-- TODO: should support attaching files here too! --%>
				<textarea id="actualResult" rows="5" title='<spring:message code="testrunner.step.actual.result.title"/>'></textarea>
			</div>
		</fieldset>
		<div class="clearer" ></div>
	</div>

	<script type="text/javascript">
		var previousRunData = null;
		<%-- render the previous run's data as JSON, this will be added by js in testRunner.js --%>
		<c:if test="${! empty editedTestRun}">
			previousRunData = [<c:forEach var="stepResult" items="${editedTestRun.stepsResults}" varStatus="status">
			    {
			    	'actualResult' : '<spring:escapeBody htmlEscape="true" javaScriptEscape="true" >${stepResult.actualResult}</spring:escapeBody>',
			    	'stepResult'   : '${stepResult.result}'
			    }<c:if test="${! status.last}">,</c:if></c:forEach>]
		</c:if>

		var stepper = new Stepper("#testStepsTable", '${empty editedTestRun ? testCase.issue.interwikiLink: editedTestRun.delegate.interwikiLink}', previousRunData);
		$("body").data("stepperInstance", stepper);
	</script>
</c:if>

<c:if test="${! empty testCase.postAction}">
<div class="row" id="postAction" style="margin-top: 10px;">
	<label class="subtitle"><spring:message code="tracker.field.Post-Action.label" text="Post-Action" /></label>
	<tag:transformText value="${testCase.postAction}" owner="${testCase.issue}" format="W" />
</div>
</c:if>

</div>
</div>

<div class="ui-layout-south">
<spring:message var="conclusionHint" code="testrun.field.conclusion.hint" text="Conclusion" />
<div id="conclusionRow" class="row" title="${conclusionHint}">
	<spring:message var="conclusionText" code="testrun.field.conclusion" text="Conclusion" />
	<script type="text/javascript">
		function updateLayoutForConclusion() {
			var updateIt = function() {
				$("#command").layout().resizeAll();
			};

			updateIt();
			setTimeout(updateIt, 100);
		}
	</script>

	<ui:collapsingBorder label="${conclusionText}" onChange="updateLayoutForConclusion" open="${! hasSteps || (!empty command.conclusion)}">
		<form:textarea id="conclusion" path="conclusion" />
	</ui:collapsingBorder>
</div>

<div id="buttonContainer" class="row actionBar">
	<table id="buttonTable">
 	<tr>

	<c:if test="${hasSteps}">
		<script type="text/javascript">
			function toggleControlButton(event, name) {
				$('[name="'+name+'"]').toggle();
				return false;
			}
		</script>
<%--
		<td style="width:1px;">
			<div class="buttonsContainer" style="width: 21px;">
			<spring:message var="stepperLabel" code="testrunner.move.to.step.title" />
			<button type="button" class="button" style="position:relative;" title="${stepperLabel}" >
				<spring:message var="prevStepLabel" code="testrunner.move.to.previous.step"/>
				<a href="#" class="prevStep" title="${prevStepLabel}" onclick="prevStep(this); return false;">
					<img src="<ui:urlversioned value='/images/newskin/action/testrunner-teststep-prev-a.png'/>"/>
				</a>
				<img class="runner" src="<ui:urlversioned value='/images/newskin/action/testrun-running.png'/>"/>

				<spring:message var="nextStepLabel" code="testrunner.move.to.next.step"/>
				<a href="#" class="nextStep" title="${nextStepLabel}" onclick="nextStep(this); return false;">
					<img src="<ui:urlversioned value='/images/newskin/action/testrunner-teststep-next-a.png'/>"/>
				</a>
			</button>
			</div>
		</td>
--%>
		<td>
			<c:if test="${! hasReferenceResolutionProblem}">
			<div class="buttonsContainer">
			<spring:message var="passOneLabel" code="testrunner.pass.one.steps.button.label" />
			<button type="button" class="button" name="passStep"
				onclick="stepper.markCurrent('PASSED'); return false;" >
				<img src="<ui:urlversioned value='/images/newskin/action/testrunner-pass-step.png'/>"/>
				${passOneLabel}
			</button>

			<a href="#" id="passMore" onclick="return toggleControlButton(this, 'passAll');">
				<button type="submit" class="button multiStepButton autoHideMenu" name="passAll" id="passAll"
					title='<spring:message code="testrunner.pass.all.steps.button.label.title" />'
				>
					<%-- the acceptAll.png is created using gimp as described here: http://journalxtra.com/easyguides/how-to-make-a-semi-transparent-image-using-gimp-222/ --%>
					<img src="<ui:urlversioned value='/images/newskin/action/testrunner-pass-allstep.png'/>"/>
					<spring:message code="testrunner.pass.all.steps.button.label" />
				</button>
			</a>
			</div>
			</c:if>
		</td>

		<td>
			<c:if test="${! hasReferenceResolutionProblem}">
			<div class="buttonsContainer">
			<spring:message var="failOneLabel" code="testrunner.fail.one.steps.button.label" />
			<button type="button" class="button" name="failStep"
				onclick="stepper.markCurrent('FAILED'); return false;" >
				<img src="<ui:urlversioned value='/images/newskin/action/testrunner-fail-step.png'/>"/>
				${failOneLabel}
			</button>

			<a href="#" id="failMore" onclick="return toggleControlButton(this, 'failAll');">
				<button type="submit" class="button multiStepButton autoHideMenu" name="failAll" id="failAll"
					title='<spring:message code="testrunner.fail.all.steps.button.label.title" />'
				>
					<img src="<ui:urlversioned value='/images/newskin/action/testrunner-fail-allstep.png'/>"/>
					<spring:message code="testrunner.fail.all.steps.button.label" />
				</button>
			</a>
			</div>
			</c:if>
		</td>

		<c:if test="${engine.testManagementConfig.testRunnerShowsBlock}">
		<td>
			<c:if test="${! hasReferenceResolutionProblem}">
			<div class="buttonsContainer blockStepButtonContainer">
			<spring:message var="blockOneLabel" code="testrunner.block.one.steps.button.label" />
			<button type="button" class="button" name="blockStep"
				onclick="stepper.markCurrent('BLOCKED'); return false;" >
				<img src="<ui:urlversioned value='/images/newskin/action/testrunner-block-step.png'/>"/>
				${blockOneLabel}
			</button>

			<a href="#" id="blockMore" onclick="return toggleControlButton(this, 'blockAll');" >
				<button type="submit" class="button multiStepButton autoHideMenu" name="blockAll" id="blockAll"
					title='<spring:message code="testrunner.block.all.steps.button.label.title" />'
				>
					<img src="<ui:urlversioned value='/images/newskin/action/testrunner-block-allstep.png'/>"/>
					<spring:message code="testrunner.block.all.steps.button.label" />
				</button>
			</a>
			</div>
			</c:if>
		</td>
		</c:if>

		<td>
			<spring:message var="clearTooltip" code="testrunner.clear.step.tooltip" />
			<div class="buttonsContainer">
			<button type="button" class="button" name="clearStep" title="${clearTooltip}" onclick="stepper.clearStep(); return false;">
				<img src="<ui:urlversioned value='/images/newskin/action/clearStep.png'/>"/>
				<spring:message code="testrunner.clear.step" />
			</button>
			</div>
		</td>

		<script type="text/javascript">
		//  hotkeys...
		mapHotKeys([
			{ key: 'alt+p' , action: function() { $("[name='passStep']").click(); } },
			{ key: 'alt+f' , action: function() { $("[name='failStep']").click(); } },
			{ key: 'alt+b' , action: function() { $("[name='blockStep']").click();} },
			{ key: 'alt+c' , action: function() { $("[name='clearStep']").click();} }
		]);
		</script>
	</c:if>

	<c:if test="${!hasSteps}">
		<td>
			<button type="submit" class="button" name="passAll" id="passAll" >
				<img src="<ui:urlversioned value='/images/newskin/action/testrunner-pass-step.png'/>"/>
				<spring:message code="testrunner.pass.testcase.button.label" />
			</button>
		</td>
		<td>
			<button type="submit" class="button" name="failAll" id="failAll" >
				<img src="<ui:urlversioned value='/images/newskin/action/testrunner-fail-step.png'/>"/>
				<spring:message code="testrunner.fail.testcase.button.label" />
			</button>
		</td>
		<c:if test="${engine.testManagementConfig.testRunnerShowsBlock}">
		<td>
			<button type="submit" class="button" name="blockAll" id="blockAll" >
				<img src="<ui:urlversioned value='/images/newskin/action/testrunner-block-step.png'/>"/>
				<spring:message code="testrunner.block.testcase.button.label"/>
			</button>
		</td>
		</c:if>
		<script type="text/javascript">
		//  hotkeys...
		mapHotKeys([
			{ key: 'alt+p' , action: function() { $("[name='passAll']").click(); return false;} },
			{ key: 'alt+f' , action: function() { $("[name='failAll']").click(); return false;} },
			{ key: 'alt+b' , action: function() { $("[name='blockAll']").click(); return false;} }
		]);
		</script>
	</c:if>

		<script type="text/javascript">
			function markAllRemainingSteps(result) {
				if (typeof stepper != 'undefined') {
					stepper.markAllRemainingSteps(result);
				}
			}

			$(function() {
				$("#passAll").click(function() {
					markAllRemainingSteps('PASSED');
					return SubmitDialog.submitForm('PASSED', false, false, false);
				});
				$("#failAll").click(function() {
					markAllRemainingSteps('FAILED');
					return SubmitDialog.submitForm('FAILED', true);
				});
				$("#blockAll").click(function() {
					markAllRemainingSteps('BLOCKED');
					return SubmitDialog.submitForm('BLOCKED', true);
				});
			});
		</script>

		<td>
			<button id="reportBugButton" type="button" class="button" name="reportBugButton">
				<%-- same as the bug entity icon /images/entity/trackeritem.gif, but nicer --%>
				<img src="<ui:urlversioned value='/images/newskin/action/testrunner-bugreport.png'/>"/>
				<spring:message code="testrunner.report.bug.button.label" text="Report Bug" />
			</button>
			<script type="text/javascript">
				// don't put this to onclick, because we copy the button to an overlay, and that would copy the onclick event handler too
				$("#reportBugButton").click(function() {
					reportBug.showOverlay(this);
					return false;
				});
			</script>
		</td>

		<c:choose>
			<c:when test="${hasSteps}">
				<td>
					<button type="submit" class="button" name="saveAndNext" onclick="return SubmitDialog.submitForm(this);" >
						<img src="<ui:urlversioned value='/images/newskin/action/testrunner-save.png'/>"/>
						<spring:message code="testrunner.save.and.next.testcase.button.label.1" text="Save" />
						<br/>
						<spring:message code="testrunner.save.and.next.testcase.button.label.2" text="& Next Test Case" />
					</button>
				</td>
			</c:when>
			<c:otherwise>
				<c:if test="${!testSetRun.sequential && hasMoreTests}">
					<td>
						<button type="submit" class="button" name="nextTextCase">
							<img src="<ui:urlversioned value='/images/newskin/action/testrunner-save.png'/>"/>
							<spring:message code="testrunner.next.testcase.button.label" text="Next Test Case" />
						</button>
					</td>
				</c:if>
			</c:otherwise>
		</c:choose>

		<td>
			<spring:message var="pauseRunTitle" code="testrunner.pause.run.button.title" />
			<button class="button" name="pauseButton" onclick="pauseRun(); return false;" title="${pauseRunTitle}" >
				<img src="<ui:urlversioned value='/images/newskin/action/testrunner-pause-run.png'/>"/>
				<spring:message code="testrunner.pause.run.button.label" />
			</button>
		</td>

		<c:set var="usingWorkflow" value="${testSetRun.delegate.tracker.isUsingWorkflow()}" />
		<c:if test="${engine.testManagementConfig.testRunnerShowsEndRun && usingWorkflow}">
		<td>
			<spring:message var="endRunTitle" code="testrunner.end.run.button.title" />
			<button type="submit" class="button" value="End Run" onclick="showEndRunDialog(); return false;" title="${endRunTitle}" >
				<img src="<ui:urlversioned value='/images/newskin/action/testrunner-stop-l.png'/>"/>
				<spring:message code="testrunner.end.run.button.label" text="End Run" />
			</button>
		</td>
		</c:if>
	</tr>
	</table>

	<button id="continueButton" type="button" class="button continueButton" >
		<img src="<ui:urlversioned value='/images/newskin/action/testrunner-play-l.png'/>"/>
		<span><spring:message code="button.continue" text="Continue" /></span>
	</button>

</div>
</div>

<script type="text/javascript">
$(function() {
	$("#hotkeysHint").click(function(event) {
		$("#hotkeysHint table").toggle();
		event.stopPropagation();
		return false;
	});
});
</script>
<spring:message code="testrunner.hotkeys.hint" var="hotkeysHintText" text="Show keyboard hotkeys..."/>
<div id="hotkeysHint" class="hint" title="${hotkeysHintText}">
<b><spring:message code="testrunner.hotkeys.title" text="Hotkeys..."/></b><br/>
<table title="<spring:message code='testrunner.hotkeys.hint.hide'/>" class="autoHideMenu" >
<tr><td><b>alt + p</b></td><td><spring:message code="testrunner.hotkeys.pass.current.step" text="Pass current step"/></td><td><b>alt + shift + p</b></td><td><spring:message code="testrunner.hotkeys.pass.test" text="Pass test"/></td></tr>
<tr><td><b>alt + f</b></td><td><spring:message code="testrunner.hotkeys.fail.current.step" text="Fail current step"/></td><td><b>alt + shift + f</b></td><td><spring:message code="testrunner.hotkeys.fail.test" text="Fail test"/></td></tr>
<tr><td><b>alt + b</b></td><td><spring:message code="testrunner.hotkeys.block.current.step" text="Block current step"/></td><td><b>alt + shift + b</b></td><td><spring:message code="testrunner.hotkeys.block.test" text="Block test"/></td></tr>
<tr><td><b>alt + r</b></td><td><spring:message code="testrunner.hotkeys.report.bug" text="Report bug"/></td><td><b>alt + n</b></td><td><spring:message code="testrunner.hotkeys.next.test" text="Next test"/></td></tr>
<tr><td><b>alt + c</b></td><td><spring:message code="testrunner.clear.step.tooltip" /></td></tr>
</table>
</div>

<input type="hidden" name="actualResults" value="" /> <%-- this hidden field just fixes binding problem when there is just 1 single Step--%>

<c:if test="${! empty missingParameters || empty testCase.currentParameters}">
	<c:set var="missingParametersForDialog" value="${!empty missingParameters ? missingParameters : testCase.usedParameterNames}"/>
	<div id="missingParameterDialog" title="Missing parameter values">
		<div class="warning"><spring:message code="testrunner.missing.some.parameter.values.fill.out.dialog"/></div>
		<div class="missingParameterTableContainer">
			<table class="displaytag">
				<tr>
					<th><spring:message code="testrunner.test.case.run.used.parameter"/></th>
					<th><spring:message code="testrunner.test.case.run.used.parameter.value"/></th>
				</tr>
				<c:forEach items="${missingParametersForDialog}" var="parameter">
					<tr>
						<td><c:out value="${parameter}"/></td>
						<td><textarea name="${parameter}" rows="1"></textarea></td>
					</tr>
				</c:forEach>
			</table>
		</div>
	</div>
	<script type="text/javascript">
		$(function() {
			initMissingParameterDialog(${param.askMissingParams != 'false'});
		});
	</script>
</c:if>

</form:form>

<jsp:include page="/testmanagement/endTestRunDialog.jsp"/>
<jsp:include page="/testmanagement/parameters/skipTestParametersDialog.jsp" />

<ui:delayedScript>
<script type="text/javascript">
	disableDoubleSubmit($("form"));

	Stepper.prototype.MARK_ALL_STEPS_FAILED_IF_CRITICAL_STEP_FAILS = ${MARK_ALL_STEPS_FAILED_IF_CRITICAL_STEP_FAILS};

	$(function() {
		keepWindowDimensions("TESTRUNNER_WINDOW_DIMENSIONS", false);
	});
</script>
</ui:delayedScript>

</c:otherwise> <%-- end of otherwise when page is empty because of a sequentialTestSetLocked exception (somebody else is locked a sequential testset --%>
</c:choose>

<script type="text/javascript">
$(function() {
	reportBug.stopTimerWhileRepotingBug = ${engine.testManagementConfig.stopTimerWhileRepotingBug};

	var allowTiming = ${engine.testManagementConfig.allowTiming};
	timer.allowTiming = allowTiming;
	if (!allowTiming) {
		$("body").addClass("hideTimer");
	}
});

$(autoHideMenus);

</script>

<%-- reload the opener window if the TestRunner was generating TestCaseRuns --%>
<c:if test="${engine.testRunsGenerated}">
<script type="text/javascript">
	$(function() {
		console.log("Reloading opener window because TestRuns has been generated, and that window does not show them yet;");
		var success = reloadOpener();
		if (! success) {
			console.log("Ignored: can not reload opener window when testruns generated!");
		}
	});
</script>
</c:if>


