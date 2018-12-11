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
<%--
 renders a tracker branch badge
 --%>
<%@tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ attribute name="branch" required="true" type="com.intland.codebeamer.persistence.dto.BranchDto" rtexprvalue="true"
	description="The branch to render"  %>

<span class="trackerBranchBadgeContainer">
	<c:set var="branchName" value="${branch.name }"/>
	<c:url var="branchUrl" value="${branch.urlLink }"/>

	<a href="${branchUrl }">
		<span class="trackerBranchBadge" data-branch-id="${branch.id}" title="${branchName}">
			${branchName}

		</span>
	</a>
</span>