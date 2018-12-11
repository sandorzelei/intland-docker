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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:set var="projectId" value="${proj_id}" scope="request"/>
<%--<c:set var="screenFilter" scope="request">
	<jsp:include page="/sources/sccCommitsOverview.jsp" flush="true"/>
</c:set>--%>
<spring:message var="screenTitle" code="scm.commits.title" text="Commits"/>

<ui:showErrors />

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<style type="text/css">
<!--
	.filterForm label, .filterForm > input {
		margin-top: 2px;	/* when wrapping use a small gap between the wrapped lines */
	}
-->
</style>

<c:if test="${showTagsAndBranches }">
	<c:set var="tagsColumnTitle" scope="request">
		<form:form cssClass="filterForm" method="GET" commandName="command">
			<spring:message code="scm.change.appears.on.branchOrTag" text="Appears on"/>
			<form:select path="branchTagFilter" items="${branchTagSelector}" onchange="this.form.submit();" cssStyle="margin-left:2px;"/>
			<c:if test="${not empty param.pageNumber }">
				<input type="hidden" name="pageNumber" value="${param.pageNumber }"/>
			</c:if>
		</form:form>
	</c:set>
</c:if>

<c:if test="${!minimalInfo}">
	<c:if test="${!hideFilters}">
		<c:url var="changesUrl" value="${repository.changeSetsUrlLink}"/>
		<div class="actionBar">
			<form:form action="${changesUrl}" cssClass="filterForm" method="GET" onsubmit="$.Watermark.HideAll();">
				<label><spring:message code="scm.commit.author.label" text="Author"/>
					<spring:message var="authorFilterTitle" code="scm.commit.author.filter" text="Filter by author of the changes"/>
					<form:select path="userName" title="${authorFilterTitle}" style="width:20em;" >
						<c:forEach items="${command.userOptions}" var="userOption">
							<form:option value="${userOption.value}">
								<spring:message text="${userOption.name}" htmlEscape="true"/>
							</form:option>
						</c:forEach>
					</form:select>
				</label>
				<spring:message code="scm.branches.label" var="branchesLabel"/>
				<spring:message code="scm.tags.label" var="tagsLabel"/>
				<spring:message code="scm.branches.all.label" var="allLabel"/>

				<c:if test="${supportsBranches}">
					<label><spring:message code="scm.branches.label" text="Branches"/>
						<spring:message var="branchFilterTitle" code="scm.commit.branch.filter" text="Filter changes by branch name"/>
						<form:select path="branchOrTag" title="${branchFilterTitle}" style="width:20em;" >
							<form:option value="all" title="${allLabel}"/>
							<c:forEach items="${command.branches}" var="branch">
								<form:option value="${branch}"/>
							</c:forEach>
						</form:select>
					</label>
				</c:if>

				<label>
					<spring:message var="commentFilterTitle" code="scm.commit.comment.filter" text="Find change by comment text"/>
					<form:input path="commentRevisionOrFile" size="30" maxlength="255" title="${commentFilterTitle}" id="commentRevisionOrFile"/>
				</label>

				<spring:message var="commentRevisionOnFileNameTitle" code="scm.filter.label" text="Comment, revision or file name"/>
				<script type="text/javascript">
					$("#commentRevisionOrFile").Watermark("${commentRevisionOnFileNameTitle}", "#d1d1d1");
				</script>

				<label>
					<spring:message var="fieldLabel" code="scm.commit.date.from.label" text="From" />${fieldLabel}
					<spring:message var="startFilterTitle" code="scm.commit.date.from.filter" text="Filter change by start date"/>
					<form:input path="startDate" size="10" maxlength="30" styleId="startDate" title="${startFilterTitle}" style="margin-right:0;"/>
					<ui:calendarPopup textFieldId="startDate" otherFieldId="endDate" fieldLabel="${fieldLabel}" />
				</label>

				<label>
					<spring:message var="fieldLabel" code="scm.commit.date.to.label" text="To"/>${fieldLabel}
					<spring:message var="endFilterTitle" code="scm.commit.date.to.filter" text="Filter change by end date"/>
					<form:input disabled="${disabled}" path="endDate" size="10" maxlength="30" styleId="endDate"	title="${endFilterTitle}" style="margin-right:0;"/>
					<ui:calendarPopup textFieldId="endDate" otherFieldId="startDate" fieldLabel="${fieldLabel}" />
				</label>

				<spring:message var="goButton" code="search.submit.label" text="GO"/>
				<spring:message var="goTitle" code="search.submit.tooltip" text="Apply filter"/>
				<input type="submit" class="button narrowButton" title="${goTitle}" value="${goButton}"/>
			</form:form>
		</div>
	</c:if>
</c:if>

<div class="scrollable">

<c:if test="${ empty requestUri }">
	<c:set var="requestUri" value="/proj/scm/repository.spr"/>
</c:if>
<c:if test="${scmHistoryTooManyResult != null && scmHistoryTooManyResult}">
	<div class="warning">
		${scmHistoryTooManyResultMessage}
	</div>
</c:if>

<display:table requestURI="${requestUri }" name="commits" id="commit" cellpadding="0" cellspacing="0">

	<display:setProperty name="pagination.sort.param" value="orderBy" />
	<display:setProperty name="pagination.pagenumber.param" value="pageNumber" />

	<display:setProperty name="paging.banner.placement" value="bottom"/>
	<display:setProperty name="paging.banner.item_name"><spring:message code="scm.commit.label"/></display:setProperty>
	<display:setProperty name="paging.banner.items_name"><spring:message code="scm.commits.title"/></display:setProperty>

	<spring:message var="authorTitle" code="scm.commit.author.label" text="Author"/>
	<display:column title="${authorTitle}" headerClass="textData" class="textData columnSeparator assocSubmitterCol" style="padding-top:2px; padding-bottom:15px;">
		<ui:changeSetAuthor changeSet="${commit}"/>
	</display:column>

	<c:set var="changeFilesLimit" value="100" />
	<c:set var="changeFiles" value="${commit.changeFiles}" />
	<c:set var="changes" value="${fn:length(changeFiles)}" />
	<c:set var="revision" value="${commit.revision}"/>
	<c:if test="${empty commit.revision}">
		<c:if test="${not empty commit.firstModifiedFile}">
			<c:set var="revision" value="${commit.firstModifiedFile.newRevision}"/>
		</c:if>
	</c:if>
	<spring:message var="commentTitle" code="scm.commit.comment.label" text="Comment"/>
	<display:column title="${commentTitle}" headerClass="expandText textData" class="expandText textDataWrap">
		<c:url var="commitUrl" value="${commit.urlLink}"/>
		<c:if test="${integratedRevisions[commit.revision] != null}">
			<a href="${commitUrl}"><span class="changeset integrated scmIntegratedTablet"><spring:message code="scm.commit.integrated.to.upstream.label" text="INTEGRATED"/></span></a>
		</c:if>
		<pre class="commitmessage"><c:out value="${commit.message}"/></pre>

		<span class="subtext">

		<c:if test="${minimalInfo}">
			<c:url var="repoUrl" value="${commit.repository.urlLink}"/>
			<br/><span class="subtext">
				<a href="${repoUrl}"><c:out value='${commit.repository.name}'/></a>&nbsp;<spring:message code="scm.commit.committed.to.label" text="repository"/>,
			</span>
		</c:if>
		<a href="${commitUrl}"><c:out value='${revision}'/></a>
		<c:if test="${commitsToRepositories[commit.id] != null}">
			<c:url var="mergedFromUrl" value="${commitsToRepositories[commit.id].urlLink}"/>
			&nbsp;<spring:message code="scm.commit.merged.from.label" text="merged from"/>:&nbsp;<a href="${mergedFromUrl}"><c:out value='${commitsToRepositories[commit.id].name}'/></a>
		</c:if>
		<c:set var="tags" value="${commit.tags}"/>
		<c:if test="${!empty tags and !dontShowBranchesFromDB and supportsBranches}">
			<spring:message code="scm.commit.branch.info" text="branches"/>:
			<c:forEach items="${tags}" var="tag" varStatus="varStatus">
				<c:set var="tag"><c:out value='${tag}'/></c:set>
				<c:url var="tagUrl" value="${commit.repository.changeSetsUrlLink}/${tag}" />
				<c:if test="${commit.repository.possibleToManage}">
					<a href="${tagUrl}">
				</c:if>
				${tag}
				<c:if test="${commit.repository.possibleToManage}">
					</a>
				</c:if>
				<c:if test="${!varStatus.last}">,</c:if>
			</c:forEach>
		</c:if>
		</span>

		<ui:changeSetFiles changeSet="${commit}" />
	</display:column>

	<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
		<c:if test="${!hideContextMenu}">
			<ui:actionMenu builder="scmChangeSetContextActionMenuBuilder" subject="${commit}" lazyInit="false" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
		</c:if>
	</display:column>

	<c:if test="${!minimalInfo}">
		<spring:message var="tasksTitle" code="scm.commit.tasks.label" text="Tasks"/>
		<display:column title="${tasksTitle}" headerClass="textDataWrap" class="textDataWrap columnSeparator">
			<tag:joinLines>
				<c:choose>
					<c:when test="${fn:length(commit.trackerItems) > 0}">
						<c:forEach items="${commit.trackerItems}" var="trackerItem" varStatus="status">
							<tag:formatDate var="submittedAt" value="${trackerItem.submittedAt}" />

							<c:set var="styleClass" value="${trackerItem.closed ? 'closedItem' : ''}" />

							<c:url var="issueUrl" value="${trackerItem.urlLink}" />
							<span style='white-space:nowrap;'>
							<a class="${styleClass}" href="${issueUrl}" title='<c:out value="${trackerItem.summary}; Submitted: ${submittedAt}" />'><c:out value="${trackerItem.keyAndId}" /></a>
							<c:if test="${!status.last}">,</c:if>
							</span>
						</c:forEach>
					</c:when>
					<c:otherwise>
						--
					</c:otherwise>
				</c:choose>
			</tag:joinLines>
		</display:column>
	</c:if>

	<c:if test="${showTagsAndBranches }">
		<display:column title="${tagsColumnTitle}" headerClass="textDataWrap" class="textDataWrap columnSeparator">
			<c:set var="tagsAndBranchesForCommit"  value="${tagsAndBranches[commit] }"/>
			<c:if test="${empty tagsAndBranchesForCommit}">--</c:if>
			<ul class="branchesAndTags">
			<c:forEach var="tag" items="${tagsAndBranchesForCommit}">
				<li>
					<c:url var="fileUrl" value="${repository.filesUrlLink}">
						<c:param name="path" value="${tag.name}" />
					</c:url>
					<a href="${fileUrl}">
						<img border="0" src='<c:url value="/images/${tag.isTag ? 'Tag.png': 'Branch.png'}" />' />
						<c:out value="${tag.name}" />
					</a>
				</li>
			</c:forEach>
			</ul>
		</display:column>
	</c:if>

	<c:if test="${! empty extraColumn}">
		<display:column title="${extraColumnTitle}" headerClass="textDataWrap" class="textDataWrap columnSeparator">
			${extraColumn}
		</display:column>
	</c:if>

</display:table>
</div>
