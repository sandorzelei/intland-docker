<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/showErrors.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.ShowErrorsWrapper" %>

<% ShowErrorsWrapper a = ((ShowErrorsWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:showErrors
	errors="<%=a.errors%>"
	messages="<%=a.messages%>"
></gen:showErrors>
