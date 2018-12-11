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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<spring:message var="detailsTitle" code="planner.issueDetails" text="Details" />
<spring:message var="descriptionTitle" code="planner.issueDescription" text="Description" />
<spring:message var="associationsTitle" code="planner.issueAssociations" text="Associations"/>
<spring:message var="referencesTitle" code="planner.issueReferences" text="References"/>
<spring:message var="commentsTitle" code="planner.issueComments" text="Comments"/>

<ul class="quick-icons" id="right-pane-quick-icons"><!--
	--><li class="details" title="<c:out value="${detailsTitle}" />"></li><!--
	--><li class="description" title="<c:out value="${descriptionTitle}" />"></li><!--
	--><li class="references" title="<c:out value="${referencesTitle}" />"></li><!--
	--><li class="associations" title="<c:out value="${associationsTitle}" />"></li><!--
	--><li class="comments" title="<c:out value="${commentsTitle}" />"></li><!--
--></ul>

<div class="overflow">

	<div class="accordion" data-quick-icons="right-pane-quick-icons">

		<h3 class="issue-details-title accordion-header"><span class="icon"></span><c:out value="${detailsTitle}" /></h3>
		<div class="issue-details accordion-content" data-section-id="details"></div>

		<h3 class="issue-description-title accordion-header"><span class="icon"></span><c:out value="${descriptionTitle}" /></h3>
		<div class="issue-description accordion-content" data-section-id="description"></div>

		<h3 class="issue-references-title accordion-header"><span class="icon"></span><c:out value="${referencesTitle}" /> <span class="item-count"></span></h3>
		<div class="issue-references accordion-content" data-section-id="references"></div>

		<h3 class="issue-associations-title accordion-header"><span class="icon"></span><c:out value="${associationsTitle}" /> <span class="item-count"></span></h3>
		<div class="issue-associations accordion-content" data-section-id="associations"></div>

		<h3 class="issue-comments-title accordion-header"><span class="icon"></span><c:out value="${commentsTitle}" /> <span class="comment-count"></span></h3>
		<div class="issue-comments accordion-content" data-section-id="comments"></div>

	</div>

</div>
