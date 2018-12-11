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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<c:set var="project" value="${PROJECT_DTO}" />

<%--<c:choose>
	<c:when test="${empty project.syncOptions}">
		<div class="warning">
			<spring:message code="scm.repository.not.configured"/>
		</div>
	</c:when>
	<c:otherwise>--%>

<%-- action bars --%>
<ui:actionGenerator builder="sourceCodeActionMenuBuilder" actionListName="sourceCodeActions" subject="${project}">
	<c:set var="screenTitle" ><%=request.getParameter("screenTitle")%></c:set>
	<c:set var="screenLinks" value="${param.screenLinks}"/>
	<c:url var="topLink" value="/repository/${repository.id}/files"/>

	<c:set var="actionMenuBodyPart">
			<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
			<a href="${topLink}"><spring:message code="scm.repository.node.label"/></a> :
			<ui:pageTitle>${screenTitle}</ui:pageTitle>
			</ui:breadcrumbs>
		${repoURLBox}
	</c:set>
	<c:set var="actionMenuRightPart">
		<c:if test="${!empty screenFilter}">
			<span class="filterForm">
				${screenFilter}
			</span>
		</c:if>
	</c:set>	
<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">${actionMenuRightPart}</jsp:attribute>
	<jsp:body>${actionMenuBodyPart}</jsp:body>
</ui:actionMenuBar>

	<ui:actionBar>
		<ui:rightAlign>
			<jsp:attribute name="filler">
				<ui:actionMenu title="more" actions="${sourceCodeActions}" keys="browseCommits, browseRepository, listFiles" />
			</jsp:attribute>
			<jsp:attribute name="rightAligned">
				<%-- pass project ID as "entityId" --%>
				<%--
				Single-click notification temporarily removed, see here why: https://codebeamer.com/cb/issue/35519
				<jsp:include page="/includes/notificationBox.jsp" >
					<jsp:param name="entityTypeId" value="${GROUP_SOURCE}" />
					<jsp:param name="entityId" value="${project.id}" />
					<jsp:param name="starred" value="false" />
				</jsp:include>
				--%>
			</jsp:attribute>
			<jsp:body>
				${param.fragmentBeforeActionLink}
				<c:if test="${!empty screenLinks}">
					<ui:actionLink actions="${sourceCodeActions}" keys="${screenLinks}" />
				</c:if>
				${param.fragmentAfterActionLink}
			</jsp:body>
		</ui:rightAlign>
	</ui:actionBar>
</ui:actionGenerator>