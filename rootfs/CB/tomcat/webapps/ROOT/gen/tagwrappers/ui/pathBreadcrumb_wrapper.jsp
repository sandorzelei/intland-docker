<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/pathBreadcrumb.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.PathBreadcrumbWrapper" %>

<% PathBreadcrumbWrapper a = ((PathBreadcrumbWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:pathBreadcrumb
	requestParameterName="<%=a.requestParameterName%>"
	path="<%=a.path%>"
	baseURL="<%=a.baseURL%>"
	separator="<%=a.separator%>"
	rootName="<%=a.rootName%>"
></gen:pathBreadcrumb>
