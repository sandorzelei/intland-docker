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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<style type="text/css">
	.actionBar .actionBarIcon {
		top: -3px !important;
	}
</style>

<c:set var="dirTrail">
	<c:set var="branchOrTagEscaped"><c:out value="${branchOrTag}"/></c:set>
	<c:url var="breadCrumbUrl" value="/scm/dir/${repository.id}/${branchOrTagEscaped}"/>
	<span class='breadcrumbs-separator'>&raquo;</span>
	<ui:pathBreadcrumb requestParameterName="path" baseURL="${breadCrumbUrl}" />
</c:set>

<c:set var="screenTitle" value="Log of ${dirTrail}" />

	<c:set var="isDir" value="${param.isDir == true}" />

	<c:url var="diffURL" value="/proj/sources/scmFileDiff">
		<c:param name="repositoryId" value="${repository.id}" />
		<c:param name="filename" value="${filename}" />
	</c:url>

<script type="text/javascript">
<!--
	<%@include file="../wikispace/includes/compareRevisions.js" %>
//-->
	function updateUrl(formId, urlPattern, branch, path) {
		var f = document.getElementById(formId);
		var s = urlPattern;
		s = s.replace("#branch", branch);
		s = s.replace("#path", path);
		f.action = s;
	}
</script>
	<c:set var="showCompare" value="${(!isDir) && (fn:length(changelog) gt 1)}" />
	<c:set var="compareRevisionsFragment">
		<c:if test="${showCompare}">
			<spring:message var="compareButton" code="scm.commit.revision.compare.button" text="Compare Selected Revisions"/>
			<input type="button" class="button" onclick="compareRevisions(document.getElementById('changeLog'),'<spring:escapeBody javaScriptEscape="true">${diffURL}</spring:escapeBody>' ); return false;" value="${compareButton}" />
			&nbsp;&nbsp;
		</c:if>
	</c:set>

<c:set var="switchBranchesFragment">
	<c:if test="${supportsBranches}">
			<spring:message code="scm.branches.label" var="branchesLabel"/>
			<spring:message code="scm.tags.label" var="tagsLabel"/>
			<c:url var="self" value="/scm/filelog.spr"/>
			<c:set var="dirOrFile" value="file"/>
			<c:if test="${isDir}">
				<c:set var="dirOrFile" value="dir"/>
			</c:if>
			<c:url var="urlPattern" value="/scm/${dirOrFile}/${repository.id}/#branch/#path/history"/>
			<form:form action="${self}" cssClass="filterForm" method="GET" id="fileLogForm" style="display:inline;position:relative;top:-1px;">
				<label><spring:message code="scm.branchesortags.label" text="Branches"/>
					<c:set var="filenameEscaped"><spring:escapeBody javaScriptEscape="true">${filename}</spring:escapeBody></c:set>
					<form:select path="branchOrTag" style="width:20em;position:relative;top:-1px;" id="branchOrTag" onchange="updateUrl('fileLogForm','${urlPattern}',document.getElementById('branchOrTag').value, '${filenameEscaped}'); this.form.submit();">
						<form:option disabled="true" value="${branchesLabel}"/>
						<c:set var="branchOrTagDisplayed" value="false"/>
						<c:forEach items="${branches}" var="branch">
							<form:option value="${branch}"/>
						</c:forEach>
					</form:select>
				</label>
			</form:form>
	</c:if>
</c:set>

	<jsp:include page="includes/actionBar.jsp" >
		<jsp:param name="screenTitle" value="${screenTitle}"/>
		<jsp:param name="fragmentBeforeActionLink" value="${compareRevisionsFragment}"/>
		<jsp:param name="fragmentAfterActionLink" value="${switchBranchesFragment}" />
	</jsp:include>

	<ui:displaytagPaging defaultPageSize="15" items="${changelog}" />

	<c:set var="defaultSort" value="3"/>
	<c:if test="${isDir}">
		<c:set var="defaultSort" value="2"/>
	</c:if>

	<display:table requestURI="/scm/filelog.spr" name="${changelog}" id="changeLog" cellpadding="0" cellspacing="0"
		defaultsort="${defaultSort}" defaultorder="descending" pagesize="${pagesize}">

		<display:setProperty name="paging.banner.placement" value="bottom"/>
		<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
		<display:setProperty name="paging.banner.onepage" value="" />
		<display:setProperty name="paging.banner.one_item_found" value="" />

		<c:set var="changeFile" value="${changeLog.changedFiles[0]}" />

		<c:choose>
			<c:when test="${changeLog.revision != null}">
				<c:set var="rev" value="${changeLog.revision}"/>
			</c:when>
			<c:otherwise>
				<c:set var="rev" value="${changeFile.newRevision}"/>
			</c:otherwise>
		</c:choose>

		<c:if test="${showCompare}">
			<display:column media="html">
				<input type="checkbox" name="selectedRevisions" value="${rev}" />
			</display:column>
		</c:if>

		<spring:message var="revisionTitle" code="scm.commit.revision.label" text="Revision"/>
		<display:column title="${revisionTitle}" headerClass="textData" class="textData columnSeparator"
			sortable="true" sortProperty="date">

			<c:choose>
				<c:when test="${!isDir}">
					<c:url var="catURL" value="/scmShowFileRevision">
						<c:param name="repositoryId" value="${repository.id}" />
						<c:param name="path" value="${rev}/${filename}" />
						<c:param name="date" value="${changeLog.date}" />
					</c:url>

					<spring:message var="revisionPopup" code="scm.commit.revision.show" text="Show this revision in a popup."/>
					<a href="${catURL}" title="${revisionPopup}">
						<c:out value="${rev}" />
					</a>
				</c:when>

				<c:otherwise>
					<c:out value="${changeLog.revision}" />
				</c:otherwise>
			</c:choose>
		</display:column>

		<spring:message var="dateTitle" code="scm.browse.date.label" text="Date"/>
		<display:column title="${dateTitle}" headerClass="dateData" class="dateData columnSeparator" sortable="true" sortProperty="date">
			<tag:formatDate value="${changeLog.date}" useNbsp="true" />
		</display:column>

		<spring:message var="authorTitle" code="scm.commit.author.label" text="Author"/>
		<display:column title="${authorTitle}" headerClass="textData" class="textData columnSeparator" sortable="true" sortProperty="author">
			<c:out value="${changeLog.author}" default="--" />
		</display:column>

		<spring:message var="commentTitle" code="scm.commit.comment.label" text="Comment"/>
		<display:column title="${commentTitle}" headerClass="expandText textData" class="expandText textDataWrap">
			<pre class="commitmessage"><c:out value="${changeLog.message}"/></pre>
		</display:column>

	</display:table>
