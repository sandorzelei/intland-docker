<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/wiki/tab/wikiFormatSelect.tag' --%>
<%@ taglib uri="wikitab" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.wiki.tab.WikiFormatSelectWrapper" %>

<% WikiFormatSelectWrapper a = ((WikiFormatSelectWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:formatSelect
	id="<%=a.id%>"
	formControl="<%=a.formControl%>"
	tabContainerId="<%=a.tabContainerId%>"
	name="<%=a.name%>"
	value="<%=a.value%>"
	springPath="<%=a.springPath%>"
	strutsProperty="<%=a.strutsProperty%>"
	disabled="<%=a.disabled%>"
></gen:formatSelect>
