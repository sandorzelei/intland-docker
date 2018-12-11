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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin reviewModule"/>
<meta name="module" content="review"/>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect-filter.less" />" type="text/css" media="all" />
<script src="<ui:urlversioned value='/js/multiselect-filter.js'/>"></script>
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/review/review.less' />" type="text/css" media="all" />

<style type="text/css">
	.miniprogressbar {
		width: 100%;
	}

	form label {
		font-weight: bold;
		padding-right: 10px;
	}

	.newskin .ui-multiselect-header.ui-widget-header {
		display: block;
	}

	.ui-multiselect-header .ui-helper-reset {
		display: none;
	}

	.ui-multiselect-filter {
		width: 80%;
	}

	.ui-multiselect-filter input {
		width: 100%;
	}

	.newskin .ui-multiselect-menu {
		display: none;
	}

	.issueIcon {
		vertical-align: middle;
	}

	.action .smallWarning.permission {
		display: none;
	}

	.action.disabled .smallWarning.permission {
		display: block;
	}

	.action .smallWarning {
		margin-bottom: 10px;
	}

	.group-title {
		margin-top: 15px;
		margin-bottom: 0px;
	}

	table.item-progress {
		margin-top: -8px;
	}

	option[value=DoNotChange] {
		color: red;
	}

	.wikiLinkContainer .jumpToDocumentViewBadge a {
		top: 0;
	}
</style>


<ui:actionMenuBar>
	<spring:message code="review.statusMapping.title" text="Status Mapping"/>
</ui:actionMenuBar>
<div class="contentWithMargins">
	<table class="propertyTable statsTable">
		<tr>
			<td class="optional">
				<spring:message code="review.approved.label" text="Approved"/>:
			</td>
			<td>
				<span class="stat accepted">${cummulatedStats.accepted }</span>
			</td>
		</tr>
		<tr>
			<td class="optional">
				<spring:message code="review.needMoreWork.label" text="Needs More Work"/>:
			</td>
			<td>
				<span class="stat rejected">${cummulatedStats.rejected }</span>
			</td>
		</tr>
		<tr>
			<td class="optional">
				<spring:message code="review.noteDecided.label" text="Not Decided"/>:
			</td>
			<td>
				<span class="stat">${cummulatedStats.total - cummulatedStats.accepted - cummulatedStats.rejected }</span>
			</td>
		</tr>
	</table>
	<form:form id="completeReviewForm">
		<form:hidden path="comment"/>
		<p class="hint">
			<spring:message code="review.done.status.mappings.hint"
				text="The statuses you select below will be set on the Accepted and Rejected items respectively."/>
		</p>
		<form:hidden path="baselineSignature"/>
		<table class="propertyTable">
			<tr>
				<td class="optional">
					<label for="approvedStatusIds">
						<spring:message code="review.done.approved.votes.label" text="Status to set for Approved items"/>:
					</label>
				</td>
				<td>
					<form:select path="approvedStatusIds" multiple="true" id="approvedStatusIds">
						<c:forEach items="${targetItemStatuses }" var="entry">

							<optgroup label='<c:out value="${entry.key.name }"/>' data-tracker-id="${entry.key.id }">
								<c:forEach items="${entry.value }" var="status">
									<c:set var="statusName"><c:out value="${status.name }"/></c:set>
									<form:option value="${entry.key.id }-${status.id }" title="${statusName }" data-tracker-id="${entry.key.id }">${statusName }</form:option>
								</c:forEach>
							</optgroup>
						</c:forEach>
					</form:select>
				</td>
			</tr>
			<tr>
				<td class="optional">
					<label for="rejectedStatusIds">
						<spring:message code="review.done.rejected.votes.label" text="Status to set for Rejected items"/>:
					</label>
				</td>
				<td>
					<form:select path="rejectedStatusIds" multiple="true" id="rejectedStatusIds">
						<c:forEach items="${targetItemStatuses }" var="entry">

							<optgroup label='<c:out value="${entry.key.name }"/>' data-tracker-id="${entry.key.id }">
								<c:forEach items="${entry.value }" var="status">
									<c:set var="statusName"><c:out value="${status.name }"/></c:set>
									<form:option value="${entry.key.id }-${status.id }" title="${statusName }" data-tracker-id="${entry.key.id }">${statusName }</form:option>
								</c:forEach>
							</optgroup>
						</c:forEach>
					</form:select>
				</td>
			</tr>

			<tr>
				<td class="optional">
				</td>
				<td>
					<label>
						<form:checkbox path="executeOnlyValidTransitions" id="executeOnlyValidTransitions"/>
						<spring:message code="review.complete.executeOnlyValidTransitions.label" text="Execute only valid transitions"/>
					</label>
				</td>
			</tr>
		</table>

		<p class="hint" style="margin-bottom: 0px; margin-top: 25px;">
			<spring:message code="review.done.status.mappings.override.hint" text="You can override the default action for each item in the list below."/>
		</p>
		<c:set var="showActions" value="true" scope="request"/>

		<div class="information">
			<spring:message code="review.completed.item.mapping.transition.warning"
				text="If there is a transition from the current status of an item to the selected status then the transition will be executed."/>
		</div>

		<div class="warning" id="invalid-mappings-warning" style="display: none;">
			<spring:message code="review.completed.item.mapping.invalid.status"/>
		</div>

		<c:forEach items="${statGroupsPerItem}" var="statsGroup">
			<c:if test="${not empty statsGroup.stats}">
				<h2 class="group-title">
					<spring:message code="${statsGroup.label }" text="${statsGroup.label }"/>
				</h2>

				<c:set var="statsPerItem" scope="request" value="${statsGroup.stats }"></c:set>
				<jsp:include page="includes/itemProgress.jsp"/>
			</c:if>
		</c:forEach>

		<p style="margin-top: 10px;">
			<spring:message code="review.complete.approve.label" text="Approve" var="approveLabel"></spring:message>
			<button name="status" class="button" value="FINISH" disabled="disabled">${approveLabel }</button>
			<c:url value="/proj/review/completeReview.spr?reviewId=${command.reviewId }" var="backUrl"/>
			<a href="${backUrl }" style="margin-left: 10px;"><spring:message code="button.back" text="Back"/></a>
		</p>
	</form:form>
</div>

<script src="<ui:urlversioned value='/reviews/statusMappings.js'/>"></script>

