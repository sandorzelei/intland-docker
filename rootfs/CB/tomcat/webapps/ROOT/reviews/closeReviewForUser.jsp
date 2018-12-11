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
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin reviewModule"/>
<meta name="module" content="review"/>

<script src="<ui:urlversioned value='/reviews/initPreventPrefill.js'/>"></script>

<ui:actionMenuBar>
    <spring:message code="review.${review.mergeRequest ? 'merge.' : '' }complete.title" text="Complete Review"/>
</ui:actionMenuBar>

<div class="contentWithMargins">
    <c:choose>
        <c:when test="${stats.notReviewed > 0}">
            <div class="warning">
                <spring:message code="review.finish.not.reviewed.warning"
                                text="You cannot finish this review here are items that you have not reveiwed"/>
            </div>
        </c:when>
        <c:otherwise>
            <c:url var="actionUrl" value="/proj/review/completeReviewForUser.spr"/>
            <form:form action="${actionUrl}" commandName="command">
                <form:hidden path="reviewId"/>
                <spring:message code="review.complete.stats" text="From ${stats.total } items you accepted ${stats.accepted } and rejected ${stats.rejected }." arguments="${stats.total },${stats.accepted },${stats.rejected }"/>

                <h3>
                    <spring:message code="review.${review.mergeRequest ? 'merge.' : '' }progress.progress.summary" text="Progress of all reviewers reviewers"></spring:message>
                </h3>

                <jsp:include page="includes/reviewProgress.jsp"></jsp:include>

                <p>
                    <label for="comment"><spring:message code="review.complete.final.comments.label" text="Comment"/>:</label>
                    <form:textarea path="comment" cssStyle="width: 100%;" rows="5"/>
                </p>

                <div class="field">
                    <label for="baselineSignature" class="mandatory"><spring:message code="baseline.signature.label" text="Baseline Signature"/>:</label>
                    <form:password path="baselineSignature" size="30" maxlength="30" autocomplete="new-password"/><form:errors path="baselineSignature" cssClass="invalidfield"></form:errors>
                </div>

                <p style="margin-top: 10px;">
                    <spring:message code="review.complete.${review.mergeRequest ? 'merge.' : '' }approve.for.user.label" text="Sign Review" var="signReviewLabel"/>
                    <button name="status" class="button" value="FINISH_FOR_USER" style="margin-right: 10px;">${signReviewLabel }</button>
                </p>
            </form:form>
        </c:otherwise>
    </c:choose>

</div>

