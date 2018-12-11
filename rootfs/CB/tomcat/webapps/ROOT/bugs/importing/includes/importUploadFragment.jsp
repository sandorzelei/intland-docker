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
<%@ page import="com.intland.codebeamer.flow.form.ImportForm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<style type="text/css">
#fileFormats {
	padding: 0;
	margin: 15px 0 0 7px;
	clear:both;
	list-style: none;
}
#fileFormats > li {
	margin-bottom: 25px;
}
#fileFormats input, #fileFormats img {
	margin-right: 10px;
	vertical-align: text-top;
}
#fileFormats label {
	display: block;
	margin-bottom: 15px;
	font-size: 16px;
	font-weight: bold;
}

#fileFormats input {
	outline: none;
}

.fileFormatExplanation {
	display: block;
	margin-left: 35px;
	font-size:13px;
}
#fileFormats .fileFormatExplanation label {
	font-weight: bold;
	font-size: 13px;
	margin: 0;
}
.fileFormatExplanation li {
	font-size:13px;
}
.fileFormatExplanation ul {
	list-style-type: disc;
	padding-left: 1em;
}
.visibilityChanges {
	margin-top:  20px;
	margin-left: 40px;
}
.visibilityChanges tr td {
	padding-bottom: 10px;
}
.visibilityChanges .labelColumn {
	font-weight: bold;
	font-size: 13px;
	text-align: right;
	padding-right: 10px
}
.visibilityChanges select {
	font-size: 13px;
}
.invalidfield a {
	font-size: 8pt !important;
}

#fileUploadCell .qq-upload-button {
	width: auto;
	border: none;
}

#fileUploadCell .qq-upload-list {
	float: right;
	position: inherit;
	left: 0em;

}

#fileUploadCell .qq-uploader {
	border: dashed 1px #DDDDDD;
	width: 45em;
}

#fileUploadCell .qq-uploader:after
{
	content: ".";
	display: block;
	height: 0;
	clear: both;
	visibility: hidden;
}

/* special look for word-table import, indented a bit */
li.fileFormat_wordTable {
	margin-left: 30px;
}

li.fileFormat_wordTable .fileFormatExplanation {
	margin-left: 5px;
}

#mandatoryFieldWarning {
	margin-bottom: 1em;
	width: 50%;
}

</style>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
// Hide validation error messages.
function mySubmitHandler(frm) {
	hideUploadValidationMessage();

	return true;
}
function onNextButton() {
	if (isFileUploadsFinished()) {
		ajaxBusyIndicator.showProcessingPage();
		return true;
	}
	return false;
}
</SCRIPT>

<form:form commandName="importForm" onsubmit="mySubmitHandler();" action="${flowUrl}" enctype="multipart/form-data">

<ui:actionBar>
	<c:if test="${param.nextEnabled eq true}">
		<spring:message var="nextButton" code="button.goOn" text="Next &gt;"/>
		&nbsp;&nbsp;<input type="submit" class="button disabledButton" disabled="disabled" id="_eventId_next" name="_eventId_next" value="${nextButton}"
				onclick="return onNextButton();" />
	</c:if>

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<c:choose>
		<c:when test="${!empty cancelUrl}">
			<input type="button" class="button linkButton cancelButton" name="_eventId_cancel" value="${cancelButton}" onclick="document.location.href='${cancelUrl}'; return false;" />
		</c:when>
		<c:otherwise>
			<input type="submit" class="button cancelButton" name="_eventId_cancel" value="${cancelButton}" />
		</c:otherwise>
	</c:choose>
</ui:actionBar>

<div style="margin-top: 6px; margin-left: 8px;">
		<spring:message var="fileTooltip" code="useradmin.importUsers.importFile.label" text="File" />
		<div id="fileUploadCell" title="${fileTooltip}">
			<ui:fileUpload uploadConversationId="${importForm.uploadConversationId}" conversationFieldName="uploadConversationId" single="true"
				cssClass="inlineFileUpload"	onSubmitCallback="function() {hideUploadValidationMessage();}" />
			<br/>
			<form:errors path="uploadConversationId" cssClass="invalidfield" htmlEscape="false"/>
		</div>

		<spring:message var="fileFormatTooltip" code="useradmin.importUsers.importFile.format.label" text="File format"/>
		<ul id="fileFormats" title="${fileFormatTooltip}">
			<c:forEach var="format" items="${importForm.fileFormats}">
				<li class="fileFormat_${format}">
					<label for="fileFormat_${format}">
						<c:choose>
							<c:when test="${format == 'wordTable'}">
								<form:checkbox path="wordTableImport" id="fileFormat_${format}"/>
							</c:when>
							<c:otherwise>
								<form:radiobutton path="fileFormat" value="${format}" id="fileFormat_${format}"/>
							</c:otherwise>
						</c:choose>

						<img src="<c:url value='${format.iconURL}'/>"></img>
						<spring:message code="useradmin.importUsers.importFile.format.${format}.label" />
					</label>
					<div class="fileFormatExplanation">
						<c:if test="${format == 'word' && hasTrackerMandatoryFields}">
							<div class="warning" id="mandatoryFieldWarning">
								<spring:message code="word.import.mandatory.field.warning" arguments="${ui:removeXSSCodeAndHtmlEncode(trackerCustomizeUrl)}"></spring:message>
							</div>
						</c:if>
						<spring:message code="useradmin.importUsers.importFile.format.${format}.explanation" />
					</div>

					<div class="visibilityChanges visibleFor_${format}">
						<c:if test="${format == 'excelCSV'}">
							<c:catch><jsp:include page="./options_${format}.jsp"/></c:catch>
						</c:if>
					</div>
				</li>
			</c:forEach>
		</ul>
</div>

</form:form>
<script type="text/javascript">
	function updateFieldsVisibility(ignoreWarmings) {
		var fileFormatSelected=$("form input:radio[name='fileFormat']:checked")[0];
		// all dom elements which show/hide when the file-format changes are marked with the visibilityChanges css-class
		// showing and hiding them depending on the selection, the visibleFor_.... css class is used as marker
		$(".visibilityChanges").each(function() {
			if (fileFormatSelected && $(this).hasClass("visibleFor_" + fileFormatSelected.value)) {
				$(this).show();
			} else {
				$(this).hide();
			}
		});

		var hasFiles = uploaderExtensions.hasFiles($(".qq-uploader").first());

		var hasError = $("#globalMessages").is(":visible");
		if (ignoreWarmings) {
			hasError = false;
		}

		var nextDisabled = !hasFiles || (hasFiles && hasError);
		var wordImportTableChecked = $("#fileFormat_wordTable").is(":checked");
		if (fileFormatSelected && fileFormatSelected.value == "word" && $("#mandatoryFieldWarning").length > 0 && !wordImportTableChecked) {
			nextDisabled = true;
		}
		$("#_eventId_next").toggleClass("disabledButton", nextDisabled).prop("disabled", nextDisabled);
	};

	$("form input:radio[name='fileFormat']").click(function() {
		updateFieldsVisibility(true);
	});
	$(updateFieldsVisibility);

	function hideUploadValidationMessage() {
		$("#fileUploadCell .invalidfield").hide();
	}

	function hideGlobalMessages() {
		$("#globalMessages").hide();
	}

	// subscribe to the event when file has been uploaded, and try to be smart about what kind of file has
	// been uploaded and select the appropriate type
	$("#fileUploadCell .fileUpload_dropZone").bind("onUploadComplete", function(event, id, fileName, responseJSON) {
		hideGlobalMessages();
		fileName = fileName.toLowerCase();
		if (fileName.match(/\.csv$/) /* file name ends with csv, the mime type can not be used as it suggests excel */) {
			// CSV
			$("#fileFormat_excelCSV").click();
		} else {
			var mimeType = responseJSON.mimeType;
			mimeType = mimeType == null ? "" : mimeType.toLowerCase();

			if (mimeType.indexOf("/xml") != -1 || mimeType == "application/vnd.ms-project") {
				// ms-project
				$("#fileFormat_msProject").click();
			} else if (mimeType.indexOf("excel") != -1 || mimeType.indexOf("spreadsheet") != -1) {
				// excel
				$("#fileFormat_excel").click();
			} else {
				// check if this is a valid word document (not word 2007)
				if (mimeType !== "application/vnd.openxmlformats-officedocument.wordprocessingml.document" && mimeType !== "application/zip") {
					$("#globalMessages>div>ul>li").remove(); //remove all warnings and errors
					$("#globalMessages>div.warning").hide(); //hide warnings div
					GlobalMessages.showErrorMessage(i18n.message("error.word2007.import.from.unsupported.mimetype", fileName));
					$("#globalMessages").show();
				}

				if (mimeType.indexOf("zip") != -1) {
					$("#fileFormat_doors").click();
				} else {
					// word: mostly using this, because this can read plain-text formats, RTFs and similar
					$("#fileFormats>li").first().find('label').click();
				}
			};
		};
		updateFieldsVisibility();
	}).bind("onChange", function(event) {
		updateFieldsVisibility();
	});

	// handle when removing the uploaded file
	$("#fileUploadCell").click(function(e, a) {
		if ($(e.target).hasClass("qq-upload-remove")) {
			// removing the file
			hideGlobalMessages();
			updateFieldsVisibility();
		}
	});

	$("#fileFormat_wordTable").change(function() {
		var mandatoryFieldWarning = $("#mandatoryFieldWarning");
		if (mandatoryFieldWarning.length > 0) {
			if ($(this).is(":checked")) {
				mandatoryFieldWarning.hide();
			} else {
				mandatoryFieldWarning.show();
			}
		}
		updateFieldsVisibility(true);
	});
</script>
