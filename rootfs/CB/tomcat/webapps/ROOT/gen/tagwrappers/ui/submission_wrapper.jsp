<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/submission.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.SubmissionWrapper" %>

<% SubmissionWrapper a = ((SubmissionWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:submission
	userId="<%=a.userId%>"
	userName="<%=a.userName%>"
	cssClass="<%=a.cssClass%>"
	cssStyle="<%=a.cssStyle%>"
	date="<%=a.date%>"
	lastModifiedBy="<%=a.lastModifiedBy%>"
	lastModifiedAt="<%=a.lastModifiedAt%>"
></gen:submission>
