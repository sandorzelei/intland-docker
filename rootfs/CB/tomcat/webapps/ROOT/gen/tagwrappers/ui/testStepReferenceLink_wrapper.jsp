<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/testStepReferenceLink.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.TestStepReferenceLinkWrapper" %>

<% TestStepReferenceLinkWrapper a = ((TestStepReferenceLinkWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:testStepReferenceLink
	testStepReference="<%=a.testStepReference%>"
	source="<%=a.source%>"
></gen:testStepReferenceLink>