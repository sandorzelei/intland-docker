<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/applyCheckbox.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.ApplyCheckboxWrapper" %>

<% ApplyCheckboxWrapper a = ((ApplyCheckboxWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:applyCheckbox
	initialState="<%=a.initialState%>"
	biDirectional="<%=a.biDirectional%>"
	name="<%=a.name%>"
	fieldId="<%=a.fieldId%>"
	extraCssClass="<%=a.extraCssClass%>"
	leftEditable="<%=a.leftEditable%>"
	rightEditable="<%=a.rightEditable%>"
></gen:applyCheckbox>