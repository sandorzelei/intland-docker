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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<script type="text/javascript">

	var reminderFormDefaults = {
		inLabel		: '<spring:message code="issue.reminder.offset.label"   text="in" javaScriptEscape="true" />',
		inTooltip   : '<spring:message code="issue.reminder.offset.tooltip" text="Remind me in this number of seconds/minutes/hours/days (working time) from now" javaScriptEscape="true" />',
		units 		: [{ id : 6, name : '<spring:message code="timeunit.days"    text="days"    javaScriptEscape="true" />' },
					   { id : 5, name : '<spring:message code="timeunit.hours"   text="hours"   javaScriptEscape="true" />' },
					   { id : 4, name : '<spring:message code="timeunit.minutes" text="minutes" javaScriptEscape="true" />' }],
		atLabel		: '<spring:message code="issue.reminder.dueDate.label"   text="or on" javaScriptEscape="true" />',
		atTooltip	: '<spring:message code="issue.reminder.dueDate.tooltip" text="Remind me at this date" javaScriptEscape="true" />',
		timeLabel	: '<spring:message code="issue.reminder.dueTime.label"   text="at" javaScriptEscape="true" />',
		timeTooltip	: '<spring:message code="issue.reminder.dueTime.tooltip" text="Remind me at this time on the specified date" javaScriptEscape="true" />',
		hoursLabel  : '<spring:message code="issue.reminder.hours.label"     text="hrs" javaScriptEscape="true" />',
		datepicker  : ${decorated.datePickerJSON}
	};

	var reminderDialogDefaults = {
		submitUrl		: '<c:url value="/trackers/ajax/addReminder.spr?task_id="/>',
		title     		: '<spring:message code="issue.reminder.tooltip" text="Please send me a reminder via email ..." javaScriptEscape="true" />',
		submitText    	: '<spring:message code="button.ok" 	text="OK" 		javaScriptEscape="true"/>',
		cancelText   	: '<spring:message code="button.cancel" text="Cancel" 	javaScriptEscape="true"/>'
	};


	function createIssueReminder(menuItem, issueId) {
		$(menuItem).showReminderDialog(issueId, reminderFormDefaults, $.extend( {}, reminderDialogDefaults, {
			submitUrl : reminderDialogDefaults.submitUrl + issueId
		}), function(reminder) {
			document.location.href = '<c:url value="/issue/"/>' + issueId + '?orgDitchnetTabPaneId=task-escalation-schedule';
		});

		return false;
	}

</script>
