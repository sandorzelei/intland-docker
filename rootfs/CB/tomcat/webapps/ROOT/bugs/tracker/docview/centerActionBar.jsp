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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="compact-view-mode-switch actionBarIcon" title="<spring:message code='tracker.tree.enableCompactMode.hint'/>">
	<div class="switch ${compactMode ? 'on' : 'off' }">
	</div>
</div>

<span class="simpleDropdownMenu" style="margin-left: 10px;display:inline-block;position:relative;top:-2px;left:-4px;">
	<ui:actionMenu title="more" builder="${actionBuilder}" subject="${trackerMenuData}" keys="${actionKeys}" inline="true"/>
</span>
<c:if test="${buildSubtree }">
	<span style="margin-left: 10px;">
		<c:url var="wholeTrackerUrl" value="/tracker/${tracker.id}">
			<c:if test="${not empty param.revision }">
				<c:param name="revision" value="${param.revision}"/>
			</c:if>
			<c:param name="mode" value="${param.mode}"/>
		</c:url>
	</span>
</c:if>
<c:if test="${not empty baseline}">
	<div class="date-filters">
		<spring:message code="issue.updated.title" text="Updated" var="optGroupTitle"/>
		<label for="intervalSelector"><spring:message code="Filter" text="Filter"/>:</label>
		<select id="intervalSelector" onchange="filterItems();">
			<spring:message var="statusLabel" code="tracker.field.Status.label" text="Status"/>
			<optgroup label="${statusLabel}" class="first">
				<ui:coloredEntityIcon subject="${tracker}" iconUrlVar="imgUrl" iconBgColorVar="bgColor"/>
				<c:forEach items="${statusFilters}" var="statusFilter">
					<option value="${statusFilter.id}" class="status" title="${statusFilter.name}"
							data-background="${statusFilter.style}" data-icon="<c:url value="${imgUrl}"/>">
							${statusFilter.name}
					</option>
				</c:forEach>
			</optgroup>

			<c:if test="${empty baseline }">
				<optgroup label="${optGroupTitle}" class="first">
					<c:forEach items="${dateFilters}" var="dateFilter">
						<spring:message code="${dateFilter.labelCode}" text="${dateFilter.name}" var="title"/>
						<option value="${dateFilter.name}" class="modified-in" title="${title}">${title }</option>
					</c:forEach>
				</optgroup>
				<spring:message code="association.suspected.label" text="Suspected" var="suspectedLabel"/>
				<optgroup label="${suspectedLabel}" class="first">
					<spring:message code="tracker.type.${tracker.type.name}.plural" text="Requirements" var="trackerTypeLabel"/>
					<option value="suspected" class="suspected" title="${suspectedLabel} ${trackerTypeLabel}">${suspectedLabel} ${trackerTypeLabel}</option>
				</optgroup>
				<spring:message var="averageRatingLabel" code="rating.average.rating.label" text="Average rating"/>
				<optgroup label="${averageRatingLabel}" class="first">
					<c:forEach items="${ratingFilters}" var="ratingFilter">
						<spring:message code="${ratingFilter.label}" text="${ratingFilter.label}" var="ratingTitle"/>
						<option value="${ratingFilter.name}" class="average-rating" title="${ratingTitle}">
								${ratingTitle}
						</option>
					</c:forEach>
				</optgroup>
				<spring:message code="tracker.view.filtering.references" text="References" var="referencesLabel"/>
				<optgroup label="${referencesLabel}" class="first">
					<spring:message code="tracker.view.layout.document.filter.references.orphan.label" text="Orphan" var="orphanLabel"/>
					<option value="Orphan" class="reference" title="${orphanLabel }">
							${orphanLabel }
					</option>
					<spring:message code="tracker.view.layout.document.filter.references.specified.label" text="Orphan" var="specifiedLabel"/>
					<option value="Specified" class="reference" title="${specifiedLabel }">
							${specifiedLabel }
					</option>
				</optgroup>
			</c:if>
		</select>
	</div>
</c:if>