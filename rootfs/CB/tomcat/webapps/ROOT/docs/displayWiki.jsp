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
<meta name="moduleCSSClass" content="documentsModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@page import="com.intland.codebeamer.remoting.GroupType"%>

<c:set var="doc_id" value="${param.doc_id}" />
<c:set var="revision" value="${param.revision}" />
<c:set var="displayFormat" value="${param.displayFormat}" />

<style>
	#middleHeaderDiv.actionBar {
		padding-top: 7px;
		padding-bottom: 6px;
	}
	#middleHeaderDiv.actionBar .actionLink:first-child {
		margin-left: 10px;
	}
	#middleHeaderDiv.actionBar img.menuArrowDown.actionBarIcon {
		margin: 0;
		top: 0;
	}
	#opener-west {
		margin-top: -20px !important;
		margin-left: -5px;
	}
</style>

<tag:document var="document" doc_id="${doc_id}" revision="${revision}" scope="request"
	artifactRevisionVar="documentRevision"
	displayedRevisionVar="displayedRevision"
	displayedRevisionModifiedAtVar="displayedRevisionModifiedAt"
	displayedRevisionModifiedByVar="displayedRevisionModifiedBy"
	isArtifactApprovalLicensedVar="isArtifactApprovalLicensed"
	approvalStateVar="approvalState"
	approvalHistoryVar="approvalHistory"
	canApplyOrRemoveApprovalWorkflowVar="canApplyOrRemoveApprovalWorkflow"
	canApproveWorkflowVar="canApproveWorkflow"
	canRejectDocumentInWorkflowVar="canRejectDocumentInWorkflow"
	canApprovePendingStepVar="canApprovePendingStep"
	commentsVar="comments"
/>

<tag:history command="add" type="<%=Integer.valueOf(GroupType.ARTIFACT)%>" id="${doc_id}" version="${revision}"/>

<c:set var="requestURI" scope="request" value="${documentRevision.propertiesLink}"/>

<ui:pageTitle printBody="false"><c:out value='${document.name}'/></ui:pageTitle>

<ui:actionGenerator builder="allArtifactActionsMenuBuilder" actionListName="artifactActions" subject="${documentRevision}" >
	<c:set var="actionMenuBodyPart">
			<c:url var="historyUrl" value="${documentRevision.propertiesLink}">
				<c:param name="orgDitchnetTabPaneId" value="document-history"/>
			</c:url>
			<c:url var="commentsUrl" value="${documentRevision.propertiesLink}">
				<c:param name="orgDitchnetTabPaneId" value="document-comments"/>
			</c:url>
			<ui:breadcrumbs showProjects="false" historyUrl="${historyUrl}" commentsUrl="${commentsUrl}"/>
			<c:if test="${!empty revision}">
				&nbsp;<spring:message code="document.version.info" text="Version {0}" arguments="${revision}"/>
			</c:if>
			<%-- include meta-data part --%>
			<c:set var="Artifact" scope="request" value="${document}" />
			<c:set var="docComments" scope="request" value="${comments}" />
			<ui:actionUrl var="unlockArtifactUrl" actions="${artifactActions}" key="unlock-artifact" />

			<jsp:include page="./includes/docMetaData.jsp" flush="true">
				<jsp:param name="infoURL" value="${requestURI}"/>
				<jsp:param name="ditchnetPrefix" value="document" />
				<jsp:param name="unlockArtifactUrl" value="${unlockArtifactUrl}" />
			</jsp:include>
	</c:set>

	<c:set var="actionMenuRightPart"></c:set>

	<ui:actionMenuBar>
		<jsp:attribute name="rightAligned">${actionMenuRightPart}</jsp:attribute>
		<jsp:body>${actionMenuBodyPart}</jsp:body>
	</ui:actionMenuBar>

	<c:if test="${empty documentRevision.baseline and !empty document.additionalInfo.approvalWorkflow}">
		<c:set var="artifactToApprove" value="${document}" scope="request" />
		<jsp:include page="includes/artifactApprovalList.jsp">
			<jsp:param name="forwardUrl" value="${requestURI}" />
		</jsp:include>
	</c:if>

	<c:if test="${!empty documentRevision.baseline}">
		<style type="text/css">
			#middle-panel {
				background: #FFFFDD !important;
			}
		</style>
	</c:if>

	<%-- Display the formatted document --%>
	<c:set var="wikiContent">
		<c:if test="${empty isArtifactViewableInApproval || isArtifactViewableInApproval}">
			<div id="pagecontent"><%-- JSPWiki javascript function rely on using this ID --%>
				<c:if test="${!empty documentRevision.baseline}">
					<ui:baselineInfoBar projectId="${document.project.id}" baselineName="${documentRevision.baseline.name}" baselineParamName="revision" />
				</c:if>
				<div class="full wikiContentSpacingWrapper thumbnailImages thumbnailImages800px">
					<tag:wikiPage doc_id="${doc_id}" revision="${revision}" format="${displayFormat}"/>
				</div>
			</div>
		</c:if>
	</c:set>

	<c:set var="wikiActionBar">
		<c:if var="pageIsEditable" test="${!empty artifactActions['Edit']}" />
		<ui:rightAlign>
			<jsp:attribute name="filler">
				<ui:actionMenu title="more" actions="${artifactActions}" keys="Add Association, Add Comment, Add Tag, addBaseline, ---, viewInOtherFormat, ----, importOneWikiPage, exportOneWikiPage, exportWikiPages, ExportToTracker, -----, Trends, copyWiki"  />
			</jsp:attribute>
			<jsp:body>
				<ui:actionLink keys="Edit, rtf, Properties" actions="${artifactActions}" />
			</jsp:body>
		</ui:rightAlign>
	</c:set>

	<jsp:include page="./includes/docTreeLayout.jsp">
		<jsp:param name="middlePaneActionBar" value="${wikiActionBar}" />
		<jsp:param name="middlePanel" value="${wikiContent}" />
	</jsp:include>

</ui:actionGenerator>
