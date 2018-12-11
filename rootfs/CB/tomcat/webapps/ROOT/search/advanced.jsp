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
<meta name="module" content="global_search"/>
<meta name="moduleCSSClass" content="searchModule newskin"/>
<meta name="stylesheet" content="search.css"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<ui:actionMenuBar showGlobalMessages="true">
	<ui:pageTitle><spring:message code="search.advanced.title" text="Advanced Search"/></ui:pageTitle>
	<ui:actionGenerator builder="projectListPageActionMenuBuilder" actionListName="actions"
			allowedKeys="currentWorkingSet" renderBodyWithoutActions="false">
	</ui:actionGenerator>
</ui:actionMenuBar>

<form:form commandName="searchForm" action="${pageContext.request.contextPath}/advancedSearch.spr" method="get">

	<div class="accordion advancedSearchParameters">
		<h3 class="search-title accordion-header<c:if test="${empty searchResults || searchResults.hitCount == 0}"> opened</c:if>"><span class="icon"></span>Search parameters</h3>

		<div class="accordion-content" <c:if test="${not empty searchResults && searchResults.hitCount > 0}"> style="display: none"</c:if>>
			<c:if test="${not empty searchForm.filter && (not empty searchResults && searchResults.hitCount == 0)}">
				<ui:message type="warning">
					<spring:message code="search.no.results.tip" arguments="${searchForm.filter}" htmlEscape="false"/>
				</ui:message>
			</c:if>

			<c:set var="workingSetsCount" value="${fn:length(availableWorkingSets)}" />
			<c:if test="${workingSetsCount != 0 and filteredByWorkingSet}">
				<ui:message type="warning">
					<spring:message code="search.filtered.by.working.set"
									text="The result is restricted to some selected working sets. You can change this selection in the Working Sets box below."></spring:message>
				</ui:message>
			</c:if>

			<jsp:include page="./includes/filter.jsp" />
		</div>
	</div>


	<jsp:include page="results.jsp" flush="true" />
</form:form>

<script>
	jQuery(function() {
		$(".advancedSearchParameters.accordion").cbMultiAccordion({
			active: ${empty searchResults or searchResults.hitCount == 0 ? 0 : -1}
		});
	});
</script>
