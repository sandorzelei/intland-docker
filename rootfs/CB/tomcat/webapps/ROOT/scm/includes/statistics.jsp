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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<div class="actionBar" style="height:16px;"></div>

<c:set var="statisticsWiki">
[{Table style='width:100%; border:none; border-spacing:0;' dataStyle='vertical-align:top; padding-right:5px; border:none; width: 50%;'

|[{CommitTrends repositoryId='${repository.id}' display='chart'}]|[{CommitStatistics repositoryId='${repository.id}' }]
}]
</c:set>

<tag:transformText value="${statisticsWiki}" format="W" />