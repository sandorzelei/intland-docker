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

<meta name="decorator" content="popup" />
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin CMDBModule"/>

<%-- Page to select one of the parameters --%>

<head>
<style type="text/css">
	table td {
		cursor: pointer;
	}
</style>
</head>
<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">
		<spring:message code="testrunner.select.parameter.progress.label"
			arguments="${unusedParameters.size},${usedParameters.size + unusedParameters.size}"
			text="${unusedParameters.size} parameters left from ${usedParameters.size + unusedParameters.size} total" />
		<c:if test="${! empty skippedParameters && skippedParameters.size > 0}">
			<spring:message code="testrunner.select.parameter.progress.skipped.label" arguments="${skippedParameters.size}" />
		</c:if>
	</jsp:attribute>
	<jsp:body>
		<b><spring:message code="testrunner.select.parameter.label" text="Select Parameters!"/></b>
	</jsp:body>
</ui:actionMenuBar>

<spring:message var="buttonSelect" code="button.select" />
<ui:actionBar>
	<spring:message var="cancelTitle" code="button.cancel" text="Cancel" />
	<input type="submit" class="cancelButton" onclick="closePopupInline(); return false;" value="${cancelTitle}" />
</ui:actionBar>

<div class="contentWithMargins" style="margin-top:0;">
<%--
	<h2>Unused:</h2>
	${unusedParameters}

	<h2>Used:</h2>
	${usedParameters}
 --%>
	<c:set var="testParameters" value="${unusedOrSkipped}" scope="request" />
	<c:remove var="usedParameters" scope="request" />
	<jsp:include page="/testmanagement/parameters/testParametersTable.jsp?singleSelect=true"/>
</div>

<spring:message var="selectButtonTitle" code="testrunner.select.parameter.button.title" />
<style type="text/css">
.parameterHashSelect {
	display: none;
}
td.checkbox-column-minwidth {
	padding-top: 7px !important;
	padding-bottom: 7px !important;
}
tr.skippedParameter td.parameterData {
	text-decoration: line-through;
	color: red;
}

tr .testRunPartial {
	float: right;
	margin: 0 5px;
}
</style>

<spring:message var="skippedHint" code="testrunner.select.parameter.select.skipped.hint" />
<c:set var="skippedParametersHashes" value="${skippedParameters.hashes}" />

<spring:message var="selectedParameterWarning" code="testrunner.select.parameter.warning" />
<spring:message var="closeButton" code="button.close" />
<spring:message var="skippedParameterBadge" code="testrunner.skipped.parameter.badge" />

<script type="text/javascript">
var originalSelectedParameterHash = '${param.selectedParameterHash}';

function openSelectedParameter(parameterHash) {
	if (originalSelectedParameterHash == parameterHash) {
		console.log("don't reload, because the same parameter was selected");
		closePopupInline();
		return;
	} else {
		var href = window.location.href + "&selectedParametersHash=" + parameterHash;
		showFancyConfirmDialogWithCallbacks('${selectedParameterWarning}', function() {
			window.top.location.href = href;
		});
	}
}

function selectButton(button) {
	var selectedParameterHash = $(button).closest("tr").find("input[name='parameterHash']").val();
	openSelectedParameter(selectedParameterHash);
}

// the hashes of the skipped parameters
var skippedParameters = {
			<c:forEach var="hash" items="${skippedParametersHashes}" varStatus="status" >'${hash}':'true'<c:if test="${! status.last}">,</c:if></c:forEach>
		};

$(function() {
	$(".testParametersTable >tbody >tr input[name='parameterHash']").each(function() {
		var hash = $(this).val();

		var button = '${buttonSelect}';
		if (hash == originalSelectedParameterHash) {
			button = '${closeButton}';
		}
		var inp = "<input type='submit' class='button selectButton' onClick='return selectButton(this);' value='" + button +"' title='${selectButtonTitle}'></input>";
		$(inp).insertBefore(this);

		if (skippedParameters[hash]) {
			// this is skipped parameter
			var $tr = $(this).closest("tr");
			$tr.addClass("skippedParameter").find("td").attr("title","${skippedHint}");
			$tr.find("td").last().append("<span class='testRunResultTablet testRunPartial' >${skippedParameterBadge}</span>");
		}
	});
});
</script>
