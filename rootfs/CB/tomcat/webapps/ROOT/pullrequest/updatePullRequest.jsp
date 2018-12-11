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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="popup"/>
<meta name="module" content="sources"/>
<meta name="bodyCSSClass" content="newskin" />

<c:set var="status" value="${updatePullRequestForm.pullRequest.pullRequestStatus}"/>
<c:set var="action" value="${status eq 'COMPLETED' ? 'merge' : (status eq 'REJECTED' ? 'reject' : 'revoke')}"/>

<c:choose>
	<c:when test="${status eq 'COMPLETED'}">
		<c:url var="actionTitleCode" value="pullRequest.merge.action.label"/>
		<c:set var="action" value="merge"/>
	</c:when>
	<c:when test="${status eq 'REJECTED'}">
		<c:url var="actionTitleCode" value="pullRequest.reject.action.label"/>
		<c:set var="action" value="reject"/>
	</c:when>
	<c:when test="${status eq 'PENDING'}">
		<c:url var="actionTitleCode" value="pullRequest.resend.action.label"/>
		<c:set var="action" value="resend"/>
	</c:when>
	<c:otherwise>
		<c:url var="actionTitleCode" value="pullRequest.revoke.action.label"/>
		<c:set var="action" value="revoke"/>
	</c:otherwise>
</c:choose>
<spring:message var="actionTitle" code="${actionTitleCode}" />

<c:url var="actionUrl" value="/proj/scm/pullrequest/${action}.spr?task_id=${updatePullRequestForm.pullRequest.id}"/>

<spring:message var="cancelButton" code="button.cancel"/>

<script type="text/javascript">
$(function() {
	$("#comment").focus();
});

function submitMerge() {
	$(document).ready(function() {
		$("#submitButton").prop('disabled', true);
	    $("#mergeForm").submit();
    });
}

</script>

<form:form action="${actionUrl}" commandName="updatePullRequestForm" method="post" id="mergeForm">
	<form:hidden path="pullRequest.id"/>
	<form:hidden path="pullRequest.pullRequestStatus"/>
	
	<ui:actionMenuBar>${actionTitle}</ui:actionMenuBar>
	
	<ui:actionBar>	
		<input type="submit" class="button" value="${actionTitle}" onclick="return submitMerge(this);" id="submitButton" />
		&nbsp;&nbsp;<input type="button" class="cancelButton" value="${cancelButton}" name="_cancel" onclick="inlinePopup.close();return false;"/>
	</ui:actionBar>

	<table border="0" cellpadding="0" class="formTableWithSpacing" style="margin-right:5px;">
		<tr>
			<td class="optional label"><spring:message code="comment.label" text="Comment"/>:</td>
			<td style="vertical-align:top;">
				<form:textarea path="comment" cols="80" rows="10" cssStyle="width:99%;"/>
			</td>
		</tr>
		<c:if test="${status eq 'PENDING'}">
			<%-- resending the pull request --%>
			<form:hidden path="pullRequest.id"/>

			<tr>
				<td class="mandatory"><spring:message code="tracker.field.Priority.label" text="Priorty"/>:</td>
				<td>
					<form:select path="pullRequest.priority" items="${priorityOptions}" itemValue="id" itemLabel="name"/>
				</td>
			</tr>
			<%--<tr>
				<td class="optional label">Last revision:</td>
				<td>
					<form:select path="pullRequest.sourceLastRevision" items="${changesets}" itemValue="name" itemLabel="description"/>
				</td>
			</tr>--%>
			<c:set var="formId" value="updatePullRequestForm" scope="request"/>
			<c:set var="autoSubmit" value="false" scope="request"/>
			<c:set var="showRadio" value="true" scope="request"/>
			<jsp:include page="includes/changeSets.jsp" flush="true" />
		</c:if>
	</table>
</form:form>
