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
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	This JSP fragment shows the meta data about the current document/wiki page like revision number and last change date and user.

	This JSP fragment expects the ArtifactDto in the "Artifact" request parameter; this is either the current
	WikiPage or Document to show the meta data for...

	Also expected scope variables:
	${docComments} The list of comments/attachments for the document
	${pageChildren} The list of child pages, only for wiki documents
%>
<%-- get the artifact from request --%>
<c:set var="artifact" value="${requestScope.Artifact}" />
<%-- the url for properties of this page --%>
<c:set var="infoURL" value="${param.infoURL}" />
<%-- the prefix for ditchnet-tab, either "wiki-page" or "document" --%>
<c:set var="ditchnetPrefix" value="${param.ditchnetPrefix}" />
<%-- unlock URL or blank if user can not unlock --%>
<c:set var="unlockArtifactUrl" value="${param.unlockArtifactUrl}" />

<c:if test="${! empty artifact}">
	<span class="doc-metadata">
		<c:url var="pageInfoURL" value="${infoURL}" />

		<%-- hard lock info --%>
		<c:if test="${! empty artifact.additionalInfo.lockedBy}">
			<spring:message var="lockInfo" code="document.lockedBy.tooltip" text="Locking information"/>
			<span class="main high" title="${lockInfo}">
				<spring:message code="document.lockedBy.label" text="Currently locked by"/>
				<tag:userLink user_id="${artifact.additionalInfo.lockedBy.id}" />.
				<c:if test="${! empty unlockArtifactUrl}">
					<spring:message var="unlockTitle" code="document.unlock.tooltip" text="Unlock"/>
					<a class="action" href="${unlockArtifactUrl}" title="${unlockLabel}">
						<spring:message code="document.unlock.label" text="Unlock"/>
					</a>
				</c:if>
			</span>
		</c:if>

		<%-- soft lock info --%>
		<c:if test="${PAGE_LOCKER.id gt 0}">
			<spring:message var="editInfo" code="document.editedBy.tooltip" text="Editing information"/>
			<span class="main high" title="${editInfo}">
				<spring:message code="document.editedBy.label" text="Currently edited by"/>
				<tag:userLink user_id="${PAGE_LOCKER.id}" />.
			</span>
		</c:if>

		<c:if test="${(empty simpleWikiPage || !simpleWikiPage) && isArtifactApprovalLicensed && artifact.approvalSupported}">
			<spring:message var="approvalWorkflow" code="artifact.approval.workflow.label" text="Approval workflow"/>
			<span class="main" title="${approvalWorkflow}">
				<a href="${pageInfoURL}&orgDitchnetTabPaneId=${ditchnetPrefix}-approvals">
					<c:choose>
						<c:when test="${!empty artifact.additionalInfo.approvalWorkflow}">
							<spring:message code="artifact.approval.workflow.viewing.title" text="Approval Workflow {0}" arguments="${artifact.additionalInfo.approvalWorkflow.name}" htmlEscape="true"/>
						</c:when>
						<c:otherwise>
							<spring:message code="artifact.approval.without.message" text="No Approval Workflow" />
						</c:otherwise>
					</c:choose>
				</a>
			</span>
		</c:if>

		<c:if test="${(empty simpleWikiPage || !simpleWikiPage) && pageChildren ne null}">
			<spring:message var="childPagesTitle" code="wiki.children.tooltip" text="Children of page"/>
			<span class="main" title="${childPagesTitle}">
				<a href="${pageInfoURL}&orgDitchnetTabPaneId=${ditchnetPrefix}-children">
					<c:choose>
						<c:when test="${fn:length(pageChildren) > 1}">
							<spring:message code="wiki.children.multiple" text="{0} child pages" arguments="${fn:length(pageChildren)}" />
						</c:when>
						<c:when test="${fn:length(pageChildren) == 1}">
							<spring:message code="wiki.children.single" text="1 child page" />
						</c:when>
						<c:otherwise>
							<spring:message code="wiki.children.none" text="No child pages" />
						</c:otherwise>
					</c:choose>
				</a>
			</span>
		</c:if>
	</span>
</c:if>