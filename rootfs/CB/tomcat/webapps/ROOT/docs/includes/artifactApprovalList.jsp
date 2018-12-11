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
 *
 * $Revision: 22554:61759bf5389c $ $Date: 2009-09-08 09:50 +0000 $
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%@ page import="com.intland.codebeamer.persistence.dto.ArtifactDto"%>

<c:set var="user" value="${pageContext.request.userPrincipal}" />

<%-- Optional parameter if immediately should start approving (if possible) --%>
<c:set var="startApproving" value="${param.startApproving eq 'true'}" />
<c:if test="${startApproving}">
	<ui:delayedScript>
		<script type="text/javascript">
			try {
				showApproveArtifactForm();
			} catch (ignored) {
				// exception ignored
			}
		</script>
	</ui:delayedScript>
</c:if>

<%-- when having version waiting for approval, but not necessarily viewing it --%>
<c:set var="havingPending" value="${(!empty artifactToApprove.additionalInfo.publishedRevision)}" />
<%-- when viewing the published version and there is one waiting for approval --%>
<c:set var="viewingPublished" value="${havingPending && (displayedRevision == artifactToApprove.additionalInfo.publishedRevision)}" />
<%-- when viewing the version waiting for approval --%>
<c:set var="viewingPending" value="${havingPending && (displayedRevision == artifactToApprove.headRevision)}" />
<%-- when viewing any historical version --%>
<c:set var="viewingHistorical" value="${(!empty displayedRevision) && (displayedRevision != artifactToApprove.headRevision) && (displayedRevision != artifactToApprove.additionalInfo.publishedRevision)}" />
<%-- when not viewing any version, but still being in approval context --%>
<c:set var="notViewingButApproving" value="${havingPending && !viewingPublished && !viewingPending && !viewingHistorical}" />

<%
	ArtifactDto artifactToApprove = ((ArtifactDto)request.getAttribute("artifactToApprove"));
%>
<%-- version message --%>
<c:if test="${artifactToApprove.writable}">
	<c:url var="lastRevisionUrl" value="<%= artifactToApprove.getUrlLinkBaselined(artifactToApprove.getHeadRevision()) %>" />
	<c:url var="publishedRevisionUrl" value="<%= artifactToApprove.getUrlLinkBaselined(artifactToApprove.getAdditionalInfo().getPublishedRevision()) %>" />
	<%-- check if the last version is viewable by the user, and don't show the link to that if not --%>
	<tag:document var="document" doc_id="${artifactToApprove.id}" revision="${artifactToApprove.headRevision}" scope="page"
		isArtifactViewableInApprovalVar="canViewLastRevision" />

	<c:choose>
		<c:when test="${notViewingButApproving}">
			<c:choose>
				<c:when test="${canViewLastRevision}">
					<spring:message var="revisionMessage" code="artifact.approval.approving.message" arguments="${lastRevisionUrl},${artifactToApprove.version},${publishedRevisionUrl},${artifactToApprove.additionalInfo.publishedRevision}"/>
				</c:when>
				<c:otherwise>
					<spring:message var="revisionMessage" code="artifact.approval.approving.message.removed.link" arguments="${artifactToApprove.version},${publishedRevisionUrl},${artifactToApprove.additionalInfo.publishedRevision}"/>
				</c:otherwise>
			</c:choose>
		</c:when>
		<c:when test="${viewingPublished}">
			<c:choose>
				<c:when test="${canViewLastRevision}">
					<spring:message var="revisionMessage" code="artifact.approval.published.message" arguments="${displayedRevision},${lastRevisionUrl},${artifactToApprove.headRevision}"/>
				</c:when>
				<c:otherwise>
					<spring:message var="revisionMessage" code="artifact.approval.published.message.removed.link" arguments="${displayedRevision},${artifactToApprove.headRevision}"/>
				</c:otherwise>
			</c:choose>
		</c:when>
		<c:when test="${viewingPending}">
			<spring:message var="revisionMessage" code="artifact.approval.pending.message" arguments="${displayedRevision},${publishedRevisionUrl},${artifactToApprove.additionalInfo.publishedRevision}"/>
		</c:when>
		<c:when test="${viewingHistorical}">
			<c:url var="publishedRevisionUrl" value="${artifactToApprove.urlLink}" />
			<spring:message var="revisionMessage" code="artifact.approval.historical.message" arguments="${displayedRevision},${publishedRevisionUrl},${(empty artifactToApprove.additionalInfo.publishedRevision) ? artifactToApprove.headRevision : artifactToApprove.additionalInfo.publishedRevision}"/>
		</c:when>
	</c:choose>
	<c:if test="${! empty revisionMessage}">
		<div id="revisionMessage">${revisionMessage}</div>
	</c:if>
</c:if>

<c:if test="${isArtifactApprovalLicensed && (canApproveWorkflow || canRejectDocumentInWorkflow)}">
	<%-- approval steps --%>
	<c:if test="${viewingPending || notViewingButApproving}">
		<div id="artifactApprovalList">
			<script type="text/javascript">
				function showApproveArtifactForm() {
					document.getElementById('approveArtifactForm').style.display = 'block';
					$(document.getElementById('approveArtifactFormComment')).focus();
					return false;
				}

				function hideApproveArtifactForm() {
					document.getElementById('approveArtifactForm').style.display = 'none';
					return false;
				}
			</script>

			<jsp:include page="./artifactApprovalFlow.jsp" />

			<%-- approval form --%>
			<c:if test="${currentStep != null}">
				<form id="approveArtifactForm" style="display: none;" action="<c:url value="/approveArtifact.spr"/>" method="post">
					<input type="hidden" name="artifactId" value="<c:url value='${artifactToApprove.id}'/>" />
					<input type="hidden" name="approvalStepId" value="<c:url value='${currentStep.id}'/>" />
					<input type="hidden" name="revision" value="<c:url value='${artifactToApprove.version}'/>" />
					<input type="hidden" name="forwardUrl" value="<c:url value='${param.forwardUrl}'/>" />

					<b><c:out value="${currentStep.name}" /></b>
					<div style="margin-top: 5px;">
						<spring:message code="artifact.approval.workflow.step.comment.label" text="Comment"/>:
						<input id="approveArtifactFormComment" type="text" name="comment" size="100" />

						<c:if test="${canApprovePendingStep}" >
							<input type="submit" name="approved" value="<spring:message code='artifact.approval.workflow.step.approve.button'/>" class="button" />
						</c:if>
						<c:if test="${canRejectDocumentInWorkflow}">
							<input type="submit" name="rejected" value="<spring:message code='artifact.approval.workflow.step.reject.button'/>" class="button" />
						</c:if>

						<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
						<input type="button" value="${cancelButton}" class="button cancelButton" onclick="javascript: return hideApproveArtifactForm();" />
					</div>
				</form>
			</c:if>
		</div>
	</c:if>
</c:if>

