<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/queryConditionWidget.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.QueryConditionWidgetWrapper" %>

<% QueryConditionWidgetWrapper a = ((QueryConditionWidgetWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:queryConditionWidget
	resultContainerId="<%=a.resultContainerId%>"
	showDefaultQuery="<%=a.showDefaultQuery%>"
	queryId="<%=a.queryId%>"
	queryString="<%=a.queryString%>"
	advancedMode="<%=a.advancedMode%>"
></gen:queryConditionWidget>