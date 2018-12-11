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
<meta name="module" content="wikispace"/>
<meta name="moduleCSSClass" content="wikiModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	TODO: here is some mess about the file-upload should be cleaned up:
		- first the displayPageActionBar.jsp initializes the file-upload widget for "import-from-word"
		- then one of the child pages below (add-document I guess) replaces the same widget with the "add-attachment"
 --%>
<jsp:include page="./includes/displayPageActionBar.jsp" flush="true">
	<jsp:param name="showMoreMenu" value="false" />
	<jsp:param name="actionLinkKeys" value="editWikiPageProperties,viewWikiPage" />
	<jsp:param name="propertiesPage" value="true"/>
</jsp:include>

<c:set var="doc_id" value="${param.doc_id}" />
<c:catch>
	<c:if test="${param.forward_doc_id gt 0}">
		<c:set var="doc_id" value="${param.forward_doc_id}" />
	</c:if>
</c:catch>

<c:url var="compareBaselinesUrl" value="/proj/baselines.spr">
	<c:param name="proj_id" value="${not empty wikiPage.project ? wikiPage.project.id : ''}" />
</c:url>

<div class="contentWithMargins" >
<jsp:include page="pageProperties.jsp" />
<br/>

<c:if test="${!pageContext.request.robotRequest}">
	<tab:tabContainer id="wiki-page" skin="cb-box">

		<spring:message var="commentsTitle" code="document.commentsAndAttachments.title" text="Comments &amp; Attachments ({0})" arguments="${fn:length(docComments)}"/>
		<tab:tabPane id="wiki-page-comments" tabTitle="${commentsTitle}">
			<jsp:include page="/docs/docComments.jsp" />
		</tab:tabPane>

		<spring:message var="pageAssociationsTitle" code="associations.title" text="Associations"/>
		<tab:tabPane id="wiki-page-associations" tabTitle="${pageAssociationsTitle}">
			<jsp:include page="pageAssociations.jsp" />
		</tab:tabPane>

		<spring:message var="linksTitle" code="wiki.links.title" text="Links ({0}:{1})" arguments="${fn:length(pageIncomingLinks)},${fn:length(pageOutgoingLinks)}"/>
		<tab:tabPane id="wiki-page-links" tabTitle="${linksTitle}">
			<div class="actionBar" style="margin-bottom: 15px;"></div>
			<jsp:include page="pageLinks.jsp" />
		</tab:tabPane>

		<spring:message var="childrenTitle" code="wiki.children.title" text="Children ({0})" arguments="${fn:length(pageChildren)}"/>
		<tab:tabPane id="wiki-page-children" tabTitle="${childrenTitle}">
			<jsp:include page="pageChildren.jsp" />
		</tab:tabPane>

		<c:if test="${wikiPage.project != null}">
			<spring:message var="pageNotificationsTitle" code="document.notifications.title" text="Notifications"/>
			<tab:tabPane id="wiki-page-notifications" tabTitle="${pageNotificationsTitle}">
				<jsp:include page="../docs/includes/documentNotification.jsp" />
			</tab:tabPane>
		</c:if>

		<c:if test="${wikiPage.project != null}">
			<spring:message var="pagePermissionsTitle" code="document.permissions.title" text="Permissions"/>
			<tab:tabPane id="wiki-page-permissions" tabTitle="${pagePermissionsTitle}">
				<jsp:include page="../docs/includes/documentPermissions.jsp" />
			</tab:tabPane>
		</c:if>

		<%-- Approvals is not used any more
		<c:if test="${isArtifactApprovalLicensed && wikiPage.approvalSupported}">
			<spring:message var="pageApprovalsTitle" code="document.approvals.title" text="Approvals"/>
			<tab:tabPane id="wiki-page-approvals" tabTitle="${pageApprovalsTitle}">
				<div class="actionBar" style="margin-bottom: 15px;"></div>
				<jsp:include page="pageApprovals.jsp" />
			</tab:tabPane>
		</c:if>
		--%>

		<c:if test="${userCanBrowseHistory}">
			<spring:message var="pageHistoryTitle" code="document.history.title" text="History"/>
			<tab:tabPane id="wiki-page-history" tabTitle="${pageHistoryTitle}">
				<jsp:include page="pageHistory.jsp" />
			</tab:tabPane>
		</c:if>

		<%-- c:if test="${licenseCode.enabled.baselines}" --%>
			<spring:message var="pageBaselinesTitle" code="document.baselines.title" text="Baselines ({0})" arguments="${fn:length(baselines)}"/>
			<tab:tabPane id="wiki-page-baseline" tabTitle="${pageBaselinesTitle}">
				<form action="/proj/doc/compareBaselines.spr">
					<div class="actionBar">
						<ui:actionGenerator builder="wikiPageActionMenuBuilder" actionListName="baselineActions" subject="${wikiPage}">
							<ui:actionLink keys="addBaseline" actions="${baselineActions}" />
						</ui:actionGenerator>
						<spring:message var="baselineCompareButton" code="project.baselines.compare.button" text="Compare Selected Baselines" />
						<input type="button" class="button" onclick="codebeamer.Baselines.compareBaselinesButtonHandler(this.form, '${compareBaselinesUrl}'); return false;" value="${baselineCompareButton}" />
					</div>

					<jsp:include page="/docs/includes/documentBaselines.jsp" flush="true">
						<jsp:param name="requestURI" value="/proj/wiki/displayWikiPageProperties.spr"/>
					</jsp:include>
				</form>
			</tab:tabPane>
		<%-- c:if --%>
	</tab:tabContainer>
</c:if>
</div>

