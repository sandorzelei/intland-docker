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

<!-- This tag is deprecated! -->

<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<%@ attribute name="resultContainerId" required="true" type="java.lang.String"
			  description="DOM element ID of the result container in which the result should be displayed" %>
<%@ attribute name="showDefaultQuery" required="false" type="java.lang.Boolean"
			  description="Whether default Query should display or not during initialization" %>
<%@ attribute name="queryId" required="false" type="java.lang.Integer"
			  description="ID of the stored Query which should display during initialization" %>
<%@ attribute name="queryString" required="false" type="java.lang.String"
			  description="Query string which should display during initialization" %>
<%@ attribute name="advancedMode" required="false" type="java.lang.Boolean"
			  description="Wheter the mode is Advanced (cbQL string) or not" %>

<link rel="stylesheet" href="<ui:urlversioned value='/queries/queryConditionWidget.less' />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/queries/queryConditionWidget.js'/>"></script>

<div class="headerBody">
	<div class="conditionSelector">
		<div id="queryConditionWidgetContainer">
			<table class="queryCondition">
				<tr>
					<td class="conditions">
						<span class="selectorSection">
							<span class="addButton">&nbsp</span>
							<span id="ajaxLoadingImg"><img src="<c:url value="/images/ajax-loading_16.gif"/>" /></span>
						</span>
						<span class="inputSection">
							<input type="text">
						</span>
					</td>
					<td class="searchButton">
						<spring:message code="search.submit.label" text="GO" />
					</td>
				</tr>
			</table>
		</div>
	</div>
	<div class="advancedLink">
		<a href="#"><spring:message code="queries.advanced.label" text="Advanced"/></a>
	</div>
</div>


<script type="text/javascript">
	(function($) {
		$(function() {

			var widgetContainer = $("#queryConditionWidgetContainer");
			var resultContainer = $("#" + "${resultContainerId}");
			var queryId = ${not empty queryId ? queryId : 'null'};
			var queryString = "${not empty queryString ? queryString : 'null'}";
			var advanced = ${advancedMode ? 'true' : 'false'};

			codebeamer.QueryConditionWidget.init(queryId, queryString, advanced, widgetContainer, resultContainer, {
				"getProjectsUrl" : contextPath + "/ajax/queryCondition/getProjects.spr",
				"getTrackersUrl" : contextPath + "/ajax/queryCondition/getTrackers.spr",
				"getFieldsUrl" : contextPath + "/ajax/queryCondition/getFields.spr",
				"getFieldChoicesUrl" : contextPath + "/ajax/queryCondition/getFieldChoices.spr",
				"getUsersUrl" : contextPath + "/ajax/queryCondition/getUsers.spr",
				"getQueryStructureUrl" : contextPath + "/ajax/queryCondition/getQueryStructure.spr",
				"getExistingReferencesUrl" : contextPath + "/ajax/queryCondition/getExistingReferenceData.spr"
			});

		});
	})(jQuery);
</script>
