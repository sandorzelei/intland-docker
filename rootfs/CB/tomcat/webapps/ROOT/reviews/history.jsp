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
<%@ taglib prefix="ui" uri="uitaglib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="bugs" uri="bugstaglib" %>

<meta name="decorator" content="main"/>
<meta name="moduleCSSClass" content="newskin reviewModule ${not empty param.selectedRevision ? 'tracker-baseline' : ''}"/>
<meta name="module" content="review"/>

<head>
    <link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/review/review.less' />" type="text/css" media="all" />

    <style type="text/css">
        /* hide the bug icon column */
         #trackerItems td.bug-icon, #trackerItems > thead > tr > th:first-child {
            display: none;
        }

    </style>
</head>

<ui:actionMenuBar cssClass="large">
    <jsp:attribute name="rightAligned">
        <c:set scope="request" value="/history" var="subPage"/>
        <jsp:include page="includes/switchToHead.jsp"/>

		<ui:combinedActionMenu builder="reviewActionMenuBuilder" keys="review,feedback,statistics"
                               buttonKeys="review,feedback,statistics,history" subject="${review}" activeButtonKey="history"
                               cssClass="large" hideMoreArrow="true" />
	</jsp:attribute>
    <jsp:body>
        <ui:breadcrumbs showProjects="false" showLast="false" showTrailingId="false" strongBody="false">
            <ui:pageTitle printBody="true">
                <spring:message code="review.view.history" arguments="${review.name}"/>
            </ui:pageTitle>
        </ui:breadcrumbs>
    </jsp:body>
</ui:actionMenuBar>

<div class="contentWithMargins">
    <c:choose>
        <c:when test="${!hasLicense }">
            <div class="warning">
                <spring:message code="license.reviews.nolicense.message"/>
            </div>
        </c:when>
        <c:otherwise>
            <spring:message code="review.statistics.completed.at.label" text="Finished" var="restartedLabel"/>
            <bugs:displaytagTrackerItems htmlId="trackerItems" items="${revisions}" hideIconColumn="false" export="false"
                                         pagesize="${pagesize}" decorator="${decorator}" layoutList="${layoutList}"
                                         browseTrackerMode="false" selection="false" selectionFieldName="clipboard_task_id"
                                         isReview="false" extraColumn="${baselineExtraColumn}" extraColumnLabel="${restartedLabel}"
                                         extraColumnClass="dateData column-minwidth fieldColumn columnSeparator"/>

        </c:otherwise>
    </c:choose>
</div>