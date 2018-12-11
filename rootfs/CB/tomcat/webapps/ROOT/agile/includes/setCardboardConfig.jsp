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

<script type="text/javascript">
	codebeamer.cardboard.extendConfigWith({
		"sortableSelector": "#userStories td.lane",
		"transitions": ${transitions},
		"statusesPerColumns": ${statusesPerColumns},
		"transitionNames": ${transitionNames},
		"statusNames": ${statusNames},
		"statusesWithRequiredField": ${statusesWithRequiredField},
		"issueTypes": ${issueTypes},
		"transitionIds": ${transitionIds},
		"statusStyles": ${statusStyles},
		"limits": {
 			"minWidth": 130,
			"maxWidth": 170,
			"handleWidth": 10
		},
		"releaseId": "${subjectId}",
		"grouped": ${!empty swimlanes},
		"recursive": recursive,
		"maximumCards": ${maximumCards},
		"baseUrl": "${baseUrl}",
		"type": "${type}",
		"viewId": "${viewId}"
	});
</script>
