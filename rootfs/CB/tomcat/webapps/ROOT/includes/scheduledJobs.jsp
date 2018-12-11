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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<jsp:include page="/includes/jiraConnection.jsp"/>

<div class="actionBar empty">
</div>

<div id="${param.scheduledJobsPrefix}ScheduledJobsList">
	<spring:message code="${param.scheduledJobsPrefix}.jobs.none" text="There are currently no jobs to execute (periodically)" />
</div>

<script type="text/javascript" src="<ui:urlversioned value='/includes/scheduledJobs.js'/>"></script>
<script type="text/javascript">
	$('#${param.scheduledJobsPrefix}ScheduledJobsList').showScheduledJobs(${param.objectId}, ${scheduledJobs}, {
		jobLabel 		: '<spring:message code="project.job.name.label"		text="Job" javaScriptEscape="true"/>',
		jobHelpTitle	: '<spring:message code="project.job.help.tooltip"		text="Get more information about this job" javaScriptEscape="true"/>',
		jobIntervalLabel: '<spring:message code="project.job.interval.label"	text="Interval" javaScriptEscape="true"/>',
		jobIntervalTitle: '<spring:message code="project.job.interval.tooltip"	text="The interval, to periodically execute this job in the background, or empty, to not run the job periodically." javaScriptEscape="true"/>',
		lastAtLabel     : '<spring:message code="project.job.lastAt.label"		text="Last execution" javaScriptEscape="true"/>',
		lastAtTitle     : '<spring:message code="project.job.lastAt.tooltip"	text="The date and time of the last job execution, or empty, if the job has not been executed yet." javaScriptEscape="true"/>',
		nextAtLabel     : '<spring:message code="project.job.nextAt.label"		text="Next execution" javaScriptEscape="true"/>',
		nextAtTitle     : '<spring:message code="project.job.nextAt.tooltip"	text="The date and time of the next scheduled job execution, or empty, if the job has no scheduled next execution date." javaScriptEscape="true"/>',
		inlineEditHint  : '<spring:message code="tracker.field.layout.inline.edit.hint" text="Click to edit" javaScriptEscape="true"/>',
	    refreshTitle    : '<spring:message code="project.jobs.schedule.refresh" text="Reload the job execution schedule" javaScriptEscape="true"/>',
	    runLabel    	: '<spring:message code="project.job.run.label"			text="Run now" javaScriptEscape="true"/>',
	    runTitle    	: '<spring:message code="project.job.run.tooltip"		text="Run the specified job immediately and synchronously in the foreground" javaScriptEscape="true"/>',
	    startLabel    	: '<spring:message code="project.job.start.label"		text="Start now" javaScriptEscape="true"/>',
	    startTitle    	: '<spring:message code="project.job.start.tooltip" 	text="Start executing the specified job immediately but asynchronously in the background" javaScriptEscape="true"/>',
		submitText		: '<spring:message code="button.ok"     				text="OK" javaScriptEscape="true"/>',
		cancelText		: '<spring:message code="button.cancel" 				text="Cancel" javaScriptEscape="true"/>',
	    scheduleURL		: '<c:url value="/docs/ajax/jobSchedules.spr"/>',
		intervalURL		: '<c:url value="/docs/ajax/jobInterval.spr"/>',
	    startURL		: '<c:url value="/docs/ajax/startJobInBackground.spr"/>',
	    runURL			: '<c:url value="/docs/ajax/runJobImmediately.spr"/>',
		runImage		: '<c:url value="/images/exec.gif"/>',
		runningImage	: '<c:url value="/images/ajax-running.gif"/>',
		refreshImage	: '<c:url value="/images/refreshtopic.gif"/>',

		jobHandler 		: {
			"Jira Sync" : jiraSync
		},

		callback		: function() {
			$('#${param.scheduledJobsPrefix}ScheduledJobs').val(JSON.stringify($('#${param.scheduledJobsPrefix}ScheduledJobsList').getScheduledJobs()));
			$('#${param.scheduledJobsPrefix}SaveScheduledJobs').removeAttr('disabled');
			$('#saveButton').click();
		}
	});
</script>

