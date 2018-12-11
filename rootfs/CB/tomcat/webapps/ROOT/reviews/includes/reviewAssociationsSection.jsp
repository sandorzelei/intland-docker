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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:if test="${not empty  outgoingAssociations}">
	<table class="references" title="<spring:message code='tracker.view.layout.document.outgoing.associations.tooltip'/>" >
		<tbody>
			<tr>
				<td>
					<span class="strongText"><spring:message code='tracker.view.layout.document.outgoing.associations.tooltip'/></span>
				</td>
			</tr>
			<c:forEach var="outgoingAssociation" items="${outgoingAssociations}">
				<c:choose>
					<c:when test="${outgoingAssociation.item != null}">
						<tr class="relation-item">
							<td class="outgoingReferenceIndicator">
								<ui:wikiLink item="${outgoingAssociation.associationObject.to}" alwaysShowVersionBadge="${true}" showSuspectedBadge="${false}" hideBranchBadge="true" association="${outgoingAssociation.associationObject}" associationIsIncoming="false"/>

								<spring:message code="review.updated.title"
											text="This item has been updated since the current review started. To see the differences click this badge."
											var="itemUpdatedTitle"/>

								<c:if test="${not empty newVersions && newVersions[outgoingAssociation.associationObject.to.dto.id] != null }">
									<c:set var="newVersion" value="${newVersions[outgoingAssociation.associationObject.to.dto.id] }"/>
									<span class="referenceSettingBadge updatedBadge" data-baseline-id="${baselineId }"
										data-issue-id="${outgoingAssociation.associationObject.to.dto.id }" title="${itemUpdatedTitle }">
										<spring:message code="review.updated.badge.label" text="New Version Available"/>
									</span>
								</c:if>

								<c:if test="${not empty deletedNewVersions  && deletedNewVersions[outgoingAssociation.associationObject.to.dto.id] != null}">
									<span class="referenceSettingBadge deletedBadge" title="${itemDeletedTitle }">
										<spring:message code="review.deleted.badge.label" text="Original Item was Deleted"/>
									</span>
								</c:if>

								<c:if test="${not empty newVersionsBeforeRestart && newVersionsBeforeRestart[outgoingAssociation.associationObject.to.dto.id] != null }">
									<c:set var="newVersion" value="${newVersionsBeforeRestart[outgoingAssociation.associationObject.to.dto.id] }"/>

									<span class="referenceSettingBadge updatedBadge" data-baseline-id="${previousBaselineId }"
										data-new-version="${outgoingAssociation.associationObject.to.version }"
										data-issue-id="${outgoingAssociation.associationObject.to.dto.id }" title="${itemUpdatedTitle }">
										<spring:message code="review.updated.since.last.review.badge.label" text="Was updated in Last Review"/>
									</span>
								</c:if>

							</td>
						</tr>
					</c:when>
					<c:otherwise>
						<tr class="relation-item">
							<td>
								<a href="<c:url value="${outgoingAssociation.url}"/>"><c:out value='${outgoingAssociation.url}'/></a>
							</td>
						</tr>
					</c:otherwise>
				</c:choose>
			</c:forEach>
		</tbody>
	</table>
</c:if>

<c:if test="${not empty  incomingAssociations}">
	<table class="references" title="<spring:message code='tracker.view.layout.document.incoming.associations.tooltip'/>" >
		<tbody>
			<tr>
				<td>
					<span class="strongText"><spring:message code='tracker.view.layout.document.incoming.associations.tooltip'/></span>
			</td>
			</tr>
			<c:forEach var="incomingAssociation" items="${incomingAssociations}">
				<c:choose>
					<c:when test="${incomingAssociation.item != null}">
						<tr class="relation-item">
							<td>
								<ui:wikiLink item="${incomingAssociation.associationObject.from}" alwaysShowVersionBadge="${true}" showSuspectedBadge="${false}" hideBranchBadge="true" association="${incomingAssociation.associationObject}" associationIsIncoming="true" />

								<spring:message code="review.updated.title"
									text="This item has been updated since the current review started. To see the differences click this badge."
									var="itemUpdatedTitle"/>

								<c:if test="${not empty newVersions && newVersions[incomingAssociation.associationObject.from.dto.id] != null }">
									<c:set var="newVersion" value="${newVersions[incomingAssociation.associationObject.from.dto.id] }"/>
									<span class="referenceSettingBadge updatedBadge" data-baseline-id="${baselineId }"
										data-issue-id="${incomingAssociation.associationObject.from.dto.id }" title="${itemUpdatedTitle }">
										<spring:message code="review.updated.badge.label" text="New Version Available"/>
									</span>
								</c:if>

								<c:if test="${not empty deletedNewVersions  && deletedNewVersions[incomingAssociation.associationObject.from.dto.id] != null}">
									<span class="referenceSettingBadge deletedBadge" title="${itemDeletedTitle }">
										<spring:message code="review.deleted.badge.label" text="Original Item was Deleted"/>
									</span>
								</c:if>

								<c:if test="${not empty newVersionsBeforeRestart && newVersionsBeforeRestart[incomingAssociation.associationObject.from.dto.id] != null }">
									<c:set var="newVersion" value="${newVersionsBeforeRestart[incomingAssociation.associationObject.from.dto.id] }"/>

									<span class="referenceSettingBadge updatedBadge" data-baseline-id="${previousBaselineId }"
										data-new-version="${incomingAssociation.associationObject.from.version }"
										data-issue-id="${incomingAssociation.associationObject.from.dto.id }" title="${itemUpdatedTitle }">
										<spring:message code="review.updated.since.last.review.badge.label" text="Was updated in Last Review"/>
									</span>
								</c:if>

							</td>
						</tr>
					</c:when>

				</c:choose>
			</c:forEach>

		</tbody>
	</table>

</c:if>