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

<%--
Parameters:
	- cellCssClass: CSS class(es) to add to the cell
    - issueCount: number of issue
    - storyPoints: SPs
    - showStoryPoints: show or hide story point value
    - storyPointsCssClass: optional CSS class to add to SP label
    - versionStatsPageEventHandlers: true if event handlers are enabled
    - script: script to execute on click event (only used if versionStatsPageEventHandlers is true)
    - colSpan: colspan value if applicable
--%>

<c:choose>
	<c:when test="${colSpan > 1}">
		<c:set var="colSpanAttribute" value="colspan='${colSpan}'" scope="page" />
	</c:when>
	<c:otherwise>
		<c:set var="colSpanAttribute" value="" scope="page" />
	</c:otherwise>
</c:choose>

<c:choose>
	<c:when test="${issueCount == 0}">
		<td ${colSpanAttribute} class='number zero ${cellCssClass}'><!--
			--><c:choose>
				<c:when test="${showStoryPointsStats}"><!--
					--><div class="issueCountContainer">0</div><!--
					--><div class="storyPointsContainer" style="visibility: hidden"></div><!--
				</c:when>
				<c:otherwise>0</c:otherwise>
			</c:choose><!--
		--></td>
	</c:when>
	<c:otherwise>
		<td ${colSpanAttribute} class='number filterCell ${cellCssClass}
			<c:if test="${!notSelectable && not empty filterCategoryName && not empty filterCategoryValue && filterCategoryName == activeFilters.selectedFilterCategory &&
				filterCategoryValue == activeFilters.selectedFilterValue && statusFilter == activeFilters.openOrClosedFilter}">
				selected
			</c:if>'
			data-filter-category='${filterCategoryName}' data-filter-value='${filterCategoryValue}'
			data-status-open='${statusFilter}'>
				<div style="display: none;">${activeFilters}</div>
			<c:choose>
				<c:when test="${showStoryPointsStats}"><!--
					--><div class="issueCountContainer">${issueCount}</div><!--
					--><div class="storyPointsContainer">
						<div class="storyPointsLabel ${storyPointsCssClass}"<c:if test="${storyPoints eq 0}"> style="visibility: hidden"</c:if>>
							${storyPoints}<div class="storyPointsIcon"></div></div>
					</div><!--
				</c:when>
				<c:otherwise>${issueCount}</c:otherwise>
			</c:choose><!--
		--></td>
	</c:otherwise>
</c:choose>
