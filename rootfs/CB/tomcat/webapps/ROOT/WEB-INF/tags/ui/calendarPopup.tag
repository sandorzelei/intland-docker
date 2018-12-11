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
 *
 * $Id$
--%>
<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>

<%@ tag import="com.intland.codebeamer.date.PredefinedDateRangeSupport" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%--
	Tag renders calendar popup. See calendarPopup.js for related javascript.
	This tag may have a body is inserted before the popup image.
--%>
<%@ attribute name="textFieldId" required="true" description="The id of the date input-text field where the popup value will be written/read from" %>
<%@ attribute name="fieldLabel" required="false" description="The label/text will be displayed in the calendar title, this helps to identifies the calendar" %>

<%@ attribute name="otherFieldId" required="false" description="The id of the other field to copy initial value, if the normal field is empty. Use for ranges!" %>
<%@ attribute name="disabled" required="false" type="java.lang.String" description="If the popup is disabled, defaults to false." %>
<%@ attribute name="showTime" required="false" type="java.lang.Boolean" description="If time should be displayed." %>

<c:if test="${empty fieldLabel}">
	<c:set var="fieldLabel" value="" />
</c:if>
<c:if test="${empty otherFieldId}">
	<c:set var="otherFieldId" value="" />
</c:if>
<c:if test="${empty disabled}">
	<c:set var="disabled" value="false" />
</c:if>
<c:if test="${empty showTime}">
	<c:set var="showTime" value="true" />
</c:if>

<c:url var="initButtonImg" value="/images/newskin/action/calendar.png"/>

<jsp:doBody/>
<c:if test="${!disabled}">
	<img id="calendarLink_${textFieldId}" class="calendarAnchorLink" src="${initButtonImg}">
	<script type="text/javascript">
		$(function() {
			$("#calendarLink_" + "${textFieldId}").click(function() {
				jQueryDatepickerHelper.initCalendar('${textFieldId}', '${otherFieldId}', '${fieldLabel}', ${showTime});
			});
		})
	</script>
</c:if>


