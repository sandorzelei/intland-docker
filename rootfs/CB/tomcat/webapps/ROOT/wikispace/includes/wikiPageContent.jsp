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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<c:set var="withNavigationBar" value="${!empty navBarPage and !wikiPage.projectNavigationBarPage}" />

<c:set var="wikiPageContent" scope="request">
	<div id="wikiPageContent" class="scrollable gainLayout ${withNavigationBar ? 'withNavigationBar' : ''}" data-wiki-page-id="${wikiPage.id}">
		<c:if test="${empty isArtifactViewableInApproval || isArtifactViewableInApproval}">
		<c:choose>
			<c:when test="${empty navBarPage}">
				<div class="wikiContentSpacingWrapper">
					<jsp:include page="displayPagePageContent.jsp" />
				</div>
			</c:when>
			<c:otherwise>
				<table class="wikilayout" cellspacing="0" cellpadding="0" border="0">
					<tr>
						<td class="main"><c:if test="${withNavigationBar}"><div class="mainContainer"></c:if>
							<jsp:include page="displayPagePageContent.jsp" />
							<c:if test="${withNavigationBar}"></div></c:if>
						</td>
						<c:if test="${withNavigationBar}">
							<td class="navigation">
								<jsp:include page="displayPageNavigationBar.jsp" />
							</td>
						</c:if>
					</tr>
				</table>
			</c:otherwise>
		</c:choose>
		</c:if>
		<ui:delayedScript>
		<script type="text/javascript">
			$("#wikiPageContent").ready(function() {
				alignElementsToViewportEdge.init(".editsection", "centerDiv");
			});
		</script>
		</ui:delayedScript>
	</div>
</c:set>

<c:if test="${!wikiPage.userPage and empty pageRevision.baseline}">
	<c:if test="${empty simpleWikiPage || ! simpleWikiPage}">
	<jsp:include page="../../label/entityLabelList.jsp">
		<jsp:param name="entityTypeId" value="${GROUP_OBJECT}" />
		<jsp:param name="entityId" value="${wikiPage.id}" />
		<jsp:param name="forwardUrl" value="${wikiPage.urlLink}" />
		<jsp:param name="editable" value="${empty pageRevision.baseline}"/>
	</jsp:include>
	</c:if>

	<c:if test="${!empty wikiPage.additionalInfo.approvalWorkflow}">
		<c:set var="artifactToApprove" value="${wikiPage}" scope="request" />
		<jsp:include page="../../docs/includes/artifactApprovalList.jsp">
			<jsp:param name="forwardUrl" value="${pageRevision.urlLink}" />
		</jsp:include>
	</c:if>
</c:if>
${wikiPageContent}
