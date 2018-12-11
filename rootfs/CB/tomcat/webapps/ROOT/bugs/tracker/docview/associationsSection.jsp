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
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<spring:message code="tracker.field.associationObjects.label" var="associationObjectsTitle"/>

<c:if test="${empty revision && canCreateAssociation }">
	<div class="addAssociationControl">
		<ui:osSpecificHotkeyTooltip code="association.add.tooltip.label" var="addAssociationTooltip" modifierKey="ALT" />
		<a class="actionLink" href="#" title="${addAssociationTooltip}" onclick="trackerObject.addAssociation(${item.id}); return false;"><spring:message code="association.add.label" text="Add Association"/></a>
	</div>
</c:if>

<c:choose>
	<c:when test="${(not empty incomingAssociations)  || (not empty outgoingAssociations) || (not empty urlReferencesByIssue)}">

		<table class="references" title="<spring:message code='tracker.view.layout.document.associations.tooltip'/>" >
			<tbody>

				<c:forEach var="outgoingReference" items="${outgoingAssociations}">
					<c:choose>
						<c:when test="${outgoingReference.item != null}">
							<tr class="relation-item">
								<td class="outgoingReferenceIndicator">
									<span class="subtext"><spring:message code="association.typeId.outgoing.${outgoingReference.associationObject.type.name}" text="${outgoingReference.associationObject.type.name}"/></span>
								</td>
								<td>
									<ui:wikiLink item="${outgoingReference.associationObject.to}" showSuspectedBadge="${true}" showDependenciesBadge="${true}" association="${outgoingReference.associationObject}" associationIsIncoming="false"/>
								</td>
							</tr>
						</c:when>
						<c:otherwise>
							<tr class="relation-item">
								<td>
									<span class="subtext"><spring:message code="association.typeId.outgoing.${outgoingReference.associationObject.type.name}" text="${outgoingReference.associationObject.type.name}"/></span>
								</td>
								<td>
									<a href="<c:url value="${outgoingReference.url}"/>"><c:out value='${outgoingReference.url}'/></a>
								</td>
								<td>
								</td>
							</tr>
						</c:otherwise>
					</c:choose>
				</c:forEach>
			</tbody>
		</table>

		<table class="references" title="<spring:message code='tracker.view.layout.document.associations.tooltip'/>" >
			<tbody>
				<c:forEach var="incomingReference" items="${incomingAssociations}">
					<c:choose>
						<c:when test="${incomingReference.item != null}">
							<c:set var="isSuspectedBadgeActive" value="${incomingReference.associationObject.suspected}"></c:set>
							<c:set var="isSuspectedBadgeDeactive" value="${!incomingReference.associationObject.suspected and incomingReference.associationObject.propagatingSuspects}"></c:set>

							<tr class="relation-item">
								<td>
									<ui:wikiLink item="${incomingReference.associationObject.from}" showSuspectedBadge="${true}" showDependenciesBadge="${true}" association="${incomingReference.associationObject}" associationIsIncoming="true" />
								</td>
								<td class="incomingReferenceIndicator">
									<span class="subtext"><spring:message code="association.typeId.incoming.${incomingReference.associationObject.type.name}" text="${incomingReference.associationObject.type.name}"/></span>
								</td>

							</tr>
						</c:when>
						<c:otherwise>
							<tr class="relation-item">
								<td class="reficon">
									<ui:coloredEntityIcon subject="${incomingReference.item}" iconBgColorVar="referencedBgColor" iconUrlVar="referencedIconUrl"/>
									<ui:tooltipWrapper dto="${incomingReference.item}">
										<img class="trackerImage" data-id="${incomingReference.item.id}"
											style="background-color:${referencedBgColor}" src="<c:url value="${referencedIconUrl}"/>"/>
									</ui:tooltipWrapper>
								</td>
								<td>
									<c:set var="referenceData" value="${incomingReference.wrapper.referenceDataDto }"/>
									<c:set var="useVersionedUrl" value="${isReview || (referenceData != null && referenceData.revision != null) }"/>
									<ui:itemLink item="${incomingReference.item}" showVersionBadge="${useVersionedUrl }" baselineId="${revision }"/>
								</td>
								<td>
									<span class="subtext"><spring:message code="relations.referenced"/></span>
								</td>
								<td>
								</td>
							</tr>
						</c:otherwise>
					</c:choose>
				</c:forEach>

			</tbody>
		</table>

	</c:when>
	<c:otherwise>
		<div class="subtext"><spring:message code="planner.no.associationObjects.found.message" text="No Associatons"/></div>
	</c:otherwise>
</c:choose>