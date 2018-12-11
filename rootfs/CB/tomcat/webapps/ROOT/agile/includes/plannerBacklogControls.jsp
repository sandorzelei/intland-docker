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

<c:set var="index" value="${projectBacklogState.tabIndex}" />

<div class="backlog-controls" <c:if test="${not isProjectBacklogEditable}">data-read-only="true"</c:if>>
    <ol class="navigation"><!--
        --><li class="filter ${index == 0 ? 'selected' : ''}" data-url="/ajax/planner/backlogControls.spr?type=filter" data-arrow-class="filter-arrow">Filter</li><!--
        --><li class="history ${index == 1 ? 'selected' : ''}" data-url="/ajax/planner/backlogControls.spr?type=history" data-arrow-class="history-arrow">History</li><!--
        --><li class="filter-arrow arrow ${index == 0 ? 'selected' : ''}"></li><!--
        --><li class="history-arrow arrow ${index == 1 ? 'selected' : ''}"></li><!--
    --></ol>
</div>
