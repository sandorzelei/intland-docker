<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/colorPicker.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.ColorPickerWrapper" %>

<% ColorPickerWrapper a = ((ColorPickerWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:colorPicker
	fieldId="<%=a.fieldId%>"
	indicatorId="<%=a.indicatorId%>"
	cssStyle="<%=a.cssStyle%>"
	cssClass="<%=a.cssClass%>"
	dialogCssClass="<%=a.dialogCssClass%>"
	showClear="<%=a.showClear%>"
	disableReservedColors="<%=a.disableReservedColors%>"
></gen:colorPicker>
