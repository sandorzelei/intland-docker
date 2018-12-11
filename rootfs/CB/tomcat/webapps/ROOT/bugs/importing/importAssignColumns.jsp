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

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="java.io.IOException" %>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" %>
<%@ page import="com.intland.codebeamer.remoting.*" %>


<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="trackersModule newskin ${importForm.tracker.isBranch() ? 'tracker-branch' : ''}" />

<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">
		<c:if test="${importForm.tracker.isBranch()}">
			<ui:branchBaselineBadge branch="${importForm.branch}"/>
		</c:if>
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" projectAware="${importForm.tracker}"><span class='breadcrumbs-separator'>&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="issue.import.assign.title" text="Assign Columns of Imported Data"/></ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<form:form commandName="importForm" action="${flowUrl}">

<form:hidden path="trackerId"/>

<ui:actionBar>
	<jsp:include page="./includes/nextPrevButtons.jsp"/>
</ui:actionBar>

<form:errors cssClass="error"/>

<style type="text/css">
	fieldset {
		margin: 5px 0;
		border: solid 1px silver;
	}
	table .mandatory {
		width: 10em;
	}
	table th {
		padding: 2px 0.5em;
	}
	input[type="checkbox"] {
		vertical-align: text-bottom;
	}
	.propertyTable select, .propertyTable input {
		width: 250px;
		box-sizing: border-box;
	}
	.propertyTable input[type="checkbox"] {
		width: auto !important;
	}
	.propertyTable .hint {
		max-width: 70%;
		margin-left: 10px;
	}

    #defaultDescriptionFormat:disabled {
        text-decoration: line-through;
    }
</style>

<div style="margin: 15px;">
<TABLE BORDER="0" class="formTableWithSpacing propertyTable" CELLPADDING="0">

<%-- if this is a multi-part data-source allow changing between parts --%>
<c:if test="${importForm.multiDataParts}">
	<spring:message var="title" code="useradmin.importUsers.importpart.tooltip" />
	<TR title="${title}">
		<TD class="optional">
			<spring:message var="importPartDefault" code="useradmin.importUsers.importpart.label" text="Importing part"/>
			<spring:message code="useradmin.importUsers.importpart.${importForm.fileFormat}.label" text="${importPartDefault}" />:
		</TD>
		<TD>
			<form:select path="selectedImportDataPart" onchange="return reloadSelectedPart();">
				<c:forEach var="partEntry" items="${importForm.importDataParts}">
					<form:option value="${partEntry.key}"><c:out value="${partEntry.value}"/></form:option>
				</c:forEach>
			</form:select>
		</TD>
		<TD/>
	</TR>
</c:if>

<%-- hidden field indicates when an other-part is selcted --%>
<input type="hidden" id="selectOtherPart" name="_eventId_selectOtherPart" value="" />
<script type="text/javascript">
function reloadSelectedPart() {
	$('#selectOtherPart').val('true').closest('form').submit();
	return false;
}
</script>

<c:if test="${importForm.importMetaData.hasHiddenColumns}">
<TR>
	<TD class="optional"><label for="loadHiddenCols"><spring:message code="issue.import.import.hidden" />:</label></TD>
	<TD><form:checkbox id="loadHiddenCols" path="loadHiddenCols" onchange="return reloadSelectedPart();"/></TD>
	<TD>
		<div class="hint"><spring:message code="issue.import.import.hidden.hint"/></div>
	</TD>
</TR>
</c:if>

<c:if test="${importForm.canChangeStartImportRow}">
	<TR>
		<TD class="mandatory"><spring:message code="useradmin.importUsers.startImportAtRow.label" text="Start Import at Row"/>:</TD>
		<TD><form:input size="4" path="startImportAtRow" cssClass="fixSelectWidth" type="number" min="1" max="${importForm.dataSize}" />
			<br/><form:errors path="startImportAtRow" cssClass="invalidfield"/>
		</TD>
		<TD/>
	</TR>
</c:if>
<TR>
	<TD class="optional"><spring:message code="issue.import.dateFormat.label" text="Date Format"/>:</TD>
	<TD>
		<form:select path="dateFormat" cssClass="fixSelectWidth">
			<form:options items="${importForm.availableDateFormats}" itemValue="value" itemLabel="name"/>
		</form:select>
	</TD>
	<TD/>
</TR>
<TR>
    <TD class="optional"><spring:message code="issue.import.dateFormat.timezone" />:</TD>
    <TD>
        <form:select path="timeZone">
            <form:option value="" ><spring:message code="issue.import.dateFormat.timezone.default.user" /></form:option>
            <form:options items="${importForm.timeZoneOptions}" itemLabel="name" itemValue="value" />
        </form:select>
    </TD>
    <TD>
        <div class="hint"><spring:message code="issue.import.dateFormat.timezone.hint" /></div>
    </TD>
</TR>
<TR>
	<TD class="optional"><spring:message code="issue.import.numberFormat.label" text="Number Format"/>:</TD>
	<TD>
	<form:select path="numberFormat" cssClass="fixSelectWidth">
		<form:options items="${importForm.numberFormats}" itemValue="value" itemLabel="name"/>
	</form:select>
	</TD>
	<TD/>
</TR>
<TR>
	<TD class="optional"><spring:message code="tracker.field.Description Format.label" />:</TD>
	<TD>
	<form:select id="defaultDescriptionFormat" path="defaultDescriptionFormat" cssClass="fixSelectWidth">
		<form:option value="<%=DescriptionFormat.PLAIN_TEXT%>"><spring:message code="text.format.flat"/></form:option>
		<form:option value="<%=DescriptionFormat.WIKI%>"><spring:message code="text.format.wiki"/></form:option>
		<form:option value="<%=DescriptionFormat.HTML%>"><spring:message code="text.format.html"/></form:option>
	</form:select>
	</TD>
	<TD>
        <div class="hint"><spring:message code="issue.import.descriptionFormat.hint"/></div>
    </TD>
</TR>
<TR>
	<TD class="optional"><spring:message code="issue.import.do.not.modify.value.label" />:</TD>
	<TD><form:input path="doNotModifyValue" size="50" /></TD>
	<TD><div class="hint"><spring:message code="issue.import.do.not.modify.value" /></div></TD>
</TR>

<jsp:include page="./includes/importHierarchyConfig.jsp" />

<TR>
	<TD class="optional"><spring:message code="issue.import.id.fields.mapping.label" text="Find and update existing items by" />:</TD>
	<TD>
		<form:select multiple="true" path="idFields" id="idFields">
			<c:set var="fields" value="${importForm.fieldsTranslatedSorted}" />
			<c:forEach var="fieldLabels" items="${fields}">
				<c:set var="fieldDescription" value="${fieldLabels}" />
				<c:set var="field" value="${fieldLabels.field}"/>
				<form:option value="${field.id}" label="${fieldDescription}" />
			</c:forEach>
		</form:select>
	</TD>
	<TD><div class="hint"><spring:message code="issue.import.id.fields.mapping.hint" /></div></TD>
</TR>

<TR>
	<TD class="optional"><label for="strictDataTypeMapping"><spring:message code="issue.import.strict.datatype.mapping" /></label>:</TD>
	<TD colspan="2"><form:checkbox id="strictDataTypeMapping" path="strictDataTypeMapping"/>
	    <label for="strictDataTypeMapping"><spring:message code="issue.import.strict.datatype.mapping.warning" /></label>
	</TD>
</TR>

</TABLE>

 <jsp:include page="./includes/showRawImportData.jsp"/>
</div>

</form:form>

<script type="text/javascript">
$(function() {
	function submitParentForm() {
		$(this).closest('form').submit();
	}

	var $strictDataTypeMapping = $('input[name="strictDataTypeMapping"]');
	if ($strictDataTypeMapping.is(":checked")) {
		$('input[name="startImportAtRow"]').change(submitParentForm);
	}
	$strictDataTypeMapping.click(submitParentForm);
});

$(function() {
	// initialize the mulitselect widget for id fields
	$("#idFields").multiselect({
			multiple: true,
			selectedList: 99,
			noneSelectedText: "--",
			"classes" : "rawImportData"
		}
	).multiselectfilter();
});
</script>

