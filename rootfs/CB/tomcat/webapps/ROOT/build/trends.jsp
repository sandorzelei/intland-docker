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
<meta name="module" content="build"/>
<meta name="moduleCSSClass" content="buildsModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

	<c:set var="actionMenuBodyPart">
			<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="build.trends.title" text="Successful and failed builds by date."/></ui:pageTitle>
			</ui:breadcrumbs>
	</c:set>
	<c:set var="actionMenuRightPart">
		<c:import url="/report/simpleDateSelectorForm.jsp">
			<c:param name="action" value="/proj/build/trendsChart" />
		</c:import>
	</c:set>	
<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">${actionMenuRightPart}</jsp:attribute>
	<jsp:body>${actionMenuBodyPart}</jsp:body>
</ui:actionMenuBar>	

<jsp:include page="/report/buildsTrends.jsp" flush="true" />