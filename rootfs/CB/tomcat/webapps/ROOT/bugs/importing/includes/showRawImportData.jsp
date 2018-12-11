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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="callTag" prefix="ct" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" %>

<%--
	Shows a part of the raw import data when importing to issues/accounts
 --%>
<c:set var="nr_of_records" value="${fn:length(importForm.dataList)}" />
<c:set var="nr_of_columns" value="${fn:length(importForm.dataList[0])}" />

<fieldset style="overflow:auto;">
<legend><spring:message code="useradmin.importUsers.raw.data.legend"/></legend>
<c:set var="maxPreviewSize" value="50" />

<spring:message code="useradmin.importUsers.scanResult.message" text="Scanned <strong>{0}</strong> rows and <strong>{1}</strong> columns" arguments="${nr_of_records},${nr_of_fields}"/>
<c:if test="${nr_of_records gt maxPreviewSize}">
	<spring:message code="useradmin.importUsers.truncation.message" text="(The list below is truncated to <strong>{0}</strong> rows.)" arguments="${maxPreviewSize}"/>
</c:if>

<span class="hint" style="margin-left: 40px;">
	<spring:message code="useradmin.import.required.hint"></spring:message>
</span>

<spring:message var="allowMultiMappingTooltip" code="useradmin.import.multifield.hint"/>
<label for="allowMultiMapping" style="margin-left: 40px;" title="${allowMultiMappingTooltip}">
	<form:checkbox id="allowMultiMapping" path="allowMultiMapping" /><spring:message code="useradmin.import.multifield.label" />
</label>

<spring:message var="clearAllMappings" code="useradmin.import.clear.all.mappings" />
<input id="clearAllMappingsButton" type="button" class="button" onclick="clearAllMappings(); return false;" value='${clearAllMappings}'></input>
<span id="duplicateFieldSelectionWarning" class="warning" style="display: none;"></span>

<style type="text/css">
input[type="checkbox"], input[type="radio"] {
  vertical-align: text-bottom;
}

.mandatoryField, li.mandatoryField span {
	color: red !important;
}
#rawDataTable {
	width: 98%;
	cursor: pointer;
}

#rawDataTable th {
	vertical-align: top;
}

.columnToFieldMapping {
}
select.columnToFieldMapping {
	height: 10em;
	min-width: 15em;
}

/* hide the check-all checkbox for columns it is pointless here */
.ui-multiselect-menu .ui-multiselect-all {
	display: none !important;
}
..ui-multiselect-menu {
	min-width: 20em !important;
}

.dataRow td.indexColumn, .startImportAtRow {
	background-color: #ffffe0;
}

#clearAllMappingsButton {
	margin: 0 10px !important;
	font-size: 12px !important;
}

.dupicateFieldSelection {
    border: solid 2px red;
}
#duplicateFieldSelectionWarning {
    display: inline;
    background-position-y: 3px;
    margin-left:10px;
}

</style>

<spring:message var="startImportAtRowTooltip" code="useradmin.importUsers.startImportAtRow.tooltip" />

<c:choose>
<c:when test="${nr_of_columns > 0}">

<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" class="displaytag" id="rawDataTable" title="${startImportAtRowTooltip}">

	<spring:message var="tooltip" code="issue.import.mapping.tooltip" />
	<TR CLASS="head" title="${tooltip}">
		<TH class="columnSeparator"><spring:message code="issue.import.mapping.label" /></TH>

		<c:forEach begin="0" end="${nr_of_columns - 1}" var="columnIdx">
			<th class="textData columnSeparator">
				<form:select id="${fieldId}" path="columnToFieldMapping[${columnIdx}]"  multiple="${importForm.allowMultiMapping}" cssClass="columnToFieldMapping" >
					<form:option value="" label="--" />
					<c:set var="possibleMappings" value="${importForm.columnPossibleMappings[columnIdx]}" />
					<c:forEach var="fieldAndLabels" items="${possibleMappings}">
						<c:set var="fieldDescription" value="${fieldAndLabels}" />
						<c:set var="field" value="${fieldAndLabels.field}"/>
						<c:if test="${field.mandatory}">
							<c:set var="fieldDescription" value="* ${fieldDescription}" />
						</c:if>
						<form:option cssClass="${field.mandatory ? 'mandatoryField':''}"  value="${field.id}" label="${fieldDescription}"/>
					</c:forEach>
				</form:select>
			</th>
		</c:forEach>
	</TR>

	<c:forEach items="${importForm.dataList}" var="record" end="${maxPreviewSize - 1}" varStatus="loopStatus">
		<TR VALIGN="top" CLASS="${loopStatus.index % 2 == 0 ? 'even' : 'odd'}">

			<TD CLASS="textDataWrap columnSeparator mapping indexColumn"><c:out value="${loopStatus.index + 1}" /></TD>
			<c:forEach items="${record}" var="column">
				<c:set var="value" value="${column}"/>
				<c:if test="${importForm.converter != null}">
					<ct:call object="${importForm.converter}" method="convert" param1="${column}" param2="false" return="value"/>
				</c:if>
				<TD CLASS="textDataWrap columnSeparator"><c:out value="${value}" /></TD>
			</c:forEach>
		</TR>
	</c:forEach>
</TABLE>
</c:when>
	<c:otherwise>
		<div class="warning" style="margin-top:20px;">
			<spring:message code="errors.import.file.empty" text="No record found in the import file."/>
		</div>
	</c:otherwise>
</c:choose>
</fieldset>


<script type="text/javascript">
$(function() {
	//console.log("scrolling to top/left");
	$("html,body").scrollTop(0).scrollLeft(0);
});

function initMappingMultiSelect(refresh) {
	var multiple = $("#allowMultiMapping").is(':checked');

	var $selects = $("select.columnToFieldMapping");
	$selects.each(function() {
		var $select = $(this);

		if (refresh) {
			// destroy the old mutiselect so we can rebuild it
			$select.multiselectfilter('destroy').multiselect('destroy');
		}
		// convert the mapping select boxes to a nicer select widget
		$select.multiselect({
				multiple: multiple,
				selectedList: 99,
				noneSelectedText: "--",
				"classes" : "rawImportData"
			}).multiselectfilter();
	});

	detectWhenAFieldIsSelectedTwice();
}

function disableDescriptionFormatWhenDescriptionFormatIsMapped() {
    setTimeout(function() {
        var $selects = $("select.columnToFieldMapping");

        var DESCRIPTION_FORMAT_ID = <%=TrackerLayoutLabelDto.DESCRIPTION_FORMAT_ID%>; // the description format's id
        var found = $selects.find("option:selected[value='" + DESCRIPTION_FORMAT_ID +"']");

        var descriptionFormatMapped = found.length > 0;
        $("#defaultDescriptionFormat").attr("disabled", descriptionFormatMapped ? "true": null);
    }, 200);
}

function detectWhenAFieldIsSelectedTwice() {
    setTimeout(function() {
        var $selects = $("select.columnToFieldMapping");

        // clear all previous selection
        $(".dupicateFieldSelection").removeClass("dupicateFieldSelection");

        // get the label for the field by its id
        // @param select
        // @param id
        var getLabelForFieldId = function (select, id) {
            var label = $(select).find("option[value='" + id + "']").first().text();
            return label;
        }

        var markAsDuplicated = function (select) {
            var $button = $(select).multiselect("getButton");
            $button.addClass("dupicateFieldSelection");
        }

        // find common values in the two array or value
        // @param arr1 Array or value
        // @param arr2 Array or value
        // @return the common values as array
        var findCommonValues = function(arr1, arr2) {
            var common = [];
            if (arr1 != null && arr2 != null) {
                // convert simple values to array
                if (! $.isArray(arr1)) {
                    arr1 = [arr1];
                }
                if (! $.isArray(arr2)) {
                    arr2 = [arr2];
                }

                $.each(arr1, function(i, v) {
                    // skip "" that is "--"
                    if (v != "") {
                        if (arr2.indexOf(v) != -1) {
                            common.push(v);
                        }
                    }
                });
            }
            return common;
        };

        // check duplicates
        var duplicatedFields = [];
        $selects.each(function () {
            var outer = this;
            var outerval = $(outer).val();
            $selects.each(function () {
                var inner = this;
                if (inner != outer) {
                    // check if the two selects has common values
                    var innerval = $(inner).val();
                    var commonValues = findCommonValues(outerval, innerval);

                    if (commonValues.length > 0) {
                        $.each(commonValues, function(i, val) {
                            markAsDuplicated(outer);
                            markAsDuplicated(inner);

                            var label = getLabelForFieldId(outer, val);
                            if (duplicatedFields.indexOf(label) == -1) {
                                duplicatedFields.push(label);
                            }
                        });
                    }
                }
            });
        });

        console.log("duplicatedFields:" + duplicatedFields);

        // show the warning message if there are duplicates
        var $dupeWarn = $("#duplicateFieldSelectionWarning");
        if (duplicatedFields.length == 0) {
            $dupeWarn.hide();
        } else {
            $dupeWarn.html(i18n.message("issue.import.mapping.warning.same.field.mapped.multiple.times", duplicatedFields.join(",")))
                .show();
        }
    }, 200);
};

$(function() {
    var $selects = $("select.columnToFieldMapping");
    $selects.change(detectWhenAFieldIsSelectedTwice)
            .change(disableDescriptionFormatWhenDescriptionFormatIsMapped);

    disableDescriptionFormatWhenDescriptionFormatIsMapped();
});

function clearAllMappings() {
	var $selects = $("select.columnToFieldMapping");
	$selects.val("").change(); // trigger change-even because val() does not do that
	initMappingMultiSelect(true);
}

$(function() {
	initMappingMultiSelect(false);

	$("#allowMultiMapping").click(function() {
		initMappingMultiSelect(true);
	});
});

var $startImportAtRow = $("input[name=startImportAtRow]");
var $rawDataTable = $("#rawDataTable");
$startImportAtRow.attr("title", "${startImportAtRowTooltip}");

function selectStartRow() {
	var row = parseInt($startImportAtRow.val()); 	// TODO: check if this is a valid number
	var $selectedTR = $rawDataTable.find('tr').eq(row);

	var $rows = $rawDataTable.find('tr');
	$rows.removeClass("firstImportRow");
	$selectedTR.addClass("firstImportRow");

	var selectedIdx = $selectedTR.index();
	var idx =0;
	$rows.each(function() {
		$(this).toggleClass('dataRow', idx >= selectedIdx);
		idx ++;
	});
}

$(function() {
	$startImportAtRow.addClass("startImportAtRow");
	// initialize events for selecting rows by clicking
	// select row on click
	$rawDataTable.on('click', 'tr', function() {
		var $selectedTR = $(this);
		var rowIdx = $selectedTR.index();
		if (rowIdx == 0) {
			return;	// don't allow selecting the header
		}

		$startImportAtRow.val(rowIdx);
		selectStartRow();	// update selection
	});
	$startImportAtRow.change(selectStartRow);

	selectStartRow();
});

</script>