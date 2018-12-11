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

<%--
 Fragment prints out the progress when repository SCM checkout or synchronization is running.
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<style>
<!--
	.RUNNING {
		background: url('<c:url value="/images/ajax-loading_16.gif"/>') no-repeat;
		padding-left: 20px;
	}
	.WAITING, .FINISHED {
		background: url('<c:url value="/images/r_arrow.gif"/>') no-repeat;
		padding-left: 20px;
	}
	.steps li {
		list-style: none;
	}
-->
</style>

<div class="warning" style="margin: 10px 0px;">
	<h3 style="margin-top:0;"><spring:message code="scm.repository.jobs.running.label" text="Please wait, SCM Repository is being refreshed."/></h3>

	<ul class="steps">
		<c:forEach var="subTask" items="${repoSynchState.subTasks}">
			<li>
				<span class='${ui:removeXSSCodeAndHtmlEncode(subTask.state)}'>
					<spring:message var="taskLabel" code="scm.repository.jobs.${subTask.name}.label" />
					${ui:removeXSSCodeAndHtmlEncode(taskLabel)} <spring:message code="scm.repository.jobs.state.${subTask.state}"/>
				</span>
			</li>
		</c:forEach>
		<c:if test="${! empty repoSynchState.user}">
			<li>
				<span class="WAITING">
					<c:set var="userLink"><tag:userLink user_id="${repoSynchState.user.id}"/></c:set>
					<%-- user name and others are escaped in userlink tag class --%>
					<spring:message code="scm.repository.jobs.send.notification.email.to" arguments="${userLink}"
						argumentSeparator="|do-not-separate|" htmlEscape="false" />
				</span>
			</li>
		</c:if>
	</ul>
</div>
<script type="text/javascript">
	window.setTimeout(function() {window.location.reload();}, 3000);
</script>

