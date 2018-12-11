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
 * $Revision: 19247:238b59e29ffd $ $Date: 2008-11-07 09:47 +0000 $
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<tag:mimeLinkTarget var="target" value="${artifactToApprove.name}" mimetypeVar="mimetype" />

<c:url var="showAllApprovalWorkflowsURL" value="/proj/admin.spr">
	<c:if test="${!empty artifactToApprove.project.id}">
		<c:param name="proj_id" value="${artifactToApprove.project.id}" />
	</c:if>
	<c:param name="orgDitchnetTabPaneId" value="project-admin-approvals" />
</c:url>

<c:choose>
	<c:when test="${artifactToApprove.wikiPage}">
		<c:choose>
			<c:when test="${artifactToApprove.wikiNotes}">
				<spring:message var="artifactTypeName" code="document.type.wikiNote" text="Wiki Note"/>
			</c:when>
			<c:otherwise>
				<spring:message var="artifactTypeName" code="document.type.wikiPage" text="Wiki Page"/>
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:otherwise>
		<spring:message var="artifactTypeName" code="document.label" text="Document"/>
	</c:otherwise>
</c:choose>

<div style="margin-bottom: 5px;">
	<c:choose>
		<c:when test="${canApplyOrRemoveApprovalWorkflow}">
			<c:url var="setArtifactApprovalURL" value="/setArtifactApproval.spr" >
				<c:param name="artifactId" value="<c:url value='${artifactToApprove.id}'/>"/>
				<c:param name="forwardUrl" value="<c:url value='${param.forwardUrl}'/>" />
			</c:url>
			<c:choose>
				<c:when test="${empty artifactToApprove.additionalInfo.publishedRevision}">
					<c:choose>
						<c:when test="${!empty approvalWorkflows}">
							<spring:message code="artifact.approval.workflow.label" text="Approval Workflow"/>:
							<form action="${setArtifactApprovalURL}" method="post" style="display:inline;" >
								<select name="artifactApprovalId">
									<option value="-1" <c:if test="${empty artifactToApprove.additionalInfo.approvalWorkflow}">selected="selected"</c:if>>
										<spring:message code="artifact.approval.none.label" text="None (Publish Instantly)"/>
									</option>
									<optgroup label='<spring:message code="artifact.approval.workflows.label" text="Approval Workflows"/>'>
										<c:forEach items="${approvalWorkflows}" var="approvalWorkflow">
											<option value="${approvalWorkflow.id}"  <c:if test="${(!empty artifactToApprove.additionalInfo.approvalWorkflow) and (artifactToApprove.additionalInfo.approvalWorkflow.id eq approvalWorkflow.id)}">selected="selected"</c:if>><c:url value='${approvalWorkflow.name}'/></option>
										</c:forEach>
									</optgroup>
								</select>
								<spring:message var="changeWorkflowButton" code="artifact.approval.change.button" text="Change Workflow"/>
								<input type="submit" class="button" style="margin-right: 30px;" value="${changeWorkflowButton}" />
							</form>
						</c:when>
						<c:otherwise>
							<spring:message code="artifact.approval.workflow.none.hint" arguments="${showAllApprovalWorkflowsURL}"/>
						</c:otherwise>
					</c:choose>
				</c:when>
				<c:otherwise>
					<spring:message code="artifact.approval.remove.hint" text="The approval workflow can not be changed because of pending changes, but you can"/>

					<form action="${setArtifactApprovalURL}" method="post" style="display:inline;" >
						<input type="hidden" name="artifactApprovalId" value="-1"/>

						<spring:message var="removeButton" code="artifact.approval.remove.button" text="Remove from Workflow"/>
						<spring:message var="removeConfirm" code="artifact.approval.remove.confirm" text="Are you sure to remove this Artifact from workflow?\nIt will be automatically published, or if it has already been rejected then the original content will be restored back!"/>
						<input type="submit" class="button" style="margin-right: 30px;" value="${removeButton}"	onclick="return confirm('${removeConfirm}');" />
					</form>
				</c:otherwise>
			</c:choose>
		</c:when>
		<c:otherwise>
			<spring:message code="artifact.approval.change.hint" arguments="${artifactTypeName}"/>
		</c:otherwise>
	</c:choose>
</div>

<style type="text/css">
<!--
 table.displaytag .approvalCell {
 	padding: 4px 5px;
 }
-->
</style>

<display:table requestURI="" defaultsort="2" defaultorder="descending" cellpadding="0" name="${approvalHistory}" id="approvalHistoryEntry">

	<spring:message var="documentVersion" code="document.version.label" text="Version"/>
	<display:column title="${documentVersion}" sortProperty="version" headerClass="numberData" class="numberData columnSeparator" media="html" sortable="true">
		<c:choose>
			<c:when test="${artifactToApprove.file}">
				<%-- document --%>
				<c:choose>
					<c:when test="${mimetype == 'text/wiki'}">
						<c:url var="click_url" value="${document.urlLink}">
							<c:param name="doc_id" value="${artifactToApprove.id}" />
							<c:param name="revision" value="${approvalHistoryEntry.version}" />
						</c:url>

						<c:remove var="onclick" />
					</c:when>

					<c:otherwise>
						<tag:replace var="filename" value="${document.name}" pattern="'" replacement="_" />
						<tag:replace var="filename" value="${filename}" pattern="&quot;" replacement="_" />
                        <tag:encodePath var="filename" value="${filename}" />
						<c:set var="filename"><spring:escapeBody javaScriptEscape="true">${filename}</spring:escapeBody></c:set>

                        <c:url var="click_url" value="/displayDocument/${filename}">
							<c:param name="doc_id" value="${artifactToApprove.id}" />
							<c:param name="revision" value="${approvalHistoryEntry.version}" />
						</c:url>

						<c:set var="onclick" value="launch_url('${click_url}');return false;" />
					</c:otherwise>
				</c:choose>
			</c:when>
			<c:otherwise>
				<%-- wiki page --%>
				<c:url var="click_url" value="/proj/wiki/displayWikiPageRevision.spr">
					<c:param name="doc_id" value="${artifactToApprove.id}" />
					<c:param name="revision" value="${approvalHistoryEntry.version}" />
				</c:url>
			</c:otherwise>
		</c:choose>
		<spring:message var="versionTitle" code="artifact.approval.version.tooltip" text="Display This Version"/>
		<html:link href="${click_url}" onclick="${onclick}" title="${versionTitle}"><c:out value="${approvalHistoryEntry.version}" /></html:link>
	</display:column>

	<spring:message var="approvalDate" code="artifact.approval.approvedAt.label" text="Date"/>
	<display:column title="${approvalDate}" sortProperty="approvedAt" sortable="true" headerClass="dateData" class="dateData"
		media="html xml csv pdf rtf">
		<tag:formatDate value="${approvalHistoryEntry.approvedAt}" />
	</display:column>

	<spring:message var="approvalStep" code="artifact.approval.workflow.step.label" text="Step"/>
	<display:column title="${approvalStep}" headerClass="textData" class="textData columnSeparator approvalCell">
		<c:set var="approvalCSSClass" value="${approvalHistoryEntry.approved? 'approvedStep' : 'rejectedStep' }"/>
		<div class="${approvalCSSClass}"><c:out value="${approvalHistoryEntry.stepName}" /></div>
	</display:column>

	<spring:message var="approvalApprover" code="artifact.approval.approver.label" text="Account"/>
	<display:column title="${approvalApprover}" sortProperty="approver.name" sortable="true" media="html" headerClass="textData" class="textData columnSeparator">
		<tag:userLink user_id="${approvalHistoryEntry.approver.id}" />
	</display:column>

	<spring:message var="approvalComment" code="artifact.approval.comment.label" text="Comment"/>
	<display:column title="${approvalComment}" sortProperty="comment" headerClass="textData expand" class="textData" sortable="true">
		<c:out value="${approvalHistoryEntry.comment}" />
	</display:column>

</display:table>
