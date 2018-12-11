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
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<!DOCTYPE html>
<html>
<head>
    <meta name="decorator" content="popup"/>
	<meta name="moduleCSSClass" content="newskin fr-model" />

	<script type="text/javascript" src="<ui:urlversioned value='/js/wysiwyg/froala_plugins/cbartifact/js/artifactPopup.js'/>"></script>
	<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/wysiwyg/froala_plugins/froalaModal.less'/>"/>

	<style type="text/css">
		.fr-model .table-header {
			margin-top: 20px;
			margin-bottom: 10px;
		}

		.fr-model .form {
			margin-left: 5px;
		}

		.fr-model .invalidWikiLinkWarning {
			display: none;
		}

		.fr-model .form-line:after {
			content: '';
			clear: both;
			display: block;
		}

		.fr-model .float-left {
			float: left;
		}

		.fr-model .float-right {
			float: right;
		}

		#linkFilter {
			width: 150px;
			margin-top: 2px;
		}

		.fr-model .issueIcon {
			vertical-align:text-top;
		}

		.form-line label {
			width: 80px;
		}

		.form-line h3 {
		    margin-top: 6px;
		}

		input.alias {
			font-size: 13px;
		}

		.checkbox-column-minwidth {
			vertical-align: middle;
		}

		.Chrome input[name=wikiLinkRadio],
		.FF input[name=wikiLinkRadio] {
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

		#wikiHistoryLinkTable tr {
			vertical-align: middle;
		}
	</style>

</head>

<body>
	<ui:pageTitle printBody="false"><spring:message var="title" code="wysiwyg.mxgraph.artifact.title" text="Insert Artifact"/></ui:pageTitle>

	<ui:actionMenuBar>
		<span class="menuTitle">${title}</span>
	</ui:actionMenuBar>

	<spring:message var="insertLinkButtonLabel" code="wysiwyg.wiki.markup.plugin.insertMarkup.button.label" />
	<spring:message var="cancelButtonLabel" code="wysiwyg.history.link.plugin.cancel.button.label" />

	<ui:actionBar>
		&nbsp;&nbsp;<input type="button" class="button" name="insert" value="${insertLinkButtonLabel}"/>
		<input type="button" class="button cancelButton" value="${cancelButtonLabel}" />
	</ui:actionBar>

	<c:set var="selectedTabPane" value="wikiLinkHistoryTabPane" />
	<c:if test="${not empty selected}">
		<c:set var="selectedTabPane" value="${selected}" />
	</c:if>
	<tab:tabContainer id="insertWikiLinkTabContainer" skin="cb-box" selectedTabPaneId="${selectedTabPane}">

		<spring:message var="tabTitle" code="wysiwyg.history.link.plugin.historyTab.title" />
		<tab:tabPane id="wikiLinkHistoryTabPane" tabTitle='${tabTitle}'>

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

				<display:column title="" headerClass="textData checkbox-column-minwidth" class="textDataWrap checkbox-column-minwidth columnSeparator">
					<input type="radio" name="wikiLinkRadio" />
				</display:column>

				<display:column title="${wikiLinkLabel}" sortProperty="sortInterwikiLink"
					headerClass="`" class="textData columnSeparator" sortable="true">
					<ui:wikiLink item="${item.dto}" hideBadges="${true}" showItemName="${false}"/>
				</display:column>

				<display:column title="${artifactLabel}" property="shortDescription" sortProperty="sortShortDescription" sortable="true"
					headerClass="textData" class="textDataWrap columnSeparator filterable" escapeXml="true" />

				<display:column title="${dateLabel}" sortProperty="date" headerClass="textData" class="textData" sortable="true">
					<tag:formatDate value="${item.date}" />
				</display:column>
			</display:table>

		</tab:tabPane>
		<c:if test="${empty disableSearch || !disableSearch}">
			<spring:message var="searchTabTitle" code="wysiwyg.search.plugin.searchTab.title" />
			<tab:tabPane id="searchTab" tabTitle="${searchTabTitle}">
				<form:form commandName="searchForm" action="${pageContext.request.contextPath}/wysiwyg/plugins/plugin.spr?pageName=mxgraph&selected=searchTab" method="post">
					<c:set var="matches" value="${searchResults.hitCount}" />

					<%-- TODO: compute the correct requestURI --%>
					<c:set var="requestURI" value="/proj/addAssociationDialog.do?method=search" />

					<%-- search filters --%>
					<%-- The search controller's form bean is bound to "searchForm" command bean,
						so to make the spring form tags work we need to wrap them with a nestedPath, tells the tags what is the form name. --%>
					<%-- spring:nestedPath path="searchForm" --%>
						<jsp:include page="/search/includes/filter.jsp" flush="false">
							<jsp:param name="associationMode" value="true" />
							<jsp:param name="showSearchCheckboxes" value="false" />
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
