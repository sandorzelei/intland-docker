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
<%@ taglib uri="taglib" prefix="tag" %>

<c:if test="${empty itemLabel}">
	<spring:message var="itemLabel" code="${param.isCmdb ? 'cmdb.category.item.label' : 'issue.label' }" />
</c:if>
<spring:message var="transName" code="tracker.transition.${transitionName}.label" text="${transitionName}" htmlEscape="true"/>
<ui:actionMenuBar showRating="false">
	<jsp:attribute name="rightAligned">
		<ui:branchBaselineBadge branch="${branch}"/>
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" showTrailingId="${not duplicate}">
			<c:choose>
				<c:when test="${!empty param.task_id}">
					<span class="breadcrumbs-separator">&raquo;</span>
					<ui:pageTitle>${transName}</ui:pageTitle>
				</c:when>

				<c:when test="${addUpdateTaskForm.creatingSubTask}">
					<c:out value="[${addUpdateTaskForm.parentTask.keyAndId}]"/>
					<span class="breadcrumbs-separator">&raquo;</span>
					<ui:pageTitle prefixWithIdentifiableName="false">
						<c:choose>
							<c:when test="${(trackerItem.typeName eq 'Release') || (addUpdateTaskForm.tracker.name eq 'Releases')}">
								<spring:message code="issue.newSprint.title" text="New Sprint"/>
							</c:when>
							<c:otherwise>
								<spring:message code="issue.newChild.title" text="New Child"/>
							</c:otherwise>
						</c:choose>
					</ui:pageTitle>
				</c:when>

				<c:otherwise>
					<span class="breadcrumbs-separator">&raquo;</span>
					<ui:pageTitle prefixWithIdentifiableName="false">
						<spring:message code="issue.create.title" text="{0} {1}" arguments="${transName},${itemLabel}"/>
					</ui:pageTitle>
				</c:otherwise>
			</c:choose>
		</ui:breadcrumbs>
		<c:if test="${not empty locker }">
			<div>
				<spring:message var="lockInfo" code="document.lockedBy.tooltip" text="Locking information"/>
				<span class="main high">
				<spring:message code="document.lockedBy.label" text="Currently locked by"/>
				<tag:userLink user_id="${locker.id}" />.
			</span>
			</div>
		</c:if>
		<c:if test="${not empty addUpdateTaskForm and not empty addUpdateTaskForm.trackerItem}">
			<ui:itemDependenciesBadge item="${addUpdateTaskForm.trackerItem}" />
		</c:if>
	</jsp:body>
</ui:actionMenuBar>
