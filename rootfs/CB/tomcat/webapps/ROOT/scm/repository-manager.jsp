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
<meta name="module" content="sources"/>
<meta name="moduleCSSClass" content="sourceCodeModule newskin"/>
<meta name="stylesheet" content="sources.css"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false" strongBody="true">
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="scm.repositories.page.title" text="SCM Repositories"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<ui:actionBar>
	<ui:rightAlign>
		<jsp:body>
			<ui:actionLink builder="scmRepositoryActionMenuBuilder" keys="newRepository" />
		</jsp:body>
	</ui:rightAlign>
</ui:actionBar>

<div class="contentWithMargins" style="margin-top:0;">
	<c:choose>
	<c:when test="${repositoryModelBuilder.numOfRepositories == 0}">
		<div class="warning"><spring:message code="scm.repository.not.configured" /></div>
	</c:when>
	<c:otherwise>
		<jsp:include page="./includes/repository-list.jsp"/>
	</c:otherwise>
	</c:choose>
</div>


