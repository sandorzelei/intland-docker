<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/showSpringErrors.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.ShowSpringErrorsWrapper" %>

<% ShowSpringErrorsWrapper a = ((ShowSpringErrorsWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:showSpringErrors
	errors="<%=a.errors%>"
></gen:showSpringErrors>
