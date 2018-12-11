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
 * $Revision: 23955:cdecf078ce1f $ $Date: 2009-11-27 19:54 +0100 $
--%>
<%@ tag language="java" pageEncoding="UTF-8" %>
<%@ tag import="org.apache.struts.util.LabelValueBean"%>
<%@ tag import="java.util.ArrayList"%>
<%@ tag import="java.util.List"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ attribute name="property" required="true" description="The name of property in nested form to be used to specify duration value."  %>
<%@ attribute name="value" required="true" description="The current value for the property."  %>
<%@ attribute name="allowFutureDuration" required="false" type="java.lang.Boolean" description="Whether durations span into the future are to be shown."  %>

<c:set var="divStyleId" value="${property}DivId" />

<SCRIPT language="JavaScript" type="text/javascript">
<!--
function updateDurationField(selectorId, customFieldsDivId) {
	var selector = document.getElementById(selectorId);
	var customFields = document.getElementById(customFieldsDivId);
	if (!selector || !customFields) {
		return false;
	}

	if (selector.selectedIndex == 0) {
		// enable custom fields
		customFields.className = "";
		customFields.style.display = "inline";
	} else {
		customFields.className = "invisible";
		customFields.style.display = "none";
	}
	return true;
}
-->
</SCRIPT>

<%!
	// map of labels-> values
	static List<LabelValueBean> durationWoFutureOptions = new ArrayList<LabelValueBean>();
	static {
		durationWoFutureOptions.add(new LabelValueBean("User Specified", ""));
		durationWoFutureOptions.add(new LabelValueBean("-",""));	// separator
		durationWoFutureOptions.add(new LabelValueBean("Today",  "this day"));
		durationWoFutureOptions.add(new LabelValueBean("This Week", "this week"));
		durationWoFutureOptions.add(new LabelValueBean("This Month", "this month"));
		durationWoFutureOptions.add(new LabelValueBean("This Quarter", "this quarter"));
		durationWoFutureOptions.add(new LabelValueBean("This Year", "this year"));
		durationWoFutureOptions.add(new LabelValueBean("-",""));	// separator
		durationWoFutureOptions.add(new LabelValueBean("Yesterday",   "past 1 days"));
		durationWoFutureOptions.add(new LabelValueBean("Last 2 Days", "-2"));
		durationWoFutureOptions.add(new LabelValueBean("Last 5 Days", "-5"));
		durationWoFutureOptions.add(new LabelValueBean("Last 7 Days", "-7"));
		durationWoFutureOptions.add(new LabelValueBean("Last 10 Days", "-10"));
		durationWoFutureOptions.add(new LabelValueBean("Last 30 Days", "-30"));
	}
%>

<%!
	static List<LabelValueBean> allDurationOptions = new ArrayList<LabelValueBean>(durationWoFutureOptions);
	static {
		allDurationOptions.add(new LabelValueBean("-",""));	// separator
		allDurationOptions.add(new LabelValueBean("Tomorrow",  "Tomorrow"));
		allDurationOptions.add(new LabelValueBean("Next 2 Days",  "2"));
		allDurationOptions.add(new LabelValueBean("Next 5 Days",  "5"));
		allDurationOptions.add(new LabelValueBean("Next 7 Days",  "7"));
		allDurationOptions.add(new LabelValueBean("Next 10 Days", "10"));
		allDurationOptions.add(new LabelValueBean("Next 30 Days", "30"));
	}
%>

<%
	Boolean allowFutureDuration = (Boolean)jspContext.getAttribute("allowFutureDuration");
	if (allowFutureDuration == null || allowFutureDuration) {
		jspContext.setAttribute("options", allDurationOptions);
	} else {
		jspContext.setAttribute("options", durationWoFutureOptions);
	}
%>

<spring:message var="durationTitle" code="duration.tooltip" text="Choose one of the default periods, or use custom one"/>

<select name="${property}" id="${property}" size="1" onchange="return updateDurationField('${property}', '${divStyleId}');"	title="${durationTitle}">
	<c:forEach items="${options}" var="option" >
		<c:choose>
			<c:when test="${option.label eq '-'}">
				<optgroup class="separator" disabled label="---------------------"></optgroup>
			</c:when>
			<c:otherwise>
				<option value="${option.value}"
					<c:if test="${value eq option.value}">selected="selected"</c:if>
				>
					<spring:message code="${option.label}" text="${option.label}"/>
				</option>
			</c:otherwise>
		</c:choose>
	</c:forEach>
</select>

<div id="${divStyleId}" class="invisible">
	<jsp:doBody />
</div>

<SCRIPT language="JavaScript" type="text/javascript">
<!--
updateDurationField('${property}', '${divStyleId}');
-->
</SCRIPT>
