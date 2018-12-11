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
 * $Revision$ $Date$
--%>

<%@ page import="com.intland.codebeamer.manager.ReferenceSettingManager" %>
<%@ page import="com.intland.codebeamer.controller.support.relations.RelationItem" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<spring:message code="tracker.field.associationObjects.label" var="associationObjectsTitle"/>

<c:choose>
	<c:when test="${(not empty outgoingReferences) || (not empty incomingReferences)}">

		<%-- incoming references --%>
		<c:if test="${not empty incomingReferences}">
			<table class="references" title="<spring:message code='tracker.view.layout.document.incoming.references.tooltip'/>">
				<tbody>
					<c:if test="${not empty  incomingReferences}">
						<tr>
							<td colspan="3">
								<span class="strongText"><spring:message code='tracker.view.layout.document.incoming.references.tooltip'/></span><ui:referenceLimitWarning actualReferenceCount="${referenceData.incomingReferenceCount}" isNumberOfItemsExceedLimit="${referenceData.incomingReferencesExceedLimit}"></ui:referenceLimitWarning>
							</td>
						</tr>
					</c:if>
					<c:forEach var="relationCategory" items="${incomingReferences}">
						<tr>
							<td colspan="2" class="trackerCategoryLabel">
								<span class="subtext strongText">${relationCategory.categoryName}</span>
							</td>
						</tr>
						<c:forEach var="incomingReference" items="${relationCategory.relations}">
							<tr class="relation-item">
								<td>

									<c:choose>
										<c:when test="${isReview}">
											<ui:wikiLink item="${incomingReference.origin}" alwaysShowVersionBadge="${true}" showSuspectedBadge="${false}"/>
										</c:when>
										<c:otherwise>
											<ui:wikiLink item="${incomingReference.origin}" referenceWrapper="${incomingReference.incomingWrapper}" showSuspectedBadge="${true}" />
										</c:otherwise>
									</c:choose>

									<spring:message code="review.updated.title"
												text="This item has been updated since the current review started. To see the differences click this badge."
												var="itemUpdatedTitle"/>

									<c:if test="${not empty newVersions && newVersions[incomingReference.target.id] != null }">
										<c:set var="newVersion" value="${newVersions[incomingReference.target.id] }"/>
										<span class="referenceSettingBadge updatedBadge" data-baseline-id="${baselineId }"
											data-issue-id="${incomingReference.target.id }" title="${itemUpdatedTitle }">
											<spring:message code="review.updated.badge.label" text="New Version Available"/>
										</span>
									</c:if>

									<c:if test="${not empty deletedNewVersions  && deletedNewVersions[incomingReference.target.id] != null}">
										<span class="referenceSettingBadge deletedBadge" title="${itemDeletedTitle }">
											<spring:message code="review.deleted.badge.label" text="Original Item was Deleted"/>
										</span>
									</c:if>

									<c:if test="${not empty newVersionsBeforeRestart && newVersionsBeforeRestart[incomingReference.target.id] != null }">
										<c:set var="newVersion" value="${newVersionsBeforeRestart[incomingReference.target.id] }"/>

										<span class="referenceSettingBadge updatedBadge" data-baseline-id="${previousBaselineId }"
											data-new-version="${incomingReference.target.version }"
											data-issue-id="${incomingReference.target.id }" title="${itemUpdatedTitle }">
											<spring:message code="review.updated.since.last.review.badge.label" text="Was updated in Last Review"/>
										</span>
									</c:if>
								</td>
							</tr>
						</c:forEach>
					</c:forEach>
				</tbody>
			</table>
		</c:if>

		<%-- outgoing references --%>
		<c:if test="${not empty outgoingReferences}">
			<table class="references" title="<spring:message code='tracker.view.layout.document.outgoing.references.tooltip'/>" >
				<tbody>
					<c:if test="${not empty  outgoingReferences}">
						<tr>
							<td colspan="2">
								<span class="strongText"><spring:message code='tracker.view.layout.document.outgoing.references.tooltip'/></span><ui:referenceLimitWarning actualReferenceCount="${referenceData.outgoingReferenceCount}" isNumberOfItemsExceedLimit="${referenceData.outgoingReferencesExceedLimit}"></ui:referenceLimitWarning>
							</td>
						</tr>
					</c:if>
					<c:forEach var="relationCategory" items="${outgoingReferences}">
						<tr>
							<td colspan="3" class="trackerCategoryLabel">
								<span class="subtext strongText">${relationCategory.categoryName}</span>
							</td>
						</tr>
						<c:forEach var="outgoingReference" items="${relationCategory.relations}">
							<tr class="relation-item">

								<td>
									<c:choose>
										<c:when test="${isReview}">
											<ui:wikiLink item="${outgoingReference.wrapper}" alwaysShowVersionBadge="${true}" showSuspectedBadge="${false}" hideBranchBadge="true"/>
										</c:when>
										<c:when test="${!ui:isTrackerItem(outgoingReference.item)}">
											<c:if test="${not empty outgoingReference.item }">
												<%-- prevent a null pointer exception --%>
												<ui:wikiLink item="${outgoingReference.item}" hideBadges="${true}"/>
											</c:if>
										</c:when>
										<c:otherwise>
											<ui:wikiLink item="${outgoingReference.item}" referenceWrapper="${outgoingReference.wrapper}" showSuspectedBadge="${true}" hideBranchBadge="true" />
										</c:otherwise>
									</c:choose>

									<spring:message code="review.updated.title"
												text="This item has been updated since the current review started. To see the differences click this badge."
												var="itemUpdatedTitle"/>
									<c:if test="${not empty newVersions && newVersions[outgoingReference.target.id] != null }">
										<c:set var="newVersion" value="${newVersions[outgoingReference.target.id] }"/>
										<span class="referenceSettingBadge updatedBadge" data-baseline-id="${baselineId }"
											data-issue-id="${outgoingReference.target.id }" title="${itemUpdatedTitle }">
											<spring:message code="review.updated.badge.label" text="New Version Available"/>
										</span>
									</c:if>

									<c:if test="${not empty deletedNewVersions  && deletedNewVersions[outgoingReference.target.id] != null}">
										<span class="referenceSettingBadge deletedBadge" title="${itemDeletedTitle }">
											<spring:message code="review.deleted.badge.label" text="Original Item was Deleted"/>
										</span>
									</c:if>

									<c:if test="${not empty newVersionsBeforeRestart && newVersionsBeforeRestart[outgoingReference.target.id] != null }">
										<c:set var="newVersion" value="${newVersionsBeforeRestart[outgoingReference.target.id] }"/>
										<span class="referenceSettingBadge updatedBadge" data-baseline-id="${previousBaselineId }"
											data-new-version="${outgoingReference.target.version }"
											data-issue-id="${outgoingReference.target.id }" title="${itemUpdatedTitle }">
											<spring:message code="review.updated.since.last.review.badge.label" text="Was updated in Last Review"/>
										</span>
									</c:if>
								</td>
							</tr>
						</c:forEach>
					</c:forEach>
				</tbody>
			</table>
		</c:if>

	</c:when>
	<c:otherwise>
		<div class="subtext"><spring:message code="planner.no.references.found.message" text="No References"/></div>
	</c:otherwise>
</c:choose>