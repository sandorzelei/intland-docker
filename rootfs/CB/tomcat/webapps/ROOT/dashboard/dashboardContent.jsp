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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<link rel="stylesheet" href="<ui:urlversioned value='/dashboard/dashboard.less' />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/js/isotope/isotope.pkgd.min.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/isotope/packery-mode.pkgd.js'/>"></script>

<c:if test="${!empty pageRevision.baseline}">
	<ui:baselineInfoBar projectId="${wikiPage.project.id}" baselineName="${pageRevision.baseline.name}" baselineParamName="revision" notSupported="true" showChangeLink="true" />
</c:if>

<c:if test="${!wikiPage.trackerHomePage}">
	<jsp:include page="../label/entityLabelList.jsp">
		<jsp:param name="entityTypeId" value="${GROUP_OBJECT}"/>
		<jsp:param name="entityId" value="${wikiPage.id}"/>
		<jsp:param name="forwardUrl" value="${wikiPage.urlLink}"/>
		<jsp:param name="editable" value="${empty pageRevision.baseline}"/>
	</jsp:include>
</c:if>

<div id="dashboardLoadingIndicator" style="text-align:center;width: 100%;">
</div>

<div class="contentWithMargins">
	<div id="dashboard">
	</div>
</div>

<c:choose>
	<c:when test="${deferInitialization}">
	</c:when>
	<c:otherwise>
		<script type="text/javascript">
			(function () {
				var config = {
						dashboardId: ${dashboard.id},
						$container: $('#dashboard'),
						editable: ${editable},
						showBusyPage: false
				};

				<c:if test="${not empty projectId }">
					config["projectId"] = ${projectId};
				</c:if>

				<c:if test="${ param.detailed_layout}">
				config["parameters"] = {
						detailed_layout: true
				};
				</c:if>

				if ("${param.revision}" != "") {
					config['revision'] = "${param.revision}";
				}

				codebeamer.dashboard.initWikiPageLoadingIndicator($("#dashboardLoadingIndicator"), $("#dashboard"));
				codebeamer.dashboard.init(config);
			})();
		</script>
	</c:otherwise>
</c:choose>
