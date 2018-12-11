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
<meta name="decorator" content="popup"/>

<script type="text/javascript">
	try {
		var isCardBoard = ((typeof parent.codebeamer != "undefined") && ("cardboard" in parent.codebeamer));
		var isPlanner = ((typeof parent.codebeamer != "undefined") && ("planner" in parent.codebeamer));
		if (isCardBoard) {
			<c:choose>
				<c:when test="${groupingFieldChanged}">
					parent.submitForm();
				</c:when>
				<c:otherwise>
					parent.codebeamer.cardboard.updateHandler("${cardId}");
				</c:otherwise>
			</c:choose>
		} else if (isPlanner) {
			parent.codebeamer.planner.cardEditorSaveHandler("${cardId}", "${editorType}");
		}
	} catch (ignored) {
		console.log("Failed to call callback on the opener page:" + ignored);
	}
	inlinePopup.close();
</script>
