<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/wiki/tab/dynaWysiwygEditor.tag' --%>
<%@ taglib uri="wikitab" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.wiki.tab.DynaWysiwygEditorWrapper" %>

<% DynaWysiwygEditorWrapper a = ((DynaWysiwygEditorWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:dynaWysiwygEditor
	mode="<%=a.mode%>"
	cbProjectID="<%=a.cbProjectID%>"
	cbEntityTypeID="<%=a.cbEntityTypeID%>"
	cbEntityID="<%=a.cbEntityID%>"
></gen:dynaWysiwygEditor>
