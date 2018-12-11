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

<%@page import="com.intland.codebeamer.remoting.GroupType"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="sources"/>
<meta name="moduleCSSClass" content="sourceCodeModule newskin"/>
<meta name="stylesheet" content="sources.css"/>

<script language="javascript" type="text/javascript">
$(document).ready(function() {
	<%-- make pull request updateable --%>
	$(".descriptionBox.editable").dblclick(function() {
		if($(this).hasClass("edited")) {
			return;
		}

		$(this).addClass("edited");
		$(this).removeClass("highlighted");
		$(this).get(0).oldHtml = $(this).html();
		$(this).html($("#updatepullrequest-form").html());
		$(this).find("#updatepullrequest-form").removeClass("inplace-form");

		$(this).find("a").click(function() {
			var $editable = $(this).closest(".edited");
			$editable.removeClass("edited");
			$editable.addClass("highlighted");
			$editable.html($editable.get(0).oldHtml);
			return false;
		});
	});

	codebeamer.addHighlightWithInplaceEditableIcon();
});

function validatePullRequestEditor(form) {
	var nameText = form.elements["name"].value;
	if (trim(nameText).length == 0) {
		alert('"Summary" is required!');
		return false;
	}

	var descriptionText = form.elements["description"].value;
	if (trim(descriptionText).length == 0) {
		alert('"Description" is required!');
		return false;
	}

	return true;
}

$(function(){
	$(".votingwidget").on("beforeRatingSubmitted", Voting.prototype.confirmVoteAndAskComment);
	$(".votingwidget").on("afterRatingSubmitted", function(event, data, votingWidget) {
		// reload window
		window.location.reload();
	});
});

$(function(){
	codeReview.init({
		"entityTypeId": <%=GroupType.TRACKER_ITEM%>,
		"entityId": ${pullRequest.id}
	});
});
</script>

	<c:set var="actionMenuBodyPart">
			<ui:breadcrumbs showProjects="false">
			<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
				<c:out value="${pullRequest.name} ${pullRequest.keyAndId}"/>
			</ui:pageTitle>
			</ui:breadcrumbs>
	</c:set>
	<c:set var="actionMenuRightPart">
		<%-- <ui:rating entity="${pullRequest}" voting="true" /> --%>
	</c:set>
<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">${actionMenuRightPart}</jsp:attribute>
	<jsp:body>${actionMenuBodyPart}</jsp:body>
</ui:actionMenuBar>

<ui:actionBar>
	<ui:rightAlign>
		<jsp:attribute name="rightAligned">
			<jsp:include page="/includes/notificationBox.jsp" >
				<jsp:param name="entityTypeId" value="${GROUP_TRACKER_ITEM}" />
				<jsp:param name="entityId" value="${pullRequest.id}" />
				<jsp:param name="editable" value="true" />
			</jsp:include>
		</jsp:attribute>
		<jsp:body>
			<ui:actionGenerator builder="scmPullRequestActionMenuBuilder" subject="${pullRequest}" actionListName="actions">
				<ui:actionLink keys="mergePullRequest, rejectPullRequest, revokePullRequest, resendPullRequest" actions="${actions}" />
			</ui:actionGenerator>
			<a class="actionLink" href="<c:url value='${pullRequest.targetRepository.urlLink}/pullrequests'/>"><spring:message code="issue.details.back.label" text="Go Back"/></a>

			<spring:message var="voteTooltip" code="${votesRequired > 0 ? 'scm.pullRequest.vote.tooltip.with.required':'scm.pullRequest.vote.tooltip'}" arguments="${votesRequired}" />
			<ui:rating voting="true" entity="${pullRequest}" disabled="${! votingEnabled}" title="${voteTooltip}" />
		</jsp:body>
	</ui:rightAlign>
</ui:actionBar>

<c:set var="autoMergeable" value="${canMerge && !alreadyMerged && (fn:length(conflictHtmls) == 0)}"/>
<c:set var="hasConflicts" value="${!alreadyMerged && (fn:length(conflictHtmls) > 0)}"/>

<div class="contentWithMargins" style="margin-top:0;">
<c:choose>
	<c:when test="${alreadyMerged || pullRequest.pullRequestStatus eq 'COMPLETED'}">
		<%-- greenish --%>
		<c:set var="statusCSS" value="pullRequestCOMPLETED" />
		<c:set var="statusMessage" value="This pull request has been merged."/>
	</c:when>
	<c:otherwise>
		<c:choose>
			<c:when test="${pullRequest.pullRequestStatus eq 'PENDING'}">
				<c:choose>
					<c:when test="${canMerge}">
						<c:choose>
							<c:when test="${autoMergeable}">
								<c:set var="statusCSS" value="pullRequestPENDING_AUTOMERGE"/>
								<c:set var="statusMessage" value="This pull request can be automatically merged."/>
							</c:when>
							<c:otherwise>
								<c:set var="statusCSS" value="pullRequestPENDING_CONFLICTS" />
								<c:set var="statusMessage" value="This pull request would result in ${fn:length(conflictHtmls)} conflicts, and can only be manually merged."/>
							</c:otherwise>
						</c:choose>
					</c:when>
					<c:otherwise>
						<c:set var="statusCSS" value="pullRequestPENDING_WAITING" />
						<c:set var="statusMessage" value="This pull request is waiting for one of the integrators to merge it."/>
					</c:otherwise>
				</c:choose>
			</c:when>
			<c:when test="${pullRequest.pullRequestStatus eq 'REJECTED'}">
				<c:set var="statusCSS" value="pullRequestPENDING_REJECTED"/>
				<c:set var="statusMessage" value="This pull request has been rejected."/>
			</c:when>
			<c:when test="${pullRequest.pullRequestStatus eq 'REVOKED'}">
				<c:set var="statusCSS" value="pullRequestPENDING_REVOKED"/>
				<c:set var="statusMessage" value="This pull request has been revoked."/>
			</c:when>
		</c:choose>
	</c:otherwise>
</c:choose>
<div style="padding: 10px; margin: 1em 0;" class="${statusCSS}">
	<c:out value="${statusMessage}"/>
</div>

<table border="0" class="propertyTable" cellpadding="2">
	<tr>
		<c:url var="sourceBranchUrl" value="${pullRequest.sourceRepository.urlLink}/changesets">
			<c:param name="branchOrTag" value="${pullRequest.sourceBranch}"/>
		</c:url>
		<td class="optional">From:</td>
		<td class="tableItem"><a href="<c:url value="${pullRequest.sourceRepository.urlLink}"/>"><c:out value="${pullRequest.sourceRepository.name}" default="--" /></a> / <a href="${sourceBranchUrl}"><c:out value="${pullRequest.sourceBranch}" default="--" /></a></td>

		<c:url var="targetBranchUrl" value="${pullRequest.targetRepository.urlLink}/changesets">
			<c:param name="branchOrTag" value="${pullRequest.targetBranch}"/>
		</c:url>
		<td class="optional">To:</td>
		<td class="tableItem"><a href="<c:url value="${pullRequest.targetRepository.urlLink}"/>"><c:out value="${pullRequest.targetRepository.name}" default="--" /></a> / <a href="${targetBranchUrl}"><c:out value="${pullRequest.targetBranch}" default="--" /></a></td>

		<td class="optional">Priority:</td>
		<td class="tableItem"><c:out value="${pullRequest.namedPriority.name}"/></td>

		<td class="optional">Merge conflicts:</td>
		<td class="tableItem" style="font-weight: bold; color: ${not empty conflictHtmls ? '#CC0000' : '#078C00'};"><c:out value="${alreadyMerged ? 'Merged' : (pullRequest.pending ? (not empty conflictHtmls ? fn:length(conflictHtmls) : 'No conflicts') : '--')}" /></td>
	</tr>
	<tr>
		<td class="optional">Integrators:</td>
		<td class="tableItem">
			<c:forEach var="integrator" varStatus="status" items="${pullRequest.assignedTo}"><tag:userLink user_id="${integrator.id}" /><c:if test="${not status.last}">, </c:if></c:forEach>
		</td>

		<td class="optional">Sent by:</td>
		<td class="tableItem"><tag:userLink user_id="${pullRequest.submitter.id}" /> <tag:formatDate value="${pullRequest.submittedAt}" /></td>

		<c:choose>
			<c:when test="${(not empty pullRequest.closedAt) && (pullRequest.closedAt >= pullRequest.modifiedAt)}">
				<c:choose>
					<c:when test="${pullRequest.pullRequestStatus eq 'REVOKED'}">
						<c:set var="updatedLabel" value="Revoked by"/>
					</c:when>
					<c:when test="${pullRequest.pullRequestStatus eq 'REJECTED'}">
						<c:set var="updatedLabel" value="Rejected by"/>
					</c:when>
					<c:otherwise>
						<c:set var="updatedLabel" value="Merged by"/>
					</c:otherwise>
				</c:choose>
			</c:when>
			<c:otherwise>
				<c:set var="updatedLabel" value="Updated by"/>
			</c:otherwise>
		</c:choose>
		<td class="optional">${updatedLabel}:</td>
		<td class="tableItem"><tag:userLink user_id="${pullRequest.modifier.id}" /> <tag:formatDate value="${pullRequest.modifiedAt}" /></td>
	</tr>
</table>


<ui:collapsingBorder label="Comment:" hideIfEmpty="false" open="true" cssClass="descriptionBox scrollable separatorLikeCollapsingBorder">
	<div class="descriptionBox pullRequest scrollable ${canUpdate ? 'editable highlighted' : ''}">
		<tag:transformText value="${pullRequest.description}" format="${pullRequest.descriptionFormat}" />
	</div>
</ui:collapsingBorder>

<%-- hidden form for in-place editing --%>
<c:if test="${canUpdate}">
	<div id="updatepullrequest-form" class="inplace-form">
		<c:url var="actionUrl" value="/proj/scm/pullrequest/update.spr"/>
		<form:form action="${actionUrl}" commandName="pullRequest" onsubmit="return validatePullRequestEditor(this)" method="post">
			<input type="hidden" name="task_id" value="${pullRequest.id}"/>
			<form:hidden path="id"/>
			<div>
				<form:input path="name" size="82"/>
			</div>
			<div>
				<form:select path="priority" items="${priorityOptions}" itemValue="id" itemLabel="name"/>
			</div>
			<div>
				<form:textarea path="description" cols="80" rows="10"/>
			</div>
			<div class="okcancel">
				<spring:message var="saveButton" code="button.save"/>
				<input type="submit" class="button" value="${saveButton}" />
				<a href="#" onclick="return false;"><spring:message code="button.cancel"/></a>
			</div>
		</form:form>
	</div>
</c:if>

<tab:tabContainer id="task-details" skin="cb-box">
	<spring:message var="label" code="comments.label" text="Comments"/>
	<tab:tabPane id="task-details-comments-attachments" tabTitle="${label} (${fn:length(comments)})">
		<jsp:include page="includes/comments.jsp" flush="true" />
	</tab:tabPane>
	<c:if test="${!hideTabs}">
		<tab:tabPane id="changesets" tabTitle="Change Sets (${fn:length(changeSets)})">
			<jsp:include page="includes/changeSets.jsp" flush="true" />
		</tab:tabPane>
		<tab:tabPane id="changefiles" tabTitle="Files Changed (${fn:length(changeFiles)})">
			<jsp:include page="includes/changeFiles.jsp" flush="true" />
		</tab:tabPane>
	</c:if>
	<c:if test="${hasConflicts}">
		<tab:tabPane id="conflicts" tabTitle="Merge Conflicts (${fn:length(conflictHtmls)})">
			<jsp:include page="includes/conflicts.jsp" flush="true" />
		</tab:tabPane>
	</c:if>
</tab:tabContainer>

</div>
