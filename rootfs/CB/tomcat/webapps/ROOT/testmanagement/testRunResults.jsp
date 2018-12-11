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
<%@page import="com.intland.codebeamer.controller.dndupload.UploadStorage"%>
<%@page import="org.springframework.context.ApplicationContext"%>
<%@page import="com.intland.codebeamer.persistence.dto.UserDto"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ page import="com.intland.codebeamer.manager.testmanagement.TestRun"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%
	TrackerItemDto testRunItem = (TrackerItemDto) pageContext.findAttribute("testRunItem");

    UserDto user = ControllerUtils.getCurrentUser(request);
    ApplicationContext ctx = ControllerUtils.getSpringDispatcherServletContext(request);

    TestRun testRun = TestRun.cast(testRunItem, user, ctx);
    pageContext.setAttribute("testRun", testRun);
%>

 <c:if test="${testRun.isTestSetRun()}"> <%-- only show the details if this is a TestSetRun --%>

	<%--The wiki markup for TestRun's results --%>
	<c:set var="testRunResultsWiki">
	 [{TestRunResults<c:if test="${not empty testRunResultsParams}"> ${testRunResultsParams}</c:if>}]
 	</c:set>
	 <c:choose>
		 <c:when test="${loadOnlyPlugin}">
			 <tag:transformText owner="${testRunItem}" value="${testRunResultsWiki}" format="W" />
		 </c:when>
		 <c:otherwise>

			 <c:set var="uploadPart">
				 <style type="text/css">

					 .testRunResultsPlugin .testRunSummaryTable, .testRunResultsPlugin .testRunDescription {
						 display: none;
					 }

					 #file-upload {
						 margin-left: 5px;
					 }

					 .file-upload-container {
						 margin-left: 8px;
					 }

					 .file-upload-container .qq-upload-button {
						 margin-right: 1em;
						 -webkit-border-radius: 22px;
						 -moz-border-radius: 22px;
						 border-radius: 22px;
						 border: dashed 3px #DDD;
					 }

					 .file-upload-container .qq-upload-icon {
						 display: inline-block;
						 vertical-align: top;
						 float: none;
					 }

					 .file-upload-container .qq-upload-text {
						 display: inline-block;
						 float: none;
					 }

					 .file-upload-container .qq-uploader {
						 white-space: nowrap;
					 }

					 .file-upload-container .qq-upload-list {
						 padding-top: 15px;
						 margin-left: 0px;
					 }

					 .qq-upload-list li {
						 margin-left: 15px;
					 }
				 </style>
				 <c:if test="${not empty userHasPermissionToRunTestRun && userHasPermissionToRunTestRun}">
					 <c:url var="uploadUrl" value="/testmanagement/ajax/excelimport.spr" />
					 <script type="text/javascript">
						 var uploader = $("#uploadExcelConversationId_dropZone");

						 var layoutFix = function() {
							 uploader.find(".qq-upload-list").addClass("qq-upload-list-has-files"); // layout fix
						 };

						 layoutFix();
						 setTimeout(function() {
							 layoutFix(); // again, for IE8
						 }, 500);

						 jQuery(function($) {
							 $("div.file-upload-container").bind("DOMNodeInserted",function(){
								 if ($("ul.qq-upload-list.qq-upload-list-has-files > li").length > 0) {
									 $("#uploadButton").removeAttr('disabled');
								 }
							 });
							 $("div.file-upload-container").bind("DOMNodeRemoved",function(){
								 setTimeout(function() {
									 if ($("ul.qq-upload-list.qq-upload-list-has-files > li").length == 0) {
										 $("#uploadButton").attr('disabled','disabled');
									 }
								 }, 200);
							 });
							 $("#uploadButton").click(function() {
								 if (!isFileUploadsFinished()) {
									 return;
								 }

								 var files = $("ul.qq-upload-list.qq-upload-list-has-files > li");
								 if (!files.length || files.length == 0) {
									 return;
								 }
								 ajaxBusyIndicator.showProcessingPage();
								 $.ajax({
									 url: '${uploadUrl}' + '?runId=' + $("#runId").val() + '&uploadConversationId=' + $("input[name='uploadExcelConversationId']").val(),
									 type: 'GET',
									 async: false,
									 cache: false,
									 contentType: false,
									 processData: false,
									 success: function (data) {
										 var response = $.parseJSON(data);
										 if (response.success == "true") {
											 window.top.location.reload();
										 } else {
											 ajaxBusyIndicator.close()
											 showFancyAlertDialog(response.message, null, "200px", function() {
												 $("#uploadExcelConversationId_dropZone").find("a.qq-upload-remove").each(function() {
													 this.click(); // deliberately using native click method because jQuery can only trigger click events that are attached by itself
												 });
											 });
										 }

									 },
									 error: function(){
										 ajaxBusyIndicator.close()
										 showFancyAlertDialog("<spring:message code='testmanagement.import.error' />", null, "200px", function() {
											 $("#uploadExcelConversationId_dropZone").find(".qq-upload-remove").each(function() {
												 this.click(); // deliberately using native click method because jQuery can only trigger click events that are attached by itself
											 });
										 });
									 }
								 });
							 });

							 if ('${testRun.testRunStatus}' == 'SUSPENDED') {
								 //$("#uploadFormDiv").show();
								 $("#uploadFormDiv").css("display","inline-block")
							 }
						 });
					 </script>

					 <div id="uploadFormDiv" style="display: none; vertical-align: top;">
						 <form id="uploadFileForm" name="uploadFileForm" enctype="multipart/form-data" method="post">
							 <input type="hidden" value="${testRunItem.id}" name="runId" id="runId" />
							 <div class="file-upload-container" style="display: inline-block;">
								 <ui:fileUpload single="true" conversationFieldName="uploadExcelConversationId" uploadConversationId="<%= UploadStorage.newConversationId() %>"
												dndControlMessageCode="testmanagement.import.upload.message"/>
							 </div>
							 <input type="button" value="<spring:message code='testmanagement.import.button' />" name="upload" id="uploadButton" style="display: inline-block; vertical-align: top; position: relative; top: 13px;" />
						 </form>
					 </div>
				 </c:if>
			 </c:set>


			 <div class="contentWithMargins" style="margin-left: 0px;">

					 <%-- JSP fragment displays TestRun's result report: practically everything here is rendered by the TestRunResults wiki plugin ! --%>
				 <tag:catch>
					 <c:set var="ajax" value="<%=ControllerUtils.isAjaxRequest(request)%>" />
					 <c:set var="loadWithAjax" value="${testRunItem.children.size() > 20}" /> <%-- only load with ajax if it is not small TestSetRun --%>
					 <c:choose>
						 <c:when test="${loadWithAjax && (! ajax)}">
							 ${uploadPart}

							 <div id="testRunResultsAjaxPlaceHolder"><%--TestRun's results will be loaded here via ajax --%>
								 <img title="<spring:message code='ajax.loading' />" src="<ui:urlversioned value='/images/ajax_loading_horizontal_bar.gif'/>" />
							 </div>

							 <script type="text/javascript">
								 $(function() {
									 $("#testRunResultsAjaxPlaceHolder").load(contextPath + "/ajax/testrun/testRunResults.spr?task_id=${testRunItem.id}");
								 });
							 </script>

						 </c:when>
						 <c:otherwise>
							 <c:if test="${! loadWithAjax}">
								 ${uploadPart}
							 </c:if>

							 <spring:message var="label" code="testrun.details.run.results" />
							 <ui:collapsingBorder label="${label}" cssClass="relations-box separatorLikeCollapsingBorder" open="true" >
								 <%--
										   <c:if test="${! testRun.isTestRunsMissing()}">
										   <!-- test run progress display -->
										 <c:if test="${testRunTestCases != null}">
											 <jsp:include page="/testmanagement/testRunProgress.jsp" flush="true"/>
										 </c:if>
										 </c:if>
								 --%>

								 <tag:transformText owner="${testRunItem}" value="${testRunResultsWiki}" format="W" />
							 </ui:collapsingBorder>

							 <script type="text/javascript">
								 // move the upload widget behind the pie chart
								 $("table.testRunProgressCounts")
									 .css("display", "inline-block")
									 .after($("#uploadFormDiv"));
							 </script>
						 </c:otherwise>
					 </c:choose>
				 </tag:catch>

			 </div>

		 </c:otherwise>
	 </c:choose>

 </c:if>
