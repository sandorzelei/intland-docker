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
<%@ page language="java" %>

<%@ page import="com.intland.codebeamer.servlet.bugs.dynchoices.ReferenceHandlerSupport"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.intland.codebeamer.servlet.report.AddUpdateTrackerReportForm" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>

<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<meta name="decorator" content="main"/>
<meta name="module" content="${module}"/>
<meta name="moduleCSSClass" content="newskin ${moduleCSSClass}"/>

<SCRIPT LANGUAGE="JavaScript" SRC="<ui:urlversioned value='/menu/OptionTransfer.js'/>" type="text/javascript"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="<ui:urlversioned value='/menu/selectbox.js'/>" type="text/javascript"></SCRIPT>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers

function submitForm(form) {
	if ($('body').hasClass('IE8')) {
		$(form).unbind('submit');
	}
	var length = form.elements.length;
	for (var i=0; i < length; i++)
	{
		var e = form.elements[i];
		var name = e.name;
		if(name.indexOf('selectedColumnIds') == 0)
		{
			selectAllOptions(e);
			if (e.value.length == 0)
			{
				alert('<spring:message code="error.report.select.columns.required" />');
				if ($('body').hasClass('IE8')) {
					$(form).submit(function() {
						return false;
					});
				} else {
					return false;
				}
			}
		}
		if(name.indexOf('selectedHistoryFields') == 0)
		{
			selectAllOptions(e);
		}
		if(name.indexOf('selectedSummaryFields') == 0)
		{
			selectAllOptions(e);
		}
	}
//	form.submit();
	return true;
}

function submitFormNoValidation(form) {
	if ($('body').hasClass('IE8')) {
		$(form).submit(function() {
			form.submit();
		});
	} else {
		return true;
	}
}


// -->
</SCRIPT>

<c:set var="doc_id" value="-1" />
<spring:message var="title" code="report.create.${CMDB ? 'item' : 'issue'}.title"/>
<c:if test="${!empty param.doc_id}">
	<c:set var="doc_id" value="${param.doc_id}" />
	<spring:message var="title" code="report.edit.${CMDB ? 'item' : 'issue'}.title"/>
</c:if>
<spring:message var="trackerType" code="${CMDB ? 'cmdb.category' : 'tracker'}.label"/>
<spring:message var="anyButton" code="tracker.filter.any.button" htmlEscape="true"/>

<%-- defined here, because script elements are not allowed inside ditchnet tabs' tags---%>
<c:set var="ReferenceHandlerSupport_KEY_SEPARATOR" value="<%=ReferenceHandlerSupport.KEY_SEPARATOR%>"/>
<%
	Map labelMap = new HashMap();
	labelMap.put(AddUpdateTrackerReportForm.ANY_VALUE, "tracker.filter.Any.label");
	labelMap.put(AddUpdateTrackerReportForm.UNSET_VALUE, AddUpdateTrackerReportForm.UNSET_LABEL);
	pageContext.setAttribute("chooseReferences_labelMap", labelMap);
	pageContext.setAttribute("chooseReferences_unsetValue", AddUpdateTrackerReportForm.UNSET_VALUE);
%>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="report.step5.title" text="{0} - Step 5" arguments="${title}"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<c:set var="form" value="${sessionScope.addUpdateTrackerReportForm}" />

<html:form action="/proj/report/editReportFilters">

<html:hidden property="page" value="5" />
<html:hidden property="proj_id" />
<html:hidden property="dir_id" />

<c:if test="${doc_id != -1}">
	<html:hidden property="doc_id" value="${doc_id}" />
</c:if>

<ui:actionBar>
	<html:submit styleClass="button" property="PREVIOUS" onclick="return submitFormNoValidation(this.form)">
		<spring:message code="button.back" text="&lt; Back"/>
	</html:submit>
	&nbsp;&nbsp;
	<html:submit styleClass="button" property="SAVE" onclick="return submitForm(this.form)">
		<spring:message code="button.save" text="Save"/>
	</html:submit>
	&nbsp;&nbsp;
	<html:submit styleClass="linkButton" property="SAVE_EXECUTE" onclick="return submitForm(this.form)">
		<spring:message code="report.save.and.execute.label" text="Save &amp; Execute"/>
	</html:submit>
	&nbsp;&nbsp;
	<html:cancel styleClass="cancelButton" onclick="return submitFormNoValidation(this.form)">
		<spring:message code="button.cancel" text="Cancel"/>
	</html:cancel>
	&nbsp;&nbsp;
</ui:actionBar>

<ui:showErrors />

<tab:tabContainer id="reportFilters" skin="cb-box">

<c:forEach items="${form.trackerMasks}" var="tracker">

<c:choose>
	<c:when test="${form.merged}">
		<spring:message var="trackerMaskTitle" code="report.merged.label" text="Merged Report"/>
	</c:when>
	<c:otherwise>
		<spring:message var="trackerName" code="tracker.${tracker.name}.label" text="${tracker.name}" htmlEscape="true"/>
		<spring:message var="trackerMaskTitle" code="report.query.label" text="{0} - {1}" arguments="${tracker.projectName},${trackerName}" htmlEscape="true"/>
	</c:otherwise>
</c:choose>

<tab:tabPane id="reportTrackerMasks-${tracker.id}" tabTitle="${trackerMaskTitle}">
	<c:if test="${!form.merged}">
		<spring:message code="report.query.tooltip" text="Set displayed columns, filters and order options for {0} {1} below !" arguments="${trackerType},${trackerMaskTitle}"/>
	</c:if>

	<TABLE WIDTH="100%" BORDER="0" class="formTableWithSpacing" CELLPADDING="0">

	<ui:title style="headline.grayed" colSpan="7" alreadyInTable="true" >
		<spring:message code="tracker.view.filtering.label" text="Filtering"/>
	</ui:title>

	<c:set var="tracker_id" value="${tracker.id}" />

	<c:forEach items="${tracker.dropDownLists}" var="dropDownList" varStatus="forStatus">
		<c:set var="label_id" value="${dropDownList.id}" />
	    <c:set var="key_id" value="${tracker_id}_${label_id}" />

<%--
		<bean:size id="selectionSize" name="choiceValues" />
		<c:if test="${selectionSize gt 6}">
			<c:set var="selectionSize" value="6" />
		</c:if>
--%>
		<c:set var="selectionSize" value="6" />
		<c:set var="choiceValues" value="${tracker.choiceValues[label_id]}" />

		<%-- these ifs make 2 selectbox in a row  --%>
		<c:if test="${forStatus.count mod 2 eq 1}">
			<c:set var="rowClosed" value="false" />
			<TR VALIGN="TOP">
			<TD></TD>
		</c:if>

		<TD width="8em" class="optional">
			<spring:message code="tracker.field.${dropDownList.label}.label" text="${dropDownList.label}"/>
			<br/><br/>
			<html:checkbox styleId="not_${key_id}" property="notSelection(${key_id})" />
			<label for="not_${key_id}"><spring:message code="tracker.view.not.label" text="Not"/></label>
		</TD>

		<TD NOWRAP width="23%">
			<html:select multiple="true" size="${selectionSize}" styleClass="fixMiddleSelectWidth"	property="dropDownSelection(${tracker_id}_${label_id})">
				<c:forEach items="${choiceValues}" var="cv">
					<html:option value="${cv.value}">
						<c:out value="${cv.label}" />
					</html:option>
				</c:forEach>
			</html:select></TD>

		<c:if test="${forStatus.count mod 2 eq 0}">
			<c:set var="rowClosed" value="true" />
			</TR>
		</c:if>

		<c:if test="${!rowClosed}">
			<TD width="4em"></TD>
		</c:if>
	</c:forEach>
	<%-- close the row it may have left open --%>
	<c:if test="${rowClosed eq false}">
		</TR>
	</c:if>

	<c:forEach items="${tracker.dynChoiceFlds}" var="dynChoice" varStatus="forStatus">
	  <c:set var="label_id" value="${dynChoice.id}" />
	  <c:set var="key_id" value="${tracker_id}_${label_id}" />

	  <tr>
		<td></td>
		<td width="8em" class="optional" nowrap>
			<spring:message code="tracker.field.${dynChoice.label}.label" text="${dynChoice.label}"/><br/>
			<html:checkbox styleId="not_${key_id}" property="notSelection(${key_id})" />
			<label for="not_${key_id}"><spring:message code="tracker.view.not.label" text="Not"/></label>
		</td>
		<td colspan="4" valign="middle" style="padding-right:5px;" >
			<c:set var="labelKey">${tracker_id}${ReferenceHandlerSupport_KEY_SEPARATOR}${label_id}</c:set>
			<c:set var="defaultValue" value="${form.referenceHandlerSupport.referencesDefaultValue}" />

			<c:choose>
			  <c:when test="${dynChoice.memberChoice}">
				<bugs:userSelector ids="${form.dynChoiceValues[labelKey]}" fieldName="dynChoiceValue(${labelKey})" showUnset="true" showCurrentUser="true" allowRoleSelection="true"
						projectList="${form.selectedProjectList}"
						setToDefaultLabel="${anyButton}" defaultValue="${defaultValue}"
						specialValueResolver="com.intland.codebeamer.servlet.report.AddUpdateTrackerReportFormSpecialValues" />
			  </c:when>
			  <c:otherwise>
				<%-- the form.dynChoiceValues[] will actually go to ReferenceHandlerSupport... --%>
				<bugs:chooseReferences tracker_id="${tracker_id}" ids="${form.dynChoiceValues[labelKey]}" label="${dynChoice}" forceMultiSelect="true"
						setToDefaultLabel="${anyButton}" defaultValue="${defaultValue}"
						labelMap="${chooseReferences_labelMap}" emptyValue="${defaultValue}"
						showUnset="${! dynChoice.required}" unsetValue="${chooseReferences_unsetValue}"	/>
			  </c:otherwise>
			</c:choose>
		</td>
	  </tr>
	</c:forEach>

	<c:if test="${!empty tracker.referenceTypeList}">
		<script language="JavaScript" type="text/javascript">
			var nextReference${tracker.id} = ${tracker.nextReferenceCriterion}
			var maxReference${tracker.id} = 10
			function addReference${tracker_id}() {
				if (nextReference${tracker.id} >= maxReference${tracker.id}) {
					return;
				}
				var trId = "trRefCriteria${tracker.id}_" + nextReference${tracker.id};
				var tr = document.getElementById(trId);
				if (tr == null) {
					return;
				}
				tr.className = "";
				nextReference${tracker.id}++;

				// remove the control
				if (nextReference${tracker.id} >= maxReference${tracker.id}) {
					tr = document.getElementById("addRefCriteriaControl${tracker.id}");
					tr.className = "invisible";
				}
			}
		</script>

	  	<c:forEach begin="0" end="9" var="num">
	  		<c:set var="key_id" value="${tracker_id}_${num}" />
			<c:set var="trClass" value="normal" />
			<c:if test="${num gt 0}">
				<logic:empty property="referencesType(${key_id})" name="form">
					<c:set var="trClass" value="invisible" />
				</logic:empty>
			</c:if>

			<tr id="trRefCriteria${key_id}" class="${trClass}">
				<td></td>
				<td width="8em" class="optional" valign="middle">
					<c:if test="${num == 0}">
  						<spring:message code="issue.references.title" text="References"/>
  					</c:if>
				</td>

				<td valign="middle" colspan="4" nowrap>
					<html:checkbox styleId="noRef_${key_id}" property="referencesNot(${key_id})" value="true"/>
					<label for="noRef_${key_id}"><spring:message code="tracker.view.no.references.label" text="No"/></label>

					<html:select property="referencesType(${key_id})">
						<c:forEach items="${tracker.referenceTypeList}" var="refType">
							<html:option value="${refType.value}">
								<c:out value="${refType.label}"/>
							</html:option>
						</c:forEach>
					</html:select>

					<spring:message code="issue.references.status.label" text="with status"/>
					<html:select property="referencesFlags(${key_id})">
						<c:forEach items="${tracker.referenceFlagsList}" var="refFlag">
							<html:option value="${refFlag.id}">
								<spring:message code="issue.flags.${refFlag.name}.label" text="${refFlag.name}"/>
							</html:option>
						</c:forEach>
					</html:select>

					<spring:message code="issue.references.filter.label" text="and due"/>
					<html:select property="referencesFilter(${key_id})">
						<c:forEach items="${tracker.referenceFilterList}" var="refFilter">
							<html:option value="${refFilter.id}">
								<spring:message code="issue.filter.${refFilter.name}.label" text="${refFilter.name}" htmlEscape="true"/>
							</html:option>
						</c:forEach>
					</html:select>
				</td>
			</tr>
	  	</c:forEach>

		<tr id="addRefCriteriaControl${tracker.id}">
			<td></td>
			<td width="8em" class="optional" valign="middle"></td>
			<td valign="middle" colspan="4" nowrap>
				<html:link href="#" onclick="addReference${tracker_id}(); return false;"><spring:message code="tracker.view.criteria.add.label" text="Add Criteria..."/></html:link>
			</td>
		</tr>
	</c:if>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
var nextCriteria${tracker.id} = <c:out value="${tracker.nextCustomCriterion}" />
var maxCriteria${tracker.id} = <c:out value="10" />
function addCriteria${tracker_id}() {
	if (nextCriteria${tracker.id} >= maxCriteria${tracker.id}) {
		return;
	}
	var trId = "customCriteria${tracker.id}_" + nextCriteria${tracker.id};
	var tr = document.getElementById(trId);
	if (tr == null) {
		return;
	}
	tr.className = "";
	nextCriteria${tracker.id}++;

	// remove the control
	if (nextCriteria${tracker.id} >= maxCriteria${tracker.id}) {
		tr = document.getElementById("addCriteriaControl${tracker.id}");
		tr.className = "invisible";
	}
}
</SCRIPT>

	<TR>
	  <TD colspan="6">
		<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="2">

		<c:forEach begin="0" end="9" var="criteriaIdx">
	  		<c:set var="key_id" value="${tracker_id}_${criteriaIdx}" />
			<c:set var="trClass" value="normal" />
			<logic:empty property="criteriaField(${key_id})" name="form">
				<c:set var="trClass" value="invisible" />
			</logic:empty>

			<TR id="customCriteria${key_id}" class="${trClass}">
				<TD CLASS="optional">
					<html:select styleId="criteriaField${key_id}" property="criteriaField(${key_id})" onchange="onChangeCriteria(this)">
						<html:option value="">
							<spring:message code="tracker.view.none.label" text="-- None --"/>
						</html:option>
						<c:forEach items="${tracker.customFlds}" var="cv">
							<html:option value="${cv.id}">
								<spring:message code="tracker.field.${cv.label}.label" text="${cv.labelWithoutBR}"/>
							</html:option>
						</c:forEach>
					</html:select>
				</TD>
				<TD CLASS="optional" VALIGN="middle">
					<html:checkbox property="criteriaNot(${key_id})" value="true"/>
					<spring:message code="tracker.view.not.label" text="Not"/>&nbsp;
				</TD>
				<TD CLASS="optional">
					<html:select property="criteriaCmpOp(${key_id})">
						<html:option value="eq">=</html:option>
						<html:option value="ne">!=</html:option>
						<html:option value="in">in</html:option>
						<html:option value="lt">&lt;</html:option>
						<html:option value="le">&lt;=</html:option>
						<html:option value="gt">&gt;</html:option>
						<html:option value="ge">&gt;=</html:option>
						<html:option value="like">like</html:option>
					</html:select>
				</TD>
				<TD>
					<html:text styleId="criteriaValue${key_id}" property="criteriaValue(${key_id})" />
				</TD>
			</TR>
		</c:forEach>
			<TR id="addCriteriaControl${tracker.id}">
				<TD colspan="4">
					<a href="#" onclick="addCriteria${tracker_id}(); return false;"><spring:message code="tracker.view.criteria.add.label" text="Add Custom Criteria..."/></a>
				</TD>
			</TR>
		</TABLE>
	  </TD>
	</TR>

<%--
	<TR VALIGN="TOP">
		<TD></TD>

		<TD class="optional">SQL Where:</TD>

		<TD CLASS="expandTextArea" COLSPAN="5">
			<html:textarea styleClass="expandTextArea" rows="2" cols="80" property="extraWhere(${tracker_id})" />
		</TD>
	</TR>
--%>
	<%-- Filters to select columns & odering --%>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
		var opt_${tracker_id} = new OptionTransfer("nonSelectedColumnIds(${tracker_id})","selectedColumnIds(${tracker_id})");
		opt_${tracker_id}.setAutoSort(false);
		opt_${tracker_id}.setDelimiter(",");
		opt_${tracker_id}.setDelimiter("removedLeft");
		opt_${tracker_id}.setDelimiter("removedRight");
		opt_${tracker_id}.setDelimiter("addedLeft");
		opt_${tracker_id}.setDelimiter("addedRight");
		opt_${tracker_id}.setDelimiter("newLeft");
		opt_${tracker_id}.setDelimiter("newRight");
	</SCRIPT>

	<ui:title style="headline.grayed" colSpan="7" alreadyInTable="true" >
		<spring:message code="tracker.view.fields.label" text="Displayed Fields"/>
	</ui:title>

	<%-- Select Columns --%>
	<TR VALIGN="TOP">
		<TD></TD>

		<TD class="optional">&nbsp;<spring:message code="tracker.view.fields.available.label" text="Available Fields"/>:</TD>

		<c:set var="selectionSize" value="8" />

		<TD NOWRAP VALIGN="TOP">
			<html:select property="nonSelectedColumnIds(${tracker_id})"	size="${selectionSize}" multiple="true"
						 ondblclick="opt_${tracker_id}.transferRight()" styleClass="fixMiddleSelectWidth">
				<c:forEach items="${tracker.nonSelectedColumns}" var="layoutData">
					<html:option value="${layoutData.id}">
						<spring:message code="tracker.field.${layoutData.label}.label" text="${layoutData.labelWithoutBR}"/>
					</html:option>
				</c:forEach>
			</html:select>
		</TD>

		<TD width="4em" VALIGN="MIDDLE" ALIGN="CENTER">
			<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="RIGHT" onclick="opt_${tracker_id}.transferRight()" value="&nbsp;&gt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>

			<TR>
				<TD HEIGHT="4"></TD>
			</TR>

			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="RIGHT" onclick="opt_${tracker_id}.transferAllRight()" value="&nbsp;&gt;&gt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>

			<TR>
				<TD HEIGHT="4"></TD>
			</TR>

			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="LEFT" onclick="opt_${tracker_id}.transferLeft()"	value="&nbsp;&lt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>

			<TR>
				<TD HEIGHT="4"></TD>
			</TR>

			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="LEFT" onclick="opt_${tracker_id}.transferAllLeft()" value="&nbsp;&lt;&lt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>
			</TABLE>
		</TD>

		<TD class="optional"><spring:message code="tracker.view.fields.selected.label" text="Selected Fields"/>:</TD>

		<TD NOWRAP VALIGN="TOP">
			<html:select property="selectedColumnIds(${tracker_id})" size="${selectionSize}" multiple="true"
						 ondblclick="opt_${tracker_id}.transferLeft()" styleClass="fixMiddleSelectWidth">
				<c:forEach items="${tracker.selectedColumns}" var="layoutData">
					<html:option value="${layoutData.id}">
						<spring:message code="tracker.field.${layoutData.label}.label" text="${layoutData.labelWithoutBR}"/>
					</html:option>
				</c:forEach>
			</html:select>
		</TD>

		<TD VALIGN="MIDDLE" ALIGN="LEFT" WIDTH="40%">
			&nbsp;
			<html:button styleClass="button" property="UP" onclick="moveOptionUp(this.form['selectedColumnIds(${tracker_id})'])" >
				<spring:message code="tracker.view.fields.up.label" text="&nbsp;Up&nbsp;"/>
			</html:button>
			<BR><BR>
			&nbsp;
			<html:button styleClass="button" property="DOWN" onclick="moveOptionDown(this.form['selectedColumnIds(${tracker_id})'])">
				<spring:message code="tracker.view.fields.down.label" text="Down"/>
			</html:button>
		</TD>
	</TR>


	<%-- History fields --%>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
		var hist_${tracker_id} = new OptionTransfer("nonSelectedHistoryFields(${tracker_id})","selectedHistoryFields(${tracker_id})");
		hist_${tracker_id}.setAutoSort(false);
		hist_${tracker_id}.setDelimiter(",");
		hist_${tracker_id}.setDelimiter("removedLeft");
		hist_${tracker_id}.setDelimiter("removedRight");
		hist_${tracker_id}.setDelimiter("addedLeft");
		hist_${tracker_id}.setDelimiter("addedRight");
		hist_${tracker_id}.setDelimiter("newLeft");
		hist_${tracker_id}.setDelimiter("newRight");
	</SCRIPT>

	<ui:title style="headline.grayed" colSpan="7" alreadyInTable="true" >
		<spring:message code="report.history.fields.label" text="Display change history of fields"/>
	</ui:title>

	<%-- Select Columns --%>
	<TR VALIGN="TOP">
		<TD></TD>

		<TD class="optional"><spring:message code="tracker.view.fields.available.label" text="Available Fields"/>:</TD>

		<c:set var="selectionSize" value="6" />

		<TD NOWRAP VALIGN="TOP">
			<html:select property="nonSelectedHistoryFields(${tracker_id})"	size="${selectionSize}" multiple="true"
						 ondblclick="hist_${tracker_id}.transferRight()" styleClass="fixMiddleSelectWidth">
				<c:forEach items="${tracker.nonHistoryFields}" var="cv">
					<html:option value="${cv.value}">
						<spring:message code="tracker.field.${cv.label}.label" text="${cv.label}"/>
					</html:option>
				</c:forEach>
			</html:select>
		</TD>

		<TD VALIGN="MIDDLE" ALIGN="CENTER">
			<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="RIGHT" onclick="hist_${tracker_id}.transferRight()" value="&nbsp;&gt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>

			<TR>
				<TD HEIGHT="4"></TD>
			</TR>

			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="RIGHT" onclick="hist_${tracker_id}.transferAllRight()" value="&nbsp;&gt;&gt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>

			<TR>
				<TD HEIGHT="4"></TD>
			</TR>

			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="LEFT" onclick="hist_${tracker_id}.transferLeft()" value="&nbsp;&lt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>

			<TR>
				<TD HEIGHT="4"></TD>
			</TR>

			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="LEFT" onclick="hist_${tracker_id}.transferAllLeft()"	value="&nbsp;&lt;&lt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>
			</TABLE>
		</TD>

		<TD class="optional"><spring:message code="tracker.view.fields.selected.label" text="Selected Fields"/>:</TD>

		<TD NOWRAP VALIGN="TOP">
			<html:select property="selectedHistoryFields(${tracker_id})" size="${selectionSize}" multiple="true"
						 ondblclick="hist_${tracker_id}.transferLeft()" styleClass="fixMiddleSelectWidth">
				<c:forEach items="${tracker.historyFields}" var="cv">
					<html:option value="${cv.value}">
						<spring:message code="tracker.field.${cv.label}.label" text="${cv.label}"/>
					</html:option>
				</c:forEach>
			</html:select>
		</TD>
	</TR>

	<%-- Summary fields --%>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
		var summary_${tracker_id} = new OptionTransfer("nonSelectedSummaryFields(${tracker_id})","selectedSummaryFields(${tracker_id})");
		summary_${tracker_id}.setAutoSort(false);
		summary_${tracker_id}.setDelimiter(",");
		summary_${tracker_id}.setDelimiter("removedLeft");
		summary_${tracker_id}.setDelimiter("removedRight");
		summary_${tracker_id}.setDelimiter("addedLeft");
		summary_${tracker_id}.setDelimiter("addedRight");
		summary_${tracker_id}.setDelimiter("newLeft");
		summary_${tracker_id}.setDelimiter("newRight");
	</SCRIPT>

	<ui:title style="headline.grayed" colSpan="7" alreadyInTable="true" >
		<spring:message code="report.summary.fields.label" text="Show value summary for fields"/>
	</ui:title>

	<%-- Select Columns --%>
	<TR VALIGN="TOP">
		<TD></TD>

		<TD class="optional"><spring:message code="report.summary.fields.available.label" text="Available Summaries"/>:</TD>

		<c:set var="selectionSize" value="6" />

		<TD NOWRAP VALIGN="TOP">
			<html:select property="nonSelectedSummaryFields(${tracker_id})"	size="${selectionSize}" multiple="true"
						 ondblclick="summary_${tracker_id}.transferRight()" styleClass="fixMiddleSelectWidth">
				<c:forEach items="${tracker.nonSummaryFields}" var="fld">
					<html:option value="${fld.id}">
						<spring:message code="tracker.field.${fld.label}.label" text="${fld.label}"/>
					</html:option>
				</c:forEach>
			</html:select>
		</TD>

		<TD VALIGN="MIDDLE" ALIGN="CENTER">
			<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="RIGHT" onclick="summary_${tracker_id}.transferRight()" value="&nbsp;&gt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>

			<TR>
				<TD HEIGHT="4"></TD>
			</TR>

			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="RIGHT" onclick="summary_${tracker_id}.transferAllRight()" value="&nbsp;&gt;&gt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>

			<TR>
				<TD HEIGHT="4"></TD>
			</TR>

			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="LEFT" onclick="summary_${tracker_id}.transferLeft()"	value="&nbsp;&lt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>

			<TR>
				<TD HEIGHT="4"></TD>
			</TR>

			<TR>
				<TD NOWRAP ALIGN="CENTER">
					&nbsp;
					<html:button styleClass="button" property="LEFT" onclick="summary_${tracker_id}.transferAllLeft()" value="&nbsp;&lt;&lt;&nbsp;" />
					&nbsp;
				</TD>
			</TR>
			</TABLE>
		</TD>

		<TD class="optional"><spring:message code="report.summary.fields.selected.label" text="Selected Summaries"/>:</TD>

		<TD NOWRAP VALIGN="TOP">
			<html:select property="selectedSummaryFields(${tracker_id})" size="${selectionSize}" multiple="true"
						 ondblclick="summary_${tracker_id}.transferLeft()" styleClass="fixMiddleSelectWidth">
			<c:forEach items="${tracker.summaryFields}" var="fld">
				<html:option value="${fld.id}">
					<spring:message code="tracker.field.${fld.label}.label" text="${fld.label}"/>
				</html:option>
			</c:forEach>
			</html:select>
		</TD>
	</TR>


	<%-- Order By Columns --%>
	<ui:title style="headline.grayed" colSpan="7" alreadyInTable="true" >
		<spring:message code="tracker.view.sorting.label" text="Sorting"/>
	</ui:title>

	<c:set var="visibleOrderBy" value="${fn:length(tracker.orderByColumns)}" />
	<c:if test="${visibleOrderBy < 1}">
		<c:set var="visibleOrderBy" value="1" />
	</c:if>
	<c:set var="totalOrderBy" value="10" />

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
var nextSortingField${tracker.id} = ${visibleOrderBy};
var maxSortingField = ${totalOrderBy};

function addSortingField${tracker.id}() {
	if (nextSortingField${tracker.id} > maxSortingField) {
		return;
	}
	var trId = "trSorting_${tracker.id}_" + nextSortingField${tracker.id};
	var tr = document.getElementById(trId);
	if (tr == null) {
		return;
	}
	tr.className = "";
	nextSortingField${tracker.id}++;

	// remove the control
	if (nextSortingField${tracker.id} >= maxSortingField) {
		tr = document.getElementById("trSortingControl${tracker.id}");
		tr.className = "invisible";
	}
}
</SCRIPT>
	<TR>
		<TD COLSPAN="7">
			<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="2">
				<c:forEach begin="0" end="${totalOrderBy - 1}" var="idx">

				<c:set var="trClass" value="normal" />
				<c:if test="${idx >= visibleOrderBy}">
					<logic:empty property="orderByColumnIds(${tracker_id}_${idx})" name="addUpdateTrackerReportForm">
						<c:set var="trClass" value="invisible" />
					</logic:empty>
				</c:if>

				<TR id="trSorting_${tracker.id}_${idx}" class="${trClass}">
					<TD>
					<STRONG><spring:message code="tracker.view.orderBy.label" text="Order By"/>:</STRONG>
					<html:select property="orderByColumnIds(${tracker_id}_${idx})" styleClass="fixMiddleSelectWidth">
						<html:option value="">
							<spring:message code="tracker.view.none.label" text="-- None --"/>
						</html:option>
						<c:forEach items="${tracker.nonOrderByColumns}" var="layoutData">
							<html:option value="${layoutData.id}">
								<spring:message code="tracker.field.${layoutData.label}.label" text="${layoutData.label}"/>
							</html:option>
						</c:forEach>
					</html:select>&nbsp;&nbsp;
					<html:checkbox property="ascend(${tracker_id}_${idx})" value="true">
						<spring:message code="tracker.view.ascending.label" text="Ascending"/>
					</html:checkbox>
					</TD>
				</TR>
				</c:forEach>
				<TR id="trSortingControl${tracker.id}">
					<TD>
						<html:link href="#" onclick="addSortingField${tracker.id}(); return false;"><spring:message code="report.sorting.field.add.label" text="Add Field..."/></html:link>
					</TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
</TABLE>

</tab:tabPane>

</c:forEach>

</tab:tabContainer>

</html:form>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<c:forEach items="${form.trackerMasks}" var="tracker">
	<c:set var="tracker_id" value="${tracker.id}" />
	<c:out value="opt_${tracker_id}.init(document.addUpdateTrackerReportForm);" />
	<c:out value="hist_${tracker_id}.init(document.addUpdateTrackerReportForm);" />
	<c:out value="summary_${tracker_id}.init(document.addUpdateTrackerReportForm);" />
</c:forEach>
</SCRIPT>
