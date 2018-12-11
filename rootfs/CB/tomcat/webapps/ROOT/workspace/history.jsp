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
<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/historyList.css' />" type="text/css"/>
<script src="<ui:urlversioned value="/js/historyList.js" />"></script>
<script type="text/javascript">
	$(document).ready(function() {
		codebeamer.history.initializeHistoryList('#item');
		codebeamer.history.initilizeLinkHandler();
		codebeamer.history.initilizeAdvancedSearchLinkHandler();
	});
</script>

<ui:actionMenuBar>
		<ui:pageTitle prefixWithIdentifiableName="false" >
			<spring:message code="user.history.label" />
		</ui:pageTitle>
</ui:actionMenuBar>

<ui:pageTitle printBody="false"><spring:message code="user.history.title" text="User History"/></ui:pageTitle>

<tag:history var="history" command="list" />

<div class="historyFilter forUser">
	<input type="text" autocomplete="off" name="filterInput" id="filterInput" maxlength="30" size="30" />
	<a href="${pageContext.request.contextPath}/advancedSearch.spr" class="goToAdvancedSearchLink"><spring:message code="search.advanced.title" text="Advanced Search"/></a>
</div>

<display:table class="fullExpandTable" cellpadding="0" requestURI="" name="${history}" id="item" decorator="com.intland.codebeamer.ui.view.table.HistoryDecorator">
	<c:set var="styleClass" value="" />
	<c:catch>
		<c:if test="${item.dto.closed}">
			<c:set var="styleClass" value="closedItem" />
		</c:if>
	</c:catch>

	<spring:message var="objectShortDescription" code="user.history.shortDescription.label" text="Artifact"/>
	<display:column title="${objectShortDescription}" sortProperty="sortNavigationHistoryDtoAsWikiOrTrackerLink"  property="navigationHistoryDtoAsWikiLinkWithShortDescription" sortable="true" headerClass="textData" class="expand textDataWrap columnSeparator">
	</display:column>

	<spring:message var="objectAccessDate" code="user.history.date.label" text="Date"/>
	<display:column title="${objectAccessDate}" sortProperty="date" headerClass="textData" class="textData smallerText" sortable="true">
		<tag:formatDate value="${item.date}" />
	</display:column>
</display:table>
