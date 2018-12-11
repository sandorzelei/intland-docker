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
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="tag" uri="taglib" %>

<c:if test="${not empty groupedByReview}">
    <div class="reviewListPlugin plugin-${pluginId}">
        <div class="accordion">
            <c:forEach items="${statsPerReview}" var="entry">
                <c:set var="review" value="${entry.key}"/>
                <h3 class="accordion-header">
                    <ui:wikiLink item="${entry.key}"/>
                </h3>
                <div class="accordion accordion-content">
                    <div class="stats-box">
                        <table class="propertyTable">
                            <tr>
                                <td class="optional"><spring:message code="review.statistics.started.by.label" text="Started by"/>:</td>
                                <td>
                                    <ui:userPhoto userId="${review.submitter.id }" ></ui:userPhoto>
                                    <div class="link-and-date">
                                        <tag:userLink user_id="${review.submitter }"></tag:userLink>
                                        <c:choose>
                                            <c:when test="${not empty review.startDate }">
                                                <span class="subtext date"><tag:formatDate value="${review.startDate }"></tag:formatDate></span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="subtext date"><spring:message code="review.statistics.date.not.defined" text="Undefined"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="optional"><spring:message code="review.statistics.completed.at.label" text="Completed at"/>:</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${review.resolvedOrClosed }">
                                            <ui:userPhoto userId="${review.closedBy}" ></ui:userPhoto>

                                            <div class="link-and-date">
                                                <tag:userLink user_id="${review.closedBy }"></tag:userLink>
                                                <c:choose>
                                                    <c:when test="${not empty review.closedAt }">
                                                        <span class="subtext date"><tag:formatDate value="${review.closedAt }"></tag:formatDate></span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="subtext date"><spring:message code="review.statistics.date.not.defined" text="Undefined"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="subtext"><spring:message code="review.statistics.not.finished" text="Not Finished"/></span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                            <tr>
                                <td class="optional"><spring:message code="review.statistics.signed.by.label" text="Signed by"/>:</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${review.signedBy != null }">
                                            <ui:userPhoto userId="${review.signedBy}" ></ui:userPhoto>

                                            <div class="link-and-date">
                                                <tag:userLink user_id="${review.signedBy }"></tag:userLink>
                                                <c:choose>
                                                    <c:when test="${not empty review.signedAt }">
                                                        <span class="subtext date"><tag:formatDate value="${review.signedAt }"></tag:formatDate></span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="subtext date"><spring:message code="review.statistics.date.not.defined" text="Undefined"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="subtext"><spring:message code="review.statistics.not.signed" text="Not Signed"/></span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                            <tr>
                                <td class="optional"><spring:message code="review.flow.step1.deadline.label" text="Deadline"/>:</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty review.endDate }">
                                            <span class="subtext"><tag:formatDate value="${review.endDate }"></tag:formatDate></span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="subtext"><spring:message code="review.statistics.date.not.defined" text="Undefined"/></span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                            <c:if test="${creationBaselinePerReview[review] != null }">
                                <td class="optional"><spring:message code="baseline.label" text="Baseline"/>:</td>
                                <td>
                                    <c:url var="baselineUrl" value="${creationBaselinePerReview[review].urlLink }"/>

                                    <a href="${baselineUrl }"><c:out value="${creationBaselinePerReview[review].name }"/></a>
                                </td>
                            </c:if>
                            <c:if test="${creationBaselinePerReview[review] == null }">
                                <td class="optional"><spring:message code="baseline.label" text="Baseline"/>:</td>
                                <td>
							<span class="subtext">
								<spring:message code="review.baselines.head.label" text="HEAD"></spring:message>
							</span>
                                </td>
                            </c:if>
                        </table>
                    </div>
                    <c:set var="statsPerItem" value="${entry.value}" scope="request"/>
                    <jsp:include page="/reviews/includes/itemProgress.jsp"></jsp:include>
                </div>
            </c:forEach>
        </div>
    </div>

    <script type="text/javascript">

        (function ($) {
            $('.reviewListPlugin.plugin-${pluginId} > .accordion').cbMultiAccordion({active: -1});
        })(jQuery);
    </script>

    <style type="text/css">
        .newskin .reviewListPlugin .displaytag, .newskin .reviewListPlugin .propertyTable {
            margin-left: 0px;
            margin-right: 0px;
        }

        .newskin .reviewListPlugin .stats-box .propertyTable td.optional {
            text-align: left;
            width: 30%;
        }

        .newskin .reviewListPlugin .accordion-header .wikiLinkContainer a {
            font-size: 12px;
        }
    </style>
</c:if>
