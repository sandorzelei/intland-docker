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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<div class="actionBar" style="margin-bottom: 15px;"></div>
<style type="text/css">
.diffPath {
	font-weight: bold;
}
.diffContainer {
	margin-bottom: 1em;
}
</style>

<c:choose>
	<c:when test="${sourceBranchExists || not empty changeFiles}">
		<c:if test="${tooManyFiles}">
			<spring:message code="scm.pullRequest.too.many.files" arguments="${hiddenFileCount}"
				text="Too many files, ${hiddenFileCount} are not shown."/>
		</c:if>
		<!-- change files -->
		<div style="margin-bottom: 1em;">
			<b>Changes:</b>
			<display:table class="changeset expandTable" name="changeFiles" id="changeFile" cellpadding="0" export="false">
				<display:column title="File" headerClass="expandText textData" class="textData columnSeparator" style="width:10%; padding-top:2px; padding-bottom:2px;">
					<span class="subtext">
						<c:choose>
							<c:when test="${changeFile.action eq 'A'}">
								<span class="added"><spring:message code="scm.commit.file.added" text="added"/></span>
							</c:when>
							<c:when test="${changeFile.action eq 'D'}">
								<span class="deleted"><spring:message code="scm.commit.file.deleted" text="deleted"/></span>
							</c:when>
							<c:otherwise>
								<span class="modified"><spring:message code="scm.commit.file.modified" text="modified"/></span>
							</c:otherwise>
						</c:choose>
					</span>
					<c:out value="${changeFile.path}"/></a>

					<c:set var="diffStat" value="${diffStats[changeFile]}"/>
					<c:set var="diffHtml" value="${diffHtmls[changeFile]}"/>
					<c:if test="${not empty diffHtml}"><a href="#diff-${changeFile.id}"></c:if>
						<c:if test="${not empty diffHtml || changeFile.action eq 'M'}"><span class="added">+${diffStat.linesAdded}</span></c:if> <c:if test="${changeFile.action eq 'M'}"><span class="deleted">-${diffStat.linesRemoved}</span></c:if>
					<c:if test="${not empty diffHtml}"></a></c:if>
				</display:column>
			</display:table>
		</div>

		<!-- diffs per file -->
		<c:if test="${fn:length(diffHtmls) > 0}">
			<div>
				<c:forEach var="diffHtml" items="${diffHtmls}">
					<c:set var="changeFile" value="${diffHtml.key}" />
					<div class="diffPath" id="diff-${changeFile.id}"><c:out value='${changeFile.path}'/></div>
					<div class="diffContainer"
						scmChangeFilePath="<c:out value='${changeFile.path}'/>" scmChangeFileOldRevision="<c:out value='${changeFile.oldRevision}'/>" scmChangeFileNewRevision="<c:out value='${changeFile.newRevision}'/>">
						${diffHtml.value}
					</div>
				</c:forEach>
			</div>
		</c:if>
	</c:when>
	<c:otherwise>
		<c:choose>
			<c:when test="${sourceBranchExists}">
				<c:set var="args"><c:out value='${pullRequest.sourceBranch},${pullRequest.sourceRepository.urlLink},${pullRequest.sourceRepository.name}'/></c:set>
				<spring:message code="scm.pullRequest.branch.deleted" arguments="${pullRequest.sourceBranch},${pullRequest.sourceRepository.urlLink},${pullRequest.sourceRepository.name}"
					text="Cannot retreive changed file information because branch <b>${pullRequest.sourceBranch}</b> was deleted in <a href='${pullRequest.sourceRepository.urlLink}'>{pullRequest.sourceRepository.name}</a>"/>
			</c:when>
			<c:when test="${empty changeFiles}">
				<spring:message code="scm.pullRequest.mergecommit.no.files"/>
			</c:when>
			<c:otherwise>
				<spring:message code="table.nothing.found"/>
			</c:otherwise>
		</c:choose>
	</c:otherwise>
</c:choose>
