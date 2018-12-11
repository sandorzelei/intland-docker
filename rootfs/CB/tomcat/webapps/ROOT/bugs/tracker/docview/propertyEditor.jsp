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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page import="com.intland.codebeamer.ui.view.ColoredEntityIconProvider" %>

<spring:message var="detailsTitle" code="planner.issueDetails" text="Details" />
<spring:message var="descriptionTitle" code="planner.issueDescription" text="Description" />
<spring:message var="associationsTitle" code="planner.issueAssociations" text="Associations"/>
<spring:message var="referencesTitle" code="planner.issueReferences" text="References"/>
<spring:message var="commentsTitle" code="planner.issueComments" text="Comments"/>

<link rel="stylesheet" href="<ui:urlversioned value='/bugs/includes/itemReviewStats.less' />" type="text/css" media="all" />
<div class="attributes">
	<tag:joinLines newLinePrefix="">
		<ul class="quick-icons" id="document-view-quick-icons">
		   <li class="details" title="<c:out value="${detailsTitle}" />"></li>
		   <c:if test="${showDescription}"><li class="description" title="<c:out value="${descriptionTitle}" />"></li></c:if>
		   <li class="references" title="<c:out value="${referencesTitle}" />"></li>
		   <li class="associations" title="<c:out value="${associationsTitle}" />"></li>
		   <li class="comments" title="<c:out value="${commentsTitle}" />"></li>
		</ul>
	</tag:joinLines>

	<div class="overflow">
		<div class="accordion" data-quick-icons="document-view-quick-icons">

			<c:if test="${not empty itemReviewStats }">
					<spring:message code="review.details.statistics.label" var="reviewStatisticsLabel"/>
				<h3 class="issue-review-title accordion-header"><span class="icon"></span><c:out value="${reviewStatisticsLabel}" /></h3>
				<div class="issue-review accordion-content" data-section-id="review">
					<jsp:include page="/bugs/tracker/includes/itemReviewStats.jsp"></jsp:include>
				</div>
			</c:if>


			<h3 class="issue-details-title accordion-header"><span class="icon"></span><c:out value="${detailsTitle}" /></h3>
			<div class="issue-details accordion-content" data-section-id="details">

				<h3>
					<c:set var="lockedTitle" value=""></c:set>
					<c:if test="${isLocked }">
						<c:set var="lockedTitle" value="${locker }"></c:set>

						<span class="locked" title="${lockedTitle}"></span>
					</c:if>

					<ui:wikiLink item="${item}" hideBadges="${true}" forceBaselineAware="${true}"/>
				</h3>

				<c:if test="${item.branchItem }">
					<c:set var="originalItem" value="${item.branchOriginalItem.originalTrackerItem }"/>
					<div style="margin-top: 10px;">
						<spring:message code="tracker.branching.show.on.master.label" text="Show on parent Branch" var="showOnMasterLabel"/>
						<c:if test="${originalItem != null }">
							<c:url var="originalTrackerUrl" value="${originalItem.tracker.urlLink }">
								<c:if test="${item.branchOriginalItem.branchItem }">
									<c:param name="branchId" value="${item.branchOriginalItem.originalTrackerItem.branch.id }"></c:param>
								</c:if>
								<c:param name="selectedItemId" value="${originalItem.id }"></c:param>
							</c:url>
							<a href="${originalTrackerUrl}">${showOnMasterLabel}</a>
						</c:if>
					</div>

					<div style="margin-top: 10px;">
						<bugs:itemBranchBadges itemDivergedOnMaster="${divergedOnMaster}"
							itemDivergedOnBranch="${divergedOnBranch}"
							itemCreatedOnBranch="${createdOnBranch}" branch="${item.branch }" item="${item }" ></bugs:itemBranchBadges>
					</div>
				</c:if>

				<form:form action="${actionUrl}" enctype="multipart/form-data" commandName="addUpdateTaskForm" method="POST" class="dirty-form-check">
					<input type="hidden" name="swimlanes" value="<c:out value='${param.swimlanes}'/>"/>

					<c:set var="uploadConversationId" ><c:out value='${addUpdateTaskForm.uploadConversationId}'/></c:set>
					<input type="hidden" name="uploadConversationId" value="${uploadConversationId}" />

					<c:if test="${!item.groupingItem && decorated.statusVisible }">
						<%-- add the readable status field to the beginning of the dynamic layout table --%>
						<c:set var="insertAtBeginningOfDynamicLayoutFragment" scope="request">
							<spring:message code="tracker.field.Status.label" text="Status" var="statusLabel"/>
							<div class="fieldInputControl optional">
								<div class="fieldLabel optional" title="${statusLabel }">
									<span class="labelText">${statusLabel }:</span>
								</div>
								<div class="fieldValue dataCell optional" title="${statusLabel }">
									${decorated.status }
								</div>
							</div>
						</c:set>
					</c:if>

					<jsp:include page="/bugs/addUpdateTask.jsp?skipScripts=true&noComment=true&nestedPath=null&noAssociation=true&noTrackerField=true&isPopup=true&minimal=true&isPopup=true&noActionMenuBar=true&maxColumns=1&noMeta=true&embeddedView=true" />
					<%-- don't show the edit buttons and the transition dropdown if there are no editable fields --%>
					<%--<c:if test="${fn:length(writableFields) > 0}">--%>
					<div class="saveControls">
						<div class="fieldValue">
							<c:if test="${(empty canEdit || canEdit) && itemEditable}">
								<span style="border:0 !important;">
									<spring:message code="button.save" var="saveTitle"/>

									<c:set var="disabled" value=""/>
									<c:if test="${isLocked }">
										<c:set var="disabled" value="disabled='disabled'"></c:set>
									</c:if>
									<input type="button" class="button" onclick="saveIssueProperties()" value="${saveTitle}" ${disabled }/>
								</span>
							</c:if>
						</div>
					</div>
					<%--</c:if>--%>
				</form:form>
			</div>

			<c:if test="${showDescription}">
				<h3 class="issue-description-title accordion-header"><span class="icon"></span><c:out value="${descriptionTitle}" /></h3>
				<div class="issue-description accordion-content" data-section-id="description">
					<tag:transformText value="${item.description}" format="${item.descriptionFormat}" />
				</div>
			</c:if>

			<h3 class="issue-references-title accordion-header"><span class="icon"></span><c:out value="${referencesTitle}" />(${referenceCount})</h3>
			<div class="issue-references accordion-content" data-section-id="references">
				<jsp:include page="referencesSection.jsp"/>
			</div>

			<h3 class="issue-associations-title accordion-header"><span class="icon"></span><c:out value="${associationsTitle}" />(${associationCount})</h3>
			<div class="issue-associations accordion-content" data-section-id="associations">
				<jsp:include page="associationsSection.jsp"/>
			</div>

			<h3 class="issue-comments-title accordion-header"><span class="icon"></span><c:out value="${commentsTitle}" /> <span class="comment-count">(${fn:length(itemAttachments)})</span></h3>
			<div class="issue-comments accordion-content" data-section-id="comments">
				<jsp:include page="commentsSection.jsp"/>
			</div>
		</div>
	</div>
</div>

<c:if test="${isLocked }">
	<script type="text/javascript">
		$(document).ready(function () {
			disableAllInputs($("#issuePropertiesPane .issue-details"));
		});
	</script>
</c:if>

<c:if test="${!isLocked}">
    <script type="text/javascript">
        $(document).ready(function () {
            codebeamer.NavigationAwayProtection.init(false, $('#issuePropertiesPane'));
        });
    </script>
</c:if>
