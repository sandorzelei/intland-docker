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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<c:set var="repositoryId" value="${param.repo_id}" />

<ui:actionGenerator builder="buildsPageActionMenuBuilder" subject="${PROJECT_DTO}" actionListName="pageActions" allowedKeys="newBuild,trends" >
	<ui:actionMenuBar>
			<ui:breadcrumbs showProjects="false">
			<c:if test="${empty param.build_id or param.build_id le 0}">
				<span class="breadcrumbs-separator">&raquo;</span><ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="Builds" text="Builds"/></ui:pageTitle>
			</c:if>
			</ui:breadcrumbs>
	</ui:actionMenuBar>

	<ui:actionBar>
		<ui:rightAlign>
			<jsp:attribute name="filler">
				<ui:actionMenu title="more" actions="${pageActions}" keys="trends"/>
			</jsp:attribute>
			<jsp:attribute name="rightAligned">
			</jsp:attribute>
			<jsp:body>
				<ui:actionLink actions="${pageActions}" keys="newBuild" />
			</jsp:body>
		</ui:rightAlign>
	</ui:actionBar>
</ui:actionGenerator>

<tab:tabContainer id="build" skin="cb-box">
	<spring:message var="buildsTitle" code="Builds" text="Builds"/>
	<tab:tabPane id="builds" tabTitle="${buildsTitle}">

		<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
		function confirmDelete(form) {
			return confirm('<spring:message code="build.delete.confirm" />');
		}
		</SCRIPT>

		<%-- <tag:buildList var="builds" repositoryId="${repositoryId}" /> --%>
		<%-- copy the build var to scope, so listLogs will see it too --%>
		<c:set var="builds" scope="request" value="${builds}" />

		<display:table requestURI="/proj/build.do?orgDitchnetTabPaneId=builds" name="${builds}" id="build" cellpadding="0" defaultsort="2" export="true">

			<ui:actionGenerator builder="buildsListContextPageActionMenuBuilder" actionListName="buildActions" subject="${build}">

				<display:column media="html" title="" class="textData">
					<c:if test="${build.postCommit}">
						<spring:message var="postCommitTitle" code="build.post.commit.tooltip" text="Post Commit Build"/>
						<img border="0" title="${postCommitTitle}" src="<c:url value='/images/cvs_view.gif'/>"/>
					</c:if>
				</display:column>

				<spring:message var="nameTitle" code="build.name.label" text="Build Name"/>
				<display:column title="${nameTitle}" headerClass="textData" class="textData" sortable="true" style="width:20%;" media="html" >
					<%-- clicking on the name will run the build --%>
					<c:set var="runAction" value="${buildActions.run}"/>
					<spring:message var="runTitle" code="${runAction.toolTip}"/>
					<a onclick="${runAction.onClick}" title="${runTitle}" href="${runAction.url}">
						<spring:message code="build.${build.name}.label" text="${build.name}"/>
					</a>
				</display:column>
				<display:column title="${nameTitle}" media="excel xml csv pdf rtf">
					<spring:message code="build.${build.name}.label" text="${build.name}"/>
				</display:column>

				<display:column media="html" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator"
					class="action-column-minwidth columnSeparator">
					<ui:actionMenu actions="${buildActions}" />
				</display:column>

				<c:choose>
					<c:when test="${build.lastLog.status == 'Successful' || build.lastLog.status == 'SUCCESSFUL'}">
						<c:set var="statusStyle" value="STATUS_SUCCESSFUL" />
					</c:when>

					<c:when test="${empty build.lastLog.status}">
						<c:set var="statusStyle" value="" />
					</c:when>

					<c:otherwise>
						<c:set var="statusStyle" value="STATUS_FAILED" />
					</c:otherwise>
				</c:choose>

				<tag:formatDate var="lastStartDate" value="${build.lastLog.startDate}" />

				<spring:message var="lastRunTitle" code="build.last.run.label" text="Last Run"/>
				<display:column title="${lastRunTitle}" sortProperty="lastLog.startDate" headerClass="dateData"
					class="${statusStyle} dateData columnSeparator"	sortable="true" style="width:10%; " media="html">
					<c:choose>
						<c:when test="${empty statusStyle}">
							${lastStartDate}
						</c:when>

						<c:otherwise>
							<ui:actionGenerator builder="buildLogActionMenuBuilder" actionListName="buildLogActions" subject="${build.lastLog}" >
								<c:set var="viewLogAction" value="${buildLogActions.viewLog}"/>
								<spring:message var="viewLogTitle" code="${viewLogAction.toolTip}"/>
								<a onclick="${viewLogAction.onClick}" title="${viewLogTitle}" href="${viewLogAction.url}" class="${statusStyle}" >
									${lastStartDate}
								</a>
							</ui:actionGenerator>
						</c:otherwise>
					</c:choose>
				</display:column>
				<display:column title="${lastRunTitle}" media="excel xml csv pdf rtf">
					${lastStartDate}
				</display:column>

				<spring:message var="descrTitle" code="build.description.label" text="Description"/>
				<display:column title="${descrTitle}" headerClass="textData" class="textData columnSeparator" sortable="true" style="width:100%;">
					<spring:message var="buildDesc" code="build.${build.name}.tooltip" text="${build.description}"/>
					<tag:transformText value="${buildDesc}" format="${build.descriptionFormat}" />
				</display:column>

				<spring:message var="nextTitle" code="build.nextFireTime.label" text="Next Scheduled"/>
				<display:column title="${nextTitle}" sortProperty="nextFireTime" headerClass="dateData" class="dateData columnSeparator" sortable="true" style="width:10%;">
					<tag:formatDate value="${build.nextFireTime}" />
				</display:column>

				<spring:message var="createdTitle" code="build.createdAt.label" text="Created"/>
				<display:column title="${createdTitle}" sortProperty="createdAt" headerClass="dateData" class="dateData" sortable="true" style="width:10%;">
					<tag:formatDate value="${build.createdAt}" />
				</display:column>

			</ui:actionGenerator>

		</display:table>
	</tab:tabPane>

	<spring:message var="logsTitle" code="build.logs.title" text="Build Logs"/>
	<tab:tabPane id="build-logs" tabTitle="${logsTitle}">
		<jsp:include page="./listLogs.jsp" />
	</tab:tabPane>

</tab:tabContainer>
