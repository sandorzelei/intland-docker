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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:url var="baselinesBaseUrl" value="/proj/baselines.spr">
	<c:param name="proj_id" value="${PROJECT_DTO.id}" />
</c:url>
<c:url var="compareBaselinesUrl" value="/proj/doc/compareBaselines.spr">
	<c:param name="proj_id" value="${PROJECT_DTO.id}" />
</c:url>

<c:set var="baselineInfo">
	<table class="selectedBaselineInfo">
		<tr>
			<td>
				<span class="id"></span>
				<span class="parentTypeId"></span>
				<a href="#" class="name">&nbsp;</a>
				<div class="source">&nbsp;</div>
				<div class="description baseline-description">&nbsp;</div>
			</td>
			<td>
				<span class="date">&nbsp;</span>
				<span class="timestamp"></span>
			</td>
			<td>
				<button class="changeComparison button"><spring:message code="project.baseline.changeComparison.label" text="Change"/></button>
			</td>
		</tr>
	</table>
</c:set>

<div class="baselineListWrapper noSelectionYet">

	<div class="baselineDropArea"><!--
					--><div class="leftBaselineWrapper">
		<div class="leftBaseline">${baselineInfo}</div>
	</div><!--
					--><div class="rightBaselineWrapper">
		<div class="rightBaseline">${baselineInfo}</div>
	</div>
		<c:if test="${canCompareBaseLines}">
			<div class="compareBaselinesCont">
				<spring:message var="compareButton" code="project.baselines.compare.button" text="Compare Selected Baselines"/>
				<spring:message var="compareButtonDisabledTooltip" code="project.baselines.compare.button.disabled.tooltip" text="Please select two baselines to compare"/>
				<spring:message var="compareButtonEnabledTooltip" code="project.baselines.compare.button.enabled.tooltip" text="Please click here to check the compare result"/>
				<button id="compareSelectedBaselines"
						class="button"
						title="${compareButtonDisabledTooltip}"
						data-title-for-enabled-state="${compareButtonEnabledTooltip}"
						data-compare-url="${compareBaselinesUrl}"
						data-base-url="${baselinesBaseUrl}" style="display: none;">${compareButton}</button>
				<img style="display: none" id="baselineCompareInProgress" src="<c:url value="/images/ajax-loading_16.gif"/>" />
			</div>
			<div class="dropHint disableTextSelection">
				<spring:message var="selectToCompareButton" code="project.baselines.select.baseline.button" text="Select Baseline to compare"/>
				<table>
					<tr>
						<td>
							<input type="button" class="button" id="leftBaselineSelector" value="${selectToCompareButton}"
								   onclick='codebeamer.Baselines.selectBaseline(${PROJECT_DTO.id}, "left")'>
						</td>
						<td class="drop">
							<button id="placeHolderCompareSelectedBaselines" class="button" title="${compareButtonDisabledTooltip}" disabled>${compareButton}</button>
						</td>
						<td>
							<input type="button" class="button" id="rightBaselineSelector" value="${selectToCompareButton}"
								   onclick='codebeamer.Baselines.selectBaseline(${PROJECT_DTO.id}, "right")'>
						</td>
					</tr>
				</table>
			</div>
		</c:if>
	</div>

	<ui:actionBar cssClass="filter">
		<ui:actionGenerator builder="baselineFilterActionMenuBuilder" actionListName="baselineActions" subject="${PROJECT_DTO}">
			<ui:actionLink keys="showAll" actions="${baselineActions}" />
			<ui:actionLink keys="showProjectBaselines" actions="${baselineActions}" />
			<ui:actionLink keys="showTrackerBaselines" actions="${baselineActions}" />
			<ui:actionLink keys="showDirectoryBaselines" actions="${baselineActions}" />
		</ui:actionGenerator>
		&nbsp;
	</ui:actionBar>

	<display:table name="${baselines}" id="baseline" requestURI="" defaultsort="3" defaultorder="descending" export="false"
				   class="expandTable" cellpadding="0" decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator"
				   excludedParams="orgDitchnetTabPaneId, requestURI">

		<display:column media="html">
			<div class="issueHandle" style="visibility: hidden"></div>
			<tag:formatDate value="${baseline.dto.createdAt}" var="formattedCreateDate" />
			<ct:call object="${baselineRenderer}" method="renderDescription" return="description" param1="${baseline.dto}" param2="${baselineDecorator}" param3="baselineDescription"/>
			<ct:call object="${baselineRenderer}" method="renderUrlLink" param1="${baseline.dto}" param2="${baselineDecorator}" return="itemUrlLink"/>
			<ct:call object="${completedBaselined}" method="contains" param1="${baseline}" return="isCompleted"/>
			<span class="metaData" style="display: none;"
				  data-baseline-id="${baseline.dto.id}"
				  data-baseline-created-timestamp="${baseline.dto.createdAt.time}"
				  data-baseline-created-date="<c:out value="${formattedCreateDate}" />"
				  data-baseline-name="<c:out value="${baseline.dto.name}" />"
				  data-baseline-url="<c:out value="${itemUrlLink}" />"
				  data-baseline-description="<c:out value="${description}" />"
				  data-baseline-is-completed="${isCompleted }"
				  <c:if test="${baseline.dto.parent != null}">
				  	  <ct:call object="${baselineRenderer}" method="getParent" return="parent" param1="${baseline.dto}" param2="${user}"/>
				  	  data-baseline-parent="<c:out value="${parent.typeId}" />"
				  	  <ct:call object="${baselineRenderer}" method="renderSource" return="source" param1="${baseline.dto}" param2="${user}" param3="${locale}"/>
				  	  data-baseline-source="<c:out value="${source}" />"
				  </c:if>
			></span>
		</display:column>

		<%--<c:if test="${canCompareBaseLines}">
			<display:column media="html">
				<input type="checkbox" name="selectedBaselines" value="${empty baseline.baseline ? baseline.id : baseline.baseline.root.id}" />
			</display:column>
		</c:if>--%>

		<spring:message var="baselineLabel" code="baseline.label" text="Baseline"/>
		<display:column title="${baselineLabel}" property="nameAndDescriptionForBaseline" sortable="false" headerClass="textData expand" class="textData" />

		<spring:message var="baselineCreatedBy" code="baseline.createdBy.label" text="Created by"/>
		<display:column title="${baselineCreatedBy}" sortable="true" sortProperty="sortCreatedAt" headerClass="textData bcbHeader" class="textData columnSeparator" >
			<ui:submission userId="${baseline.dto.owner.id}" userName="${baseline.dto.owner.name}" date="${baseline.dto.createdAt}" cssClass="submission" />
		</display:column>

		<spring:message var="baselineSignature" code="baseline.signed.label" text="Signed"/>
		<display:column title="${baselineSignature}" sortable="false" headerClass="textData" class="textData centered">
			<c:if test="${fn:contains(baseline.dto.comment, 'baseline.signed.label')}">
				<img src="<c:url value='/images/newskin/action/baselines/signed.png'/>"/>
			</c:if>
		</display:column>

		<display:column>
			<ui:actionGenerator builder="baselineListActionMenuBuilder" subject="${baseline}" actionListName="actions">
				<ui:actionLinkList actions="${actions}" keys="Properties,Delete..." cssClass="baselineActions" />
			</ui:actionGenerator>
		</display:column>

	</display:table>
</div>
