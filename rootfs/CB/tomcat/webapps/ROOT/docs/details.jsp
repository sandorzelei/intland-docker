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
<meta name="module" content="docs"/>
<meta name="moduleCSSClass" content="documentsModule newskin ${not empty documentRevision.baseline ? "tracker-baseline" : ""}"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="com.intland.codebeamer.remoting.GroupType"%>

<style type="text/css">
	/* More menu align */
	.rightAlignCell .yuimenubar .yuimenubaritemlabel {
		position: relative;
		top: -4px;
	}
</style>

<%
	request.setAttribute("HISTORY_DOCUMENT", Integer.valueOf(GroupType.ARTIFACT));
%>

<c:set var="doc_id" value="${param.doc_id}" scope="request" />
<c:if test="${empty doc_id}">
	<c:set var="doc_id" value="-1" scope="request" />
</c:if>

<tag:document var="document" doc_id="${doc_id}" revision="${documentRevisionNumber}" scope="request"
	historyStatsVar="historyStatsVar" historyVar="docRevisions" accessLogVar="accessLog" accessLogFilter="${param.accessLogFilter}"
	commentsVar="docComments"
	entityLabelsVar="entityLabels"
	attributesVar="attributes"
	softLockVar="docLock"
	isArtifactApprovalLicensedVar="isArtifactApprovalLicensed"
	approvalStateVar="approvalState"
	approvalWorkflowsVar="approvalWorkflows"
	approvalHistoryVar="approvalHistory"
	canApplyOrRemoveApprovalWorkflowVar="canApplyOrRemoveApprovalWorkflow"
	canApproveWorkflowVar="canApproveWorkflow"
	canRejectDocumentInWorkflowVar="canRejectDocumentInWorkflow"
	canApprovePendingStepVar="canApprovePendingStep"
	entitySubscriptionVar="entitySubscription"
	artifactRevisionVar="documentRevision"
	displayedRevisionVar="displayedRevision"
	displayedRevisionModifiedAtVar="displayedRevisionModifiedAt"
	displayedRevisionModifiedByVar="displayedRevisionModifiedBy"
	baselinesVar="baselines"
	referencesVar="docReferences" />


<c:set var="requestURI" scope="request" value="${documentRevision.propertiesLink}"/>

<ui:pageTitle printBody="false"><c:out value='${document.name}'/></ui:pageTitle>

<ui:actionGenerator builder="allArtifactActionsMenuBuilder" actionListName="artifactActions" subject="${documentRevision}">
	<c:set var="actionMenuBodyPart">
		<tag:versionUrl var="commentsVersionLink" urlLink="${documentRevision.simplePropertiesLink}" revisionNumber="${documentRevision.dto.version}" appendRequestParameters="true" requestParametersUrlFragment="orgDitchnetTabPaneId=document-comments"></tag:versionUrl>
		<c:url value="${commentsVersionLink}" var="commentsUrl"/>
		<tag:versionUrl var="historyVersionLink" urlLink="${documentRevision.simplePropertiesLink}" revisionNumber="${documentRevision.dto.version}" appendRequestParameters="true" requestParametersUrlFragment="orgDitchnetTabPaneId=document-history"></tag:versionUrl>
		<c:url value="${historyVersionLink}" var="historyUrl"/>

		<ui:breadcrumbs projectAware="${documentRevision.dto}" showProjects="false" commentsUrl="${commentsUrl}" historyUrl="${historyUrl}"/>
		<%-- include meta-data part --%>
		<div>
		<c:set var="Artifact" scope="request" value="${document}" />
		<ui:actionUrl var="unlockArtifactUrl" actions="${artifactActions}" key="unlock-artifact" />

		</div>
	</c:set>
	<c:set var="actionMenuRightPart">
		<c:if test="${not empty documentRevision.baseline}">
			<ui:branchBaselineBadge baseline="${documentRevision.baseline}"/>
		</c:if>
	</c:set>
<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">${actionMenuRightPart}</jsp:attribute>
	<jsp:body>${actionMenuBodyPart}</jsp:body>
</ui:actionMenuBar>
	<c:if test="${empty documentRevision.baseline}">
	  <ui:actionBar>
		<ui:rightAlign>
			<jsp:attribute name="filler">
				<ui:actionMenu title="more" actions="${artifactActions}" keys="Open Directory, Display Document, Follow, exportOneWikiPage, Live Edit, Add Association, Add Comment, Add Tag, addBaseline, Trends, lock-artifact, unlock-artifact, Favourite"  />
			</jsp:attribute>
			<jsp:attribute name="rightAligned">
				<c:set var="entityTypeId" value="${GROUP_OBJECT}"/>
			 	<c:set var="entityId" value="${document.id}"/>
			 	<jsp:include page="/includes/notificationBox.jsp">
				 	<jsp:param name="entityTypeId" value="${entityTypeId}"/>
				 	<jsp:param name="entityId" value="${entityId}" />
			 	</jsp:include>
			</jsp:attribute>
			<jsp:body>
				<ui:actionLink keys="Browse, New Version, Edit, rtf, Live Edit, Edit Properties" actions="${artifactActions}" />
			</jsp:body>
		</ui:rightAlign>
	  </ui:actionBar>
	</c:if>
</ui:actionGenerator>

<c:if test="${empty documentRevision.baseline and !empty document.additionalInfo.approvalWorkflow}">
	<c:set var="artifactToApprove" value="${document}" scope="request" />
	<jsp:include page="includes/artifactApprovalList.jsp">
		<jsp:param name="forwardUrl" value="${requestURI}" />
	</jsp:include>
</c:if>

<acl:isUserInRole var="userCanBrowseHistory" value="document_view_history" />

<%-- FIXME --%>
<c:set var="userCanViewAssociations" value="${document.typeId != 17}" />
<c:set var="userCanViewComments" value="${document.typeId != 17}" />

<c:url var="editNoteURL" value="/proj/doc/editWikiPage.do">
	<c:param name="doc_id" value="${doc_id}" />
</c:url>

<c:url var="newVersionURL" value="/proj/doc/upload.do">
	<c:param name="doc_id" value="${doc_id}" />
	<c:param name="upload" value="true" />
	<c:param name="revision"><c:out value='${param.revision}'/></c:param>
</c:url>

<c:url var="listDocumentsURL" value="/proj/doc.do">
	<c:choose>
		<c:when test="${document.directory}">
			<c:param name="doc_id" value="${doc_id}" />
		</c:when>

		<c:otherwise>
			<c:if test="${not empty document.parent}">
				<c:param name="doc_id" value="${document.parent.id}" />
			</c:if>
		</c:otherwise>
	</c:choose>
</c:url>

<c:url var="compareBaselinesUrl" value="/proj/baselines.spr">
	<c:param name="proj_id" value="${document.project.id}" />
</c:url>

<c:url var="compareTrackerBaselinesUrl" value="/proj/baselines.spr">
	<c:param name="proj_id" value="${document.project.id}" />
	<c:param name="tracker_id" value="${document.id}" />
</c:url>

<div class="contentWithMargins">

    <jsp:include page="../label/entityLabelList.jsp">
        <jsp:param name="entityTypeId" value="${GROUP_OBJECT}" />
        <jsp:param name="entityId" value="${doc_id}" />
        <jsp:param name="forwardUrl" value="/proj/doc/details.do?doc_id=${doc_id}" />
    </jsp:include>

    <c:set var="docProperties">
	<tag:mimeLinkTarget var="target" value="${document.name}" mimetypeVar="mimetype" />

	<jsp:include page="docProperties.jsp" />

	<c:if test="${!pageContext.request.robotRequest}">
		<tab:tabContainer id="document" skin="cb-box">

			<c:if test="${userCanViewComments}">
				<spring:message var="docCommentsTitle" code="document.commentsAndAttachments.title" text="Comments &amp; Attachments ({0})" arguments="${fn:length(docComments)}"/>
				<tab:tabPane id="document-comments" tabTitle="${docCommentsTitle}">
					<jsp:include page="docComments.jsp" />
				</tab:tabPane>
			</c:if>

			<c:if test="${userCanViewAssociations}">
				<spring:message var="docAssociationsTitle" code="associations.title" text="Associations"/>
				<tab:tabPane id="document-associations" tabTitle="${docAssociationsTitle}">
					<jsp:include page="docAssociations.jsp" />
				</tab:tabPane>
			</c:if>

			<spring:message var="docReferencesTitle" code="document.references.title" text="References ({0})" arguments="${fn:length(docReferences)}"/>
			<tab:tabPane id="document-references" tabTitle="${docReferencesTitle}">
				<jsp:include page="docReferences.jsp" />
			</tab:tabPane>

			<c:if test="${empty documentRevision.baseline and document.typeId != 15 and document.typeId != 16 and document.typeId != 17 and document.project != null}">
				<spring:message var="docNotificationsTitle" code="document.notifications.title" text="Notifications"/>
				<tab:tabPane id="document-notifications" tabTitle="${docNotificationsTitle}">
					<jsp:include page="./includes/documentNotification.jsp" />
				</tab:tabPane>

				<c:if test="${!empty document.project && !isBranch}">
					<spring:message var="docPermissionsTitle" code="document.permissions.title" text="Permissions"/>
					<tab:tabPane id="document-permissions" tabTitle="${docPermissionsTitle}">
						<jsp:include page="./includes/documentPermissions.jsp" />
					</tab:tabPane>
				</c:if>

				<%-- Approvals is not used any more
				<c:if test="${isArtifactApprovalLicensed && document.approvalSupported}">
					<spring:message var="docApprovalsTitle" code="document.approvals.title" text="Approvals"/>
					<tab:tabPane id="document-approals" tabTitle="${docApprovalsTitle}">
						<jsp:include page="./includes/documentApprovals.jsp" flush="true" />
					</tab:tabPane>
				</c:if>
				--%>
			</c:if>

			<c:if test="${userCanBrowseHistory and document.typeId != 16}">
				<spring:message var="docHistoryTitle" code="document.history.title" text="History"/>
				<tab:tabPane id="document-history" tabTitle="${docHistoryTitle}">
					<jsp:include page="docHistory.jsp" />
				</tab:tabPane>
				<c:if test="${!document.directory}">
					<spring:message var="docAccessLogTitle" code="document.accessLog.title" text="Access Log"/>
					<tab:tabPane id="document-access-log" tabTitle="${docAccessLogTitle}">
						<jsp:include page="docAccessLog.jsp" />
					</tab:tabPane>
				</c:if>
			</c:if>

			<%-- and licenseCode.enabled.baselines --%>
			<c:if test="${(document.typeId == 2 or document.typeId == 16 or document.wikiNotes)}">
				<spring:message var="docBaselinesTitle" code="document.baselines.title" text="Baselines ({0})" arguments="${fn:length(baselines)}"/>
				<tab:tabPane id="document-baseline" tabTitle="${docBaselinesTitle}">
					<form action="/proj/doc/compareBaselines.spr">
						<div class="actionBar">
							<ui:actionGenerator builder="allArtifactActionsMenuBuilder" actionListName="baselineActions" subject="${documentRevision}">
								<ui:actionLink keys="addBaseline" actions="${baselineActions}" />
							</ui:actionGenerator>
							<spring:message var="baselineCompareButton" code="project.baselines.compare.button" text="Compare Selected Baselines" />
							<c:choose>
								<c:when test="${document.typeId eq 16}">
									<input type="button" class="button" onclick="codebeamer.Baselines.compareBaselinesButtonHandler(this.form, '${compareTrackerBaselinesUrl}', 'revision'); return false;" value="${baselineCompareButton}" />
								</c:when>
								<c:otherwise>
									<input type="button" class="button" onclick="codebeamer.Baselines.compareBaselinesButtonHandler(this.form, '${compareBaselinesUrl}'); return false;" value="${baselineCompareButton}" />
								</c:otherwise>
							</c:choose>

						</div>

						<jsp:include page="./includes/documentBaselines.jsp" flush="true">
							<jsp:param name="requestURI" value="/proj/doc/details.do"/>
							<jsp:param name="projectScope" value="false"/>
						</jsp:include>
					</form>
				</tab:tabPane>
			</c:if>
		</tab:tabContainer>
	</c:if>
</c:set>

<%-- uncomment this block to restore the tree --%>
<%-- <jsp:include page="./includes/docTreeLayout.jsp">
	<jsp:param name="middlePanel" value="${docProperties}" />
</jsp:include> --%>

${docProperties}
</div>

