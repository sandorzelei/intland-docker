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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	Tag renders a border around some other element, which can be collapsed and expanded then.
	See collapsingBorder.css and CollapsingBorder.js for css and javascript used by this tag.
--%>
<%@ attribute name="label" required="true"
	description="The label appears on the collapsing border" %>
<%@ attribute name="title" required="false"
	description="The title/tooltip appears on the collapsing border" %>
<%@ attribute name="tooltip" required="false"
	description="The (optional) tooltip appears on the collapsing border" %>
<%@ attribute name="cssClass" required="false"
	description="CSS class attribute" %>
<%@ attribute name="cssStyle" required="false"
	description="CSS style attribute" %>
<%@ attribute name="hideIfEmpty" required="false" type="java.lang.Boolean"
	description="Should the collapsing border be hidden if the content is empty? Defaults to false." %>
<%@ attribute name="id" required="false"
	description="The html id of the widget (the container field-set)"%>
<%@ attribute name="open" required="false" type="java.lang.Boolean"
	description="If the content is open/shown. Defaults to false"%>
<%@ attribute name="onChange" required="false" type="java.lang.String"
	description="Optional javascript callback called when toggling changes"%>
<%@ attribute name="toggle" required="false" type="java.lang.String"
	description="The CSS selector of the element which will be show or hidden when the collapsingBoder is toggled"%>
<%@ attribute name="headerContent" required="false" description="A html fragment that will be rendered in the header of the toggle box (after the toggle button)" %>

<%
if (title == null) {
	title = label;
	jspContext.setAttribute("title", title);
}
if (open == null) {
	open = Boolean.FALSE;
	jspContext.setAttribute("open", open);
}
%>

<c:set var="content"><jsp:doBody></jsp:doBody></c:set>
<c:if test="${not (empty content && hideIfEmpty)}">
<fieldset class="collapsingBorder ${open ? 'collapsingBorder_expanded' : 'collapsingBorder_collapsed'} ${cssClass}" style="${cssStyle}"
	<c:if test="${! empty id}">id="${id}"</c:if>
>
	<legend class="collapsingBorder_legend">
		<c:if test="${empty tooltip}">
			<spring:message var="tooltip" code="ui.tag.collapsingBorder.title" arguments="${title}" htmlEscape="true"/>
		</c:if>
		<a href="#" class="collapseToggle" onclick="CollapsingBorder.toggle(this, ${empty onChange ? 'null' : onChange}, '${toggle}'); return false;" title="${tooltip}">${label}</a>
		${headerContent }
	</legend>
	<div class="collapsingBorder_content">${content}</div>
</fieldset>
</c:if>
