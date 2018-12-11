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
<%@tag language="java" pageEncoding="UTF-8" %>
<%@tag import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@tag import="com.intland.codebeamer.manager.testmanagement.TestStep"%>
<%@tag import="com.intland.codebeamer.remoting.DescriptionFormat"%>
<%@tag import="com.intland.codebeamer.wiki.WikiMarkupProcessor"%>
<%@tag import="java.util.HashMap"%>
<%@tag import="java.util.Map"%>
<%@tag import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="taglib" prefix="tag"%>

<%@ attribute name="owner" required="false" description="The wiki context = owner entity may contain the attachments referenced here"
	type="com.intland.codebeamer.persistence.dto.base.IdentifiableDto" %>
<%@ attribute name="testSteps" required="false" type="java.util.List"
		description="List of TestStep objects" %>
<%@ attribute name="tableId" required="true" %>
<%@ attribute name="droppable" required="false" description="if true, then nodes from a tree can be dropped to the steps table" %>
<%@ attribute name="readOnly" required="false" type="java.lang.Boolean" %>
<%@ attribute name="export" required="false" type="java.lang.Boolean" description="If the export is enabled?" %>
<%@ attribute name="uploadConversationId" required="false" %>
<%@ attribute name="onlyTable" required="false" description="If only the table is shown. Defaults to false" %>

<%@ attribute name="showReferences" required="false" description="If the information about the referenced/referencing test-steps are shown. Defaults to true" %>

<tag:catch>
<%
	Map<String,Boolean> tableFieldsHidden = new HashMap();
	jspContext.setAttribute("tableFieldsHidden", tableFieldsHidden); // in case of an exception there will be an empty map here

	if (owner instanceof TrackerItemDto) {
		TrackerSimpleLayoutDecorator decorator = new TrackerSimpleLayoutDecorator(request);
		decorator.initForTrackerItem((TrackerItemDto) owner);

		tableFieldsHidden = decorator.getTableFieldsHidden("Test Steps", "Test Step Results"); // the TestSteps table can be in these fields in TestCase or in TestRun
	}
	jspContext.setAttribute("tableFieldsHidden", tableFieldsHidden);
%>
</tag:catch>

<%-- set default value for export attribute--%>
<c:if test="${empty export}"><c:set var="export" value="false" /></c:if>
<c:if test="${empty showReferences}"><c:set var="showReferences" value="true" /></c:if>

<c:url value='/images/newskin/action/delete-grey-xs.png' var="deleteImgUrl"/>
<c:url value="/images/newskin/action/insert-after.png" var="rowAfterUrl"/>
<c:url value="/images/newskin/action/insert-before.png" var="rowBeforeUrl"/>

<spring:message code="tracker.field.Critical.label" var="criticalLabel" text="Critical"/>
<c:set var="criticalLabelWithHelp">${criticalLabel}<ui:helpLink helpURL="https://codebeamer.com/cb/wiki/95044#section-Test+Step+attributes" target="_blank" cssStyle="margin-left:0px;"/></c:set>

<spring:message code="tracker.field.Action.label" var="actionLabel" text="Action"/>
<spring:message code="tracker.field.Expected result.label" var="expectedResultLabel" text="Expected result"/>
<spring:message code="tracker.table.deleteStep.hint" var="deleteStepHint" text="Delete step"/>
<spring:message code="tracker.table.insertStep.after.hint" var="insertAfterHint"/>
<spring:message code="tracker.table.insertStep.before.hint" var="insertBeforeHint"/>

<c:set var="classes" value="expandTable dragReorder highlightedTable testStepTable ${readOnly ? 'readOnly' : '' } ${tableFieldsHidden['Critical'] == true ? 'criticalColumnHidden':''}"/>
<c:if test="${droppable}">
	<c:set var="classes" value="${classes} jstree-drop"/>
</c:if>

<ui:delayedScript avoidDuplicatesOnly="true">
<script type="text/javascript" src="<ui:urlversioned value="/js/treeToTableDndIntegration.js"/>"></script>
<link rel="stylesheet" href="<ui:urlversioned value='/testmanagement/testSteps.less' />" type="text/css" media="all" />
</ui:delayedScript>

<c:set var="emptyMessageRow">
	<c:if test="${readOnly}">
		<tr class='emptyIndicatorRow'><th colspan="3" style="text-align: left; border:none;"><spring:message code="testcase.editor.no.steps" /></th></tr>
	</c:if>
</c:set>

<c:if test="${not empty owner}">
	<input type="hidden" id="testStepsOwnerId" value="${owner.id}"/>
</c:if>
<display:table requestURI="" export="${export}" class="${classes}" htmlId="${tableId}"
	cellpadding="0" name="${testSteps}" id="step">

	<display:setProperty name="basic.msg.empty_list_row" >${emptyMessageRow}</display:setProperty>
	<display:setProperty name="paging.banner.placement" value="bottom" />

	<c:set var="generatedId" value="${step.generatedId}"/>
	<c:set var="uniqueId" value="${step.generatedId}_${step_rowNum}_" /> <%-- the generatedId is not unique if the two teststep has same text --%>
	<c:if test="${onlyTable == 'true'}">
		<c:set var="uniqueId" value="__uniqueId__" />
	</c:if>

	<c:set var="cellCSSClass" value="textData columnSeparator" />
	<c:set var="rowEditDisabled" value="" />
	<c:set var="linkToReferenced" value="" />
	<c:set var="ref" value="" />
	<c:set var="rowEditReadOnly" value="" />
	<c:set var="trCSSClass" value="" />

	<c:if test="${showReferences && step.referrencing}">
		<c:set var="refStep" value="${step.referredTestStep}" />
		<c:set var="ref" value="${refStep.asString}" />
		<c:set var="cellCSSClass" value="${cellCSSClass} referrencingStep resolveStatus_${refStep.resolveStatus}" />
		<c:set var="rowEditReadOnly" value=" readonly='readonly' " />
		<c:set var="linkToReferenced">
			<spring:message var="referringTitle" code="testcase.editor.referring.title" text="This step is reusing some other Test Step/Test Case" />
			<div class="linkToReferenced" title="${referringTitle}">
				<c:if test="${refStep.resolveStatus != 'Resolved'}">
					<div class="warning">
						<spring:message code="testcase.editor.step.can.not.be.resolved" text="Can not resolve referenced step, because"/>
						<spring:message code="testcase.editor.step.can.not.be.resolved.${refStep.resolveStatus}" text="${refStep.resolveStatus}" />
					</div>
				</c:if>
				<img src="<c:url value='/images/newskin/action/outgoing_ref.png'/>" />
				<spring:message code="testcase.editor.referring.link" text="Referring:" />
				<ui:testStepReferenceLink source="${owner}" testStepReference="${refStep}" />
			</div>
		</c:set>
	</c:if>

	<%-- adding an anchor to jump to when following referencing test-steps --%>
	<c:set var="anchor"><a name="<c:out value='${step.anchorName}' />"></a></c:set>

	<c:set var="hiddenFields">
		<input type="hidden" name="stepIds" value="<c:out value='${step.id}'/>" />
		<input type="hidden" name="generatedId" value="<c:out value='${generatedId}'/>" />
	</c:set>

	<c:set var="reusingMe">
		<c:if test="${showReferences && ! empty step.reusingMeAndExists}">
			<spring:message var="reusingTitle" code="testcase.editor.reusing.title" text="This step is reused by some other Test Step/Test Case" />
			<p class="reusingMe" title="${reusingTitle}">
				<img src="<c:url value='/images/newskin/action/incoming_ref.png'/>" />
				<spring:message code="testcase.editor.reused.by.link" text="Reused by:" />
				<c:forEach var="incomingRef" items="${step.reusingMe}">
					<ui:testStepReferenceLink source="${owner}" testStepReference="${incomingRef}" />
				</c:forEach>
			</p>
		</c:if>
	</c:set>

<c:set var="ownerEntity" value="${empty step.referencedItem ? owner : step.referencedItem}" />
<c:choose>
	<c:when test="${!readOnly }">
		<c:set var="controls">
			<span class="testStepControls">
				<img src="${deleteImgUrl}" class="testStepBtn" onclick="codebeamer.TestStepEditor.get(this).deleteTestStep(this);" title="${deleteStepHint}" alt="${deleteStepHint}"/>
				<img src="${rowBeforeUrl}" class="testStepBtn" onclick="codebeamer.TestStepEditor.get(this).insertStepBefore(this);" title="${insertBeforeHint}"/>
				<img src="${rowAfterUrl}" class="testStepBtn" onclick="codebeamer.TestStepEditor.get(this).insertStepAfter(this);" title="${insertAfterHint}"/>
			</span>
		</c:set>

			<display:column title="" class="dragColumn issueHandle" media="html">
			</display:column>

			<display:column title="" headerClass="operationColumnHeader" class="booleanColumn operationColumn dragRow ${cellCSSClass}" media="html">
				${hiddenFields}
				${controls}
				${anchor}
				<input type="hidden" value="${generatedId}" name="generatedIds"/>
				<input type="hidden" name="referredTestSteps" value="${ref}" />
				<input type="hidden" name="originalTestSteps" value="" />	<%-- The original Test Case where this step was copied from --%>
			</display:column>

			<c:choose>
				<c:when test="${tableFieldsHidden['Critical'] != true}">
					<display:column title="${criticalLabelWithHelp}" headerClass="criticalColumn" class="booleanColumn criticalColumn ${cellCSSClass}" media="html">
						<input class="criticalCheckbox" title="${criticalLabel}" type="checkbox" <c:if test="${step.critical}">checked</c:if> ${rowEditReadOnly} />
						<input type="hidden" value="${step.critical}" name="critical"/>
					</display:column>
				</c:when>
				<c:otherwise>
					<display:column headerClass="column-minwidth" class="column-minwidth booleanColumn ${cellCSSClass}" media="html">
						<input type="hidden" value="${step.critical}" name="critical"/>
					</display:column>
				</c:otherwise>
			</c:choose>
			<display:column title="${actionLabel}" headerClass="actionColumnHeader" class="${cellCSSClass} actionCell thumbnailImages300px" sortable="false" media="html">
				<textarea class="inlineInput" name="actions" id="${uniqueId}actions" ${rowEditReadOnly} data-entity-id="${ownerEntity.id}"><c:out value="${step.action}"/></textarea>
				<c:if test="${not empty uploadConversationId}">
					<input type="hidden" name="conversationId" value="<c:out value='${uploadConversationId}' />">
				</c:if>
				<tag:transformText owner="${ownerEntity}"
					value="${step.action}" format="<%=DescriptionFormat.WIKI%>"
					uploadConversationId="${uploadConversationId}" default="<span class='wikiContent' tabindex='0'></span>"/>
				${linkToReferenced}
				${reusingMe}
			</display:column>
			<display:column title="${expectedResultLabel}" headerClass="expectedResultColumnHeader" class="${cellCSSClass} expectedResultCell thumbnailImages300px" sortable="false" media="html">
				<textarea class="inlineInput" name="expectedResults" id="${uniqueId}expectedResults" ${rowEditReadOnly} data-entity-id="${ownerEntity.id}"><c:out value="${step.expectedResult}"/></textarea>
				<c:if test="${not empty uploadConversationId}">
					<input type="hidden" name="conversationId" value="<c:out value='${uploadConversationId}' />">
				</c:if>
				<tag:transformText owner="${ownerEntity}"
					value="${step.expectedResult}" format="<%=DescriptionFormat.WIKI%>"
					uploadConversationId="${uploadConversationId}" default="<span class='wikiContent' tabindex='0'></span>"/>
			</display:column>
	</c:when>
	<c:otherwise>
			<c:choose>
			<c:when test="${tableFieldsHidden['Critical'] != true}">
			<display:column title="${criticalLabelWithHelp}" headerClass="criticalColumnHeader" class="criticalColumn ${cellCSSClass}" media="html">
				${hiddenFields}
				${anchor}
				<spring:message code="tracker.field.Critical.label" text="Critical" var="criticalLabel"/>
				<c:choose>
					<c:when test="${step.critical}">
						<img src="<c:url value='/images/newskin/action/testrun-critical.png'/>" title="<c:out value='${step.critical ? criticalLabel : ""}'/>"></img>
					</c:when>
					<c:otherwise>-</c:otherwise>
				</c:choose>
			</display:column>
			</c:when>
			<c:otherwise>
				<!-- Critical column is hidden -->
				<display:column title="" headerClass="column-minwidth" class="column-minwidth ${cellCSSClass}" media="html">
					${hiddenFields}
					${anchor}
				</display:column>
			</c:otherwise>
			</c:choose>
			<display:column title="${actionLabel}" headerClass="actionColumnHeader" class="actionColumn ${cellCSSClass} thumbnailImages480px" sortable="false" media="html">
				<tag:transformText owner="${ownerEntity}" value="${step.action}" format="<%=DescriptionFormat.WIKI%>" default="--" />
				${linkToReferenced}
				${reusingMe}
			</display:column>
			<display:column title="${expectedResultLabel}" headerClass="expectedResultColumnHeader" class="expectedResultColumn ${cellCSSClass} thumbnailImages480px" sortable="false" media="html">
				<tag:transformText owner="${ownerEntity}" value="${step.expectedResult}" format="<%=DescriptionFormat.WIKI%>" default="--" />
				<c:if test="${step.autoCopyExpectedResultsSetting}">
					<span class="expectedResultsWikiContent" data-owner="${ownerEntity.interwikiLink}"><c:out value="${step.expectedResult}"/></span>
				</c:if>
			</display:column>
	</c:otherwise>
</c:choose>
	<%-- definitions for exporting as CSV/XML/EXCEL
		TODO: for some reason CSV and XML export does not work, why?
		should be: <c:set var="exportMedias" value="csv xml excel pdf" />
	--%>
	<c:set var="exportMedias" value="excel" />
	<display:column title="${criticalLabel}" media="${exportMedias}" >${step.critical ? 'Y' : 'N'}</display:column>
	<display:column title="${actionLabel}" media="${exportMedias}" >${step.action}</display:column>
	<display:column title="${expectedResultLabel}" media="${exportMedias}" >${step.expectedResult}</display:column>
</display:table>

<c:if test="${!(readOnly || onlyTable == 'true')}">
	<div style="font-size: 80%; margin: 10px 0 10px 15px;">
		<a onclick="codebeamer.TestStepEditor.get('${tableId}').addNewRow('${tableId}');" style="cursor: pointer;"><spring:message code="tracker.table.addStep.label" text="Add step..."/></a>
	</div>

	<script type="text/javascript">
		$(document).ready(function() {
			editor_${tableId} = new codebeamer.TestStepEditor();
			editor_${tableId}.init("${tableId}");
		});
	</script>
</c:if>

<script type="text/javascript">
$(document).ready(function() {
	codebeamer.TestStepEditor.updateTestStepEditorLook($("#${tableId}"));
	window.setTimeout(codebeamer.TestStepEditor.focusTestStepInHash, 100);
});
</script>
