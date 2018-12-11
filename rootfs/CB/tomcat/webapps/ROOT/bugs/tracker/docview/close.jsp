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
		if (parent != window) {
			parent.location.reload();
		} else {
			// the user opened this overlay in a new tab using ctrl+click, so close the new window
			window.close();
		}
	} catch (ignored) {
		console.log("Failed to call callback on the opener page:" + ignored);
	}
	inlinePopup.close();
</script>
