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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="callTag" prefix="ct" %>

<style type="text/css">
	ul.integrators {
		margin:0;
		padding:0;
		overflow-y: auto;
		overflow-x: hidden;
		float:left;
		width: 100%;
		height: 14em;
		border: solid 1px silver;
	}
	/** hack: IE6/7 scrollbar not visible otherwise */
	.IE6or7 ul.integrators {
		position: relative;
	}

	li.integrator {
		margin:5px 2px;
		overflow:hidden;
		width: 18em;
		float:left;
	}

	li.integrator img {
		vertical-align: middle;
	}
</style>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="pullRequest.new.pagetitle" text="New Pull Request"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<script type="text/javascript">
	$(document).ready(function() {
		$("input[tabindex='1']").focus();

		$("#select-all").click(function() {
			$(".integrator input[type='checkbox']:not(:disabled)").attr("checked", "checked");
			return false;
		});
		$("#select-none").click(function() {
			$(".integrator input[type='checkbox']").removeAttr("checked");
			return false;
		});
	});
</script>

<c:url var="actionUrl" value="/proj/scm/pullrequest/send.spr?repositoryId=${sendPullRequestForm.pullRequest.sourceRepository.id}"/>
<form:form action="${actionUrl}" commandName="sendPullRequestForm" method="post">
	<form:hidden path="pullRequest.id"/>
	<form:hidden path="pullRequest.sourceRepository.id"/>
	<form:hidden path="pullRequest.sourceRepository.name"/>
	<form:hidden path="pullRequest.sourceBranch"/>
	<form:hidden path="pullRequest.sourceFirstRevision"/>
	<form:hidden path="pullRequest.sourceLastRevision"/>
	<input type="hidden" id="sourceLastRevisionPicked" name="sourceLastRevisionPicked" value="false"/>
	<form:hidden path="pullRequest.targetRepository.id"/>
	<form:hidden path="pullRequest.targetRepository.name"/>
	<form:hidden path="pullRequest.targetBranch"/>

	<ui:actionBar>
		<c:url var="backUrl" value="/proj/scm/pullrequest/send.spr">
			<c:param name="repositoryId">${sendPullRequestForm.pullRequest.sourceRepository.id}</c:param>
			<c:param name="sourceBranch">${sendPullRequestForm.pullRequest.sourceBranch}</c:param>
			<c:param name="targetBranch">${sendPullRequestForm.pullRequest.targetBranch}</c:param>
		</c:url>

		<a href="${backUrl}" style="text-decoration: none;">
			<spring:message code='scm.repository.action.send.pull.request.back' text='< Back' var="backText"/>
			<input type="button" class="button" value="${backText}" />
		</a>
		<spring:message code='scm.repository.action.send.pull.request' text='Send Pull Request' var="sendPullRequestText"/>
		<input type="submit" class="button" value="${sendPullRequestText}" />

		<c:url var="cancelUrl" value="${sendPullRequestForm.pullRequest.sourceRepository.urlLink}"/>
		<spring:message code='Cancel' text="Cancel" var="cancelButtonText" />
		<input type="button" class="button cancelButton" value="${cancelButtonText}" onclick="document.location='${cancelUrl}'; return false;" />
	</ui:actionBar>

<div class="contentWithMargins" >
	<p>
		<spring:message code='pullRequest.integrating.changes' arguments="${fn:length(changeSets)}" />:
		<b><tt><a href="<c:url value="${sendPullRequestForm.pullRequest.sourceRepository.urlLink}"/>"><c:out value="${sendPullRequestForm.pullRequest.sourceRepository.name}"/></a> / <c:out value="${sendPullRequestForm.pullRequest.sourceBranch}"/></tt></b>
			&rarr; <b><tt><a href="<c:url value="${sendPullRequestForm.pullRequest.targetRepository.urlLink}"/>"><c:out value="${sendPullRequestForm.pullRequest.targetRepository.name}"/></a> / <c:out value="${sendPullRequestForm.pullRequest.targetBranch}"/></tt></b>
	</p>

	<c:if test="${not empty conflictHtmls}">
		<div class="warning">
			Sending this pull request <b>would result in ${fn:length(conflictHtmls)} merge conflicts</b>.<br/>
			Hint: resolve the conflicts by the guide in the &quot;Merge Conflicts&quot; tab, then try sending the pull request again.
		</div>
	</c:if>

	<c:set var="summaryBoxContent">
		<table border="0" cellpadding="0" class="formTableWithSpacing" >
			<tr style="height:1em;">
				<td class="mandatory"><spring:message code="tracker.field.Summary.label" text="Summary"/>:</td>
				<td>
					<form:input path="pullRequest.name" tabindex="1" size="82"/><c:if test="${!sourceLastRevisionPicked}"><div class="invalidfield"><form:errors path="nameValid" cssClass="invalidfield"/></div></c:if>
				</td>
			</tr>
			<tr>
				<td class="mandatory"><spring:message code="tracker.field.Priority.label" text="Priorty"/>:</td>
				<td>
					<form:select path="pullRequest.priority" items="${priorityOptions}" itemValue="id" itemLabel="name"/>
				</td>
			</tr>
			<tr style="height:1em;">
				<td class="mandatory"><spring:message code="tracker.field.Description.label" text="Description"/>:</td>
				<td style="vertical-align:top;">
					<form:textarea path="pullRequest.description" tabindex="2" cols="80" rows="10" /><c:if test="${!sourceLastRevisionPicked}"><div class="invalidfield"><form:errors path="descriptionValid" cssClass="invalidfield"/></div></c:if>
				</td>
			</tr>
		</table>
	</c:set>
	<c:set var="integratorsContent">
			<div><b><spring:message code="pullRequest.integrators.to.notify"/></b>
			<span style="margin-left:2em; font-size:80%;">
				<a id="select-all" href="#">
					<spring:message code="pullRequest.integrators.select.all" text="Select All"/></a> |
				<a id="select-none" href="#"><spring:message code="pullRequest.integrators.select.none" text="None"/></a>
			</span>
			</div>
			<ul class="integrators">
				<c:forEach var="integrator" items="${integrators}">
					<li class="integrator">
						<ct:call object="${userManager}" method="getAliasName" return="integratorName" param1="${integrator}"/>
						<ui:userPhoto userId="${integrator.id}" userName="${integratorName}"/>
						<c:choose>
							<c:when test="${not mergeCapableIntegrators[integrator.id]}">
								<form:checkbox id="integrator-${integrator.id}" path="integratorsToNotify[${integrator.id}]" tabindex="3" value="false" disabled="true"/>
								<label for="integrator-${integrator.id}"><c:out value="${integratorName}"/></label>
								<span class="subtext" style="margin-left:1em;">
									<spring:message code="pullRequest.integrators.cant.merge" text="(can't merge)"/>
								</span>
							</c:when>
							<c:otherwise>
								<form:checkbox id="integrator-${integrator.id}" path="integratorsToNotify[${integrator.id}]" tabindex="3" value="false"/>
								<label for="integrator-${integrator.id}"><c:out value="${integratorName}"/></label>
							</c:otherwise>
						</c:choose>
					</li>
				</c:forEach>
			</ul>
			<c:if test="${!sourceLastRevisionPicked}"><div class="invalidfield"><form:errors path="integratorsToNotify" cssClass="invalidfield"/></div></c:if>
	</c:set>

	<table border="0" cellpadding="0" cellspacing="0" style="width: 100%; margin-bottom: 1em;">
		<tr>
			<td style="width: 60em;vertical-align: top;">
				${summaryBoxContent}
			</td>
			<td style="width: 100%;vertical-align: top; padding-left: 1em;">
				${integratorsContent}
			</td>
		</tr>
	</table>

	<spring:message code="pullRequest.changesets" arguments="${fn:length(changeSets)}" var="changesetsText" />
	<spring:message code="pullRequest.files.changed" arguments="${fn:length(changeFiles)}" var="fileschangedText" />
	<tab:tabContainer id="pullrequest" skin="cb-box">
		<tab:tabPane id="changesets" tabTitle="${changesetsText}">
			<jsp:include page="includes/changeSets.jsp" flush="true" />
		</tab:tabPane>
		<tab:tabPane id="changefiles" tabTitle="${fileschangedText}">
			<jsp:include page="includes/changeFiles.jsp" flush="true" />
		</tab:tabPane>
		<c:if test="${not empty conflictHtmls}">
			<tab:tabPane id="conflicts" tabTitle="Merge Conflicts (${fn:length(conflictHtmls)})">
				<jsp:include page="includes/conflicts.jsp" flush="true" />
			</tab:tabPane>
		</c:if>
	</tab:tabContainer>
</div>
</form:form>
