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

<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<head>
<style type="text/css">
	ul.submodules_branch, ul.branchesAndTags {
		margin: 0 0 0 4px;
		padding: 0;
		list-style: none;
		white-space: nowrap;
	}
	ul.submodules_branch {
		margin-left: 16px;
	}
</style>
</head>

<ui:pageTitle printBody="false" prefixWithIdentifiableName="false">
	<spring:message code="scm.commit.title" text="SCM Repository Commit"/>
</ui:pageTitle>
<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false" showLast="false" linkLast="false" strongBody="true">
		<span><spring:message code="scm.commit.changeset" text="Changeset"/></span>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<spring:message var="detailsTitle" code="scm.commits.details.title" text="Details"/>
<form:form commandName="commit" id="commitDataForm">
	<c:if test="${canEdit}">
		<ui:actionBar>
			<spring:message var="saveButton" code="button.save" text="Save"/>
			<input type="submit" class="button" value="${saveButton}" />
			<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
			<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" />
		</ui:actionBar>
	</c:if>

	<div class="contentWithMargins">
	<table style='margin-bottom:5px;' class="formTableWithSpacing" cellpadding="1" >
		<c:set var="length" value="${fn:length(mergeChain)}"/>
		<c:if test="${length > 0}">
			<tr>
				<td class="label optional" align="right"><spring:message code="scm.commit.merge.chain.label" text="Merge chain"/>:</td>
				<td width="90%">
					<c:forEach items="${mergeChain}" var="mergedFrom" varStatus="status">
						<c:url value="${mergedFrom.urlLink}" var="mergedFromUrl"/>
						<a href="${mergedFromUrl}"><c:out value='${mergedFrom.name}'/></a> &nbsp;
						(<spring:message code="scm.commit.branch.info" text="branches"/>: <c:forEach items="${chainMap[mergedFrom].tags}" var="t" varStatus="varStatus">
							<c:url var="url" value="${mergedFrom.changeSetsUrlLink}/${t}"/>
							<a href="${url}">${t}</a><c:if test="${!varStatus.last}">,</c:if>
						</c:forEach>)
						<c:if test="${status.count < length}">
							&larr;
						</c:if>
					</c:forEach>
				</td>
			</tr>
		</c:if>

		<c:if test="${canEdit}">
			<tr>
				<td class="label optional" align="right"><spring:message code="scm.commit.tasks.label" text="Tasks"/>:</td>

				<td nowrap width="90%">
					<form:input path="scmTask" cssClass="expandText" size="40"/><br/>
					<form:errors path="scmTask" cssClass="invalidfield"/>
				</td>
			</tr>
		</c:if>
	</table>
	</div>
</form:form>

<div class="contentWithMargins">
<%-- preparing parameters for changesets.jsp --%>
<c:set var="minimalInfo" value="true" scope="request" />
<c:set var="dontShowBranchesFromDB" value="true" scope="request" />
<c:if test="${supportTags}">
	<spring:message var="extraColumnTitle" code="scm.submodule.supermodules.title" text="Supermodules" scope="request" />
	<c:set var="extraColumn" scope="request">
		<c:if test="${empty supermodules}">--</c:if>

		<c:forEach var="supermodule" items="${supermodules}">
		<ul class="branchesAndTags">
				<c:set var="skey" value="${supermodule.key}" />
				<c:set var="modules" value="${supermodules[skey]}" />
				<c:set var="repo" value="${modules[0]}" />
				<c:url var="superRepoUrl" value="${repo.superRepository.urlLink}" />

			<li>
				<img border="0" src='<c:url value="/images/Used-as-submodule.png" />' />&nbsp;<a href="${superRepoUrl}"><c:out value="${repo.superRepository.name}" /><a>

				<ul class="submodules submodules_branch">
				<c:forEach var="module" items="${modules}">
					<c:url var="fileUrl" value="${module.superRepository.filesUrlLink}">
						<c:param name="path" value="${module.superRepositoryBranchOrTag.name}" />
					</c:url>
					<li>
						<img border="0" src='<c:url value="/images/${module.superRepositoryBranchOrTag.tag ? 'Tag.png': 'Branch.png'}" />' />
						<a href="${fileUrl}"><c:out value="${module.superRepositoryBranchOrTag.name}" /></a>
					</li>
				</c:forEach>
				</ul>
			</li>
		</ul>
		</c:forEach>
	</c:set>

</c:if>

<c:if test="${!empty pushedCommits}">
	<table>
		<tr valign="middle">
			<td width="10%">
				<ui:changeSetAuthor changeSet="${commits[0]}"/>
			</td>
			<td valign="middle" style="padding-left: 2em;">
				<c:url var="repoUrl" value="${repository.urlLink}"/>
				<a href="${repoUrl}"><c:out value='${repository.name}'/></a>:
				 ${commitCount} <spring:message code="scm.commits.title" text="Commits"/> <spring:message code="activity.pushed" text="pushed"/>
			</td>
		</tr>
	</table>

	<c:set var="commits" value="${pushedCommits}" scope="request" />
	<c:set var="minimalInfo" value="false" scope="request" />
	<c:set var="hideFilters" value="true" scope="request" />
	<c:set var="requestUri" value="/proj/scm/sccChangeSet.spr" scope="request"/>
	<c:set var="showTagsAndBranches" value="${supportTags}" scope="request"/>
</c:if>

<jsp:include page="/scm/includes/changesets.jsp" flush="true"/>
</div>
