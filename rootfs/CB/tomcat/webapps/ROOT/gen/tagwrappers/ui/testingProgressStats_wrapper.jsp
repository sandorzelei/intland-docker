<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/testingProgressStats.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.TestingProgressStatsWrapper" %>

<% TestingProgressStatsWrapper a = ((TestingProgressStatsWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:testingProgressStats
	engine="<%=a.engine%>"
	showStatsNumbers="<%=a.showStatsNumbers%>"
></gen:testingProgressStats>