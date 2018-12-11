<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<ui:actionMenuBar>
		<jsp:attribute name="rightAligned">
			<c:set var="rightFragment">
				<c:choose>
				<c:when test="${coverageType == 'release' }">
					<ui:actionGenerator builder="agileVersionScopeActionMenuBuilder" actionListName="actions" subject="${release}">
						<c:if test="${not empty actions}">
							<div class="release-train-icon"></div>
							<div class="release-train">
									<ui:combinedActionMenu actions="${actions}" subject="${release}"
														   buttonKeys="planner,cardboard,versionStats" cssClass="large" hideMoreArrow="true" />
							</div>
						</c:if>
					</ui:actionGenerator>
					<div class="release-train-extra-icons">
						<ui:combinedActionMenu builder="agileVersionScopeActionMenuBuilder" subject="${release}" buttonKeys="coverageBrowser,details"
											   keys="coverageBrowser,details" hideMoreArrow="true" cssClass="large" activeButtonKey="coverageBrowser"/>
					</div>
				</c:when>
				<c:otherwise>
					<jsp:include page="../../bugs/tracker/includes/initTrackerContextMenu.jsp" flush="true">
						<jsp:param name="isCategoryTracker" value="${tracker.category}" />
						<jsp:param name="isAdvancedView" value="false" />
					</jsp:include>
					<ui:combinedActionMenu title="${viewsMenuLabel}" builder="trackerViewsActionMenuBuilder" subject="${trackerMenuData}"
										   buttonKeys="showTableView,showDocumentView,showDocumentViewExtended,showCardboardView,coverageBrowser,traceabilityBrowser,${empty branch ? 'showReviewView,testRunBrowser,showDashboardView' : ''}"
										   activeButtonKey="${coverageType == 'testrun' ? 'testRunBrowser' : 'coverageBrowser'}" hideMoreArrow="true"
										   cssClass="large"
					/>
				</c:otherwise>
			</c:choose>
			</c:set>
			<ui:branchBaselineBadge branch="${currentBranch}" rightFragment="${rightFragment}"/>
		</jsp:attribute>
		<jsp:body>
			<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span><span class="page-title">
				${coverageBrowserTitle }
			</span>
				<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
					<c:choose>
						<c:when test="${not empty release }">
							<spring:message code="tracker.coverage.browser.for.tracker.label" arguments="${release.name}" htmlEscape="true"/>
						</c:when>
						<c:otherwise>
							<c:choose>
								<c:when test="${tracker.testSet }">
									<spring:message code="tracker.test.set.browser.for.tracker.label" arguments="${tracker.name}" htmlEscape="true"/>
								</c:when>
								<c:when test="${tracker.testRun }">
									<spring:message code="tracker.test.run.browser.for.tracker.label" arguments="${tracker.name}" htmlEscape="true"/>
								</c:when>
								<c:otherwise>
									<spring:message code="tracker.coverage.browser.for.tracker.label" arguments="${tracker.name}" htmlEscape="true"/>
								</c:otherwise>
							</c:choose>
						</c:otherwise>
					</c:choose>
				</ui:pageTitle>
			</ui:breadcrumbs>
		</jsp:body>
</ui:actionMenuBar>