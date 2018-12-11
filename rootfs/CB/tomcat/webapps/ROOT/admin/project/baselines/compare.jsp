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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<div class="compareContainer">

	<c:choose>
		<c:when test="${not noDifference}">
			<c:choose>
				<c:when test="${not empty stats}">
					<div class="backContainer">
						&larr; <a href="#" id="backToListLink"><spring:message code="project.baselines.back.to.list.label" text="Back to baseline list" /></a>
					</div>

					<spring:message var="statisticsTitle" code="Statistics" text="Statistics" />

					<tab:tabContainer id="baseline-compare-tabs" skin="cb-box" selectedTabPaneId="statistics-tab">
						<tab:tabPane id="statistics-tab" tabTitle="${statisticsTitle}">
							<jsp:include page="compare/stats.jsp"/>
						</tab:tabPane>
						<c:forEach var="tab" items="${tabs}">
							<c:if test="${tab.display}">
								<c:set var="i18nKey" value="${tab.i18nKey}" />
								<c:set var="modelAttributeName" value="${tab.modelAttributeName}" />
								<c:set var="diffs" value="${requestScope[modelAttributeName]}" />
								<c:set var="diffCount" value="${diffs.fullListSize}" />
								<spring:message var="tabTitle" code="${i18nKey}" text="${i18nKey}" />
								<c:if test="${diffCount gt 0}">
									<tab:tabPane id="${tab.id}" tabTitle="${tabTitle} (${diffCount})">
										<c:set var="diffs" value="${diffs}" scope="request" />
										<jsp:include page="compare/listTabContent.jsp"/>
									</tab:tabPane>
								</c:if>
							</c:if>
						</c:forEach>
					</tab:tabContainer>
				</c:when>
				<c:otherwise>
						<ui:message type="information" isSingleMessage="true">
							<ul>
								<li><spring:message code="project.baselines.no.selection.yet" text="There is no baseline selected for comparison yet."/></li>
							</ul>
						</ui:message>
					</div>
				</c:otherwise>
			</c:choose>
		</c:when>
		<c:otherwise>
			<ui:message type="information" isSingleMessage="true">
				<ul>
					<li><spring:message code="project.baselines.no.difference" text="No difference found between selected baselines."/></li>
				</ul>
			</ui:message>
		</c:otherwise>
	</c:choose>

</div>
