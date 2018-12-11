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

<meta name="decorator" content="popup"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="trackersModule newskin" />

<style type="text/css">
  .exportKind {
    display: block;
    font-size: 16px;
    font-weight: bold;
    margin-bottom: 16px;
  }
  .exportExplanation {
    margin: 0 20px 20px 25px;
  }
  .templateSelection {
    display: none;
  }
</style>

<script type="text/javascript">
  function showBusy() {
	  ajaxBusyIndicator.showBusyPage("tracker.issues.exportToWord.wait", false, { width: "32em"});
	  $('.container-close', window.parent.document).hide();
  }

  $(function() {
    var templateDiv = $('.templateSelection');
	var $templateSelect = templateDiv.find("select");
    $('input[name="exportKind"]').change(function() {
      if ($(this).val() == 'simpleWordExport') {
    	filterTemplateFilesByType($templateSelect);
        templateDiv.show();
      } else {
        templateDiv.hide();
      }
    });

    var $uploader = $('#officeExportUploadConversationId_dropZone');
    $uploader.bind("onUploadComplete", function(event, id, fileName, responseJSON) {
  	  var extension = "";
  	  try {
  	  	extension = fileName.split('.').pop().toLowerCase();
  	  } catch (e) {
  	  alert(e);
  	  }
  	  if ( extension.indexOf("doc") == -1 ) {
  	  	$uploader.find(".qq-upload-list").empty();
  	  	showFancyAlertDialog(i18n.message("tracker.coverage.browser.export.word.warning"));
  	  	return false;
  	  }
  	  if (responseJSON.success) {
  	  	$projectSelector.multiselect("disable");
  	  	$templateSelector.multiselect("disable");
  	  }
    });
  });
</script>

<ui:actionMenuBar>
  <ui:breadcrumbs showProjects="false" >
    <span class="breadcrumbs-separator">&raquo;</span><ui:pageTitle prefixWithIdentifiableName="false">
    	<c:choose>
    		<c:when test="${isTestRunBrowserExport }">
    			<spring:message code="tracker.coverage.export.test.run.title"></spring:message>
    		</c:when>
    		<c:otherwise>
    		    <spring:message code="tracker.coverage.export.title" />
    		</c:otherwise>
    	</c:choose>
    </ui:pageTitle>
  </ui:breadcrumbs>
</ui:actionMenuBar>

<spring:message var="exportButton" code="tracker.issues.exportToWord.export.button"/>
<spring:message var="cancelButton" code="button.cancel"/>

<form:form commandName="command">

  <ui:actionBar>
    &nbsp;&nbsp;<input type="submit" class="button" value="${exportButton}" onclick="showBusy(); return true;"/>
    <input type="button" class="button cancelButton" value="${cancelButton}" onclick="inlinePopup.close(); return false;" />
  </ui:actionBar>

  <div class="contentWithMargins">

    <div class="exportBlock">
      <label for="excelExport" class="exportKind">
        <form:radiobutton id="excelExport" path="exportKind" value="excelExport"/>
        <ui:urlversioned value="/images/icon_excel_export2_green.png" var="excelExportIconUrl"/>
        <img src="${excelExportIconUrl}"/>
        <spring:message code="tracker.traceability.browser.export.excel.title" text="Excel Export" />
      </label>
      <div class="exportExplanation">
        <spring:message code="tracker.traceability.browser.export.excel.explanation" />
      </div>
    </div>

    <div class="exportBlock">
      <label for="simpleWordExport" class="exportKind">
        <form:radiobutton id="simpleWordExport" path="exportKind" value="simpleWordExport"/>
        <ui:urlversioned value="/images/newskin/action/icon_word.png" var="wordExportIconUrl"/>
        <img src="${wordExportIconUrl}"/>
        <spring:message code="tracker.traceability.browser.export.word.title" text="Word Export" />
      </label>
      <div class="exportExplanation">
        <spring:message code="tracker.coverage.browser.export.word.explanation" />
      </div>
    </div>

   <jsp:include page="../../bugs/importing/includes/selectExportTemplateFragment.jsp" />

  </div>

</form:form>
