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
<%@page import="com.intland.codebeamer.text.excel.POIExcelUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="log" prefix="log" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" %>

<%-- JSP fragment renders the preview of the mapping --%>
<link rel="stylesheet" href="<ui:urlversioned value='/bugs/importing/includes/importPreviewFragment.less' />" type="text/css" media="all" />

<%-- Show the Imported Data --%>
<jsp:useBean id="importForm" beanName="importForm" scope="request" type="com.intland.codebeamer.flow.form.ImportForm" />
<c:set var="columnToImportFieldsMappings" value="${importForm.columnToImportFieldsMappings}" />

<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" id="previewTable" class="displaytag">
<TR CLASS="head">
	<TH class="checkbox-column-minwidth">
		<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
		<INPUT TYPE="CHECKBOX" TITLE="${toggleButton}" NAME="SELECT_ALL" VALUE="on"
				ONCLICK="setAllStatesFrom(this, 'rowsSelectedForImport'); updateAllRowStyles();" checked="checked" style="margin:0;" id="selectAll">
		<input type="hidden" value="_rowsSelectedForImport" value="-1" />

		<spring:message code="issue.import.row.label" />
	</TH>
	<tag:joinLines>
	<c:forEach var="mapping" items="${columnToImportFieldsMappings}">
		<TH CLASS="textData columnSeparator">
			<c:set var="fieldLabels" value="${importForm.getFieldLabels(mapping.field)}" />
			<div class="columnField"><c:out value="${fieldLabels}" /></div>

			<c:set var="column" value="${mapping.column}" />
			<%
				String colRef = "";
				try {
					int column = ((Integer) pageContext.getAttribute("column")).intValue();
					colRef = POIExcelUtils.convertNumToColString(column);
				} catch (Throwable th) {
				}
				pageContext.setAttribute("colRef", colRef);
			%>
			<div class="columnIndex"><spring:message code="issue.import.mapping.column" text="Column"/> ${colRef} (#${column})</div>
		</TH>
	</c:forEach>
	</tag:joinLines>
</TR>

<spring:message var="checkboxTitle" code="tracker.issues.import.select.imported.items" />
<spring:message var="updateBadge" code="tracker.issues.import.update.badge" />
<spring:message var="updateBadgeTooltip" code="tracker.issues.import.update.badge.tooltip" />
<spring:message var="insertBadge" code="tracker.issues.import.insert.badge" />
<spring:message var="insertBadgeTooltip" code="tracker.issues.import.insert.badge.tooltip" />
<spring:message var="excelValueTooltip" code="tracker.issues.import.excel.value.tooltip" />
<spring:message var="cbValueTooltip" code="tracker.issues.import.cb.value.tooltip"/>
<c:set var="excelImg">
	<img src="<ui:urlversioned value='images/newskin/action/icon_excel_export_blue.png' />" title="${excelValueTooltip}" />
</c:set>
<c:set var="cbImg">
	<img src="<ui:urlversioned value='/images/favicon.ico'/>" title="${cbValueTooltip}"/><%--Current value &rarr; --%>
</c:set>

<c:set var="hiddenRows" value="0" />
<c:set var="numRows" value="0" />

<c:forEach items="${importForm.conversionResultsAsMap}" var="row" varStatus="status">
	<c:set var="numRows" value="${numRows + 1}" />
	<c:set var="rowIdx" value="${row.key}" />
	<c:set var="rowMeta" value="${importForm.rowMetaData[rowIdx]}" />

	<c:set var="trCSSClass" value="${status.index % 2 == 0 ? 'even' : 'odd' } ${rowMeta.updateRow ? 'updateRow' : 'insertRow'}" />
	<c:set var="saveError" value="${importForm.saveErrors[rowIdx]}" />

  <c:choose>
	<c:when test="${(! rowMeta.updateRow) || rowMeta.dataChanged || rowMeta.withConversionError}"> <%-- don't show rows with no changes, but show rows with conversion errors --%>
		<c:if test="${(! empty saveError) || (! empty rowMeta.failedWithError)}">
			<tr>
				<td class="saveError" colspan="99">
					<c:if test="${! empty saveError}">
						<span class="invalidfield"><spring:message code="issue.import.save.error.on.row" arguments="${saveError.errorMessage}" htmlEscape="true" argumentSeparator="<%=null%>" /></span>
					</c:if>
					<c:if test="${(! empty rowMeta.failedWithError)}">
						<span class="invalidfield"><c:out value="${rowMeta.failedWithError}" /></span>
					</c:if>
				</td>
			</tr>
		</c:if>
	<tr valign="top" class="${trCSSClass}">
		<td class="checkbox-column-minwidth">
			<ct:call return="rowSelected" object="${importForm.rowsSelectedForImport}" method="contains" param1="${rowIdx}"/>
			<input type="checkbox" name="rowsSelectedForImport" value="${rowIdx}" ${rowSelected ? 'checked="checked"' : '' } title="${checkboxTitle}" />

			<span class="rowIdx">${rowIdx}</span>
			${excelImg}

			<c:set var="badge">${rowMeta.updateRow ? updateBadge : insertBadge}</c:set>
			<c:catch>
				<c:if test="${rowMeta.updateRow && (! empty rowMeta.target)}">
					<c:url var="targetUrl" value="${rowMeta.target.urlLink}" />
					<c:set var="badge"><a href="${targetUrl}" target="_blank">${badge}</a></c:set>
				</c:if>
			</c:catch>
			<%-- only show the IMPORT badge for the new rows/data! --%>
			<c:if test="${! rowMeta.updateRow}">
				<label class="badge" title="${rowMeta.updateRow ? updateBadgeTooltip : insertBadgeTooltip}" >${badge}</label>
			</c:if>

<%--
			<pre>
				rowMeta: ${rowMeta}
				saveError: ${saveError}
			</pre>
--%>
		</td>
		<c:forEach var="mapping" items="${columnToImportFieldsMappings}"><tag:joinLines>
			<c:set var="column" value="${mapping.column}" />
			<c:set var="conversionResult" value="${row.value[mapping]}" />
			<c:set var="conversionError" value="${conversionResult.conversionError}" />
			<c:set var="dataChanged" value="${conversionResult.dataChanged}" />

			<c:set var="hasError" value="${not empty conversionError}" />
			<c:set var="notUpdateableData" value="${conversionResult.notUpdateableData}" />

			<%
				// render the cell's reference as it appears in Excel like "B3"
				String cellRef = "";
				try {
					int row = ((Integer) pageContext.getAttribute("rowIdx")).intValue() -1;
					int col = ((Integer) pageContext.getAttribute("column")).intValue();
					cellRef = POIExcelUtils.getCellReferenceAsString(row, col);
				} catch (Throwable th) {
				}
				pageContext.setAttribute("cellRef", cellRef);
			%>

			<spring:message var="cellTooltip" code="issue.import.cell.tooltip" arguments="${cellRef},${rowIdx},${column}" />
			<td class='textDataWrap columnSeparator ${hasError ? "hasError" : ""} ${dataChanged ? "dataChanged" : ""} ${notUpdateableData ? "notUpdateableData" :""}' title="${cellTooltip}">
				<c:choose>
					<c:when test="${! empty conversionResult.modifiedIssueValue}">${conversionResult.modifiedIssueValue}</c:when>
					<c:otherwise>
						<c:set var="convertedValue" value="${conversionResult.convertedValue}" />
						<c:out value="${convertedValue}" default="--" />
					</c:otherwise>
				</c:choose>
				<c:if test="${hasError}"><span class="invalidfield"><c:out value="${conversionError}" /></span></c:if>
			</td>
			</tag:joinLines>
		</c:forEach>
	</tr>

	<c:if test="${rowMeta.updateRow && rowMeta.dataChanged}">
		<%-- showing the current values in CB which will be overwritten when saving --%>
		<tr valign="top" class="${trCSSClass} originalValueRow">
			<td class="checkbox-column-minwidth">
				<c:catch>
					<c:choose>
						<c:when test="${! empty rowMeta.target}">
							<c:url var="targetUrl" value="${rowMeta.target.urlLink}" />
							<a href="${targetUrl}" target="_blank">${cbImg}</a>
						</c:when>
						<c:otherwise>${cbImg}</c:otherwise>
					</c:choose>
				</c:catch>
			</td>
			<c:forEach var="mapping" items="${columnToImportFieldsMappings}"><tag:joinLines>
				<c:set var="conversionResult" value="${row.value[mapping]}" />
				<c:set var="dataChanged" value="${conversionResult.dataChanged}" />
				<td class="textDataWrap columnSeparator ${dataChanged ? 'dataChanged' : ''}"><c:if test="${dataChanged && ! empty conversionResult.originalIssueValue}">${conversionResult.originalIssueValue}</c:if></td>
			</tag:joinLines></c:forEach>
		</tr>
	</c:if>
   </c:when>
   <c:otherwise>
   		<c:set var="hiddenRows" value="${hiddenRows + 1}" />
   </c:otherwise>
  </c:choose>
</c:forEach>

</TABLE>

<input type="hidden" name="_rowsSelectedForImport" value="" /><%-- hidden input for checkboxes when none is selected --%>

<span class="information" id="noRowsVisibleExplanation" style="${numRows > 0 ? 'display: none;' : ''} margin-top: 10px;">
	<spring:message code="tracker.issues.import.no.data.visible.explanation" text="No rows is visible because there is no change found in the import data !"/>
</span>

<div style="margin-top: 10px;">
  	<spring:message code="${hiddenRows == 0 ? 'tracker.issues.import.count.rows' : 'tracker.issues.import.count.rows.with.skipped'}" arguments="${numRows},${hiddenRows}" />
</div>

<script type="text/javascript">
	function updateRowStyle() {
		var checked = $(this).is(":checked");
		var $row = $(this).closest("tr");
		$row.toggleClass("selectedRow", checked);
	}
	function updateAllRowStyles() {
		$("[name='rowsSelectedForImport']").each(updateRowStyle);
		$("#previewTable tr").each(function() {
			var changed = $(this).find(".dataChanged").length > 0;
			$(this).toggleClass("dataChanged", changed);
			$(this).toggleClass("noDataChanged", ! changed);
		});
	}
	$("[name='rowsSelectedForImport']").click(updateRowStyle).change(updateRowStyle);
	setAllStatesFrom($("#selectAll")[0], 'rowsSelectedForImport');
	$(updateAllRowStyles);

	function selectOnlyChangedRows() {
		$("[name='rowsSelectedForImport']").each(function() {
			var $row = $(this).closest("tr");
			var changed = $row.find(".dataChanged").length > 0;
			$(this).attr('checked', changed);
		});
		updateAllRowStyles();
	}

	$(function() {
		// change all links to open in a new window
		$("#previewTable a").prop("target", "_blank");
	});

	$(function() {
		// show the not-updatable hint if there is any not-updatable cells there ?
		if ($("#previewTable .notUpdateableData").length > 0) {
			$("#notUpdateableDataExplanation").show();
		};
	});

	// show warning when trying to submit without any selection
	$(function() {
		var $finishButton = $("input[name='_eventId_next']").first();
		if ($finishButton.length >0) {
			$finishButton.click(function() {
				var selection = $("input[name='rowsSelectedForImport']:checked").length;
				if (selection == 0) {

					alert(i18n.message('no.item.selected'));
					return false;
				}
			});
		}
	});

	function uncheckAllSaveErrors() {
		var $saveErrors = $(".saveError");
		$saveErrors.each(function() {
			var $relatedRow = $(this).closest("tr").next();
			$relatedRow.find("input[name='rowsSelectedForImport']").prop('checked', false);
		});
		alert(i18n.message("issue.import.save.error.alert", $saveErrors.length));
	}
</script>
