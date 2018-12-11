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
<meta name="decorator" content="main"/>
<meta name="module" content="sources"/>
<meta name="moduleCSSClass" content="sourceCodeModule newskin"/>
<meta name="stylesheet" content="sources.css"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<script type="text/javascript">
	$(function() {
		initRepositoryBox($("#source"));
		initRepositoryBox($("#target"));

		$("#sameBranch").change(function() {
			applySameBranch(true);
		});
		applySameBranch(false);
	});

	function initRepositoryBox($box) {
		// decorate for auto-completion
		var repositoryId = $box.find(".repositoryId").val();

		$box.find(".branchSelector")
		.bind("change, keyup", function() {
				applySameBranch(false);
			})
		.autocomplete({
			source: "${pageContext.request.contextPath}/ajax/getBranchSuggestions.spr?repositoryId=" + repositoryId,
			minLength: 0, // suggest all branches
			select: function(event, ui) {
				updateRepositoryBox($box, ui);
				applySameBranch(true);
			}
		});

		// initialize last change set
		updateRepositoryBox($box, null);
	}

	// Apply the same-branch checkbox
	function applySameBranch(updateTargetBox) {
		var $sameBranchCheckbox = $("#sameBranch");
		var $targetBranchSelector = $("#target .branchSelector");
		if ($sameBranchCheckbox.is(":checked")) {
			var $sourceBranchSelector = $("#source .branchSelector");
			$targetBranchSelector.attr("disabled", true).val($sourceBranchSelector.val());

			if (updateTargetBox) {
				// update the target too
				updateRepositoryBox($("#target"), null);
			}
		} else {
			$targetBranchSelector.attr("disabled", null);
		}
	}

	function updateRepositoryBox($box, ui) {
		var contextPath = "${pageContext.request.contextPath}";

		var $changeSetDetails = $box.find(".changeset");
		$changeSetDetails.html("<img src='" + ajaxBusyIndicator.AJAX_IMAGE_PATH + "'>");

		var repositoryId = $box.find(".repositoryId").val();
		var branch = (ui != null) ? ui.item.value : $box.find(".branchSelector").val();
		var url = contextPath + "/ajax/getLastChangeSet.spr?repositoryId=" + repositoryId + "&branch=" + encodeURI(branch);
		$.ajax({
			url: url,
			success: function(data, textStatus, jqXHR) {
				if(data) {
					$changeSetDetails.html("<table class='details'><tr><td class='submission'>" + data.changeSet.submissionHtml + "</td><td class='revision'><span class='subtext'>Revision <a href='" + contextPath +
							"/changeset/" + escapeHtml(data.changeSet.id) + "'>" + escapeHtml(data.changeSet.revision) + "</a></span><pre class='commitmessage'>" + escapeHtml(data.changeSet.description) + "</pre></td></tr></table>");
				} else {
					$changeSetDetails.html("<span class='subtext'>Last change set not found.</span>");
				}
			},
			error: function(jqXHR, textStatus, errorThrown) {
				$changeSetDetails.html("<span class='subtext'>Error: " + textStatus + " - " + errorThrown + "</span>");
			}
		});
	}
</script>

<style type="text/css">
#labelForSameBranch {
	float:right;
	margin:2px;
	white-space: nowrap;
}
</style>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="pullRequest.new.pagetitle" text="New Pull Request"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<c:url var="actionUrl" value="/proj/scm/pullrequest/send2.spr?repositoryId=${sendPullRequestForm.pullRequest.sourceRepository.id}"/>
<form:form action="${actionUrl}" commandName="sendPullRequestForm" method="post">
	<ui:actionBar>
		<spring:message code='scm.repository.action.send.pull.request.next' text='Next >' var="nextText"/>
		<input type="submit" class="button" value="${nextText}" />

		<c:url var="cancelUrl" value="${sendPullRequestForm.pullRequest.sourceRepository.urlLink}"/>
		<spring:message code='Cancel' text="Cancel" var="cancelButtonText" />
		<input type="button" class="button cancelButton" value="${cancelButtonText}" onclick="document.location='${cancelUrl}'; return false;" />
	</ui:actionBar>

	<table class="contentWithMargins" >
		<tr>
			<td id="source" class="repoBox">
				<form:hidden cssClass="repositoryId" path="pullRequest.sourceRepository.id"/>
				<form:hidden path="pullRequest.sourceRepository.name"/>
				<div class="title">Source</div>
				<div class="header">
					<a href="<c:url value="${sendPullRequestForm.pullRequest.sourceRepository.urlLink}"/>"><c:out value='${sendPullRequestForm.pullRequest.sourceRepository.name}'/></a> / <form:input cssClass="branchSelector" path="pullRequest.sourceBranch"/>
				</div>
				<div class="changeset">
				</div>
			</td>
			<td style="white-space: nowrap; text-align: center;" >
				<div style="font-size:400%; font-weight: bold;">&rarr;</div>
			</td>
			<td id="target" class="repoBox">
				<form:hidden cssClass="repositoryId" path="pullRequest.targetRepository.id"/>
				<form:hidden path="pullRequest.targetRepository.name"/>
				<c:set var="labelForSameBranch">
					<label id="labelForSameBranch" for="sameBranch" title="If changes will be merged to the same branch on the parent repository?">
						<input style="vertical-align: text-bottom;" type="checkbox" checked="true" id="sameBranch"></input>
						Same branch as Source?
					</label>
				</c:set>
				<div class="title">Target ${labelForSameBranch}</div>
				<div class="header">
					<a href="<c:url value="${sendPullRequestForm.pullRequest.targetRepository.urlLink}"/>"><c:out value='${sendPullRequestForm.pullRequest.targetRepository.name}'/></a> / <form:input cssClass="branchSelector" path="pullRequest.targetBranch"/>
				</div>
				<div class="changeset">
				</div>
			</td>
		</tr>
	</table>
</form:form>
