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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:forEach var="list" items="${itemsHtml}">
	<div class="version-header">
		<span class="version-breadcrumbs">${list.versionNameUrl}</span>
		<c:if test="${not empty list.versionId}">
			<c:url var="cardboardUrl" value="/cardboard/${list.versionId}"/>
			<c:url var="cardboardIcon" value="/images/newskin/item/cardboard.png"/>
			<spring:message code="tracker.view.layout.cardboard.for.release.label" arguments="${list.versionName}" var="urlTitle"/>
			<a class="cardboardIcon append-selection-id" href="${cardboardUrl}" title="${urlTitle}"><img src="${cardboardIcon}"/></a>
		</c:if>
	</div>
   <c:if test="${isProjectBacklog}">
        <div class="dataContainer" data-project-id="${projectId}"></div>
    </c:if>
	<div style="display: none;" class="id" data-version-id="${list.versionId}" data-last-item-id="${pageInfo.lastItemId}"></div>
	${list.issueListHtml}
</c:forEach>
<c:if test="${!empty pageInfo}">
	<a href="#" class="load-more" data-start-version-id="${pageInfo.startVersionId}" data-last-item-id-rendered="${pageInfo.lastItemIdRendered}"></a>
</c:if>

<script type="text/javascript">
	jQuery(function($) {
		var newItemIds = ${(!empty targetReleaseEditable) ? targetReleaseEditable : "[]"};
		var existingItemIds = ("targetReleaseEditable" in codebeamer.plannerConfig) ? codebeamer.plannerConfig.targetReleaseEditable : [];
		codebeamer.plannerConfig.targetReleaseEditable = $.merge(existingItemIds, newItemIds);

		newItemIds = ${(!empty assigneeEditable) ? assigneeEditable : "[]"};
		existingItemIds = ("assigneeEditable" in codebeamer.plannerConfig) ? codebeamer.plannerConfig.assigneeEditable : [];
		codebeamer.plannerConfig.assigneeEditable = $.merge(existingItemIds, newItemIds);

		newItemIds = ${(!empty itemEditable) ? itemEditable : "[]"};
		existingItemIds = ("itemEditable" in codebeamer.plannerConfig) ? codebeamer.plannerConfig.itemEditable : [];
		codebeamer.plannerConfig.itemEditable = $.merge(existingItemIds, newItemIds);

		newItemIds = ${(!empty teamFieldEditable) ? teamFieldEditable : "[]"},
		existingItemIds = ("teamFieldEditable" in codebeamer.plannerConfig) ? codebeamer.plannerConfig.teamFieldEditable : [];
		codebeamer.plannerConfig.teamFieldEditable = $.merge(existingItemIds, newItemIds);

		newItemIds = ${(!empty summaryEditable) ? summaryEditable : "[]"},
		existingItemIds = ("summaryEditable" in codebeamer.plannerConfig) ? codebeamer.plannerConfig.summaryEditable : [];
		codebeamer.plannerConfig.summaryEditable = $.merge(existingItemIds, newItemIds);
		
		newItemIds = ${(!empty userStoryFieldEditable) ? userStoryFieldEditable : "[]"},
		existingItemIds = ("userStoryFieldEditable" in codebeamer.plannerConfig) ? codebeamer.plannerConfig.userStoryFieldEditable : [];
		codebeamer.plannerConfig.userStoryFieldEditable = $.merge(existingItemIds, newItemIds);
		
		newItemIds = ${(!empty requirementFieldEditable) ? requirementFieldEditable : "[]"},
		existingItemIds = ("requirementFieldEditable" in codebeamer.plannerConfig) ? codebeamer.plannerConfig.requirementFieldEditable : [];
		codebeamer.plannerConfig.requirementFieldEditable = $.merge(existingItemIds, newItemIds);
	});
</script>
