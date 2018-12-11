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
 * this file lists all the review items in the review (almost the same as the center panel of the document view).
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="callTag" prefix="ct"%>

<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemRevisionDto"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>

<%-- this bean is used for finding out if a summary is visible or not --%>
<jsp:useBean id="decorated" beanName="decorated" scope="request" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" />

<spring:message code="tracker.view.layout.document.add.comment.tooltip" text="Click to view comments or add one ..." var="addCommentTitle"/>

<spring:message code="review.item.not.editable.message" text="This review item is not editable" var="reviewItemNotEditableMessage"/>


<spring:message var="acceptTitle" code="review.item.accept.title" text="Approve"/>
<spring:message var="rejectTitle" code="review.item.reject.title" text="This item needs more work"/>

<c:if test="${not empty sourceBranch}">
	<c:set var="sourceBranchName">
		<c:out value="${sourceBranch.name}" escapeXml="true"/>
	</c:set>
</c:if>

<c:if test="${not empty targetBranch}">
	<c:set var="targetBranchName">
		<c:out value="${targetBranch.name}" escapeXml="true"/>
	</c:set>
</c:if>

<c:forEach items="${reviewItems}" var="item" varStatus="loopStatus" >
	<jsp:useBean id="item" beanName="item" type="com.intland.codebeamer.persistence.dto.TrackerItemDto" />

	<%
		decorated.initRow(new TrackerItemRevisionDto(item, null, null), 0, 0);
	%>

	<c:choose>
		<c:when test="${loopStatus.last}">
			<c:set var="dataAttribute" value='data-hasmore-before="${item.id != firstItem.id}" data-hasmore-after="${item.id != lastItem.id}"'/>
		</c:when>
		<c:when test="${loopStatus.first }">
			<c:set var="dataAttribute" value='data-hasmore-before="${item.id != firstItem.id}" data-hasmore-after="${item.id != lastItem.id}"'/>
		</c:when>
		<c:otherwise>
			<c:set var="dataAttribute" value='data-hasmore-before="true" data-hasmore-after="true"'/>
		</c:otherwise>
	</c:choose>

	<tr class="requirementTr ${item.resolvedOrClosed ? 'closed' : ''} ${canEdit ? 'canedit' : ''}" id="${item.reviewItem.id}"  data-name-visible="${ decorated.nameVisible}"
	data-review-id="${item.id }" ${dataAttribute}
		title="${item.resolvedOrClosed ? reviewItemNotEditableMessage : '' }">
		<%-- the box containing the control buttons (apply, reject etc.) --%>
		<ct:call object="${item }" method="isAccepted" param1="${user }" return="accepted"/>
		<ct:call object="${item }" method="isRejected" param1="${user }" return="rejected"/>
		<td class="control-bar ${compactMode ? 'compact' : '' }">
			<div class="controls">
				<c:if test="${(decorated.nameVisible or decorated.descriptionVisible) and !item.reviewItem.groupingItem}">
					<%-- this button will accept/reject the requirement under review --%>
					<c:set var="statusClass" value="${accepted ? 'accepted' : '' }"></c:set>
					<c:set var="statusClass" value="${rejected ? 'rejected' : statusClass }"></c:set>
					<div class="review-button ${statusClass }" title="${item.resolvedOrClosed ? reviewItemNotEditableMessage : '' }">
						<span class="switch accept" title="${item.resolvedOrClosed ? '' : acceptTitle }"></span>
						<span class="switch reject" title="${item.resolvedOrClosed ? '' : rejectTitle }"></span>
					</div>
				</c:if>

				<c:if test="${item.reviewItem.groupingItem}">
					<div style="margin-top: 11px;">
						<ui:coloredEntityIcon subject="${item.reviewItem}" iconUrlVar="imgUrl" iconBgColorVar="iconBgColor"/>
						<img style="background-color:${iconBgColor}" src="<c:url value="${imgUrl}"/>"/>
					</div>
				</c:if>

				<%-- add the comments button --%>

				<c:if test="${(decorated.nameVisible or decorated.descriptionVisible) }">
					<div class="comments">
						<span class="comment-bubble" data-id="${item.reviewItem.id }"
							  data-review-item-id="${item.id }" data-canview="${canViewCommentsAttachments}"
							  title="${addCommentTitle}" data-revision="${not empty revision ? review.eviewItemBaselineIds : ''}">
							${fn:length(decorated.attachments)}
						</span>
						<span class="comment-bubble-arrow"></span>
					</div>
				</c:if>
			</div>
		</td>

		<%-- the box containing the item description and summary --%>
		<td class="textSummaryData requirementTd">
			<h1 class="name" data-issueid="${item.reviewItem.id }"  issueid="${item.reviewItem.id }">
				<c:choose>
					<c:when test="${decorated.nameVisible}">
						<c:choose>
							<c:when test="${empty item.name}">
								<span><spring:message code="tracker.view.layout.document.no.summary" text="[No summary]"/></span>
							</c:when>
							<c:otherwise>
								<span><c:out value="${item.name}"/></span>
							</c:otherwise>
						</c:choose>
					</c:when>
					<c:otherwise>
						<a class="noAccessPermsWarn" style="text-decoration: none"
							title="<spring:message code="reference.field.read.permission" text="At this time you have no permission to read this field."/>">
							<spring:message code="tracker.view.layout.document.summary.not.readable" text="[Summary not readable]"/>
						</a>
					</c:otherwise>
				</c:choose>

				<c:if test="${item.reviewItem.version != null}">
					<c:url var="itemUrl" value="${item.reviewItem.urlLink }?version=${item.reviewItem.version}"></c:url>
					<a href="${itemUrl }"><span class="referenceSettingBadge versionSettingBadge">v${item.reviewItem.version}</span></a>
				</c:if>

				<span class="branch-badge-group">
				<%-- for accepted items always show the branch badges --%>
				<c:if test="${accepted or !item.resolvedOrClosed }">

					<c:if test="${not empty diffsPerItem and diffsPerItem[item.reviewItem.id] != null}">
						<%-- this is a normal merge request (not branch) and this item was updated in the source tracker --%>
						<spring:message code="review.merge.updated.in.tracker.title"
								text="This item has been updated in the source tracker. To see the differences click this badge."
								var="itemUpdatedTitle"/>
						<span class="referenceSettingBadge updatedBadge mergeRequestBadge branchDivergedBadge"
							  data-issue-id="${item.reviewItem.id}" data-copy-id="${mergeItemPairs[item.reviewItem].id}"
							title="${itemUpdatedTitle }" data-baseline-id="${baselineId }">
							<spring:message code="review.merge.updated.in.tracker.label" text="Updated in source tracker"/>
						</span>
					</c:if>

					<c:if test="${isBranchMergeRequest and divergedOnMaster[item.reviewItem.id] != null }">
						<spring:message code="tracker.branching.item.diverged.from.master.title"
								text="This item has diverged from the Master branch. To see the differences click this badge."
								var="itemUpdatedTitle"/>
							<span class="referenceSettingBadge updatedBadge branchBadge masterDivergedBadge branchDivergedBadge" data-issue-id="${item.id }"
								title="${itemUpdatedTitle }">
								<c:choose>
									<c:when test="${not empty targetBranchName}">
										<spring:message code="tracker.branching.item.created.on.branch.with.name.label" arguments="${targetBranchName}"/>
									</c:when>
									<c:otherwise>
										<spring:message code="tracker.branching.${topLevelBranch ? 'master' : 'parent' }.diverged.from.branch.label" text="Updated on Master"/>
									</c:otherwise>
								</c:choose>
							</span>
					</c:if>

					<c:if test="${isBranchMergeRequest and divergedOnBranch[item.reviewItem.id] != null }">
						<spring:message code="tracker.branching.item.diverged.from.master.title"
							text="This item has diverged from the Master branch. To see the differences click this badge."
							var="itemUpdatedTitle"/>
						<span class="referenceSettingBadge updatedBadge branchBadge branchDivergedBadge" data-issue-id="${item.id }"
							title="${itemUpdatedTitle }">
							<c:choose>
								<c:when test="${not empty sourceBranchName}">
									<spring:message code="tracker.branching.item.updated.on.branch.with.name.label" arguments="${sourceBranchName}"/>
								</c:when>
								<c:otherwise>
									<spring:message code="tracker.branching.item.diverged.from.master.label" text="Updated on branch"/>
								</c:otherwise>
							</c:choose>
						</span>
					</c:if>

					<c:if test="${isBranchMergeRequest and createdOnBranch[item.reviewItem.id] != null }">
						<spring:message code="tracker.branching.item.crested.on.branch.title"
								var="itemCreatedTitle"/>
						<span class="referenceSettingBadge updatedBadge branchBadge" data-issue-id="${item.id }"
							title="${itemCreatedTitle }">

							<c:choose>
								<c:when test="${not empty sourceBranchName}">
									<spring:message code="tracker.branching.item.created.on.branch.with.name.label" arguments="${sourceBranchName}"/>
								</c:when>
								<c:otherwise>
									<spring:message code="tracker.branching.item.crested.on.branch.label" text="Created on branch"/>
								</c:otherwise>
							</c:choose>
						</span>
					</c:if>
				</c:if>


				<c:if test="${not empty newVersions && newVersions[item.reviewItem.id] != null }">
					<spring:message code="review.updated.title"
						text="This item has been updated since the current review started. To see the differences click this badge."
						var="itemUpdatedTitle"/>
					<span class="referenceSettingBadge updatedBadge" data-baseline-id="${baselineId }" data-issue-id="${item.reviewItem.id }" title="${itemUpdatedTitle }">
						<spring:message code="review.updated.badge.label" text="New Version Available"/>
					</span>
				</c:if>
				<c:if test="${not empty deletedNewVersions && deletedNewVersions[item.reviewItem.id] != null }">
					<span class="referenceSettingBadge deletedBadge">
						<spring:message code="review.deleted.badge.label" text="Original Item was Deleted"/>
					</span>
				</c:if>
				<c:if test="${not empty itemsUpdatedAfterLastVersion && itemsUpdatedAfterLastVersion[item.reviewItem.id] != null }">
					<c:set var="versionPair" value="${itemsUpdatedAfterLastVersion[item.reviewItem.id] }"/>
					<spring:message code="review.updated.since.last.review.title"
						text="This item has been updated since the last version of this review. To see the differences click this badge."
						var="itemUpdatedTitle"/>

					<span class="referenceSettingBadge updatedBadge" data-baseline-id="${versionPair.left }" data-new-version="${versionPair.right }"
						data-issue-id="${item.reviewItem.id }" title="${itemUpdatedTitle }">
						<spring:message code="review.updated.since.last.review.badge.label" text="Updated Since Last Review"/>
					</span>
				</c:if>
				</span>
				<div style="clear:both;"></div>
			</h1>

			<c:if test="${item.resolvedOrClosed and not review.resolvedOrClosed}">
				<div class="smallWarning">
					${reviewItemNotEditableMessage }
				</div>
			</c:if>

			<div class="description thumbnailImages">
				<div class="description-container"
					data-description-format="${item.descriptionFormat == '' ? 'P' : item.descriptionFormat }">
					<c:if test="${item.description != '--' && not empty item.description && decorated.descriptionVisible}">
						<c:set var="descriptionDecorated" value="${decorated.description}"/>
						<c:if test="${descriptionDecorated != null }">
							<c:out value="${descriptionDecorated}" escapeXml="false"/>
						</c:if>
					</c:if>
				</div>
			</div>

			<%-- the test steps box. when clicked the test steps are loaded from the server and added to the dom.
			visible only if the original item has test cases --%>
			<c:if test="${!empty testStepsPerItem && !isGroupingItem}">
				<c:set var="steps" value="${testStepsPerItem[item.reviewItem]}"/>
				<c:if test="${not empty steps}">
					<spring:message code="tracker.field.Test Steps.label" var="testStepsLabel"/>
					<div class="teststepwrapper">
						<div class="expander testStepContainer">
							<img class="expander noMarginExpander" src="<c:url value="/images/Gap.gif"/>"/>
							<span class="testStepCount">${fn:length(steps)} ${testStepsLabel}</span>
						</div>
						<div class="expandable" style="display:none;">
							<input type="hidden" value="false" name="editable"/>
						</div>
					</div>
				</c:if>
			</c:if>

			<spring:message var="associationsTitle" code="planner.issueReferences" text="References"/>
			<c:set var="referenceData" value="${referenceDataByItem[item] }"></c:set>

			<c:choose>
				<c:when test="${referenceData.referenceCount != null && referenceData.referenceCount != 0}">
					<ui:collapsingBorder onChange="codebeamer.review.loadReviewItemReferences"
						label="${associationsTitle } (${referenceData.referenceCount })" cssClass="separatorLikeCollapsingBorder referenceContainer">
						<jsp:attribute name="headerContent">
							<c:if test="${itemsWithUpdatedReference[item.reviewItem.id] != null}">
								<span class="referenceSettingBadge updatedReferenceBadge" data-baseline-id="${baselineId }" data-issue-id="${item.reviewItem.id }">
									<spring:message code="review.updated.reference.badge.label" text="Updated References"/>
								</span>
							</c:if>


							<c:if test="${fn:contains(itemsWithReferencesUpdatedBeforeRestart, item.reviewItem.id) }">
								<span class="referenceSettingBadge updatedReferenceBadge" data-baseline-id="${baselineId }" data-issue-id="${item.reviewItem.id }">
									<spring:message code="review.updated.reference.since.last.review.badge.label" text="Updated References in previous version"/>
								</span>
							</c:if>
						</jsp:attribute>
					</ui:collapsingBorder>
				</c:when>
				<c:otherwise>
					<div class="subtext"><spring:message code="planner.no.associationObjects.found.message" text="No Associatons"/></div>
				</c:otherwise>
			</c:choose>
		</td>
	</tr>
</c:forEach>