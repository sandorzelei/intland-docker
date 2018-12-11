<%--
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
--%>
<%@ tag language="java" pageEncoding="UTF-8"%>
<%@ tag import="com.intland.codebeamer.ui.view.IssueStatusStyles"%>
<%@ tag import="com.intland.codebeamer.controller.ControllerUtils"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%--
	Simple color picker to choose from the palette.

	Will fire a "change" event on the target field when the color is selected.
--%>
<%@ attribute name="fieldId" required="true" description="The html id for the -typically hidden- field to read/write selected color (hex) code from"%>
<%@ attribute name="indicatorId" required="false" description="The html id for an element. It will show the actually selected color as the background color."%>
<%@ attribute name="cssStyle" required="false" description="The css style to add."%>
<%@ attribute name="cssClass" required="false" description="The css class to add."%>
<%@ attribute name="dialogCssClass" required="false" description="The css class to add to the dialog."%>
<%@ attribute name="showClear" required="false" description="Show or hide clear button."%>
<%@ attribute name="disableReservedColors" type="java.lang.Boolean" required="false" description="There are some colors that are used at some places by codebeamer. If this flag is true then these color options will not be shown in the picker"%>

<c:if test="${empty showClear}">
	<c:set var="showClear" value="${true}" />
</c:if>

<c:if test="${empty indicatorId}">
	<c:set var="indicatorId" value="" />
</c:if>

<%
	// this ensures that the colorPicker.tag/js is using the same palette as in the issueStatusStyles with the correct foreground colors too
	if (request.getAttribute("paletteJson") == null) {
		IssueStatusStyles issueStatusStyles = ControllerUtils.getSpringBean(request, "issueStatusStyles", IssueStatusStyles.class);
		String paletteJson = issueStatusStyles.getPaletteJson(disableReservedColors == null ? false: disableReservedColors.booleanValue());
		request.setAttribute("paletteJson", paletteJson);
%>
<ui:delayedScript avoidDuplicatesOnly="true">
	<script type="text/javascript">
		colorPicker.paletteColors = ${paletteJson};
	</script>
</ui:delayedScript>
<%
	}
%>

<ui:delayedScript avoidDuplicatesOnly="true">
<head>
<style type="text/css">


</style>
</head>
</ui:delayedScript>

<a href="#" title="<spring:message code='colorpicker.title'/>" class="colorPicker yui-skin-sam ${cssClass}" style="${cssStyle}" id="${fieldId}-colorPicker-icon"
	onclick="colorPicker.showPalette(this, '${fieldId}', '${indicatorId}', ${showClear}, '${dialogCssClass}'); return false;" >
	<img src="<c:url value='/images/color_swatch.png'/>" />
</a>

<%--
<ui:delayedScript>
<!-- prints a sample of all palette colors with white and black font color -->
<style type="text/css">
 .sample {
 	/*width: 10em; */
 	float: left;
 	margin-left: 20px;
 	margin-bottom: 5px;
 	text-align: center;
 	padding: 2px;
 }
</style>
<script type="text/javascript">
for (var i=0; i<colorPicker.paletteColors.length; i++) {
	var color = colorPicker.paletteColors[i];
	document.write(color);
	document.write("<div class='issueStatus sample' style='background-color:" + color +"; color: white;'>RESOLVED</div>");
	document.write("<div class='issueStatus sample' style='background-color:" + color +"; color: black;'>RESOLVED</div>");
	document.write("<div style='clear:both;'></div>");
}
</script>
</ui:delayedScript>
--%>
