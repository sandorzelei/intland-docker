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
 renders a the branch badges (updated on master, created on branch etc.) for a tracker item
 --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ attribute name="item" required="true" type="com.intland.codebeamer.persistence.dto.TrackerItemDto" rtexprvalue="true" description="the tracker item"%>
<%@ attribute name="branch" required="true" type="com.intland.codebeamer.persistence.dto.BranchDto" rtexprvalue="true"
	description="The branch used for badge computation" %>
<%@ attribute name="itemDivergedOnMaster" required="true" type="java.lang.Boolean" rtexprvalue="true"
	description="if the branch item diverged on the upstream branch"  %>
<%@ attribute name="itemDivergedOnBranch" required="true" type="java.lang.Boolean" rtexprvalue="true"
	description="if the branch item diverged on the branch"  %>
<%@ attribute name="itemCreatedOnBranch" required="true" type="java.lang.Boolean" rtexprvalue="true"
	description="if the branch item was created"  %>
<%@ attribute name="targetBranchLabel" required="false" type="java.lang.String" rtexprvalue="true"
	description="The label to use instead of 'master' in 'UPDATED ON MASTER'"%>

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

<c:if test="${itemDivergedOnMaster }">
	<spring:message code="tracker.branching.item.diverged.from.master.title"
		text="This item has diverged from the Master branch. To see the differences click this badge."
		var="itemUpdatedTitle"/>
	<span class="referenceSettingBadge updatedBadge masterDivergedBadge branchDivergedBadge" data-issue-id="${item.id }"
		data-original-id="${item.branchOriginalItem == null ? '' : item.branchOriginalItem.id }"
		title="${itemUpdatedTitle }">
		<c:choose>
			<c:when test="${not empty targetBranchName }">
				<spring:message code="tracker.branching.item.updated.on.branch.with.name.label" arguments="${targetBranchName}"/>
			</c:when>
			<c:otherwise>
				<c:set var="updatedLabelCode" value="${branch != null and branch.parentBranch != null ? 'tracker.branching.parent.diverged.from.branch.label' : 'tracker.branching.master.diverged.from.branch.label'}"></c:set>
				<spring:message code="${updatedLabelCode}"></spring:message>
			</c:otherwise>
		</c:choose>
	</span>
</c:if>

<c:if test="${itemDivergedOnBranch }">
	<spring:message code="tracker.branching.item.diverged.from.master.title"
		text="This item has diverged from the Master branch. To see the differences click this badge."
		var="itemUpdatedTitle"/>
	<span class="referenceSettingBadge updatedBadge branchDivergedBadge" data-issue-id="${item.id }"
		data-original-id="${item.branchOriginalItem == null ? '' : item.branchOriginalItem.id }"
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

 <c:if test="${itemCreatedOnBranch }">
	<spring:message code="tracker.branching.item.crested.on.branch.title"
		text="This item was created on this branch"
		var="itemCreatedTitle"/>
	<span class="referenceSettingBadge updatedBadge createdBadge" data-issue-id="${item.id }"
		data-original-id="${item.branchOriginalItem == null ? '' : item.branchOriginalItem.id }"
		title="${itemCreatedTitle }">

		<c:choose>
			<c:when test="${not empty sourceBranchName }">
				<spring:message code="tracker.branching.item.created.on.branch.with.name.label" arguments="${sourceBranchName}"/>
			</c:when>
			<c:otherwise>
				<spring:message code="tracker.branching.item.crested.on.branch.label" text="Created on branch"/>
			</c:otherwise>
		</c:choose>
	</span>
 </c:if>