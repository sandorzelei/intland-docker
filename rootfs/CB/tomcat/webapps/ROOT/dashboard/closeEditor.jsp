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

	<c:choose>
		<c:when test="${param.addingNewWidget == true}">
			parent.codebeamer.dashboard.addWidget("${widget}", ${columnNumber}, ${isFirst});
		</c:when>
		<c:otherwise>
			parent.codebeamer.dashboard.refreshWidget("${param.widgetId}");
		</c:otherwise>
	</c:choose>

	closePopupInline();
</script>