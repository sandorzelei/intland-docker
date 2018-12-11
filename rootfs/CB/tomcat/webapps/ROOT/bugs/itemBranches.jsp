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
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>

<style type="text/css">
	.newskin .displaytag > tbody > tr > td.branch-name.branched-item {
		padding-left: 20px;
	}

	td.selected-branch {
		background-color: #ccffe8;
	}
</style>

<spring:message code="tracker.branching.master.name" var="masterLabel" text="Master Branch"/>

<c:set var="currentBranch" value="${task.branch }"></c:set>
<display:table name="${itemVariants}" id="variant" export="false" class="expandTable" cellpadding="0" >
	<spring:message code="issue.branch.title" var="branchNameTitle" text="Branch"/>
	<c:set var="extraClass" value="${variant.branch == currentBranch ? 'selected-branch' : ''}"/>


	<display:column title="${branchNameTitle }" headerClass="textData"
		class="branch-name textData columnSeparator ${extraClass } ${variant.branchItem ? 'branched-item' : '' }">
		<c:url var="branchUrl" value="${variant.branchItem ? variant.branch.urlLink : variant.tracker.urlLink }"/>
		<c:set var="branchName" value="${variant.branchItem ? variant.branch.name : masterLabel }"></c:set>
		<c:choose>
			<c:when test="${currentBranch == variant.branch }">
				<strong>
					<a href="${branchUrl }">
						<spring:message code="tracker.brancing.current.branch.label" arguments="${branchName }" text="Current branch: ${branchName }"/>
					</a>
				</strong>
			</c:when>
			<c:otherwise>
				<a href="${branchUrl }"><c:out value="${branchName }"></c:out></a>
			</c:otherwise>
		</c:choose>

	</display:column>

	<spring:message code="issue.label" text="Work Item" var="workItemTitle"/>
	<display:column title="${workItemTitle }" class="textData smallerText columnSeparator ${extraClass }" headerClass="textData">
		<c:choose>
			<c:when test="${not empty variant}">
				<ui:wikiLink item="${variant}" showSuspectedBadge="${false}" hideBranchBadge="true"/>
			</c:when>
			<c:otherwise>
				<spring:message code="tracker.branching.item.not.present.on.branch.title" text="This item is no longer present on this Branch"/>
			</c:otherwise>
		</c:choose>
	</display:column>

	<spring:message code="issue.branch.createdFrom.title" var="createdFrom" text="Created from"/>
	<display:column title="${createdFrom }"
				headerClass="textData"
				class="textData smallerText columnSeparator ${extraClass }" >
		<c:if test="${variant.branchItem}">
			<c:choose>
				<c:when test="${not empty variant.branchOriginalItem}">
					<ui:wikiLink item="${variant.branchOriginalItem}" showSuspectedBadge="${false}" alwaysShowVersionBadge="${true }"/>
				</c:when>
				<c:otherwise>
					<spring:message code="tracker.branching.item.not.present.title" text="This item is no longer present"/>
				</c:otherwise>
			</c:choose>
		</c:if>
	</display:column>


	<spring:message code="issue.branch.description.title" var="branchDescription" text="Branch Description"/>
	<display:column title="${branchDescription }" escapeXml="true"
				headerClass="textData expand"
				class="textDataWrap smallerText columnSeparator ${extraClass }" >
		<c:if test="${variant.branchItem}">
			<c:out value="${variant.branch.branchDescription }"></c:out>
		</c:if>
	</display:column>

	<spring:message code="baseline.createdAt.label" var="createdAtLabel" text="Created at"/>
	<display:column title="${createdAtLabel }" headerClass="textData expand"
				class="textDataWrap smallerText columnSeparator ${extraClass }" >
		<c:if test="${variant.branchItem}">
			<tag:formatDate value="${variant.branch.createdAt}" />
		</c:if>
	</display:column>

	<spring:message code="baseline.createdBy.label" var="createdByLabel" text="Created by"/>
	<display:column title="${createdByLabel }" headerClass="textData expand"
				class="textDataWrap smallerText columnSeparator ${extraClass }" >
		<c:if test="${variant.branchItem}">
			<tag:userLink user_id="${variant.branch.owner }"/>
		</c:if>
	</display:column>
</display:table>