<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/displaytagPaging.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.DisplaytagPagingWrapper" %>

<% DisplaytagPagingWrapper a = ((DisplaytagPagingWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:displaytagPaging
	itemNumber="<%=a.itemNumber%>"
	items="<%=a.items%>"
	defaultPageSize="<%=a.defaultPageSize%>"
	requestURI="<%=a.requestURI%>"
	excludedParams="<%=a.excludedParams%>"
></gen:displaytagPaging>
