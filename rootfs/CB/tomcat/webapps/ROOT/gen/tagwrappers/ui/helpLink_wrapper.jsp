<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/helpLink.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.HelpLinkWrapper" %>

<% HelpLinkWrapper a = ((HelpLinkWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:helpLink
	cssClass="<%=a.cssClass%>"
	cssStyle="<%=a.cssStyle%>"
	helpURL="<%=a.helpURL%>"
	title="<%=a.title%>"
	useImage="<%=a.useImage%>"
	target="<%=a.target%>"
></gen:helpLink>
