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
 * $Revision: 22358:556ae55f7d05 $ $Date: 2009-08-21 12:45 +0000 $
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	jsp fragment used on document-list and report pages to be able to delete one or multiple artifacts (doc/report)
	this mainly contains the javascripts for that, plus a hidden input field contains the artifact ids to select
	Assumes that there is an combo box with id of "actionCombo", which is disabled before form submit.

	parameters:
	param.confirmMessageKey			- the key for multi-delete confirm message
	param.confirmOneMessageKey		- the key for one-delete confirm message
	param.confirmOneDirMessageKey	- optional key when deleting one directory
--%>

<c:set var="confirmMessageKey" value="${param.confirmMessageKey}" />
<c:set var="confirmOneMessageKey" value="${param.confirmOneMessageKey}" />
<c:set var="confirmOneDirMessageKey" value="${param.confirmOneDirMessageKey}" />

<script type="text/javascript">

// confirm the delete and submit the form if confirmed
// @param form The form to submit
function confirmDelete(form) { // FIXME There is similar function in report/mail.js. Join together?
	var answer = submitIfSelected(form, 'selectedArtifactIds');
	if (answer) {
		var msg = '<spring:message javaScriptEscape="true" code="${confirmMessageKey}" />';
		showFancyConfirmDialogWithCallbacks(msg, function() {
				disableButtonsAndSubmit(form, "delete");
			});
	}
	return false;
}

function disableButtonsAndSubmit(form, act) {
	// disable action combo
	var actionCombo = document.getElementById("actionCombo");
	actionCombo.disabled = true;
	// pass back the action value
	form.action.value = act;
	form.submit();
	return false;
}

// script for deleting one selected document
// @param artifactId the artifact to delete
// @param artifactName the name of the artifact to delete
// @param isDirectory If the artifact to be deleted is a directory
// @param isBranch If the artifact to be deleted is a branch
function deleteOneArtifact(artifactId, artifactName, isDirectory, isBranch) {
	var msg = "<spring:message javaScriptEscape="true" code="${confirmOneMessageKey}" />";
	<c:if test="${!empty confirmOneDirMessageKey}">
		if (isDirectory) {
			msg = "<spring:message javaScriptEscape="true" code="${confirmOneMessageKey}" />";
		}
	</c:if>
	if (isBranch) {
		msg = i18n.message('tracker.branching.delete.confirm');
	}
	msg = msg.replace("{name}", artifactName);
	showFancyConfirmDialogWithCallbacks(msg, function() {
			var url = contextPath + "/proj/doc/documentProperties.do?action=delete&selectedArtifactIds=" + artifactId;
			document.location.href = url;
		});
}

function deleteBranch(branchId, itemName, currentBranchId) {
	var msg = i18n.message('tracker.branching.delete.confirm');
	msg = msg.replace("{name}", itemName);
	showFancyConfirmDialogWithCallbacks(msg, function() {
		$.get(contextPath + "/branching/deleteBranch.spr?branchId=" + branchId + (currentBranchId ? "&currentBranchId=" + currentBranchId : "")).success(function(result) {
			if (result == null || result.length == 0) {
				location.reload();
			} else {
				parent.window.location.href = contextPath + "/tracker/" + result;
			}
		});
	});
}

</script>

