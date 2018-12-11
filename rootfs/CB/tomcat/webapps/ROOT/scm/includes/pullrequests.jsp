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
<%@page import="com.intland.codebeamer.persistence.dto.base.IdentifiableDto"%>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@page import="com.intland.codebeamer.ui.view.PriorityRenderer"%>
<%@page import="com.intland.codebeamer.persistence.dto.ScmPullRequestDto"%>

<script type="text/javascript">
$(document).ready(function() {
	$("#pullRequest .pullrequesttitle:not(.closed)").each(function() {
		var pullRequestId = $(this).attr('id');

		var $row = $(this).closest("tr");
		var $mergeable = $row.find(".mergeable");
		var $status = $row.find(".prTextPENDING");
		$mergeable.html("<img src='${pageContext.request.contextPath}/images/newskin/item/scm-pr-progress.gif'/>");
		$row.addClass("mergecheck");
		$status.html("PLEASE WAIT...");

		var url = "${pageContext.request.contextPath}/ajax/isPullRequestMergeable.spr?task_id=" + pullRequestId;
		$.ajax({
			url: url,
			success: function(data, textStatus, jqXHR) {
				$status.html("PENDING");
				$row.removeClass("mergecheck");
				if(data.mergeable) {
					$row.addClass("mergeable");
					$mergeable.html("<div class='mergeable'>Mergeable</div>");
				} else {
					$row.addClass("conflicting");
					$mergeable.html("<div class='conflicting'>Conflict</div>");
				}
			},
			error: function(jqXHR, textStatus, errorThrown) {
				$status.html("PENDING");
				$row.removeClass("mergecheck");
				$mergeable.html("<span class='conflicting'>Error: " + textStatus + " - " + errorThrown + "</span>");
			}
		});
	});
});
</script>

<style type="text/css">
	.switch .active {
		padding-top: 3px;
		padding-bottom: 3px;
	}
	#pullRequest .votes {
	  font-size: 16px;
	  text-align: center;
	  padding-top: 25px;
	}
</style>

<c:set var="urlInOutPostfix" value="${(incoming && !outgoing) ? '/incoming' : (!incoming && outgoing) ? '/outgoing' : ''}" />

<%-- filter --%>
<div class="actionBar actionBarWithButtons">
	<div class="switch" style="margin-left: 0"><tag:joinLines newLinePrefix="">
		<a class="${empty submodule ? 'active' : ''}" href="<c:url value="${repository.urlLink}/pullrequests/pending/${urlInOutPostFix}"/>"><spring:message code="scm.pullRequest.filter.pending" text="Pending"/></a>
		<a class="${submodule eq 'completed' ? 'active' : ''}" href="<c:url value="${repository.urlLink}/pullrequests/completed${urlInOutPostFix}"/>"><spring:message code="scm.pullRequest.filter.completed" text="Completed"/></a>
		<a class="${submodule eq 'rejected'  ? 'active' : ''}"href="<c:url value="${repository.urlLink}/pullrequests/rejected${urlInOutPostFix}"/>"><spring:message code="scm.pullRequest.filter.rejected" text="Rejected"/></a>
		<a class="${submodule eq 'all'  ? 'active' : ''}"href="<c:url value="${repository.urlLink}/pullrequests/all${urlInOutPostFix}"/>"><spring:message code="scm.pullRequest.filter.all" text="All"/></a>
		</tag:joinLines></div>
	<div class="switch"><tag:joinLines newLinePrefix="">
		<a class="${incoming && !outgoing ? 'active' : ''}" href="<c:url value="${repository.urlLink}/pullrequests/${empty submodule ? 'pending' : submodule}/incoming"/>">Incoming</a>
		<a class="${!incoming && outgoing ? 'active' : ''}" href="<c:url value="${repository.urlLink}/pullrequests/${empty submodule ? 'pending' : submodule}/outgoing"/>">Outgoing</a>
		<a class="${incoming && outgoing ? 'active' : ''}" href="<c:url value="${repository.urlLink}/pullrequests/${empty submodule ? '' : submodule}"/>">Both</a>
	</tag:joinLines></div>
</div>

<%
	PriorityRenderer priorityRenderer = new PriorityRenderer(request);
%>

<ui:displaytagPaging defaultPageSize="10" items="${pullRequests}" excludedParams="page submodule repositoryId orgDitchnetTabPaneId"/>

<div style="padding-top: 15px;">
	<display:table class="expandTable" requestURI="/repository/${repository.id}/pullrequests/${submodule}${urlInOutPostfix}" name="${pullRequests}" id="pullRequest" cellpadding="0" export="false"
				   pagesize="${pagesize}" partialList="true" size="totalSize" excludedParams="page submodule repositoryId orgDitchnetTabPaneId">

		<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
		<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
		<display:setProperty name="paging.banner.onepage" value="" />
		<display:setProperty name="paging.banner.placement" value="bottom"/>
		<display:setProperty name="basic.empty.showtable" value="false" />

		<spring:message var="sentTitle" code="scm.pullRequest.sent" text="Sent"/>
		<display:column title="${sentTitle}" headerClass="textData" class="textData" style="width:10%; padding-top:2px; padding-bottom:15px;">
			<ui:submission userId="${pullRequest.submitter.id}" userName="${pullRequest.submitter.name}" date="${pullRequest.submittedAt}"/>
		</display:column>

		<spring:message var="commentTitle" code="scm.pullRequest.comment" text="Comment"/>
		<display:column title="${commentTitle}" headerClass="textData expand" class="textDataWrap columnSeparator">
			<div id="${pullRequest.id}" class="pullrequesttitle<c:if test="${pullRequest.closed}"> closed</c:if>">
				<b><a <c:if test="${pullRequest.closed}">class="closedItem"</c:if> href="<c:url value="${pullRequest.urlLink}"/>"><c:out value="${pullRequest.name}" /></a></b>
					<%-- show direction if both directions are listed --%>
				<c:if test="${incoming && outgoing}">
					<small class="subtext"><span style="font-size:150%; font-weight:bold;"><img src="${pageContext.request.contextPath}/images/newskin/item/${(pullRequest.targetRepository.id eq repository.id) ? 'request-incoming.png' : 'request-outgoing.png'}"/></span> <c:out value="${(pullRequest.targetRepository.id eq repository.id) ? pullRequest.sourceRepository.name : pullRequest.targetRepository.name} / ${(pullRequest.targetRepository.id eq repository.id) ? pullRequest.sourceBranch : pullRequest.targetBranch}"/></small>
				</c:if>
			</div>
			<div>
				<tag:transformText value="${pullRequest.description}" format="${pullRequest.descriptionFormat}" />
			</div>
			<div class="subtext" style="margin-top:0.5em">
				<a href="<c:url value="${pullRequest.urlLink}?orgDitchnetTabPaneId=task-details-comments-attachments"/>">comments</a>
				<span class="separator">&bull;</span>
				<a href="<c:url value="${pullRequest.urlLink}?orgDitchnetTabPaneId=changesets"/>">changes</a>
				<span class="separator">&bull;</span>
				<a href="<c:url value="${pullRequest.urlLink}?orgDitchnetTabPaneId=changefiles"/>">diff</a>
			</div>
		</display:column>

		<spring:message var="priorityTitle" code="scm.pullRequest.priority" text="Priority"/>
		<display:column title="${priorityTitle}" headerClass="textData" class="textData columnSeparator"  style="padding-left: 20px;">
			<div style="margin-top: 15px;">
				<%
					out.print(priorityRenderer.renderNamedPriority(((ScmPullRequestDto) pullRequest).getNamedPriority()));
				%>
			</div>
		</display:column>

		<display:column title="Votes" headerClass="textData" class="textData columnSeparator votes">
			<c:set var="votes" value="${ratingsMappedToId[pullRequest.id].ratingTotal}" />
			<c:choose>
				<c:when test="${votes > 0}"><span class='vote-positive'>+${votes}</span></c:when>
				<c:when test="${votes < 0}"><span class='vote-negative'>${votes}</span></c:when>
				<c:otherwise>${votes}</c:otherwise>
			</c:choose>
		</display:column>

		<spring:message var="statusTitle" code="scm.pullRequest.status" text="Status"/>
		<display:column title="${statusTitle}" headerClass="textData" class="textData columnSeparator">
			<div class="prStatus" style="min-width: 113px;">
				<div class="prStatusIcon prStatusIcon${pullRequest.pullRequestStatus}"></div>
				<div class="prStatusFlag pr${pullRequest.pullRequestStatus}">
					<div class="pr prText${pullRequest.pullRequestStatus}">${pullRequest.pullRequestStatus}</div>
					<c:if test="${(not empty pullRequest.closedAt) && (pullRequest.closedAt >= pullRequest.modifiedAt)}">
						<div class="subtext"><tag:userLink user_id="${pullRequest.modifier.id}"/></div>
					</c:if>
					<div class="mergeable"></div> <%-- will be filled by AJAX --%>
				</div>
			</div>
		</display:column>

	</display:table>
</div>
