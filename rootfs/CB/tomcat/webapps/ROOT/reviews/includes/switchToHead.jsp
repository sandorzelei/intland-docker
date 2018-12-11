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
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<c:if test="${not empty revision or not empty param.selectedRevision}">
    <spring:message code="review.switch.to.head" var="title" text="Switch to HEAD version"/>
    <c:url value="${review.urlLink}${not empty subPage ? subPage : ''}" var="headUrl"/>

    <span class="branchBaselineBadge">
        <a class="branchBaselineMenuPart exit" title="${title}" href="${headUrl}"></a>
    </span>
</c:if>