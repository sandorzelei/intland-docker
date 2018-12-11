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

<div class="history-page">
	<div class="history-filter-controls">
		<c:set var="disabled" value="${hasAgileLicense ? '' : 'disabled=\"disabled\"' }"/>
		Filter: <input type="text" value="${projectBacklogState.filterText}" ${disabled}>
	</div>

	<c:if test="${historyItemCount > 0}"><c:set var="displayAttribute" value="style='display: none;'" /></c:if>

	<div class="empty-filtered" ${displayAttribute}>
		<spring:message code="table.nothing.found" text="Nothing found to display"></spring:message>
	</div>

	${historyItemsHtml}
</div>

<script type="text/javascript">
	codebeamer.plannerConfig.targetReleaseEditable =
		jQuery.merge(
	 		codebeamer.plannerConfig.targetReleaseEditable,
			${(!empty targetReleaseEditable) ? targetReleaseEditable : "[]"}
		);

	codebeamer.plannerConfig.assigneeEditable =
		jQuery.merge(
	 		codebeamer.plannerConfig.assigneeEditable,
			${(!empty assigneeEditable) ? assigneeEditable : "[]"}
		);

	codebeamer.plannerConfig.itemEditable =
		jQuery.merge(
	 		codebeamer.plannerConfig.itemEditable,
			${(!empty itemEditable) ? itemEditable : "[]"}
		);

	codebeamer.plannerConfig.teamFieldEditable =
		jQuery.merge(
	 		codebeamer.plannerConfig.teamFieldEditable,
			${(!empty teamFieldEditable) ? teamFieldEditable : "[]"}
		);

	codebeamer.plannerConfig.summaryEditable =
		jQuery.merge(
	 		codebeamer.plannerConfig.summaryEditable,
			${(!empty summaryEditable) ? summaryEditable : "[]"}
		);
</script>
