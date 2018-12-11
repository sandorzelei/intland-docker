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

<td class="center-pane">
	<script type="text/javascript">
	codebeamer.plannerConfig = jQuery.extend(codebeamer.plannerConfig || {}, {
		"targetReleaseEditable": ${(!empty targetReleaseEditable) ? targetReleaseEditable : "[]"},
		"teamFieldEditable": ${(!empty teamFieldEditable) ? teamFieldEditable : "[]"},
		"summaryEditable": ${(!empty summaryEditable) ? summaryEditable : "[]"},
		"assigneeEditable": ${(!empty assigneeEditable) ? assigneeEditable : "[]"}
	});
	</script>
	<jsp:include page="/agile/includes/plannerCenterPane.jsp" />
</td>
