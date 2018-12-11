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
<meta name="module" content="baselines"/>
<meta name="moduleCSSClass" content="newskin documentsModule baselinesModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/baselines.less' />" type="text/css" media="all" />

<script type="text/javascript">

</script>

<jsp:include page="../../docs/includes/createArtifacts.jsp" />

<%-- include the JS and hidden field for deleting one/multiple documents --%>
<jsp:include page="../../docs/includes/deleteArtifacts.jsp" >
	<jsp:param name="confirmMessageKey" value="docs.delete.baseline.confirm" />
	<jsp:param name="confirmOneMessageKey" value="docs.delete.oneBaseline.confirm" />
	<jsp:param name="confirmOneDirMessageKey" value="docs.delete.oneBaseline.confirm" />
</jsp:include>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false" strongBody="true">
			<ui:pageTitle><spring:message code="project.baselines.title" text="Baselines"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<form action="/proj/doc/compareBaselines.spr">

	<ui:actionBar>
		<ui:actionGenerator builder="baselineActionMenuBuilder" actionListName="baselineActions" subject="${PROJECT_DTO}">
			<ui:actionLink keys="newBaseline" actions="${baselineActions}" />
		</ui:actionGenerator>
		&nbsp;
	</ui:actionBar>

	<div class="accordion hiddenBeforeInit" id="baselineAccordion">
		<h3 class="accordion-header"><spring:message code="project.baseline.list.title" text="Baselines"/></h3>
		<div class="accordion-content">
			<c:set var="baselines" value="${baselines}" scope="request" />
			<c:set var="actions" value="${actions}" scope="request" />
			<jsp:include page="baselines/list.jsp" />
		</div>
		<h3 class="accordion-header"><spring:message code="project.baseline.comparingResults.title" text="Comparing results"/></h3>
		<div class="accordion-content">
			<jsp:include page="baselines/compare.jsp" />
		</div>
	</div>
</form>

<script src="<ui:urlversioned value='/js/baselineList.js'/>"></script>
<script src="<ui:urlversioned value='/js/baselineCompare.js'/>"></script>
<script type="text/javascript">

	// TODO: [baseline] canCompareBaseLines

	jQuery(function($) {
		var isComparisonPage = ${isComparisonPage == true};
		$("#baselineAccordion").prop("animationsEnabled", false);
		codebeamer.BaselineList.init(isComparisonPage);
		<c:if test="${createNewBaseline}">
			$(".createNewBaselineAction").first().click();
		</c:if>
		<c:if test="${compareWith != null}">
			codebeamer.BaselineList.addToComparison("<c:out value="${compareWith}" />");
		</c:if>
		if (isComparisonPage) {
			codebeamer.BaselineList.selectAndCompareBaselines("<c:out value="${baseline1}" />", "<c:out value="${baseline2}" />");
		}
		codebeamer.BaselineCompare.init();
		$("#baselineAccordion").prop("animationsEnabled", true);

		codebeamer.BaselineList.initBaselineDescriptions();
	});

</script>
