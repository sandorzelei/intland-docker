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
 renders the difference between a branch and the master
--%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<meta name="decorator" content="${param.isPopup || isPopup ? 'popup' : 'main' }"/>
<meta name="moduleCSSClass" content="newskin trackersModule tracker-branch"/>
<meta name="module" content="tracker"/>

<ui:pageTitle prefixWithIdentifiableName="false" printBody="false"><c:out value='${tracker.name}'/></ui:pageTitle>

<link rel="stylesheet" href="<ui:urlversioned value="/diff/diff.less" />" type="text/css" media="all" />

<spring:message code="tracker.branching.merge.updated.downstream.label" text="Updated Downstream References" var="updatedDownstreamLabel"/>

<c:set var="noDiff" value="${empty divergedItems and empty createdOnBranch and empty deletedOnBranch and empty onlyIncomingReferenceChange }"/>
<c:if test="${param.noActionMenuBar != 'true' }">
	<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="true" showLast="false" showTrailingId="false" strongBody="true">
			<c:out value='${tracker.name}'/>
		</ui:breadcrumbs>
		<ui:breadcrumbsId />
		<span class="breadcrumbs-summary">
			<bugs:trackerBranchBadge branch="${branch }"></bugs:trackerBranchBadge>
		</span>
	</ui:actionMenuBar>

	<ui:actionBar>
		<c:if test="${!disableEditing }">
			<c:set var="disabled" value="${noDiff || !canMergeToTarget ? 'disabled=disabled' : '' }"/>
			<input type="button" class="merge-action button" value="Merge" ${disabled }>

			<c:if test="${!noSwapBranched }">
				<%-- when merging between branches add the switch branches link --%>
				<c:choose>
					<c:when test="${mergeBetweenBranches }">
						<c:url var="swapBranchesUrl" value="/branching/diff.spr?branchId=${targetBranchId}&targetBranchId=${branch.id}"/>
					</c:when>
					<c:otherwise>
						<c:url var="swapBranchesUrl"
						value="/branching/diff.spr?branchId=${branch.id}&mergeFromMaster=${!mergeFromMaster }&isPopup=${param.isPopup }&issueIds=${param.issueIds }"/>
					</c:otherwise>
				</c:choose>

				<a href="${swapBranchesUrl }" class="actionLink"><spring:message code="tracker.branching.compare.swap.branches.label" text="Swap Branches"/></a>
				</c:if>
		</c:if>

		<a href="#" class="cancelButton"
			onclick="redirectToBranch(false, '${branch.id == tracker.id ? (targetBranch == null ? tracker.urlLink : targetBranch.urlLink) : branch.urlLink }');"><spring:message code="button.cancel" text="Cancel"/></a>
	</ui:actionBar>
</c:if>

<c:set var="topLevelBranch" value="${branch.parentBranch == null }"/>

<input type="hidden" name="mergeFromMaster" value="${mergeFromMaster}">
<input type="hidden" name="branchId" value="${branch.id}">
<c:if test="${not empty targetBranchId }">
	<input type="hidden" name="targetBranchId" value="${targetBranchId}">
</c:if>

<c:if test="${not empty review }">
	<input type="hidden" name="mergeRequestId" value="${review.id}">
	<input type="hidden" name="comment" value="${comment}">
</c:if>

<c:if test="${not empty sourceBranch and sourceBranch.branch}">
	<c:set var="sourceBranchName">
		<c:out value="${sourceBranch.name}" escapeXml="true"/>
	</c:set>
</c:if>

<c:if test="${not empty targetBranch and targetBranch.branch}">
	<c:set var="targetBranchName">
		<c:out value="${targetBranch.name}" escapeXml="true"/>
	</c:set>
</c:if>

<div class="contentWithMargins">
	<c:if test="${!disableEditing && canMergeToTarget}">
		<div class="information">
			<spring:message code="tracker.branching.merge.hint"></spring:message>
		</div>
	</c:if>
	<c:choose>
		<c:when test="${!canMergeToTarget }">
			<div class="information">
				<spring:message code="tracker.branching.merge.no.permission.message" text="You have no permission to merge changes to the target"/>
			</div>
		</c:when>
		<c:when test="${noDiff}">
			<div class="information">
				<spring:message code="tracker.branching.no.diff.message" text="There are no differences between the branch and the Master"/>
			</div>
		</c:when>
		<c:otherwise>

			<c:if test="${checkEditAndDeletePermissions && !canEditOnTarget }">
				<div class="warning">
					<spring:message code="tracker.branching.merge.no.edit.permission.message" text="You cannot apply your changes because you have no edit permission on the target"/>
				</div>
			</c:if>

			<c:if test="${checkEditAndDeletePermissions && !canDeleteOnTarget }">
				<div class="warning">
					<spring:message code="tracker.branching.merge.no.delete.permission.message" text="You cannot delete items on the target"/>
				</div>
			</c:if>

			<spring:message code="tracker.branching.master.name" text="Master Branch" var="masterLabel"/>

			<%-- render the diff for each item --%>
			<c:forEach var="item" items="${divergedItems }">
				<c:choose>
					<c:when test="${not empty itemsToPair }">
						<c:set var="sourceItem" value="${mergeFromMaster ? itemsToPair[item] : item  }"></c:set>
						<c:set var="targetItem" value="${mergeFromMaster ? item : itemsToPair[item] }"></c:set>
					</c:when>
					<c:otherwise>
						<c:set var="sourceItem" value="${mergeFromMaster ? item.branchOriginalItem.originalTrackerItem : item  }"></c:set>
						<c:set var="targetItem" value="${mergeFromMaster ? item : item.branchOriginalItem.originalTrackerItem }"></c:set>
					</c:otherwise>
				</c:choose>

				<c:if test="${not empty sourceItem and not empty targetItem }">
					<c:set value="${missingReferencedItemsPerItem[item] }" var="missingReferencedItems"></c:set>
					<div data-id="${sourceItem.id }" class="item-box">
						<h1><c:out value="${sourceItem.name}"/>

						<span class="branch-badge-group">
							<c:if test="${!mergeRequestClosed and fn:contains(divergedOnMaster, item) }">
								<spring:message code="tracker.branching.item.diverged.from.master.title"
										text="This item has diverged from the Master branch. To see the differences click this badge."
										var="itemUpdatedTitle"/>
									<span class="referenceSettingBadge updatedBadge masterDivergedBadge branchDivergedBadge" data-issue-id="${item.id }"
										title="${itemUpdatedTitle }">
										<c:choose>
											<c:when test="${not empty targetBranchName }">
												<spring:message code="tracker.branching.item.updated.on.branch.with.name.label" arguments="${targetBranchName}"/>
											</c:when>
											<c:otherwise>
												<spring:message code="tracker.branching.${topLevelBranch ? 'master' : 'parent' }.diverged.from.branch.label" text="Updated on Master"/>
											</c:otherwise>
										</c:choose>
									</span>
							</c:if>

							<c:if test="${!mergeRequestClosed and fn:contains(divergedOnBranch, item) }">
								<spring:message code="tracker.branching.item.diverged.from.master.title"
									text="This item has diverged from the Master branch. To see the differences click this badge."
									var="itemUpdatedTitle"/>
								<span class="referenceSettingBadge updatedBadge branchDivergedBadge" data-issue-id="${item.id }"
									title="${itemUpdatedTitle }">

									<c:choose>
										<c:when test="${not empty sourceBranchName }">
											<spring:message code="tracker.branching.item.updated.on.branch.with.name.label" arguments="${sourceBranchName}"/>
										</c:when>
										<c:otherwise>
											<spring:message code="tracker.branching.item.diverged.from.master.label" text="Updated on branch"/>
										</c:otherwise>
									</c:choose>
								</span>
							</c:if>

							<c:if test="${!mergeRequestClosed and fn:contains(conflicted, item) }">
								<span class="referenceSettingBadge updatedBadge conflictBadge" data-issue-id="${item.id }">
									<spring:message code="tracker.branching.conflit.label" text="Conflict"/>
								</span>
							</c:if>
						</span>
						</h1>


						<c:if test="${not empty missingReferencedItems}">
							<div class="warning">
								<spring:message code="tracker.branching.missing.reference.warning"></spring:message>
								<br/>
								<c:forEach items="${missingReferencedItems }" var="missingItem" varStatus="loopStatus">
									<c:if test="${not loopStatus.first }">
									,
									</c:if>
									<a href="#${missingItem.id }"><c:out value="${ui:removeXSSCodeAndHtmlEncode(missingItem.name)}"></c:out></a>
								</c:forEach>
							</div>
						</c:if>
						<%-- set request scope variables for the diff rendering --%>
						<c:set var="diff" value="${diffPerItem[item] }" scope="request"></c:set>
						<c:set var="copy" value="${targetItem }" scope="request"></c:set>
						<c:set var="original" value="${sourceItem }" scope="request"></c:set>

						<c:choose>
							<c:when test="${mergeBetweenBranches }">
								<%-- when merging between branches use the branch names as labels --%>
								<spring:message code="tracker.branching.merge.to.label" arguments="${targetBranch.id == tracker.id ? masterLabel : targetBranch.name}" scope="request" var="copyLabel"/>
								<spring:message code="tracker.branching.merge.from.label" arguments="${branch.id == tracker.id ? masterLabel : branch.name}" scope="request" var="originalLabel"/>
							</c:when>
							<c:otherwise>
								<c:set var="parentBranchLabel" value="${empty parentBranch ? masterLabel : parentBranch.name }"></c:set>
								<spring:message code="tracker.branching.merge.to.label" arguments="${mergeFromMaster ? branch.name : parentBranchLabel}" scope="request" var="copyLabel"/>
								<spring:message code="tracker.branching.merge.from.label" arguments="${mergeFromMaster ? parentBranchLabel : branch.name}" scope="request" var="originalLabel"/>
							</c:otherwise>
						</c:choose>

						<c:choose>
							<c:when test="${not empty misqualifiedAsCreated[item.id] }">
								<div class="information">
									<%-- we cannot compute the diff for this item because the target item is not available --%>
									<spring:message code="tracker.branching.compare.diff.not.available"
										text="Cannot show the diff for this item because the target item is not available"/>
								</div>
							</c:when>
							<c:otherwise>
								<c:if test="${!disableEditing }">
									<form id="diffDataForm" action="${pageContext.request.contextPath}/branching/diff.spr" method="post">
										<input type="hidden" name="field_ids" value=""> <!-- filled by JS on save -->
										<label style="margin-left: 10px;"><input type="checkbox" name="markAsMerged" value="${sourceItem.id }" style="margin-right: 10px;"/>Mark as merged</label>
									</form>
								</c:if>

								<c:if test="${disableEditing }">
									<c:set var="editable" value="${!disableEditing }" scope="request"/>
								</c:if>

								<jsp:include page="/diff/diffTable.jsp"></jsp:include>


								<c:if test="${referencesToBranchPerItem[sourceItem.id] != null and not empty referencesToBranchPerItem[sourceItem.id] }">
									<div class="contentWithMargins">
										<ui:collapsingBorder id="downstream-${surceItem.id }"
											label="${updatedDownstreamLabel }" open="false" cssClass="scrollable">

											<%-- there new incoming references to the branch item so list them as well --%>
											<c:set var="updatedDownstreamSet" value="${ referencesToBranchPerItem[sourceItem.id]}" scope="request"/>
											<c:set var="referredItem" value="${sourceItem }" scope="request"/>

											<jsp:include page="updatedDownstreamReferences.jsp"></jsp:include>
										</ui:collapsingBorder>
									</div>
								</c:if>
							</c:otherwise>
						</c:choose>

					</div>
				</c:if>
			</c:forEach>
			<c:forEach items="${createdOnBranch }" var="item">
				<div data-id="${item.id }" class="item-box">
					<h1 id="${item.id }"><c:out value="${item.name}"/>
						<span class="branch-badge-group">
							<spring:message code="${mergeFromMaster ? (topLevelBranch ? 'tracker.branching.item.created.on.master.title' : 'tracker.branching.item.created.on.parent.title') : 'tracker.branching.item.crested.on.branch.title'}"
								var="itemCreatedTitle"/>
							<span class="referenceSettingBadge updatedBadge" data-issue-id="${item.id }"
								title="${itemCreatedTitle }">

								<c:choose>
									<c:when test="${not empty sourceBranchName }">
										<spring:message code="tracker.branching.item.created.on.branch.with.name.label" arguments="${sourceBranchName}"/>
									</c:when>
									<c:otherwise>
										<spring:message code="${mergeFromMaster ?
									(topLevelBranch ? 'tracker.branching.item.created.on.master.label' : 'tracker.branching.item.created.on.parent.label') : 'tracker.branching.item.crested.on.branch.label'}" text="Created on branch"/>									</c:otherwise>
								</c:choose>
							</span>
						</span>
					</h1>

					<c:if test="${!disableEditing }">
						<div>

							<table class="diffTable" style="margin-left: 15px;">
								<tr>
									<td class="copy value">
										<input type="checkbox" name="copyToTarget" id="copyToTarget${item.id }" value="${item.id }"/>
										<label for="copyToTarget${item.id }" style="margin-left: 10px;">
											<c:choose>
												<c:when test="${mergeBetweenBranches }">
													<spring:message code="tracker.branching.copy.to.specified.branch.label" arguments="${targetBranch.name }" text="Copy to ${targetBranch.name }"></spring:message>
												</c:when>
												<c:otherwise>
													<spring:message code="tracker.branching.copy.to.${mergeFromMaster ? 'branch' : (topLevelBranch ? 'master': 'parent') }.label" text="Copy to Master"/>
												</c:otherwise>
											</c:choose>
										</label>
									</td>
								</tr>
							</table>
						</div>
						<c:if test="${referencesToBranchPerItem[item.id] != null and not empty referencesToBranchPerItem[item.id] }">
							<div class="contentWithMargins">
								<ui:collapsingBorder id="downstream-${item.id }"
									label="${updatedDownstreamLabel }" open="false" cssClass="scrollable">

									<%-- there new incoming references to the branch item so list them as well --%>
									<c:set var="updatedDownstreamSet" value="${ referencesToBranchPerItem[item.id]}" scope="request"/>
									<c:set var="referredItem" value="${item }" scope="request"/>

									<%-- disable the downstream reference checkboxes by default. they can only be selected if the item will be created on the
									target branch --%>
									<c:set var="disableDownstreamCheckboxes" value="true" scope="request"/>

									<jsp:include page="updatedDownstreamReferences.jsp"></jsp:include>
								</ui:collapsingBorder>
							</div>
						</c:if>
					</c:if>

				</div>
			</c:forEach>

			<c:set var="disableDownstreamCheckboxes" value="false" scope="request"/>
			<%-- deleted items --%>
			<c:forEach items="${deletedOnBranch }" var="item">
				<div data-id="${item.id }" class="item-box">
					<h1><c:out value="${item.name}"/>
						<span class="branch-badge-group">
							<spring:message code="tracker.branching.item.deleted.on.branch.title"
								text="This item was deleted on this branch"
								var="itemCreatedTitle"/>
							<span class="referenceSettingBadge updatedBadge" data-issue-id="${item.id }"
								title="${itemCreatedTitle }">

								<spring:message code="tracker.branching.item.deleted.on.${mergeFromMaster ? (topLevelBranch ? 'master' : 'parent') : 'branc' }.label" text="Deleted on branch"/>
							</span>
						</span>
					</h1>

					<c:if test="${!disableEditing && (!checkEditAndDeletePermissions || canDeleteOnTarget) }">
						<div>
							<table class="diffTable" style="margin-left: 15px;">
								<tr>
									<td class="copy value">
										<input type="checkbox" name="deleteOnTarget" id="deleteOnMaster-${item.id }" value="${item.id }"/>
										<label for="deleteOnMaster-${item.id }" style="margin-left: 10px;">
											<c:choose>
												<c:when test="${mergeBetweenBranches }">
													<spring:message code="tracker.branching.delete.on.specified.branch.label" arguments="${targetBranch.name }" text="Delete on ${targetBranch.name }"></spring:message>
												</c:when>
												<c:otherwise>
													<spring:message code="tracker.branching.delete.on.${mergeFromMaster ? 'branch' : (topLevelBranch ? 'master' : 'parent') }.label" text="Delete on Master"/>
												</c:otherwise>
											</c:choose>
										</label>
									</td>
								</tr>
							</table>

						</div>
					</c:if>
				</div>
			</c:forEach>

			<%-- show the items that have only incoming reference changes --%>
			<c:forEach items="${onlyIncomingReferenceChange }" var="sourceItem">
				<div data-id="${sourceItem.id }" class="item-box">
					<h1><c:out value="${sourceItem.name}"/></h1>

					<c:if test="${referencesToBranchPerItem[sourceItem.id] != null and not empty referencesToBranchPerItem[sourceItem.id] }">
						<div class="contentWithMargins">

							<%-- show a diff table with only one row that contains the item links --%>
							<table class="diffTable">
								<tr class="header">
									<th colspan="2">
										<c:choose>
											<c:when test="${ not empty originalItemPerBranchItem[sourceItem] and originalItemPerBranchItem[sourceItem].branchItem }">

											</c:when>
											<c:otherwise>
												<spring:message code="tracker.branching.master.name" text="Master Branch"></spring:message>
											</c:otherwise>
										</c:choose>
									</th>
									<th class="controls"></th>
									<th colspan="2">
										<c:out value="${sourceItem.branch.name }"/>
									</th>
								</tr>
								<tr class="fixed-id different odd">
									<td class="copy label"><spring:message code="tracker.field.ID.label" text="ID"/></td>
									<td class="copy value">
										<c:if test="${not empty originalItemPerBranchItem[sourceItem] }">
											<span>
												<ui:coloredEntityIcon subject="${originalItemPerBranchItem[sourceItem]}" iconUrlVar="originalIconUrl" iconBgColorVar="originalIconBgColor"/>

												<img class="issueIcon" style="background-color: ${originalIconBgColor}" src="${pageContext.request.contextPath}/${originalIconUrl}" alt="icon">
												<a class="issueLink" href="${pageContext.request.contextPath}${originalItemPerBranchItem[sourceItem].urlLink}">${originalItemPerBranchItem[sourceItem].id}</a>
												<span class="referenceSettingBadge versionSettingBadge">v${originalItemPerBranchItem[sourceItem].version}</span>
											</span>
										</c:if>
									</td>
									<td class="controls"></td>
									<td class="original label"><spring:message code="tracker.field.ID.label" text="ID"/></td>
									<td class="original value">
										<span>
											<ui:coloredEntityIcon subject="${sourceItem}" iconUrlVar="originalIconUrl" iconBgColorVar="originalIconBgColor"/>

											<img class="issueIcon" style="background-color: ${originalIconBgColor}" src="${pageContext.request.contextPath}/${originalIconUrl}" alt="icon">
											<a class="issueLink" href="${pageContext.request.contextPath}${sourceItem.urlLink}">${sourceItem.id}</a>
											<span class="referenceSettingBadge versionSettingBadge">v${sourceItem.version}</span>
										</span>
									</td>
								</tr>
							</table>
							<ui:collapsingBorder id="downstream-${surceItem.id }"
								label="${updatedDownstreamLabel }" open="true" cssClass="scrollable">

								<%-- there new incoming references to the branch item so list them as well --%>
								<c:set var="updatedDownstreamSet" value="${ referencesToBranchPerItem[sourceItem.id]}" scope="request"/>
								<c:set var="referredItem" value="${sourceItem }" scope="request"/>

								<jsp:include page="updatedDownstreamReferences.jsp"></jsp:include>
							</ui:collapsingBorder>
						</div>
					</c:if>
				</div>
			</c:forEach>
		</c:otherwise>

	</c:choose>
</div>

<script src="<ui:urlversioned value='/js/diff.js' />"></script>
<script src="<ui:urlversioned value='/js/branchDiff.js' />"></script>

<style type="text/css">
	.referenceSettingBadge {
		cursor: auto;
		top: -4px;
	}

	.trackerBranchBadge {
		top: 2px;
    	position: relative;
	}

	  .newskin .diffTable.highlightDifferent tr.highlighted .original.value > span {
		background-color: transparent;
	  }

	  .newskin .diffTable.highlightDifferent tr.highlighted .updated.value > span {
		background-color: #ffead1;
	  }

	  .item-box.level-1 {
	  	padding-left: 25px;
	  }

	  .branch-badge-group {
			margin-top: 9px;
			display: block;
		}

	  .updated-downstream-references {
	  	list-style: none;
	  	padding-left: 10px;
	  }

	  .collapsingBorder_content {
	  	padding: 10px;
	  }
</style>

