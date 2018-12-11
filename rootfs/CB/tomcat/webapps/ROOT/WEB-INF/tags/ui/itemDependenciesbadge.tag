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
<%@tag language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ attribute name="item" required="true" type="com.intland.codebeamer.persistence.dto.TrackerItemDto" rtexprvalue="true" description="The item for which the badge is rendered."  %>

<c:if test="${item.hasPropagateUnresolvedDependency}">
	<spring:message var="badgeLabel" code="association.unresolved.dependencies.compact.label" text="UD"></spring:message>
	<spring:message var="badgeTitle" code="association.unresolved.dependencies.label" text="Unresolved Dependencies"></spring:message>
	
	<span class="udBadge${item.hasUnresolvedDependency ? ' active' : ''}" data-item-id="${item.id}" style="position: relative; top: -4px;" title="${badgeTitle}"><i class="fa fa-exclamation"></i>${badgeLabel}</span>
</c:if>

<script type="text/javascript">
	$(function() {
		codebeamer.UnresolvedDependenciesBadges.init();
	});
</script>