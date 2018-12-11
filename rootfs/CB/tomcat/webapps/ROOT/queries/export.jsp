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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%@page import="com.intland.codebeamer.persistence.dto.base.DescribeableDto"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="java.util.Map" %>

<meta name="decorator" content="popup"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="trackersModule newskin" />

<link rel="stylesheet" href="<ui:urlversioned value='/queries/queries.less' />" type="text/css" media="all" />

<ui:actionMenuBar>
	<spring:message code="queries.export.title" text="Export Queries"/>
</ui:actionMenuBar>

<spring:message var="exportButton" code="tracker.issues.exportToWord.export.button"/>
<spring:message var="cancelButton" code="button.cancel"/>

<form id="exportForm"  action="${pageContext.request.contextPath}/proj/queries/export.spr" method="POST">
  <input type="hidden" name="cbQl" value="<c:out value="${cbQl}"/>" />
  <input type="hidden" name="queryId" value="<c:out value="${queryId}"/>" />
  <input type="hidden" name="fields" value="<c:out value="${fields}"/>"/>
  <input type="hidden" name="releaseId" value="<c:out value="${releaseId}"/>"/>
  <input type="hidden" name="releaseTrackerId" value="<c:out value="${releaseTrackerId}"/>"/>
  <input type="hidden" name="sprintHistory" value="<c:out value="${sprintHistory}"/>"/>
  
  <ui:actionBar>
    &nbsp;&nbsp;<input type="submit" class="button" value="${exportButton}" />
    <input type="button" class="button cancelButton" value="${cancelButton}" onclick="inlinePopup.close(); return false;" />
  </ui:actionBar>

  <div class="contentWithMargins">

    <div class="exportBlock">
      <label for="excelExport1" class="exportKind">
      	<input type="radio" id="excelExport1" name="excelExport" value="1" checked>
        <ui:urlversioned value="/images/icon_excel_export2_green.png" var="excelExportIconUrl"/>
        <img src="${excelExportIconUrl}"/>
        <spring:message code="queries.export.excel.simple.label" />
      </label>
      <div class="exportExplanation">
        <spring:message code="queries.export.excel.simple.explanation" />
      </div>
    </div>

    <div class="exportBlock">
      <label for="excelExport3" class="exportKind">
      	<input type="radio" id="excelExport3" name="excelExport" value="3">
        <ui:urlversioned value="/images/icon_excel_export2_green.png" var="excelExportIconUrl"/>
        <img src="${excelExportIconUrl}"/>
        <spring:message code="queries.export.excel.template.label" />
      </label>
      <div class="exportExplanation">
        <spring:message code="queries.export.excel.template.explanation" />
      </div>
      <div class="templateSelection">
      	<div class="multiselect-container">
	   		<select id="projectSelector" name="project">
				<optgroup label="<spring:message code="recent.projects.label"/>">
					<c:forEach items="${projects.get('recent')}" var="project">
						<% String name = (String) ((Map) pageContext.getAttribute("project")).get("name");%>
						<option value="${project.get('id')}">
							<c:out value="<%= StringUtils.abbreviate(name, 40) %>"></c:out>
						</option>
					</c:forEach>
				</optgroup>
				<optgroup label="<spring:message code="my.open.issues.all.projects"/>">
					<c:forEach items="${projects.get('all')}" var="project">
						<% String name = (String) ((Map) pageContext.getAttribute("project")).get("name");%>
						<option value="${project.get('id')}">
							<c:out value="<%= StringUtils.abbreviate(name, 40) %>"></c:out>
						</option>
					</c:forEach>
				</optgroup>
			</select>
		</div>
		<div class="multiselect-container">
			<select id="templateSelector" name="template">
				<c:forEach items="${templateNames}" var="template">
				<% DescribeableDto template = (DescribeableDto) pageContext.getAttribute("template");%>
					<option value="${template.name}">
						<c:out value="<%= StringUtils.abbreviate(template.getName(), 40) %>"></c:out>
					</option>
				</c:forEach>
			</select>
		</div>

		<div class="upload-container">
			<ui:fileUpload conversationFieldName="officeExportUploadConversationId" uploadConversationId="${uploadConversationId}"
				single="true" dndControlMessageCode="tracker.issues.exportToWord.roundtrip.export.upload.template"/>
		</div>
      </div>

    </div>
  </div>

</form>

<script type="text/javascript">

$(function() {

	var $projectSelector = $('#projectSelector');
	var $templateSelector = $('#templateSelector');

	function initMultiselect($selector) {
		$selector.multiselect({
			multiple: false,
			selectedList: 1,
			minWidth: 300,
			// open above the select list
			position: {
				my: 'left bottom',
				at: 'left top'
			},
			open: function(event, ui) {
				$(".ui-multiselect-filter input").first().focus();
			}
		}).multiselectfilter({
			placeholder: "<spring:message code='multiselectfilter.text'/>"
		});
	}


	$('#projectSelector').change(function(e){
		var projectId = $(e.target).val();
		var select = $('#templateSelector');

		$.get(contextPath + "/proj/queries/projectTemplates.spr?projectId="+projectId, function(data) {
			  var abbrLength = 40;
			  var json = JSON.parse(data);
			  var options = "";
			  for (var i = 0; i < json.length; i++) {
				  var trimmedName = json[i].trim();
				  var abbrName = trimmedName.length > abbrLength ? trimmedName.substring(0, abbrLength - 3) + "..." : trimmedName;
				  options += '<option value="' + trimmedName + '">' + abbrName + '</option>';
			  }
			  select.empty().append(options);
			  initMultiselect($templateSelector);
		});

	});

	$('#exportForm').submit(function() {
		ajaxBusyIndicator.showBusyPage();
		return true;
	});

	$('#excelExport1, #excelExport2').click(function(e) {
		$('.templateSelection').hide();
	});

	$('#excelExport3').click(function(e) {
		$('.templateSelection').show();
	});

	var $uploader = $('#officeExportUploadConversationId_dropZone');

	$uploader.click(function(e) {
		if ($(e.target).hasClass("qq-upload-remove")) {
			$projectSelector.multiselect("enable");
			$templateSelector.multiselect("enable");
		}
	});
	$uploader.bind("onUploadComplete", function(event, id, fileName, responseJSON) {
		var extension = "";
		try {
			extension = fileName.split('.').pop().toLowerCase();
		} catch (e) {
			//
		}
		if (extension != "xlsx") {
			$uploader.find(".qq-upload-list").empty();
			showFancyAlertDialog(i18n.message("queries.export.template.file.extension.warning"));
			return false;
		}
		if (responseJSON.success) {
			$projectSelector.multiselect("disable");
			$templateSelector.multiselect("disable");
		}
	});

	initMultiselect($projectSelector);
	initMultiselect($templateSelector);
});

</script>
