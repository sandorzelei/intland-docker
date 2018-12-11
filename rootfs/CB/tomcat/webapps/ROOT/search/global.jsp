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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="display" uri="http://displaytag.sf.net" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<ui:actionMenuBar>
		<ui:pageTitle>
		<spring:message code="search.results.title" text="Search Results"/>
		<ui:actionGenerator builder="projectListPageActionMenuBuilder" actionListName="actions"
				allowedKeys="currentWorkingSet" renderBodyWithoutActions="false">
			<ui:actionLink actions='${actions}' />
		</ui:actionGenerator>
		</ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="searchForm" action="${pageContext.request.contextPath}/search.spr" method="get">

<ui:actionBar>
	<spring:message code="search.for" text="Search for"/>:
	<form:input path="filter" size="50" id="searchFilterPattern"/> <form:errors path="filter" cssClass="invalidfield" />

	<spring:message var="searchSubmit" code="search.submit.label" text="GO"/>
	<spring:message var="searchSubmitTitle" code="search.submit.tooltip" text="Start Search"/>
	<input type="submit" class="button" title="${searchSubmitTitle}" value="${searchSubmit}" style="margin-right: 5px">

	<spring:message var="last7DaysTitle" code="search.date.filter.title" arguments="7" htmlEscape="true" />
	<spring:message var="last30DaysTitle" code="search.date.filter.title" arguments="30" htmlEscape="true" />
	<spring:message var="last90DaysTitle" code="search.date.filter.title" arguments="90" htmlEscape="true" />
	<div class="date-filters show-inline">
		<a href="#" data-days="-7" title="${last7DaysTitle}" class="${param.lastModifiedAtDuration == '-7' ? 'highlighted-date' : ''}">7</a>
		<a href="#" data-days="-30" title="${last30DaysTitle}" class="${param.lastModifiedAtDuration == '-30' ? 'highlighted-date' : ''}">30</a>
		<a href="#" data-days="-90" title="${last90DaysTitle}" class="${param.lastModifiedAtDuration == '-90' ? 'highlighted-date' : ''}">90</a>
	</div>

	&nbsp;<a href="${pageContext.request.contextPath}/advancedSearch.spr"><spring:message code="search.advanced" text="Advanced..."/></a>

	&nbsp;<ui:helpLink helpURL="/help/search.do" title="Search help" />
</ui:actionBar>

<jsp:include page="results.jsp" flush="true"/>

</form:form>

<script type="text/javascript">
	jQuery(function($) {
		var form = $("#searchForm");
		form.find(".date-filters a").click(function() {
			var days = $(this).data("days");
			$("<input>", {
				type: "hidden",
				name: "lastModifiedAtDuration",
				value: days
			}).appendTo(form);
			form.submit();
			return false;
		});
	});
</script>
