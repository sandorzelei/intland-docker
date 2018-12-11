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

<span class="excelParameterConfig">

<div class="hint" style="margin-bottom: 5px;">
<c:url var="dirURL" value="${parameterConfig.directoryURL}"/>
<spring:message code="testing.parameters.storage.ExcelInDocumentManagementParameterStorage.hint1" arguments="${dirURL}" />
<br/>
<spring:message code="testing.parameters.storage.ExcelInDocumentManagementParameterStorage.hint2" text="The rules are:" />
<ul>
 <li><spring:message code="testing.parameters.storage.ExcelInDocumentManagementParameterStorage.option1" text="Only the first sheet is used from the Excel sheet"/></li>
 <li><spring:message code="testing.parameters.storage.ExcelInDocumentManagementParameterStorage.option2" text="The first row is used as parameter names, the rows below are used as parameter values"/></li>
</ul>
</div>
<spring:message code="testing.parameters.storage.ExcelInDocumentManagementParameterStorage.choose" text="Choose an Excel sheet:"/>
<form:select id="selectedDocumentId" path="selectedDocumentId" cssStyle="width: 20em; margin-left: 1em;">
	<spring:message code="None" var="NoneLabel" />
	<form:option value="-1" title="${NoneLabel}">${NoneLabel}</form:option>
	<c:set var="selectedDoc" value="${parameterConfig.selectedDocument}" />
	<c:if test="${!empty selectedDoc}">
		<c:set var="name"><c:out value="${selectedDoc.name}"/></c:set>
		<form:option value="${selectedDoc.id}" selected="selected" title="${name}" >${name}</form:option>
	</c:if>
</form:select>

<script type="text/javascript">
  function initMultiSelect() {
	  var SEL = "#selectedDocumentId";

	  var multiselect = $(SEL).multiselect({
		  multiple: false,
		  autoOpen: false,
		  open: function() {
			  populateExcelParameterFiles();
		  },
		  "selectedText": function(numChecked, numTotal, checked) {
			  return $(checked).attr("title");
		  }
	  });

	  multiselect.multiselectfilter();

	  function populateExcelParameterFiles() {
		  var url = contextPath + "/ajax/testmanagement/getExcelParameterFiles.spr";
		  $.get(url).success(function(data) {
			  // remove previous options, but remember which was selected and select that
			  var $select = $(SEL);
			  var selectedId = $select.find("option:selected").val();
			  $select.find("option").each(function() {
				  var val = $(this).val();
				  if (val != "-1") { // remove all except the None
					  $(this).remove();
				  }
			  });

			  $.each(data, function(name, id) {
				  var opt  = $('<option>', { value : id }).text(name).attr("title", name);
				  if (id == selectedId) {
					 opt.attr("selected", "selected");
				  }
				  $select.append(opt);
			  });

			  // refresh the control
			  multiselect.multiselect("refresh");
		  })
	  }
  }

  $(initMultiSelect);
</script>

</span>
