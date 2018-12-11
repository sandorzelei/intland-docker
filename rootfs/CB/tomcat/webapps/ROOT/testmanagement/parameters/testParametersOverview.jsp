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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="taglib" prefix="tag" %>

<c:choose>
<c:when test="${testParametersOverviewModel != null}">

<style type="text/css">
.parameterHasNoValue, .parameterValue_missing, .parameterValue_missingOnSomeTestCases {
	color: red !important;
	font-weight: bold !important;
}
.parameterValueStatus {
	white-space: nowrap;
}
.collapsingBorder {
	position: relative;
}
.collapsingBorder .hint {
	/*
	position: absolute;
	top: -3px;
	left: 20em;
	*/
	min-width: 20em;
}
</style>

<div class="hint" style="margin-top: 10px;" >
	<spring:message code="testing.parameters.overview.${testParametersOverviewModel.singleTestCase ? 'testcase' : 'testset'}.hint"/>
	<br/><spring:message code="testing.parameters.overview.inheritance.hint" />
</div>

<spring:message var="usedParametersLabel" code="testing.parameters.overview.used.parameters.label" text="Used Parameters" />
<ui:collapsingBorder label="${usedParametersLabel}" open="true" cssClass="descriptionBox scrollable separatorLikeCollapsingBorder">
<c:choose>
	<c:when test="${empty testParametersOverviewModel.usedParameters}">
		<spring:message code="None" text="None" />
	</c:when>
	<c:otherwise>
		<div class="hint"><spring:message code="testing.parameters.overview.used.parameters.hint" /></div>
		<display:table class="expandTable" cellpadding="0" name="${testParametersOverviewModel.usedParameters}" id="parameterName">
			<ct:call return="valueStatus"  object="${testParametersOverviewModel}" method="getValueStatus" param1="${parameterName}" />
			<c:set var="definedInTestCases" value="${testParametersOverviewModel.parametersDefinedInTestCases[parameterName]}"/>
			<c:set var="parameterValueCss" value="parameterValue_${valueStatus}" />

			<spring:message var="label" code="testing.parameters.overview.parameter.name" text="Parameter Name" />
			<display:column title="${label}" class="${parameterValueCss}">
				<c:out value="${parameterName}" />
			</display:column>

			<spring:message var="hasValueLabel" code="testing.parameters.overview.parameter.has.value" text="Has value?" />
			<display:column title="${hasValueLabel}" class="parameterValueStatus ${parameterValueCss}" headerClass="${! testParametersOverviewModel.singleTestCase ? 'column-minwidth' :''}">
				<spring:message code="testing.parameters.overview.parameter.value.${valueStatus}" />
			</display:column>

			<c:if test="${! testParametersOverviewModel.singleTestCase}">
			<spring:message var="label" code="testing.parameters.overview.parameter.used.in" text="Used in" />
			<display:column title="${label}">
				<c:set var="usedBy" value="${testParametersOverviewModel.parameterUsage[parameterName]}" />
				<c:forEach var="issue" items="${usedBy}">
					<ct:call return="definedInTestCase" object="${definedInTestCases}" method="contains" param1="${issue}" />
					<a target="_blank" href="<c:url value='${issue.urlLink}'/>" <c:if test='${! definedInTestCase}'> class="${parameterValueCss}" </c:if>><c:out value="${issue.shortDescription}" /></a>&nbsp;
				</c:forEach>
			</display:column>
			</c:if>
		</display:table>
<%--
		<pre class="wiki"><c:forEach var="parameterName" items="${testParametersOverviewModel.usedParameters}"><c:out value="${parameterName}"/>
</c:forEach></pre>
--%>
	</c:otherwise>
</c:choose>
</ui:collapsingBorder>

<c:set var="usedParameters" value="${testParametersOverviewModel.usedParameters}" scope="request" />
<spring:message var="label" code="testing.parameters.overview.own.parameter.values" text="Own parameter values" />
<ui:collapsingBorder label="${label}" open="true" cssClass="descriptionBox scrollable separatorLikeCollapsingBorder" >
	<c:set var="parameterSource" value="${testParametersOverviewModel.ownParametersDescriptionAsWiki}"/>
	<c:if test="${! empty parameterSource }">
		<spring:message code="testing.parameters.config.label"/>: <tag:transformText value="${parameterSource}" format="W" owner="${testParametersOverviewModel.item}" />
	</c:if>

	<c:set var="testParameters" value="${testParametersOverviewModel.ownParameters}" scope="request" />
	<jsp:include page="./testParametersTable.jsp" />
</ui:collapsingBorder>

<spring:message var="label" code="testing.parameters.overview.inherited.parameter.values" text="Inherited parameter values" />
<ui:collapsingBorder label="${label}" open="true" cssClass="descriptionBox scrollable separatorLikeCollapsingBorder" >
<c:choose>
	<c:when test="${testParametersOverviewModel.nothingInhertied}">
		<spring:message code="testing.parameters.overview.same.parameter.values" text="Same (nothing is inherited from parents)" />
	</c:when>
	<c:otherwise>
		<c:set var="testParameters" value="${testParametersOverviewModel.inheritedParameters}" scope="request" />
		<jsp:include page="./testParametersTable.jsp" />
	</c:otherwise>
</c:choose>
</ui:collapsingBorder>

<%--
<pre class="hint">
testParametersOverviewModel: ${testParametersOverviewModel}
</pre>
--%>
</c:when>
<c:otherwise>
	<div class="warning"><spring:message code="table.nothing.found"/></div>
</c:otherwise>
</c:choose>