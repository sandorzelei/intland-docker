<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/progressBar.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.ProgressBarWrapper" %>

<% ProgressBarWrapper a = ((ProgressBarWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:progressBar
	greenPercentage="<%=a.greenPercentage%>"
	redPercentage="<%=a.redPercentage%>"
	greyPercentage="<%=a.greyPercentage%>"
	totalPercentage="<%=a.totalPercentage%>"
	greenTitle="<%=a.greenTitle%>"
	redTitle="<%=a.redTitle%>"
	greyTitle="<%=a.greyTitle%>"
	id="<%=a.id%>"
	title="<%=a.title%>"
	hideTotal="<%=a.hideTotal%>"
	label="<%=a.label%>"
	percentages="<%=a.percentages%>"
	titles="<%=a.titles%>"
	cssClasses="<%=a.cssClasses%>"
	bgcolors="<%=a.bgcolors%>"
	fontcolors="<%=a.fontcolors%>"
></gen:progressBar>
