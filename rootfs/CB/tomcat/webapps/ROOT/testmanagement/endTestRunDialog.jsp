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
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<script type="text/javascript">
	/**
	 * @param onSubmit Optional callback function: if not null called to submit the form. If missing the hidden form is submitted. The function gets the original/hidden form as parameter
	 */
	function showHiddenConfirmationFormAsDialog(selector, buttons, width, onSubmit) {
		// copy the html in the #endRunDialog will appear in the dialog
		var msg = $(selector).html();

		var buttonYesText=i18n.message("button.yes");
		var buttonCancelText=i18n.message("button.cancel");

		if (buttons == null) {
			buttons = [ { text:buttonYesText,
						  click:function() {
							  var $form = $(this).find("form");
							  if (onSubmit != null) {
								  onSubmit($form);
							  } else {
							      $form.submit();
							  }
							  return false;
						  }
						} ,
						{ text:buttonCancelText,
						  "class": "cancelButton",
						  click:function() { $(this).dialog("destroy"); },
						  isDefault:true
						}];
		}

		width = width || 500;

		showModalDialogWithArgs(null, msg, buttons, "cbModalDialog", true, {width: width, open: function() {
			$(this).find("label").click(function() {
				// force click on input field if label clicked
				$(this).prev("input[type='checkbox'], input[type='radio']").click();
			});
		}});
	}

	function copyFormDataToAnotherFormAsHiddenFields(sourceForm, targetForm) {
		var fields = $(sourceForm).serializeArray();
		var $targetForm = $(targetForm);
	    $.each( fields, function( i, field ) {
	    	var name = field.name;
	    	var value = field.value;
	    	var input = $("<input>").attr("type", "hidden").attr("name", name).val(value);
	    	$targetForm.append(input);
	    });
	    return fields;
	}

	/**
	 * When the Finish/End-run or Pause Run buttons clicked those should save all Step data too,
	 * but these dialogs are use a separate form, so when saving we need to copy the data from the form of the dialog to the main form
	 * and submit the main form to save the Steps too
	 */
	function submitWithMainForm(form) {
		// copy the fields from the hidden form to the main form and submit that
		var $mainForm = $("form#command").first();

		copyFormDataToAnotherFormAsHiddenFields(form, $mainForm);

		$mainForm.submit();
	}

	function showEndRunDialog() {
		saveCurrentStepData();
		showHiddenConfirmationFormAsDialog("#endRunDialog", null, null, submitWithMainForm);
	};
</script>

<head>
<style type="text/css">
<!--
#endRunDialog {
	display: none;
}

.endRunDialogForm {
	display: block !important;
}
.endRunDialogForm #optionsTable {
	margin: 5px auto;
	width: 80%;
}
.endRunDialogForm #optionsTable p {
	margin: 3px 0;
}

#optionsTable td{
    vertical-align: top;
}

.endRunDialogForm table > label {
	margin-left: 0px;
	font-size: 12px;
}
.endRunDialogForm input {
	vertical-align: sub;
}
.endRunDialogForm .warning {
	margin-bottom: 1em !important;
}
.endRunDialogForm .comment {
}

.comment label {
	font-weight: bold;
}


input[type='radio'] {
	vertical-align: text-bottom;
}
-->

.endRunComment {
	width: 100%;
	box-sizing: border-box;
	min-height: 5em;
    height: 10vh;
}

</style>
</head>

<div id="endRunDialog">
	<form:form class="endRunDialogForm" id="endRunDialogForm">
	<input type="hidden" name="index" value="${engine.index + 1}" />
	<div class="warning">
		<h3 style="margin: 0 0 1em 0"><spring:message code="testrunner.end.run.dialog.confirm" /></h3>

		<c:set var="numTestsCompleted" value="${engine.numberOfCompletedTestCaseRuns}" />
		<c:set var="total" value="${engine.totalNumberOfRunsTillFinished}" />
		<c:set var="remaining" value="${total-numTestsCompleted}" />
		<%--
		<spring:message var="completedCounter"
			code="testrunner.progress.counts" arguments="${total-numTestsCompleted},${total}"
			text="${numTestsCompleted} of ${total}" />
			--%>
		<spring:message code="testrunner.end.run.dialog.progress.info" text="The remaining {0} Test Cases will <b>not</b> be executed." arguments="${remaining}" />
		<br/>
	</div>
<%-- The user can not choose wants to set it completed/suspended or not --%>
	<input type="hidden" name="endRunStatus" value="COMPLETED"  />
<%--
	<table id="optionsTable" class="staticLayout">
	<tr>
		<td>
			<b><spring:message code="testrunner.end.run.dialog.testset.status.label" /></b>
		</td>
		<td>
			<b><spring:message code="testrunner.end.run.dialog.result.label" /></b>
		</td>
	</tr>
	<tr>
		<td>
			<p>
				<input type="radio" name="endRunStatus" value="COMPLETED" checked="checked" id="statusCompleted" />
				<label for="statusCompleted"><spring:message code="tracker.choice.Completed.label" text="Completed" /></label>
			</p>

			<p>
				<input type="radio" name="endRunStatus" value="SUSPENDED" id="statusSuspended" />
				<label for="statusSuspended"><spring:message code="tracker.choice.Suspended.label" text="Suspended" /></label>
			</p>
		</td>
		<td>
			<p>
				<input type="radio" name="endRunResult" value="BLOCKED" checked="checked" id="resultBlocked"/>
				<label for="resultBlocked" ><spring:message code="tracker.choice.Blocked.label" text="Blocked" /></label>
			</p>

			<p>
				<input type="radio" name="endRunResult" value="PASSED" id="resultPassed" />
				<label for="resultPassed" ><spring:message code="tracker.choice.Passed.label" text="Passed" /></label>
			</p>

			<p>
				<input type="radio" name="endRunResult" value="FAILED" id="resultFailed" />
				<label for="resultFailed" ><spring:message code="tracker.choice.Failed.label" text="Failed" /></label><br/>
			</p>
		</td>
	</tr>
	</table>
--%>

	<div class="row comment">
		<label><spring:message code="issue.updated.comment" text="Comment"/></label><br/>
		<textarea class="endRunComment" name="endRunComment" rows="5" cols="60" ></textarea>
	</div>
	</form:form>
</div>

<div id="pauseRunDialog" style="display:none;">
	<form:form class="endRunDialogForm">
	<div class="warning">
		<h3 style="margin: 0 0 1em 0"><spring:message code="testrunner.pause.run.dialog.confirm" /></h3>

		<spring:message code="testrunner.pause.run.dialog.progress.info" arguments="${remaining}" />
		<br/>
	</div>
	<input type="hidden" name="pauseRun" value="true"  />

	<div class="row comment">
		<label><spring:message code="issue.updated.comment" text="Comment"/></label><br/>
		<textarea class="endRunComment" name="endRunComment" rows="5" cols="60" ></textarea>
	</div>
	</form:form>
</div>