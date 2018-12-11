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
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<c:set var="singleSelect" value="${fieldLayout.multipleSelection != null && !fieldLayout.multipleSelection}"/>
<c:choose>
	<c:when test="${fieldLayout.dynamicChoice }">
		<bugs:chooseReferences htmlId="${fieldLayout.id}" tracker_id="${fieldLayout.trackerId}" label="${fieldLayout}" ids="${ids}"
			task_id="${item.id}" status_id="${item.status.id}" defaultValue="${fieldLayout.defaultValue }"
		/>
	</c:when>
	<c:otherwise>
		<bugs:userSelector field_id="${fieldLayout.id}" fieldName="${fieldLayout.label}" ids="${ids}" showUnset="false"
                   showCurrentUser="false"
                   onlyUsersAndRolesWithPermissionsOnTracker="true" tracker_id="${fieldLayout.trackerId}"
                   singleSelect="${singleSelect}" allowRoleSelection="true" />
	</c:otherwise>
</c:choose>

