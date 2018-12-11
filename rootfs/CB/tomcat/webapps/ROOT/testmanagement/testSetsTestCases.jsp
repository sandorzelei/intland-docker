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

<%--
	 JSP fragment renders TestCases/child-TestSets of a TestSet. This is a separate JSP because it is used by ajax code too

	 parameters:
	 	request.testCases - should contain the Test-Cases or Test-Sets to render
	 	param.editable 	  - boolean if the test-cases are editable
--%>
<%@page import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@ page import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<link rel="stylesheet" href="<ui:urlversioned value="/testmanagement/testSetsTestCases.less" />" type="text/css" media="all" />

<c:set var="editable" value="${empty param.editable || param.editable == 'true'}" />
<%
	TrackerSimpleLayoutDecorator decorator = new TrackerSimpleLayoutDecorator();
	request.setAttribute("decorator", decorator);
%>

<spring:message var="emptyMessage" code="testset.editor.testcases.table.drop.testcases.here" />
<c:set var="emptyMessageRow">
	<tr class="empty"><td colspan="{0}">${emptyMessage}</td></tr>
</c:set>

<c:set var="testCaseIcons">
	<spring:message var="deleteTitle" code="testset.editor.testcases.delete.button.title" text="Click to delete this TestCase from Test Set" />
	<img class="deleteTestCaseIcon" src="<c:url value='/images/edittrash.gif'/>" title="${deleteTitle}" /> <%-- TODO: i18n, is this the same icon we use for deleting other places?  --%>

	<spring:message var="removeDuplicatesTitle" code="testset.editor.testcases.removeDuplicates.button.title" />
	<img class="removeOtherDuplicates" src="<c:url value='/images/page_white_stack.png'/>" title="${removeDuplicatesTitle}" />

	<spring:message var="expandTestSet" code="testset.editor.testsets.expand.button.title" />
	<img class="expandTestSet" src="<c:url value='/images/arrow_out.png'/>" title="${expandTestSet}" />
</c:set>
<c:set var="dragRowCssClass" value="${editable ? 'dragRow' : ''}" />

<c:if test="${empty testCaseLabel}">
	<spring:message var="testCaseLabel" code="testset.editor.testcase.or.testset.label" />
</c:if>
<spring:message var="statusLabel" code="tracker.field.Status.label" />
<spring:message var="priorityLabel" code="tracker.field.Priority.label" />
<spring:message var="statusLabel" code="tracker.field.Status.label" />
<spring:message var="submittedAtLabel" code="issue.submittedAt.label" text="Submitted at" />
<spring:message var="submittedByLabel" code="issue.submitter.label" text="Submitted by" />
<display:table requestURI="" export="false" class="expandTable dragReorder highlightedTable" htmlId="testCasesTable" pagesize="${pagesize}"
	cellpadding="0"  name="${testCases}" id="testCase" decorator="decorator">
	<display:setProperty name="paging.banner.placement" value="bottom" />
	<c:if test="${editable}">
		<display:setProperty name="basic.msg.empty_list_row" value="${emptyMessageRow}" />
	</c:if>

	<c:if test="${editable}">
		<display:column title="" headerClass="numberData action-column-minwidth" class="${dragRowCssClass} action-column-minwidth" sortable="false">
			${testCaseIcons}
		</display:column>
	</c:if>

	<display:column title="${testCaseLabel}" class="textDataWrap columnSeparator expandText ${dragRowCssClass}" sortable="false" >
		<input type="hidden" name="testCaseIdsInOrder" value="${testCase.id}" />

		<c:set var="text">
			<tag:joinLines newLinePrefix="" >
				<c:if test="${(! empty requestScope.PROJECT_DTO) && (! empty testCase.project) && (requestScope.PROJECT_DTO.id != testCase.project.id)}">
					<c:out value="${testCase.project.name}"/>&nbsp;&rarr;&nbsp;
				</c:if>
				[<c:out value='${testCase.keyAndId}'/>]&nbsp;
				<%TrackerItemDto tc = (TrackerItemDto) pageContext.getAttribute("testCase");%>
				<%=decorator.getPathAndName(tc) %> <%-- Note: already html-escaped --%>
			</tag:joinLines>
		</c:set>

		<ui:wikiLink item="${testCase}" target="${empty param.openInSameWindow || ! param.openInSameWindow ? '_blank' : ''}">
			${text}
		</ui:wikiLink>

	</display:column>

	<display:column title="${statusLabel}" class="textData columnSeparator" property="status" />

	<display:column title="${priorityLabel}" class="textData columnSeparator" property="priority" sortable="false" />

	<display:column title="${submittedAtLabel}" class="textData" sortProperty="submittedAt" sortable="true" property="submittedAt" />
	<display:column title="${submittedByLabel}" class="textData" sortable="true" property="submitter" />
</display:table>

<spring:message var="showChildren" code="issue.children.show.tooltip" text="Show children" javaScriptEscape="true"/>
<spring:message var="hideChildren" code="issue.children.hide.tooltip" text="Hide children" javaScriptEscape="true"/>

<c:if test="${! editable}"> 	<%-- on the editor don't allow expanding TestSets to TestCases because that can not work properly with the drag-drop-reorder --%>
<script type="text/javascript">
$(function() {
	$("#testCasesTable").trackerItemTreeTable({
		columnIndex: ${editable ? 1: 0},
		expandString : "${showChildren}",
		collapseString : "${hideChildren}",
		ajaxUrl   : "<c:url value='/ajax/testset/testCasesListForTestSet.spr'/>",		// same url used when drag-dropping the TestSet/TestCase on the edit page
		ajaxAsync : false,
		ajaxCache : false,
		ajaxItemParamName: "testCaseOrTestSetIds[]",
		ajaxData  : {
			"allowDuplicates": true,
			"expandTestSets": true,	// expand the TestSet one level down
			"editable": ${editable}
		},
		isExpandable: function(row) {
			var isTestSet = $(row).hasClass("itemType_Testset");
			return isTestSet;	// TestSets are expandable to their TestCases...
		}
	});
});

</script>
</c:if>


