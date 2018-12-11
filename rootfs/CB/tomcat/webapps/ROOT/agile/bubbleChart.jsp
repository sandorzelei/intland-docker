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
 *
--%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="main"/>
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin CMDBModule"/>

<style type="text/css">
	.actionBar select, .actionBar input {
		margin-right: 10px;
	}

	#legend .legend-color {
		display: inline-block;
		width: 8px;
		height: 8px;
	}

	#legend, #chart {
		display: inline-block;
	}

	#legend {
		overflow: auto;
		height: 400px;
		width: 500px;
	}

	#showClosed {
		vertical-align: middle;
	}
</style>

<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">
		<ui:actionGenerator builder="agileVersionScopeActionMenuBuilder" actionListName="actions" subject="${subject}">
			<c:if test="${not empty actions}">
				<div class="release-train-icon"></div>
				<div class="release-train">
						<ui:combinedActionMenu actions="${actions}" subject="${subject}"
								   buttonKeys="planner,cardboard,versionStats" cssClass="large" hideMoreArrow="true" />
				</div>
			</c:if>
		</ui:actionGenerator>
		<div class="release-train-extra-icons">
			<ui:combinedActionMenu builder="agileVersionScopeActionMenuBuilder" subject="${subject}" buttonKeys="coverageBrowser,details"
				keys="coverageBrowser,details" cssClass="large" hideMoreArrow="true" />
		</div>
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" projectAware="${subject}"><span class='breadcrumbs-separator'>&raquo;</span><span><spring:message code="cmdb.version.bubbleChart.label" text="Bubble chart"/></span>
			<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
				<span><spring:message code="cmdb.version.bubbleChart.for.label" text="Bubble chart for ${subject.name}" arguments="${subject.name}"/></span>
			</ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<ui:actionBar>
	<form:form method="GET" id="bubbleChartForm">
		<input type="hidden" name="task_id" value="${task_id}"/>
		<c:if test="${not empty possibleFields}">
			<label><spring:message code="cmdb.version.bubbleChart.xaxis.label" text="X axis"/>:</label><form:select path="xAxisFieldId" items="${possibleFields}" itemLabel="label" itemValue="id"></form:select>
			<label><spring:message code="cmdb.version.bubbleChart.yaxis.label" text="Y axis"/>:</label><form:select path="yAxisFieldId" items="${possibleFields}" itemLabel="label" itemValue="id"></form:select>
			<label><spring:message code="cmdb.version.bubbleChart.bubbleSize.label" text="Bubble size"/>:</label><form:select path="bubbleSizeFieldId" items="${possibleFields}" itemLabel="label" itemValue="id"></form:select>
		</c:if>
		<label for="showClosed"><spring:message code="cmdb.version.bubbleChart.showClosed.label" text="Show closed"/>:</label><form:checkbox path="showClosed" id="showClosed"/>
		<spring:message code="button.ok" text="OK" var="buttonLabel"/>
		<input type="submit" class="button" value="${buttonLabel}"/>
	</form:form>
</ui:actionBar>

<div class="contentWithMargins">
	<c:if test="${empty possibleFields}">
		<div class="warning">
			<spring:message code="cmdb.version.bubbleChart.noFields.hint" text="None of the issues in this release have numeric fields."/>
		</div>
	</c:if>
	<c:if test="${not empty chart}">
		<div>
			<div id="chart">
				<tag:transformText value="${chart}" format="W" />
			</div>
			<div id="legend">
				<c:forEach items="${colorMap}" var="entry">
					<div>
						<span class="legend-color" style="background-color: #${entry.value}"></span>
						<c:url value="${entry.key.urlLink}" var="itemUrl"/>
						<a href="${itemUrl}" title="${entry.key.name}">${entry.key.name}</a>
					</div>
				</c:forEach>
			</div>
		</div>
		<script type="text/javascript">
			$(document).ready(function() {
				var cookieValue = "";
				index = 0;
				$("#bubbleChartForm select, #bubbleChartForm input[type=checkbox]").each(function() {
					var $list = $(this);
					if (index != 0) {
						cookieValue += ",";
					}
					cookieValue += "\"" + $list.attr("name") + "\": " + $list.val();
					++index;
				});
				$.cookie("codebeamer.agile.bubbleChart.${task_id}", "{" + cookieValue + "}", { path: contextPath + '/bubblechart', expires: 90, secure: (location.protocol === 'https:')});
			});
		</script>
	</c:if>
</div>
