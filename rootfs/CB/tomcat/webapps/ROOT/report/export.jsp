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
<%@ taglib uri="report" prefix="report" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@page import="com.intland.codebeamer.remoting.ReportType"%>
<%@page import="com.intland.codebeamer.controller.TrackerItemFlagsOption"%>
<%@page import="com.intland.codebeamer.controller.TrackerItemDetailsController"%>

<%
	pageContext.setAttribute("EXPORT_TYPE_EXCEL", new Integer(ReportType.EXCEL));
	pageContext.setAttribute("EXPORT_TYPE_PDF", new Integer(ReportType.PDF));
	pageContext.setAttribute("EXPORT_TYPE_CSV", new Integer(ReportType.CSV));
	pageContext.setAttribute("EXPORT_TYPE_XML", new Integer(ReportType.XML));
	pageContext.setAttribute("EXPORT_TYPE_WIKI", new Integer(ReportType.WIKI));

	pageContext.setAttribute("EXPORT_OPTION_COMMENTS", ReportType.EXPORT_OPTION_COMMENTS);
	pageContext.setAttribute("EXPORT_OPTION_HISTORY",  ReportType.EXPORT_OPTION_HISTORY);
	pageContext.setAttribute("EXPORT_OPTION_DESCRIPTIONS", ReportType.EXPORT_OPTION_DESCRIPTIONS);
	pageContext.setAttribute("EXPORT_OPTION_ASSOCIATIONS", ReportType.EXPORT_OPTION_ASSOCIATIONS);
	pageContext.setAttribute("EXPORT_OPTION_CHILDREN", ReportType.EXPORT_OPTION_CHILDREN);
	pageContext.setAttribute("EXPORT_OPTION_REFERENCES", ReportType.EXPORT_OPTION_REFERENCES);
	pageContext.setAttribute("EXPORT_OPTION_REF_TYPES", ReportType.EXPORT_OPTION_REF_TYPES);
	pageContext.setAttribute("EXPORT_OPTION_REF_FLAGS", ReportType.EXPORT_OPTION_REF_FLAGS);
	pageContext.setAttribute("EXPORT_OPTION_REF_FILTER", ReportType.EXPORT_OPTION_REF_FILTER);
%>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">

function changeReferencesSelector(checkbox) {
	var selector = document.getElementById('references-export-selector');
	if (checkbox.checked) {
		selector.className = '';
	} else {
		selector.className = 'invisible';
	}
}

function onChangeType(item) {
	var type = item.value;
	var csvOptions = document.getElementById('csv_options');
	if (type == '<c:out value="${EXPORT_TYPE_CSV}" />') {
		csvOptions.className = '';
	} else {
		csvOptions.className = 'invisible';
	}

	var exportComments = document.getElementById('tr_export_option_comments');
	var exportAssocs   = document.getElementById('tr_export_option_associations');
	var exportHistory  = document.getElementById('tr_export_option_history');
	var exportChildren = document.getElementById('tr_export_option_children');
	var exportRefs	   = document.getElementById('tr_export_option_references');

	if (type == "${EXPORT_TYPE_EXCEL}" || type == "${EXPORT_TYPE_PDF}" || type == "${EXPORT_TYPE_XML}") {
		exportComments.className = '';
		exportAssocs.className = '';
		exportHistory.className = '';
		exportChildren.className = '';
		if (exportRefs != null) {
			exportRefs.className = '';
			changeReferencesSelector(document.getElementById('export_option_references'));
		}
	} else {
		exportComments.className = 'invisible';
		exportAssocs.className = 'invisible';
		exportHistory.className = 'invisible';
		exportChildren.className = 'invisible';
		if (exportRefs != null) {
			exportRefs.className = 'invisible';
			var selector = document.getElementById('references-export-selector');
			selector.className = 'invisible';
		}
	}
}

</SCRIPT>

<report:info doc_id="${param.doc_id}" revision="${param.revision}" var="document" refTypes="referenceTypes" scope="request" />

<meta name="decorator" content="main"/>
<meta name="module" content="${empty document.parent ? 'report' : 'docs'}"/>
<meta name="moduleCSSClass" content="newskin ${empty document.parent ? 'reportModule' : 'documentsModule'}"/>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false">
			<span class="breadcrumbs-separator">&raquo;</span><ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="report.export.title" text="Export Report Results"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<c:url var="exportServlet" value="/exportTrackerReportResults" />

<c:url var="cancelURL" value="${empty document.parent ? '/proj/report.do' : document.parent.urlLink}" />

<FORM ACTION="${exportServlet}" METHOD="post">

<ui:actionBar>
	&nbsp;&nbsp;
	<spring:message var="exportButton" code="report.export.label" text="Export"/>
	<INPUT TYPE="submit" VALUE="${exportButton}" CLASS="button">
	&nbsp;&nbsp;
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<INPUT TYPE="button" VALUE="${cancelButton}" CLASS="cancelButton" ONCLICK="document.location.href='${cancelURL}'">
</ui:actionBar>

<INPUT TYPE="hidden" NAME="doc_id" VALUE="${document.id}">

<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="2">

<TR>
	<TD VALIGN="top" class="mandatory"><spring:message code="report.export.format.label" text="Export Type"/>:</TD>
	<TD VALIGN="top">
		<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="0">
			<TR>
				<TD COLSPAN="3">
					<INPUT TYPE="radio" NAME="type" VALUE="${EXPORT_TYPE_EXCEL}" CHECKED="checked" ONCLICK="onChangeType(this);" id="export_type_excel" />
					<label for="export_type_excel"><spring:message code="report.export.format.xls" text="Excel"/></label>
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="3">
					<INPUT TYPE="radio" NAME="type" VALUE="${EXPORT_TYPE_PDF}" ONCLICK="onChangeType(this);" id="export_type_pdf"/>
					<label for="export_type_pdf"><spring:message code="report.export.format.pdf" text="PDF"/></label>
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="1">
					<INPUT TYPE="radio" NAME="type" VALUE="${EXPORT_TYPE_CSV}" ONCLICK="onChangeType(this);" id="export_type_csv"/>
					<label for="export_type_csv"><spring:message code="report.export.format.csv" text="CSV"/></label>
				</TD>
				<TD>&nbsp;&nbsp;&nbsp;</TD>
				<TD NOWRAP="nowrap">
					<TABLE BORDER="0" CELLPADDING="0" CLASS="invisible formTableWithSpacing" id="csv_options">
						<TR>
							<TD CLASS="optional">
								&nbsp;<spring:message code="useradmin.importUsers.fieldSeparator.label" text="Field separator"/>: &nbsp;
								<SELECT NAME="field_separator">
									<OPTION value="\t">\t</OPTION>
									<OPTION value=",">,</OPTION>
									<OPTION value=";">;</OPTION>
									<OPTION value="###">###</OPTION>
								</SELECT>
							</TD>
							<TD>&nbsp;&nbsp;&nbsp;</TD>
							<TD CLASS="optional">
								&nbsp;<spring:message code="useradmin.importUsers.recordSeparator.label" text="Record separator"/>: &nbsp;
								<SELECT NAME="record_separator">
									<OPTION value="\r">\r</OPTION>
									<OPTION value="\n">\n</OPTION>
									<OPTION value="$$$">$$$</OPTION>
								</SELECT>
							</TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="3">
					<INPUT TYPE="radio" NAME="type" VALUE="${EXPORT_TYPE_XML}" ONCLICK="onChangeType(this);" id="export_type_xml" />
					<label for="export_type_xml"><spring:message code="report.export.format.xml" text="XML"/></label>
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="3">
					<INPUT TYPE="radio" NAME="type" VALUE="${EXPORT_TYPE_WIKI}" ONCLICK="onChangeType(this);" id="export_type_wiki" />
					<label for="export_type_wiki"><spring:message code="report.export.format.wki" text="Wiki"/></label>
				</TD>
			</TR>
		</TABLE>
	</TD>
</TR>

<TR>
	<TD VALIGN="top" class="optional">
		<spring:message code="report.export.options.label" text="Export Options"/>:
	</TD>

	<TD VALIGN="top" id="export_options" style="margin-bottom: 5px;">
		<table border="0" class="formTableWithSpacing" cellpadding="0">
			<tr id="tr_export_option_comments" valign="middle">
				<td width="2%">
					<input type="checkbox" name="${EXPORT_OPTION_COMMENTS}" value="true" id="export_option_comments">
				</td>
				<td>
					<label for="export_option_comments">
						<spring:message code="report.export.option.comments" text="Export Comments"/>
					</label>
				</td>
			</tr>

			<tr id="tr_export_option_associations" valign="middle">
				<td width="2%">
					<input type="checkbox" name="${EXPORT_OPTION_ASSOCIATIONS}" value="true" id="export_option_associations">
				</td>
				<td>
					<label for="export_option_associations">
						<spring:message code="report.export.option.assocs" text="Export Associations"/>
					</label>
				</td>
			</tr>

			<tr id="tr_export_option_descriptions" valign="middle">
				<td width="2%">
					<input type="checkbox" name="${EXPORT_OPTION_DESCRIPTIONS}" value="true" id="export_option_descriptions">
				</td>
				<td>
					<label for="export_option_descriptions">
						<spring:message code="report.export.option.description" text="Export Descriptions"/>
					</label>
				</td>
			</tr>

			<tr id="tr_export_option_history" valign="middle">
				<td width="2%">
					<input type="checkbox" name="${EXPORT_OPTION_HISTORY}" value="true" id="export_option_history">
				</td>
				<td>
					<label for="export_option_history">
						<spring:message code="report.export.option.history" text="Export History"/>
					</label>
				</td>
			</tr>

			<tr id="tr_export_option_children" valign="middle">
				<td width="2%">
					<input type="checkbox" name="${EXPORT_OPTION_CHILDREN}" value="true" id="export_option_children">
				</td>
				<td>
					<label for="export_option_children">
						<spring:message code="report.export.option.children" text="Export Children"/>
					</label>
				</td>
			</tr>

			<c:if test="${!empty referenceTypes}">
				<tr id="tr_export_option_references" valign="middle">
					<td width="2%">
						<input type="checkbox" name="${EXPORT_OPTION_REFERENCES}" value="true" id="export_option_references" onchange="changeReferencesSelector(this);">
					</td>
					<td>
						<label for="export_option_references">
							<spring:message code="report.export.option.references" text="Export References"/>
						</label>
					</td>
				</tr>

				<tr id="references-export-selector" class="invisible" valign="middle">
					<td width="2%"></td>
					<td valign="middle">
						<c:forEach items="${referenceTypes}" var="refType" varStatus="refRow">
							<input id="refType_${refRow.index}" type="checkbox" name="${EXPORT_OPTION_REF_TYPES}" value="${refType.value}"  />
							<label for="refType_${refRow.index}"><c:out value="${refType.label}"/></label>
							<br/>
						</c:forEach>

						<table border="0" cellspacing="2" cellpadding="2">
							<tr valign="middle">
								<td>
									<spring:message code="issue.references.status.label" text="with status"/>
								</td>
								<td>
									<select name="${EXPORT_OPTION_REF_FLAGS}">
										<c:forEach items="<%=TrackerItemFlagsOption.LIST%>" var="refFlag">
											<option value="${refFlag.id}">
												<spring:message code="issue.flags.${refFlag.name}.label" text="${refFlag.name}"/>
											</option>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr valign="middle">
								<td>
									<spring:message code="issue.references.filter.label" text="and due"/>
								</td>
								<td>
									<select name="${EXPORT_OPTION_REF_FILTER}">
										<c:forEach items="<%=TrackerItemDetailsController.FILTER_LIST%>" var="refFilter">
											<option value="${refFilter.id}">
												<spring:message code="issue.filter.${refFilter.name}.label" text="${refFilter.name}" htmlEscape="true"/>
											</option>
										</c:forEach>
									</select>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</c:if>
		</table>
	</TD>
</TR>

</TABLE>

</FORM>