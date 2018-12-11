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
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html>

<head>
	<meta name="decorator" content="popup"/>
	<meta name="moduleCSSClass" content="newskin fr-modal" />

	<c:set var="wikiLinkJS" value="/js/wysiwyg/froala_plugins/cbwikihistorylink/js/wikiLinkPopup.js" />
	<c:set var="attachmentsDisabled" value="${false}" />
	<c:if test="${not empty fieldId}">
		<c:set var="wikiLinkJS" value="/js/wysiwyg/froala_plugins/cbwikihistorylink/js/wikiLinkPopupForUrlField.js" />
		<c:set var="attachmentsDisabled" value="${true}" />
	</c:if>
	<script type="text/javascript" src="<ui:urlversioned value='${wikiLinkJS}'/>"></script>
	<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/wysiwyg/froala_plugins/froalaModal.less'/>"/>

	<style type="text/css">
		.fr-modal .table-header {
			margin-top: 20px;
			margin-bottom: 10px;
		}

		.fr-modal .form {
			margin-left: 5px;
		}

		.fr-modal .invalidWikiLinkWarning {
			display: none;
		}

		.fr-modal .form-line:after {
			content: '';
			clear: both;
			display: block;
		}

		.fr-modal .float-left {
			float: left;
		}

		.fr-modal .float-right {
			float: right;
		}

		.fr-modal .form label {
			text-align: right;
		}
		
		#linkFilter {
			width: 150px;
			margin-top: 2px;
		}

		#attachmentFilter {
		    width: 150px;
		    margin-top: 2px;
		}

		.fr-modal .issueIcon {
			vertical-align:text-top;
		}

		.form-line label {
			width: 120px;
		}

		.fr-modal .form .form-line h3 {
			font-size: 13px;
		}

		input.alias {
			font-size: 13px;
		}

		.selectionColumn {
			vertical-align: middle;
		}

		input[name=wikiLinkRadio] {
			display: inline-block;
		}

		.FF input[name=wikiLinkRadio] {
			margin-top: -1px;
		}

		.Chrome input[name=wikiLinkRadio] {
			margin-top: 1px;
		}

		.FF .wikiLinkContainer span[data-hover-tooltip-target] .trackerImage,
		.Chrome .wikiLinkContainer span[data-hover-tooltip-target] .trackerImage {
			margin-top: -1px;
		}

		input.button {
			float: none;
		    border: solid 1px #d1d1d1;
		    font-size: 13px !important;
		    font-weight: bold;
		    color: #1e1e1e !important;
		    background: url(${pageContext.request.contextPath}/images/newskin/action/bg-button-xs.png);
		    background-repeat: repeat-x !important;
		    background-color: #f5f5f5 !important;
		    min-height: 25px;
		    min-width: 80px;
		    cursor: pointer;
		    padding: 4px;
		}

		#searchFilterPattern {
			font: 99% arial, helvetica, clean, sans-serif
		}

		#selectColumnTitle {
			display: none;
		}

		#searchDocumentItem tr {
			vertical-align: middle;
		}

		#searchWikipageItem tr {
			vertical-align: middle;
		}

		#searchTrackerItem tr {
			vertical-align: middle;
		}

		#searchProjectItem tr {
			vertical-align: middle;
		}

		#wikiHistoryLinkTable tr {
			vertical-align: middle;
		}
	</style>
</head>

<body>
	<ui:pageTitle printBody="false"><spring:message var="title" code="wysiwyg.history.link.plugin.title" text="Link History"/></ui:pageTitle>

	<ui:actionMenuBar>
		<span class="menuTitle">${title}</span>
	</ui:actionMenuBar>

	<spring:message var="insertLinkButtonLabel" code="wysiwyg.history.link.plugin.insertLink.button.label" />
	<spring:message var="cancelButtonLabel" code="wysiwyg.history.link.plugin.cancel.button.label" />

	<ui:actionBar>
		&nbsp;&nbsp;<input type="button" class="button" name="insert" value="${insertLinkButtonLabel}"/>
		<input type="button" class="button cancelButton" value="${cancelButtonLabel}" />
	</ui:actionBar>

	<c:set var="aliasInput">
		<div class="form">
			<div class="form-line">
				<spring:message var="linkAliasTooltip" code="wysiwyg.history.link.plugin.alias.tooltip"/>
				<label for="linkAlias" title="${linkAliasTooltip}"><h3><spring:message code="wysiwyg.history.link.plugin.alias"/>:</h3></label>
				<div class="input-container"><input class="alias" name="alias" type="text" title="${linkAliasTooltip}"></div>
			</div>
		</div>
	</c:set>

	<c:set var="showSelection" value="true" scope="request" />
	<c:set var="selectedTabPane" value="wikiLinkHistoryTabPane" />
	<c:if test="${not empty selected}">
		<c:set var="selectedTabPane" value="${selected}" />
	</c:if>
	<input type="hidden" id="fieldId" value="${fieldId}" />
	<tab:tabContainer id="insertWikiLinkTabContainer" skin="cb-box" selectedTabPaneId="${selectedTabPane}">

		<spring:message var="tabTitle" code="wysiwyg.history.link.plugin.historyTab.title" />
		<tab:tabPane id="wikiLinkHistoryTabPane" tabTitle='${tabTitle}'>
			${aliasInput}

			<div class="form table-header">
				<div class="form-line">
					<div class="float-left">
						<h3><spring:message code="History"/>:</h3>
					</div>
					<div class="float-right">
						<spring:message var="linkFilterTooltip" code="wysiwyg.history.link.plugin.filter.tooltip"/>
						<label for="linkFilter" class="float-left" title="${linkFilterTooltip}"><h3><spring:message code="wysiwyg.history.link.plugin.filter"/>:</h3></label>
						<input name="filter" type="text" id="linkFilter" title="${linkFilterTooltip}"/>
					</div>
				</div>
			</div>

			<spring:message var="wikiLinkLabel" code="user.history.wikiLink.label" />
			<spring:message var="artifactLabel" code="user.history.shortDescription.label" />
			<spring:message var="dateLabel" code="user.history.date.label" />
			<spring:message var="linkTooltip" code="wysiwyg.history.link.plugin.link.tooltip" />

			<tag:history var="history" command="list" />

			<display:table class="displaytag" cellpadding="0" requestURI="" name="${history}" id="item" htmlId="wikiHistoryLinkTable"
				defaultsort="4" defaultorder="descending" decorator="com.intland.codebeamer.ui.view.table.HistoryDecorator">

				<display:column title="" headerClass="textData checkbox-column-minwidth" class="textDataWrap checkbox-column-minwidth columnSeparator selectionColumn">
					<input type="radio" name="wikiLinkRadio" />
				</display:column>

				<display:column title="${wikiLinkLabel}" sortProperty="sortInterwikiLink"
					headerClass="`" class="textData columnSeparator filterable" sortable="true">

 					<!-- Link to show on user interface. -->
					<ui:wikiLink item="${item.dto}" hideBadges="${true}" showItemName="${true}"/>

					<!-- Link to clone and insert into the page. -->
					<c:set var="url" value="CB:${item.urlLink}" />
					<c:set var="name"><c:out value="${item.name}" /></c:set>

					<c:if test="${ui:isTrackerItem(item.dto)}">
						<tag:summary var="summary" item="${item.dto}" />
						<c:set var="name" value="${item.getInterwikiLinkWithoutVersion()} ${summary}" />
					</c:if>

					<a style="display: none;" href="${url}" alt="${ui:encodeForHtml(name)}"">
						<c:out value="${item.getInterwikiLinkWithoutVersion()}" />
					</a>
				</display:column>

				<display:column title="${dateLabel}" sortProperty="date" headerClass="textData" class="textData" sortable="true">
					<tag:formatDate value="${item.date}" />
				</display:column>
			</display:table>

		</tab:tabPane>

		<c:if test="${not attachmentsDisabled}">
			<spring:message var="tabTitle" code="wysiwyg.history.link.plugin.attachment.title" />
			<tab:tabPane id="attachmentWikiLinkTabPane" tabTitle='${tabTitle}'>
				<c:choose>
					<c:when test="${fn:length(attachments) > 0}">
						${aliasInput}
						<div class="form table-header">
							<div class="form-line">
								<div class="float-left">
									<h3><spring:message code="attachments.label"/>:</h3>
								</div>
								<div class="float-right">
									<spring:message var="linkFilterTooltip" code="wysiwyg.history.link.plugin.filter.tooltip"/>
									<label for="linkFilter" class="float-left" title="${linkFilterTooltip}"><h3><spring:message code="wysiwyg.history.link.plugin.filter"/>:</h3></label>
									<input name="filter" type="text" id="attachmentFilter" title="${linkFilterTooltip}"/>
								</div>
							</div>
						</div>
						<spring:message var="wikiLinkLabel" code="user.history.wikiLink.label" />
						<spring:message var="artifactLabel" code="user.history.shortDescription.label" />
						<spring:message var="dateLabel" code="user.history.date.label" />
						<spring:message var="linkTooltip" code="wysiwyg.history.link.plugin.link.tooltip" />
						<display:table class="displaytag" cellpadding="0" requestURI="" name="${attachments}" id="item" htmlId="wikiAttachmentLinkTable"
							defaultsort="4" defaultorder="descending">
	
							<display:column title="" headerClass="textData checkbox-column-minwidth" class="textDataWrap checkbox-column-minwidth columnSeparator selectionColumn">
								<input type="radio" name="wikiLinkRadio" />
							</display:column>
	
							<display:column title="${wikiLinkLabel}"
								headerClass="`" class="textData columnSeparator" sortable="false" style="width: 194px;">
	
			 					<!-- Link to show on user interface. -->
			 					<c:choose>
			 						<c:when test="${item.newAttachment}">
			 							<a href="#"><c:out value="${item.interwikiLinkWithoutVersion}"></c:out></a>
			 						</c:when>
			 						<c:otherwise>
										<ui:wikiLink item="${item.dto}" hideBadges="${true}" showItemName="${false}"/>
			 						</c:otherwise>
			 					</c:choose>
	
								<!-- Link to clone and insert into the page. -->
								<c:set var="url" value="CB:${item.urlLink}" />
								<c:set var="name"><c:out value="${item.name}" /></c:set>
								<a style="display: none;" href="${url}" alt="${name}">
									<c:out value="${item.getInterwikiLinkWithoutVersion()}" />
								</a>
							</display:column>
	
							<display:column title="${artifactLabel}" property="name" sortable="false"
								headerClass="textData" class="textDataWrap columnSeparator filterable" escapeXml="true" />
						</display:table>
					</c:when>
					<c:otherwise>
						<span class="information" style="margin-top: 10px;">
							<spring:message code="wysiwyg.history.link.plugin.attachment.empty" />
						</span>
					</c:otherwise>
				</c:choose>
			</tab:tabPane>
		</c:if>

		<spring:message var="tabTitle" code="wysiwyg.history.link.plugin.customTab.title" />
		<tab:tabPane id="customWikiLinkTabPane" tabTitle='${tabTitle}'>
			<div class="form">
				<div class="form-line">
					<spring:message var="wikiLinkTooltip" code="wysiwyg.history.link.plugin.wikiLink.tooltip"/>
					<label for="wikiLink" title="${wikiLinkTooltip}"><h3 style="margin-bottom: 10px;"><spring:message code="wysiwyg.history.link.plugin.customTab.title" />:</h3></label>
					<div class="input-container"><input name="link" type="text" id="wikiLink" title="${wikiLinkTooltip}"/></div>
				</div>
			</div>

			${aliasInput}

			<span class="information">
				<spring:message code="wysiwyg.history.link.plugin.wikiLink.explanation.1" text="How to use:"/></br>
				<ul>
				<li><spring:message code="wysiwyg.history.link.plugin.wikiLink.explanation.2" /></li>
				<li><spring:message code="wysiwyg.history.link.plugin.wikiLink.explanation.4" /></li>
				<li><spring:message code="wysiwyg.history.link.plugin.wikiLink.explanation.3" /></li>
				</ul>
			</span>
		</tab:tabPane>
		<c:if test="${empty disableSearch || !disableSearch}">
			<spring:message var="searchTabTitle" code="wysiwyg.search.plugin.searchTab.title" />
			<tab:tabPane id="searchTab" tabTitle="${searchTabTitle}">

				${aliasInput}

				<c:if test="${empty conversationId}">
					<c:set var="conversationId" value="" scope="request"/>
				</c:if>
				<c:if test="${empty itemId}">
					<c:set var="itemId" value="" scope="request"/>
				</c:if>
				<form:form commandName="searchForm" action="${pageContext.request.contextPath}/wysiwyg/plugins/plugin.spr?pageName=wikiHistoryLink&selected=searchTab&conversationId=${conversationId}&itemId=${itemId}&fieldId=${fieldId}" method="post">
					<c:set var="matches" value="${searchResults.hitCount}" />

					<%-- TODO: compute the correct requestURI --%>
					<c:set var="requestURI" value="/proj/addAssociationDialog.do?method=search" />

					<%-- search filters --%>
					<%-- The search controller's form bean is bound to "searchForm" command bean,
						so to make the spring form tags work we need to wrap them with a nestedPath, tells the tags what is the form name. --%>
					<%-- spring:nestedPath path="searchForm" --%>
						<jsp:include page="/search/includes/filter.jsp" flush="false">
							<jsp:param name="associationMode" value="true" />
							<jsp:param name="showSearchCheckboxes" value="true" />
						</jsp:include>
						<form:hidden path="searchOnArtifact" id="searchOnArtifact0" value="64" />
					<%-- /spring:nestedPath --%>

					<%--
						displaying results
						div added to show scrollbar when necessary
					--%>
					<div id="searchResultsContainer">
						<c:choose>
							<c:when test="${matches gt 0}">

								<c:set var="showAll" value="false" scope="request"/>
								<jsp:include page="/search/results.jsp?showAssoc=false&showAll=false&advanced=true&requestURI=${requestURI}" flush="true">
									<jsp:param name="multipleSelection" value="false" />
									<jsp:param name="selectionAllowed" value="true" />
									<jsp:param name="showSubmitter" value="false" />
									<jsp:param name="showTracker" value="false" />
								</jsp:include>
							</c:when>
							<c:otherwise>
								<spring:message code="association.to.choice.search.empty" text="No matching found"/>
							</c:otherwise>
						</c:choose>
					</div>
				</form:form>
			</tab:tabPane>
		</c:if>
	</tab:tabContainer>

</body>

</html>