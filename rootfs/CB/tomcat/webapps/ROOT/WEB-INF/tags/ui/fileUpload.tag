
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
<%@ tag language="java" pageEncoding="UTF-8" %>
<%@ tag import="com.intland.codebeamer.controller.dndupload.UploadStorage"%>
<%@ tag import="com.intland.codebeamer.Config"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	Tag to render file drag-and-drop/ajax multi upload.

	Usage:
	* Add this tag inside a form tag with enctype="multipart/form-data"
	* In the onSubmit() event/method/buttons of the form *always* call
		the is isFileUploadsFinished() javascript method to check if the file upload has finished and populate the hidden field of the form
	* On the server-side:
		* bind the hidden field ${conversationFieldName} to the UploadedFileForm.uploadConversationId property
		* and call the UploadFileForm.handleUploadedFiles() method to process the uploaded files
--%>
<%@ attribute name="single" required="false" type="java.lang.Boolean" description="If only a single-fileupload is allowed. Defaults to false." %>
<%@ attribute name="conversationFieldName" required="false" description="The field name for the conversation" %>
<%@ attribute name="uploadConversationId" required="false" description="Unique id which groups the uploads belong to a single conversation. See UploadStorage class."%>
<%@ attribute name="getPreviouslyUploadedFiles" required="false" type="java.lang.Boolean" description="If the upload widget should try to get the previously uploaded files when initializing" %>
<%@ attribute name="elastic" required="false" type="java.lang.Boolean" description="If true, drop area will always be visible and fill its conatining window."%>
<%-- events --%>
<%@ attribute name="submitUrlOnComplete" required="false" description="Automatically submit (POST) to this url when all the uploads are complete. Must not be used with 'submitFormOnComplete'!" %>
<%@ attribute name="submitFormOnComplete" required="false" description="Automatically submit (POST) this form when all the uploads are complete. Must not be used with 'submitUrlOnComplete'!" %>
<%@ attribute name="onAllUploadsCompleteSuccessCallback" required="false" description="Callback function to execute when all uploads are completed" %>
<%@ attribute name="onSubmitCallback" required="false" description="Callback function to execute when a file is selected for upload" %>
<%@ attribute name="onCompleteCallback" required="false" description="Callback function to execute when all files are finished uploading" %>
<%-- style --%>
<%@ attribute name="cssClass" description="Optional css class added on dropzone" %>
<%@ attribute name="cssStyle" description="Optional css style added on dropzone" %>
<%@ attribute name="flatBox" required="false" description="If the appearance of the upload control is a flat box with only an icon" %>
<%@ attribute name="dndControlMessageCode" required="false" description="A message code to display as the text of the control" %>
<%@ attribute name="dndDropHereMessageCode" required="false" description="A message code to display as the text of the drag area" %>
<%-- wysiwyg --%>
<%@ attribute name="lazyInit" required="false" type="java.lang.Boolean" description="If the file-uploaded is initialized lazily (when the page is loaded). Defaults to true."%>
<%@ attribute name="ajax" required="false" type="java.lang.Boolean"%>
<%@ attribute name="placeholder" required="false" type="java.lang.Boolean" description="If true this is just a placeholder, no initializations scripts will be run"%>

<c:if test="${empty conversationFieldName}">
	<c:set var="conversationFieldName" value="uploadConversationId" />
</c:if>
<c:if test="${empty uploadConversationId}">
	<c:set var="uploadConversationId" value="<%=com.intland.codebeamer.controller.dndupload.UploadStorage.newConversationId()%>" />
	<c:set var="getPreviouslyUploadedFiles" value="false" />	<!-- this is a new conversation, don't try to download the previously-Uploaded-Files -->
</c:if>
<c:set var="uploadConversationId" ><c:out value='${uploadConversationId}'/></c:set> <%-- ensure this is html-escaped --%>
<input type="hidden" name="${conversationFieldName}" value="${uploadConversationId}" />

<div id="${conversationFieldName}_dropZone" class="fileUpload_dropZone ${cssClass}" style="display:none; ${cssStyle}">
	<h3><spring:message code="dndupload.dropFilesHere" text="Drop one or more files here"/></h3>
</div>

<c:set var="debug" value="<%=Config.isDevelopmentMode()%>" />

<%
	if (submitUrlOnComplete != null && submitFormOnComplete != null) {
		throw new IllegalArgumentException("Either ids parameter, or both the issue and label parameter must be provided!");
	}
%>

<c:set var="script">
<script type="text/javascript">
var codebeamer = codebeamer || {};
codebeamer.bindHandlerToUpload = function (elementId, onAllUploadsCompleteSuccessCallback, uploadConversationId, submitUrl, conversationFieldName, submitFormOnComplete) {

	if (submitFormOnComplete) {
		var submitForm = $("#" + submitFormOnComplete);
		submitUrl = submitForm.attr("action");
	}

	var uploader = $("#" + elementId);

	uploader.bind('onUploadComplete', function(event, id, fileName, responseJSON) {
		// when all uploads (on the page) are complete submit the form
		if (isFileUploadsFinished(false /*, "${conversationFieldName}" */)) {
			if (onAllUploadsCompleteSuccessCallback) {
				onAllUploadsCompleteSuccessCallback.call(uploadConversationId);
			}

			if (submitUrl && "" !== submitUrl) {
				//var submitUrl = "${submitUrlOnComplete}";
				var data = {};
				if (submitForm) {
					$.map(submitForm.serializeArray(), function(e) {
						data[e.name] = e.value;
					});
				}
				data["" + conversationFieldName] = uploadConversationId;
				jQuery.ajax({
					url: submitUrl,
					type: "POST",
					data: data,
					cache: false,
					async: true,
					success: function(data, textStaus, jqXHR) {
						// after the uploads are done reload the page
						var isInIframe = !!((window.location != window.parent.location));
						if (isInIframe) {
							window.parent.location.reload(true);
							inlinePopup.close();
						} else {
							location.reload(true);
						}
					},
					error: function(jqXHR, textStatus, errorThrown) {
						console.log("Failed to send files:" + textStatus +", error=" + errorThrown);
					}
				});
			}
		}
	});

};
(function(){
	// init fileupload
	var init = function() {
		try {
			var elementId = "${conversationFieldName}_dropZone";

			var uploaderInstance = uploaderExtensions.initFileUploader(elementId, '${uploadConversationId}', {
				<c:if test="${! empty dndControlMessageCode}">
					dndControlMessageCode: '${dndControlMessageCode}',
				</c:if>
				<c:if test="${! empty dndDropHereMessageCode}">
					dndDropHereMessageCode: '${dndDropHereMessageCode}',
				</c:if>
				<c:if test="${! empty single}">
					forcesingle: ${single},
				</c:if>
				debug: ${debug},
				<c:if test="${! empty flatBox}">
					flatBox: ${flatBox},
				</c:if>
				<c:if test="${! empty onSubmitCallback}">
		    		onSubmit: ${onSubmitCallback},
		    	</c:if>
				<c:if test="${! empty getPreviouslyUploadedFiles}">
					getPreviouslyUploadedFiles: ${getPreviouslyUploadedFiles},
				</c:if>
				integrateWithWysiwygEditor: false
			});

			<c:if test="${!empty onCompleteCallback}">
				if (typeof ${onCompleteCallback} != 'undefined') {
				    $("#" + elementId).bind("onUploadComplete", ${onCompleteCallback});
				}
			</c:if>

			<c:if test="${(!empty submitUrlOnComplete) || (!empty submitFormOnComplete) || (!empty onAllUploadsCompleteSuccessCallback)}">
			codebeamer.bindHandlerToUpload(elementId,
					<c:if test="${! empty onAllUploadsCompleteSuccessCallback}">${onAllUploadsCompleteSuccessCallback}</c:if><c:if test="${empty onAllUploadsCompleteSuccessCallback}">null</c:if>,
					"${uploadConversationId}", "${submitUrlOnComplete}", "${conversationFieldName}", "${submitFormOnComplete}");
		    </c:if>

			<c:if test="${elastic}">

			(function($) {
				var $window = $(window);
				var footerHeight = $("#footer").outerHeight();

				var uploader = $("#" + elementId).find(".qq-uploader");
				var uploaderButton = uploader.find(".qq-upload-button");
				var uploaderInput = uploaderButton.find("input");
				var dropArea = uploader.find(".qq-upload-drop-area");

				if (uploaderInput.is("[data-qq-xhr-supported]")) {
					uploader.closest(".fileUpload_dropZone").addClass("elastic");

					var adjustDropArea = throttleWrapper(function() {
						var d = $(".qq-upload-drop-area");
						var top = d.offset().top;
						var wh = $window.innerHeight();
						var newHeight = Math.max((wh - top - footerHeight - 20), 40);
						d.css("height", newHeight + "px");
					}, 25);
					adjustDropArea();
					$window.resize(adjustDropArea);

					uploaderButton.hide();

					uploader.find("span.qq-drop-here-label a").click(function() {
						uploaderInput.click();
						return false;
					});

					dropArea.addClass("qq-upload-drop-area-force-visible");
				}
			})(jQuery);

			</c:if>
		} catch (ex) {
			console.log("Exception in init-fileupload:" + ex);
		}
	};

	if (${empty placeholder || !placeholder}) {
		if (${empty lazyInit || lazyInit || elastic}) {
			$(function() {
				init();
			});
		} else {
			init();
		}
	}
})();

</script>
</c:set>

<c:choose>
	<c:when test="${ajax}">
		${script }
	</c:when>
	<c:otherwise>
		<ui:delayedScript>
			${script }
		</ui:delayedScript>
	</c:otherwise>
</c:choose>