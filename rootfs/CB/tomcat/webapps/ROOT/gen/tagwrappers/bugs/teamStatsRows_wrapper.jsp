<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/bugs/teamStatsRows.tag' --%>
<%@ taglib uri="bugstaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.bugs.TeamStatsRowsWrapper" %>

<% TeamStatsRowsWrapper a = ((TeamStatsRowsWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:teamStatsRows
	groups="<%=a.groups%>"
></gen:teamStatsRows>