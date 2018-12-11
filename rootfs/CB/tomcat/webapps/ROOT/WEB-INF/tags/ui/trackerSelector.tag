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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="html" uri="http://struts.apache.org/tags-html" %>

<%@ attribute name="projectId" required="true" type="java.lang.String" description="The project ID in which the trackers/branches should display." %>
<%@ attribute name="multiple" required="false" type="java.lang.Boolean" description="If multiple select can possible in selector." %>
<%@ attribute name="showBranches" required="false" type="java.lang.Boolean" description="If the branches should also include (by default true)." %>
<%@ attribute name="filterTrackerIds" required="false" type="java.lang.String" description="Filter trackers by ids." %>
<%@ attribute name="selectedValue" required="false" description="The value that is selected in the list." %>
<%@ attribute name="callbackFunctionName" required="false" description="Optional callback function after trackers are loaded." %>
<%@ attribute name="htmlName" required="false" description="Optional html name attribute for the generated select list" %>
<%@ attribute name="onlyFilteredTrackers" required="false" description="If true then only the trackers that are in filterTrackerIds are returned" %>
<%@ attribute name="listBranchesOnTopLevel" required="false" description="If true then only the trackers that are in filterTrackerIds are returned" %>

<%! static int idgen = 0; %>
<% jspContext.setAttribute("htmlId", "trackerSelector" + idgen++); %>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/selectorUtils.less' />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/js/selectorUtils.js'/>"></script>

<c:if test="${empty showBranches}">
	<c:set var="showBranches" value="true"/>
</c:if>

<c:if test="${empty onlyFilteredTrackers}">
	<c:set var="onlyFilteredTrackers" value="true"/>
</c:if>

<select id="${htmlId}" class="selector trackerSelectorTag" multiple="multiple" style="display: none" name="${htmlName }"></select>

<script type="text/javascript">
	$(function() {
		var filterTrackerIds = null;
		<c:if test="${not empty filterTrackerIds}">
			filterTrackerIds = "${filterTrackerIds}";
		</c:if>
		var callbackFunctionName = null;
		<c:if test="${not empty callbackFunctionName}">
			callbackFunctionName = "${callbackFunctionName}";
		</c:if>
		var onlyFilteredTrackers = false;
		<c:if test="${not empty onlyFilteredTrackers}">
			onlyFilteredTrackers = ${onlyFilteredTrackers};
		</c:if>
		var listBranchesOnTopLevel = false;
		<c:if test="${not empty listBranchesOnTopLevel}">
			listBranchesOnTopLevel = ${listBranchesOnTopLevel};
		</c:if>
		var config = {
			"projectId" : "${projectId}",
			"multiple" : ${multiple ? 'true' : 'false'},
			"showBranches" : ${showBranches ? 'true' : 'false'},
			"filterTrackerIds" : filterTrackerIds,
			"selectedValue": "${selectedValue}",
			"callbackFunctionName": callbackFunctionName,
			"onlyFilteredTrackers": onlyFilteredTrackers,
			"listBranchesOnTopLevel": listBranchesOnTopLevel
		};
		codebeamer.SelectorUtils.initTrackerSelector($("#${htmlId}"), config);
	});
</script>