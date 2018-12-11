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
<%@ page import="java.util.Map"%>
<%@ page import="com.intland.codebeamer.manager.testmanagement.parameters.TestParameters"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>

<%--
	Shows the TestParameters as table
	 inputs:
	  * ${testParameters} The TestParameters object
	  * ${usedParameters} Collection<String> the names of the used parameters (highlighted in table)
	  * ${singleSelect} Set to true to render radio buttons to select one of the Test Parameters
	  * ${selectedParameterHash} The hash of the parameter should be selected
--%>
<c:if test="${empty usedParameters}">
	<c:set var="usedParameters" value=""/>
</c:if>

<ct:call return="emptyTestParameters" object="${testParameters}" method="isEmpty" />
<c:choose>
	<c:when test="${empty testParameters || emptyTestParameters}">
		--
	</c:when>
	<c:otherwise>
		<c:if test="${! empty usedParameters}">
			<div class="hint">
				<spring:message code="testing.parameters.overview.parameters.values.hint" arguments="<span class='usedParameter'>,</span>"
					text="Hint: Used parameters are bold."
				/>
			</div>
		</c:if>

		<%-- TODO: displaytag export throws an exception, why? --%>
		<ct:call object="${testParameters}" method="iterator" return="params"/>
		<display:table export="false" class="testParametersTable expandTable" cellpadding="0" name="${params}" id="parameterRow">
			<c:if test="${param.singleSelect == 'true'}">
				<display:column class="checkbox-column-minwidth" headerClass="checkbox-column-minwidth">
					<%
						String parameterHash = TestParameters.getParametersHash((Map) parameterRow);
						pageContext.setAttribute("parameterHash", parameterHash);
					%>
					<input class="parameterHashSelect" type="radio" name="parameterHash" value="${parameterHash}"
						<c:if test="${param.selectedParameterHash == parameterHash}"> checked="checked" </c:if>
					/>
				</display:column>
			</c:if>

			<c:forEach var="parameterName" items="${testParameters.parameterNames}">
				<%-- highlighting used parameters and values --%>
				<c:remove var="cssClass" />
				<ct:call object="${usedParameters}" method="contains" return="used" param1="${parameterName}"/>
				<c:if test="${used}">
					<c:set var="cssClass" value="usedParameter" />
				</c:if>
				<c:set var="parameterNameEscaped"><c:out escapeXml="true" value="${parameterName}"/></c:set>

				<display:column title="${parameterNameEscaped}" class="parameterData ${cssClass}" headerClass="${cssClass}" property="${parameterName}" escapeXml="true"/>
			</c:forEach>
		</display:table>

		<ui:delayedScript>
		<style type="text/css">
			.usedParameter {
				font-weight: bold !important;
			}
		</style>
		</ui:delayedScript>
	</c:otherwise>
</c:choose>

<c:if test="${param.singleSelect == 'true'}">
	<script type="text/javascript">
	var radio = "input[name='parameterHash']";

	$(function() {
		// when clicking on the row select the radio button too
		clickOnTableRowSelectsInside("table.testParametersTable tr td", radio);
	});

	function getSelectedParameterHash() {
		return $(radio + ":checked").first().val();
	}
	</script>
</c:if>

<%--
	<pre>${testParameters}</pre>
--%>
